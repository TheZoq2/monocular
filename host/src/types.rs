use serde_derive::{Serialize, Deserialize};

const FREQUENCY_HZ: u32 = 16_000_000;
const CHANNEL_AMOUNT: usize = 8;
type ReadingState = [bool; CHANNEL_AMOUNT];

fn u8_to_values(input: u8) -> ReadingState {
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

#[derive(PartialEq, Debug, Serialize, Deserialize, Clone)]
pub struct Reading {
    pub values: ReadingState,
    pub time: f64
}


impl Reading {
    pub fn new(values: u8, time: f64) -> Self {
        Self {values: u8_to_values(values), time}
    }

    pub fn has_new_information(&self, prev: &Self) -> bool {
        self.values != prev.values
    }
}

impl From<[u8;5]> for Reading {
    fn from(bytes: [u8;5]) -> Self {
        Reading {
            values: u8_to_values(bytes[0]),
            time: ((
                ((bytes[4] as u32) << 24) +
                ((bytes[3] as u32) << 16) +
                ((bytes[2] as u32) << 8)  +
                ((bytes[1] as u32))
            ) as f64) / (FREQUENCY_HZ / 1_000_000) as f64
        }
    }
}


impl std::fmt::Display for Reading {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "Reading{{")?;
        for val in self.values.iter() {
            write!(f, "{}", if *val {1} else {0})?;
        }
        write!(f, ", time: {}}}", self.time)
    }
}


#[cfg(test)]
mod reading_tests {
    use super::*;

    #[test]
    fn reading_values_conversion_works() {
        assert_eq!(u8_to_values(0b00000000), [false; 8]);
        assert_eq!(u8_to_values(0b11111111), [true; 8]);
        assert_eq!(u8_to_values(0b11010010), [true, true, false, true, false, false, true, false]);
    }

    #[test]
    fn decoding_current_values_works() {
        let values = 0b10100101;
        let reading = Reading::from([values, 1,2,3,4]);

        assert_eq!(reading.values, u8_to_values(values));
    }

    #[test]
    fn dupliacte_detection_triggered_on_same() {
        let old_reading = Reading::new(123, 125.);
        let new_reading = Reading::new(123, 182.);
        assert!(!new_reading.has_new_information(&old_reading));
    }
    #[test]
    fn dupliacte_detection_not_triggered_on_different() {
        let old_reading = Reading::new(123, 125.);
        let new_reading = Reading::new(222, 182.);
        assert!(new_reading.has_new_information(&old_reading));
    }


    #[test]
    fn decoding_time_gives_correct_values() {
        let values = 123;
        let expected = 1.;
        let reading = Reading::from([values, 16, 0, 0, 0]);

        assert_eq!(reading.time, expected);

        let values = 123;
        let expected = 1_000_000.;
        let reading = Reading::from([values, 0, 0x24, 0xf4, 0]);

        assert_eq!(reading.time, expected);
    }
}
