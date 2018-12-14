use std::sync::mpsc::{Sender, Receiver};

use crate::types::Reading;

struct State {
    last_reading: Reading
}

impl State {
    fn initial() -> Self {
        State {
            last_reading: Reading::new(0, 0)
        }
    }

    pub fn update(&mut self, bytes: [u8;5]) -> Option<Reading> {
        let reading = Reading::from(bytes);

        if reading.has_new_information(&self.last_reading) {
            self.last_reading = reading.clone();
            Some(reading)
        }
        else {
            None
        }
    }
}


fn loop_iteration(state: &mut State, rx: &Receiver<[u8;5]>, tx: &Sender<Reading>) {
    let bytes = rx.recv().expect("Failed to get bytes");
    match state.update(bytes) {
        Some(reading) => {
            println!("got reading: {:?}", reading);
            tx.send(reading).expect("Failed to send reading");
        },
        None => {}
    }
}

pub fn run(rx: Receiver<[u8;5]>, tx: Sender<Reading>) {
    let mut state = State::initial();
    loop {
        loop_iteration(&mut state, &rx, &tx)
    }
}




#[cfg(test)]
mod decoder_tests {
    use super::*;

    #[test]
    fn update_with_new_data_works() {
        let mut state = State::initial();

        let reading = state.update([0;5]);

        assert_eq!(reading, None);
        let reading = state.update([1,0,0,0,0]);
        assert_eq!(reading, Some(Reading::new(1, 0)));
    }

    #[test]
    fn sending_works() {
        let (reading_tx, reading_rx) = ::std::sync::mpsc::channel();
        let (byte_tx, byte_rx) = ::std::sync::mpsc::channel();


        let mut state = State::initial();

        byte_tx.send([1,0,0,0,0]).expect("Failed to send bytes");
        byte_tx.send([1,0,0,0,0]).expect("Failed to send bytes");
        byte_tx.send([2,0,0,0,0]).expect("Failed to send bytes");

        loop_iteration(&mut state, &byte_rx, &reading_tx);
        loop_iteration(&mut state, &byte_rx, &reading_tx);
        loop_iteration(&mut state, &byte_rx, &reading_tx);

        assert_eq!(reading_rx.recv().expect("Failed to receive byte"), Reading::new(1, 0));
        assert_eq!(reading_rx.recv().expect("Failed to receive byte"), Reading::new(2, 0));
        assert!(reading_rx.try_recv().is_err());
    }
}

