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


fn create_spi() -> io::Result<Spidev> {
    let mut spi = Spidev::open("/dev/spidev0.0")?;
    let options = SpidevOptions::new()
        .bits_per_word(8)
        .max_speed_hz(1_000_00)
        .mode(SPI_MODE_0)
        .build();

    spi.configure(&options)?;
    Ok(spi)
}

/// Perform full duplex operations using Ioctl
fn full_duplex(spi: &mut Spidev) -> io::Result<[u8;3]> {
    // "write" transfers are also reads at the same time with
    // the read having the same length as the write
    let tx_buf = [0x01, 0x02, 0x03];
    let mut rx_buf = [0; 3];
    {
        let mut transfer = SpidevTransfer::read_write(&tx_buf, &mut rx_buf);
        spi.transfer(&mut transfer)?;
    }
    Ok(rx_buf)
}

fn main() {
    let mut spi = create_spi().unwrap();
    let response = full_duplex(&mut spi).unwrap();

    for byte in &response {
        println!("{:b}", byte);
    }
}
