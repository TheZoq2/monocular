use serde_derive::{Serialize, Deserialize};

#[derive(PartialEq, Eq, Debug, Serialize, Deserialize, Clone)]
pub struct Reading {
    pub state: u8,
    pub time: u32
}


impl Reading {
    pub fn new(state: u8, time: u32) -> Self {
        Self {state, time}
    }

    pub fn has_new_information(&self, prev: &Self) -> bool {
        self.state != prev.state
    }
}

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


#[cfg(test)]
mod reading_tests {
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
