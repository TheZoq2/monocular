use serde_derive::{Serialize, Deserialize};

const CHANNEL_AMOUNT: usize = 8;
type ReadingState = [bool; CHANNEL_AMOUNT];

fn u8_to_state(input: u8) -> ReadingState {
    [
        (input >> 7) & 1 == 1,
        (input >> 6) & 1 == 1,
        (input >> 5) & 1 == 1,
        (input >> 4) & 1 == 1,
        (input >> 3) & 1 == 1,
        (input >> 2) & 1 == 1,
        (input >> 1) & 1 == 1,
        input & 1 == 1
    ]
}

#[derive(PartialEq, Eq, Debug, Serialize, Deserialize, Clone)]
pub struct Reading {
    pub state: ReadingState,
    pub time: u32
}


impl Reading {
    pub fn new(state: u8, time: u32) -> Self {
        Self {state: u8_to_state(state), time}
    }

    pub fn has_new_information(&self, prev: &Self) -> bool {
        self.state != prev.state
    }
}

impl From<[u8;5]> for Reading {
    fn from(bytes: [u8;5]) -> Self {
        Reading {
            state: u8_to_state(bytes[0]),
            time: (
                ((bytes[1] as u32) << 24) +
                ((bytes[2] as u32) << 16) +
                ((bytes[3] as u32) << 8)  +
                ((bytes[4] as u32))
            )
        }
    }
}


#[cfg(test)]
mod reading_tests {
    use super::*;

    #[test]
    fn reading_state_conversion_works() {
        assert_eq!(u8_to_state(0b00000000), [false; 8]);
        assert_eq!(u8_to_state(0b11111111), [true; 8]);
        assert_eq!(u8_to_state(0b11010010), [true, true, false, true, false, false, true, false]);
    }

    #[test]
    fn decoding_current_state_works() {
        let state = 0b10100101;
        let reading = Reading::from([state, 1,2,3,4]);

        assert_eq!(reading.state, u8_to_state(state));
    }

    #[test]
    fn decoding_time_works() {
        let state = 123;
        let time = 0x11223344;
        let reading = Reading::from([state, 0x11, 0x22, 0x33, 0x44]);

        assert_eq!(reading.time, time);
    }

    #[test]
    fn dupliacte_detection_triggered_on_same() {
        let old_reading = Reading::new(123, 125);
        let new_reading = Reading::new(123, 182);
        assert!(!new_reading.has_new_information(&old_reading));
    }
    #[test]
    fn dupliacte_detection_not_triggered_on_different() {
        let old_reading = Reading::new(123, 125);
        let new_reading = Reading::new(222, 182);
        assert!(new_reading.has_new_information(&old_reading));
    }
}
