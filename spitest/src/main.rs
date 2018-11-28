//! Blinks an LED

#![deny(unsafe_code)]
#![no_std]
#![no_main]

extern crate cortex_m;
extern crate cortex_m_rt as rt;
extern crate panic_semihosting;
extern crate stm32f103xx_hal as hal;

use hal::prelude::*;
use hal::stm32f103xx;
use hal::time::Hertz;
use hal::spi::{self, Spi, Polarity, Phase};
use rt::{entry, exception, ExceptionFrame};

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
        Hertz(100_000),
        clocks,
        &mut rcc.apb2
    );

    let mut chip_sel = gpioa.pa4.into_push_pull_output(&mut gpioa.crl);
    chip_sel.set_high();
    chip_sel.set_low();

    // onboard led (1 = on)
    //
    spi.write(&[0b1111_0000]);

    chip_sel.set_high();
    loop {
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
