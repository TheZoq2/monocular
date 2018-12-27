use std::io::{
    self,
};
use std::sync::mpsc::{Sender};

use spidev::{
    Spidev,
    SpidevOptions,
    SpidevTransfer,
    SPI_MODE_0
};


pub fn create_spi(frequency_hz: u32) -> io::Result<Spidev> {
    let mut spi = Spidev::open("/dev/spidev0.0")?;
    let options = SpidevOptions::new()
        .bits_per_word(8)
        .max_speed_hz(frequency_hz)
        .mode(SPI_MODE_0)
        .build();

    spi.configure(&options)?;
    Ok(spi)
}

const BYTE_AMOUNT: usize = 5;

pub fn transfer_data(spi: &mut Spidev, data: [u8; BYTE_AMOUNT]) -> io::Result<[u8; BYTE_AMOUNT]> {
    let mut rxbuf = [0; BYTE_AMOUNT];
    let mut transfer = SpidevTransfer::read_write(&data, &mut rxbuf);
    spi.transfer(&mut transfer)?;
    Ok(rxbuf)
}

pub fn reader(mut spi: Spidev, tx: Sender<[u8;5]>) {
    loop {
        tx.send(transfer_data(&mut spi, [0; 5]).expect("Failed to read bytes from SPI"))
            .expect("Failed to send bytes");
    }
}
