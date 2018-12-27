use std::sync::mpsc::{Sender, Receiver, TryRecvError};

use crate::types::{self, WebMessage, Reading, ControlMessage};

const TIME_UPDATE_INTERVAL: f64 = 100_000.; // 100 ms

struct State {
    last_reading: Reading,
    last_time: f64,
    mask: u8
}

impl State {
    fn initial() -> Self {
        State {
            last_reading: Reading::new(0, 0.),
            last_time: 0.,
            mask: 0xff
        }
    }

    pub fn update(&mut self, mut bytes: [u8;5]) -> Option<WebMessage> {
        bytes[0] &= self.mask;

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

    pub fn handle_control_message(&mut self, message: ControlMessage) {
        match message {
            ControlMessage::ActiveChannels(mask) => {
                self.mask = types::values_to_u8(mask)
            }
        }
    }
}


fn loop_iteration(
    state: &mut State,
    rx: &Receiver<[u8;5]>,
    tx: &Sender<WebMessage>,
    control_rx: &Receiver<ControlMessage>
) {
    match control_rx.try_recv() {
        Ok(mask) => state.handle_control_message(mask),
        Err(TryRecvError::Empty) => {}
        Err(other) => {
            panic!("failed to receive control message in decoder {}. Did the sender disconnect?", other)
        }
    }

    let bytes = rx.recv().expect("Failed to get bytes");
    match state.update(bytes) {
        Some(reading) => {
            tx.send(reading).expect("Failed to send reading");
        },
        None => {}
    }
}

pub fn run(rx: Receiver<[u8;5]>, tx: Sender<WebMessage>, control_rx: Receiver<ControlMessage>) {
    let mut state = State::initial();
    loop {
        loop_iteration(&mut state, &rx, &tx, &control_rx)
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
    fn update_with_mask_works() {
        let mut state = State::initial();

        state.handle_control_message(ControlMessage::ActiveChannels(
                    [true, true, true, true, false, false, false, false]
                ));

        let reading = state.update([0b11010010,0,0,0,0]);
        assert_eq!(reading, Some(WebMessage::Reading(Reading::new(0b11010000, 0.))));
    }

    #[test]
    fn sending_works() {
        let (reading_tx, reading_rx) = ::std::sync::mpsc::channel();
        let (byte_tx, byte_rx) = ::std::sync::mpsc::channel();
        let (_control_tx, control_rx) = ::std::sync::mpsc::channel();


        let mut state = State::initial();

        byte_tx.send([1,0,0,0,0]).expect("Failed to send bytes");
        byte_tx.send([1,0,0,0,0]).expect("Failed to send bytes");
        byte_tx.send([2,0,0,0,0]).expect("Failed to send bytes");

        loop_iteration(&mut state, &byte_rx, &reading_tx, &control_rx);
        loop_iteration(&mut state, &byte_rx, &reading_tx, &control_rx);
        loop_iteration(&mut state, &byte_rx, &reading_tx, &control_rx);

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
        let (_control_tx, control_rx) = ::std::sync::mpsc::channel();


        let mut state = State::initial();

        // Ensure time updates roughly at 30 hz
        byte_tx.send([1,0,0,0b000,0]).expect("Failed to send bytes");
        byte_tx.send([1,0,0,0b100,0]).expect("Failed to send bytes");
        byte_tx.send([1,0,0,0x20,0]).expect("Failed to send bytes");
        byte_tx.send([1,0,1,0x20,0]).expect("Failed to send bytes");

        loop_iteration(&mut state, &byte_rx, &reading_tx, &control_rx);
        loop_iteration(&mut state, &byte_rx, &reading_tx, &control_rx);
        loop_iteration(&mut state, &byte_rx, &reading_tx, &control_rx);

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
        let (_control_tx, control_rx) = ::std::sync::mpsc::channel();


        let mut state = State::initial();

        // Ensure time updates roughly at 30 hz
        byte_tx.send([0,0,0,0b000,0]).expect("Failed to send bytes");
        byte_tx.send([1,0,0,0x20,0]).expect("Failed to send bytes");
        byte_tx.send([1,0,1,0x20,0]).expect("Failed to send bytes");

        loop_iteration(&mut state, &byte_rx, &reading_tx, &control_rx);
        loop_iteration(&mut state, &byte_rx, &reading_tx, &control_rx);
        loop_iteration(&mut state, &byte_rx, &reading_tx, &control_rx);

        let first_expected = WebMessage::Reading(Reading::new(1, 0x20_00_00 as f64 / 16.));

        assert_eq!(reading_rx.try_recv().expect("Failed to receive message"), first_expected);
        assert!(reading_rx.try_recv().is_err(), "Did not expect another message");
    }

    #[test]
    fn sending_mask_works() {
        let (reading_tx, reading_rx) = ::std::sync::mpsc::channel();
        let (byte_tx, byte_rx) = ::std::sync::mpsc::channel();
        let (control_tx, control_rx) = ::std::sync::mpsc::channel();


        let mut state = State::initial();

        control_tx.send(ControlMessage::ActiveChannels(
            [true, true, true, true, false, false, false, false]
        )).expect("Failed to send control message");

        byte_tx.send([0b11010010,0,0,0,0]).expect("Failed to send bytes");

        loop_iteration(&mut state, &byte_rx, &reading_tx, &control_rx);

        let first_expected = WebMessage::Reading(Reading::new(0b11010000, 0.));

        assert_eq!(reading_rx.try_recv().expect("Failed to receive byte"), first_expected);
        assert!(reading_rx.try_recv().is_err());
    }
}

