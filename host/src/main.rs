mod decoder;

use std::io::{
    self,
    prelude::*
};
use spidev::{
    Spidev,
    SpidevOptions,
    SpidevTransfer,
    SPI_MODE_0
};

use time::PreciseTime;


const SPI_FREQUENCY: u32 = 1 * 2_000_000;


fn create_spi() -> io::Result<Spidev> {
    let mut spi = Spidev::open("/dev/spidev0.0")?;
    let options = SpidevOptions::new()
        .bits_per_word(8)
        .max_speed_hz(SPI_FREQUENCY)
        .mode(SPI_MODE_0)
        .build();

    spi.configure(&options)?;
    Ok(spi)
}

const BYTE_AMOUNT: usize = 100;

fn transfer_data(spi: &mut Spidev, data: [u8; BYTE_AMOUNT]) -> io::Result<[u8; BYTE_AMOUNT]> {
    let mut rxbuf = [0; BYTE_AMOUNT];
    let mut transfer = SpidevTransfer::read_write(&data, &mut rxbuf);
    spi.transfer(&mut transfer)?;
    Ok(rxbuf)
}


fn main() {
    let mut spi = create_spi().unwrap();


    let start = PreciseTime::now();
    let read_amount = 10_000;
    let count = 0;
    for _ in 0.. read_amount {
        let response = transfer_data(&mut spi, [0; 100]).unwrap();

        // for byte in response.iter() {
        //     // println!("{:8b}", byte);
        //     if *byte != 0b1000_0001 {
        //         panic!("Got invalid byte {:8b} after {}", byte, count);
        //     }
        // }
    }

    let duration = start.to(PreciseTime::now());
    let duration_seconds =
        duration.num_milliseconds() as f32 / 1000.;
    let byte_amount = read_amount * BYTE_AMOUNT;
    println!(
        "Reading {} bytes took {} seconds",
        byte_amount,
        duration_seconds
    );
    println!("This equates to a bitrate of {} ", (byte_amount as f32 * 8.) / duration_seconds);
}
