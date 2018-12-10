//! Blinks an LED

#![deny(unsafe_code)]
#![no_std]
#![no_main]

extern crate cortex_m;
extern crate cortex_m_rt as rt;
extern crate panic_semihosting;
extern crate stm32f103xx_hal as hal;
#[macro_use(block)]
extern crate nb;

use hal::prelude::*;
use hal::stm32f103xx;
use hal::time::Hertz;
use hal::spi::{self, Spi, Polarity, Phase};
use rt::{entry, exception, ExceptionFrame};
use cortex_m::asm;

#[entry]
fn main() -> ! {
    let cp = cortex_m::Peripherals::take().unwrap();
    let dp = stm32f103xx::Peripherals::take().unwrap();

    let mut flash = dp.FLASH.constrain();
    let mut rcc = dp.RCC.constrain();

    // Try a different clock configuration
    let clocks = rcc.cfgr.freeze(&mut flash.acr);
    // let clocks = rcc.cfgr
    //     .sysclk(64.mhz())
    //     .pclk1(32.mhz())
    //     .freeze(&mut flash.acr);

    let mut afio = dp.AFIO.constrain(&mut rcc.apb2);
    let mut gpioa = dp.GPIOA.split(&mut rcc.apb2);

    let sck = gpioa.pa5.into_alternate_push_pull(&mut gpioa.crl);
    let miso = gpioa.pa6.into_floating_input(&mut gpioa.crl);
    let mosi = gpioa.pa7.into_alternate_push_pull(&mut gpioa.crl);

    let mut spi = Spi::spi1(
        dp.SPI1,
        (sck, miso, mosi),
        &mut afio.mapr,
        spi::Mode{polarity: Polarity::IdleLow, phase: Phase::CaptureOnFirstTransition},
        Hertz(4_000_000),
        clocks,
        &mut rcc.apb2
    );

    let mut chip_sel = gpioa.pa4.into_push_pull_output(&mut gpioa.crl);
    chip_sel.set_high();
    chip_sel.set_low();

    let mut rst = gpioa.pa1.into_floating_input(&mut gpioa.crl);

    while rst.is_low() {}
    while rst.is_high() {}

    // onboard led (1 = on)
    //
    // spi.write(&[0b1010_0010]);

    let mut counter = 0;
    loop {
        spi.send(0b10000001);
        let byte = block!(spi.read()).unwrap();

        if byte != 0b10000001 {
            panic!("Got invalid byte {:b} after {} bytes", byte, counter)
            // asm::bkpt();
        }
        counter += 1;
        // asm::bkpt();
    }
}

#[exception]
fn HardFault(ef: &ExceptionFrame) -> ! {
    panic!("{:#?}", ef);
}

#[exception]
fn DefaultHandler(irqn: i16) {
    panic!("Unhandled exception (IRQn = {})", irqn);
}
