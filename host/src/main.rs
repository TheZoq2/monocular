mod decoder;
mod websockets;
mod types;
mod spi;

use std::sync::mpsc;
use std::thread;

const SPI_FREQUENCY: u32 = 1 * 1_000_000;



fn main() {
    let spi = spi::create_spi(SPI_FREQUENCY).unwrap();

    let (byte_tx, byte_rx) = mpsc::channel();
    let (web_tx, web_rx) = mpsc::channel();
    let (control_tx, control_rx) = mpsc::channel();

    let t1 = thread::spawn(move || spi::reader(spi, byte_tx, control_rx));
    let t2 = thread::spawn(move || decoder::run(byte_rx, web_tx));
    let t3 = thread::spawn(move || websockets::server("0.0.0.0:8765", web_rx, control_tx));

    t1.join().unwrap();
    t2.join().unwrap();
    t3.join().unwrap();
}

