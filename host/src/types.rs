use serde_derive::{Serialize, Deserialize};

#[derive(PartialEq, Eq, Debug, Serialize, Deserialize)]
pub struct Reading {
    pub state: u8,
    pub time: u32
}
