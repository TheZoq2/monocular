use std::sync::mpsc::{Sender, Receiver};

use crate::types::{WebMessage, Reading};

const TIME_UPDATE_INTERVAL: f64 = 100_000.; // 100 ms

struct State {
    last_reading: Reading,
    last_time: f64
}

impl State {
    fn initial() -> Self {
        State {
            last_reading: Reading::new(0, 0.),
            last_time: 0.
        }
    }

    pub fn update(&mut self, bytes: [u8;5]) -> Option<WebMessage> {
        let reading = Reading::from(bytes);

        if reading.has_new_information(&self.last_reading) {
            self.last_reading = reading.clone();
            self.last_time = reading.time;
            Some(WebMessage::Reading(reading))
        }
        else if reading.time > self.last_time + TIME_UPDATE_INTERVAL {
            self.last_time = reading.time;
            Some(WebMessage::CurrentTime(reading.time))
        }
        else {
            None
        }
    }
}


fn loop_iteration(state: &mut State, rx: &Receiver<[u8;5]>, tx: &Sender<WebMessage>) {
    let bytes = rx.recv().expect("Failed to get bytes");
    match state.update(bytes) {
        Some(reading) => {
            tx.send(reading).expect("Failed to send reading");
        },
        None => {}
    }
}

pub fn run(rx: Receiver<[u8;5]>, tx: Sender<WebMessage>) {
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
        assert_eq!(reading, Some(WebMessage::Reading(Reading::new(1, 0.))));
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

        let first_expected = WebMessage::Reading(Reading::new(1, 0.));
        let second_expected = WebMessage::Reading(Reading::new(2, 0.));

        assert_eq!(reading_rx.try_recv().expect("Failed to receive byte"), first_expected);
        assert_eq!(reading_rx.try_recv().expect("Failed to receive byte"), second_expected);
        assert!(reading_rx.try_recv().is_err());
    }

    #[test]
    fn time_updates_are_sent_regularly() {
        let (reading_tx, reading_rx) = ::std::sync::mpsc::channel();
        let (byte_tx, byte_rx) = ::std::sync::mpsc::channel();


        let mut state = State::initial();

        // Ensure time updates roughly at 30 hz
        byte_tx.send([1,0,0,0b000,0]).expect("Failed to send bytes");
        byte_tx.send([1,0,0,0b100,0]).expect("Failed to send bytes");
        byte_tx.send([1,0,0,0x20,0]).expect("Failed to send bytes");
        byte_tx.send([1,0,1,0x20,0]).expect("Failed to send bytes");

        loop_iteration(&mut state, &byte_rx, &reading_tx);
        loop_iteration(&mut state, &byte_rx, &reading_tx);
        loop_iteration(&mut state, &byte_rx, &reading_tx);

        let first_expected = WebMessage::Reading(Reading::new(1, 0.));

        assert_eq!(reading_rx.try_recv().expect("Failed to receive message"), first_expected);
        match reading_rx.try_recv().expect("Failed to receive time message") {
            WebMessage::CurrentTime(_) => {},
            other => panic!("Expected time update, got {:?}", other)
        }
        assert!(reading_rx.try_recv().is_err(), "Did not expect another message");
    }

    #[test]
    fn normal_readings_update_last_time() {
        let (reading_tx, reading_rx) = ::std::sync::mpsc::channel();
        let (byte_tx, byte_rx) = ::std::sync::mpsc::channel();


        let mut state = State::initial();

        // Ensure time updates roughly at 30 hz
        byte_tx.send([0,0,0,0b000,0]).expect("Failed to send bytes");
        byte_tx.send([1,0,0,0x20,0]).expect("Failed to send bytes");
        byte_tx.send([1,0,1,0x20,0]).expect("Failed to send bytes");

        loop_iteration(&mut state, &byte_rx, &reading_tx);
        loop_iteration(&mut state, &byte_rx, &reading_tx);
        loop_iteration(&mut state, &byte_rx, &reading_tx);

        let first_expected = WebMessage::Reading(Reading::new(1, 0x20_00_00 as f64 / 16.));

        assert_eq!(reading_rx.try_recv().expect("Failed to receive message"), first_expected);
        assert!(reading_rx.try_recv().is_err(), "Did not expect another message");
    }

}

