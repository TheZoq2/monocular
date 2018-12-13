mod decoder;
mod websockets;
mod types;

use std::io::{
    self,
};
use std::sync::mpsc;
use std::thread;

use spidev::{
    Spidev,
    SpidevOptions,
    SpidevTransfer,
    SPI_MODE_0
};

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

    let (web_tx, web_rx) = mpsc::channel();

    thread::spawn(move || websockets::server("0.0.0.0:7878", web_rx));
}

