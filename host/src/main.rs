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


use std::thread::sleep;
use std::time::Duration;


const SPI_FREQUENCY: u32 = 1 * 100_000;


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

const BYTE_AMOUNT: usize = 1;

/// Perform full duplex operations using Ioctl
fn read_data(spi: &mut Spidev) -> io::Result<[u8; BYTE_AMOUNT]> {
    // "write" transfers are also reads at the same time with
    // the read having the same length as the write
    let mut rx_buf = [0; BYTE_AMOUNT];

    spi.read(&mut rx_buf)?;

    Ok(rx_buf)
}

fn transfer_data(spi: &mut Spidev, data: [u8; BYTE_AMOUNT]) -> io::Result<[u8; BYTE_AMOUNT]> {
    let mut rxbuf = [0; BYTE_AMOUNT];
    let mut transfer = SpidevTransfer::read_write(&data, &mut rxbuf);
    spi.transfer(&mut transfer)?;
    Ok(rxbuf)
}


fn main() {
    let mut spi = create_spi().unwrap();

    'outer: loop {
        let response = transfer_data(&mut spi, [0b1010_0000]).unwrap();

        for byte in &response {
            println!("{:8b}", byte);
            if *byte != 0b1000_0001 {
                break 'outer;
            }
        }
        // sleep(Duration::from_millis(100));
    }
}
