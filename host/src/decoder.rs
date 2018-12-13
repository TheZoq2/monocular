use std::sync::mpsc::{Sender, Receiver};

use crate::types::Reading;

impl From<[u8;5]> for Reading {
    fn from(bytes: [u8;5]) -> Self {
        Reading {
            state: bytes[0],
            time: (
                ((bytes[1] as u32) << 24) +
                ((bytes[2] as u32) << 16) +
                ((bytes[3] as u32) << 8)  +
                ((bytes[4] as u32))
            )
        }
    }
}

pub fn run_decoder(rx: Receiver<[u8;5]>, tx: Sender<Reading>) {
    loop {
        if let Ok(bytes) = rx.recv() {
            tx.send(bytes.into())
                .expect("Failed to send reading, did the receiver disonnect?")
        }
        else {
            // panic!("Decoder error: byte sender disconnected");
            println!("Decoder error: byte sender disconnected");
            break;
        }
    }
}



#[cfg(test)]
mod decoding_tests {
    use super::*;

    #[test]
    fn decoding_current_state_works() {
        let state = 0b10100101;
        let reading = Reading::from([state, 1,2,3,4]);

        assert_eq!(reading.state, state);
    }

    #[test]
    fn decoding_time_works() {
        let state = 123;
        let time = 0x11223344;
        let reading = Reading::from([state, 0x11, 0x22, 0x33, 0x44]);

        assert_eq!(reading.time, time);
    }
}


#[cfg(test)]
mod decoder_tests {
    use super::*;

    use std::thread;

    #[test]
    fn sending_works() {
        let (reading_tx, reading_rx) = ::std::sync::mpsc::channel();
        let (byte_tx, byte_rx) = ::std::sync::mpsc::channel();


        let handle = thread::spawn(|| run_decoder(byte_rx, reading_tx));

        let received = {
            // Move RX into a new scope to force it to be dropped and crash the other thread
            let tx = byte_tx;
            let reading_rx = reading_rx;
            tx.send([0,0x11,0x22,0x33,0x44]).expect("Failed to send data");
            tx.send([1,0x12,0x22,0x33,0x44]).expect("Failed to send data");
            tx.send([2,0x13,0x22,0x33,0x44]).expect("Failed to send data");

            vec!(
                reading_rx.recv().expect("Failed to receive first reading"),
                reading_rx.recv().expect("Failed to receive second reading"),
                reading_rx.recv().expect("Failed to receive third reading"),
            )
        };

        handle.join().unwrap();

        assert_eq!(received, vec!(
            Reading{state: 0, time: 0x11223344},
            Reading{state: 1, time: 0x12223344},
            Reading{state: 2, time: 0x13223344},
        ));
    }
}
