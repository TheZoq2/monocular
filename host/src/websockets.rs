use websocket::sync::{Server};
use websocket::message::OwnedMessage;
use serde_json;
use serde_derive::{Serialize};

use std::sync::mpsc::Receiver;


use crate::types::{WebMessage, Reading};


pub fn server(address: &str, reading_receiver: Receiver<WebMessage>) {
    let server = Server::bind(address).expect("Failed to start websocket server");

    for connection in server.filter_map(Result::ok) {
        let mut client = connection.accept().expect("Failed to accept client");

        println!("Got new client");
        loop {
            let message = reading_receiver.recv()
                .expect("Reading->Websocket sender disconnected");

            let message = OwnedMessage::Text(
                serde_json::to_string(&message)
                    .expect("Failed to encode message")
            );

            client.send_message(&message).expect("Failed to send message");
        }
    }
}

