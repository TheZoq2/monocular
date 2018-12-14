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
    afio.mapr.disable_jtag();

    let mut gpioa = dp.GPIOA.split(&mut rcc.apb2);
    let mut gpiob = dp.GPIOB.split(&mut rcc.apb2);

    let mut pin_1 = gpioa.pa8.into_push_pull_output(&mut gpioa.crh);
    let mut pin_2 = gpioa.pa9.into_push_pull_output(&mut gpioa.crh);
    let mut pin_3 = gpioa.pa10.into_push_pull_output(&mut gpioa.crh);
    let mut pin_4 = gpioa.pa11.into_push_pull_output(&mut gpioa.crh);
    let mut pin_5 = gpioa.pa12.into_push_pull_output(&mut gpioa.crh);
    let mut pin_6 = gpioa.pa15.into_push_pull_output(&mut gpioa.crh);
    let mut pin_7 = gpiob.pb3.into_push_pull_output(&mut gpiob.crl);
    let mut pin_8 = gpiob.pb4.into_push_pull_output(&mut gpiob.crl);



    pin_1.set_high();
    pin_2.set_low();
    pin_3.set_low();
    pin_4.set_high();
    pin_5.set_high();
    pin_6.set_low();
    pin_7.set_high();
    pin_8.set_high();
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
