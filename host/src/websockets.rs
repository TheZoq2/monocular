use websocket::sync::{Server};
use websocket::message::OwnedMessage;
use serde_json;

use std::sync::mpsc::Receiver;

use crate::types::{WebMessage, ControlMessage};


pub fn server(address: &str, reading_receiver: Receiver<WebMessage>) {
    let server = Server::bind(address).expect("Failed to start websocket server");

    for connection in server.filter_map(Result::ok) {
        let client = connection.accept().expect("Failed to accept client");

        let (mut receiver, mut sender) = client.split().expect("Failed to split client");

        println!("Got new client");
        'outer: loop {
            let message = reading_receiver.recv()
                .expect("Reading->Websocket sender disconnected");

            let message = OwnedMessage::Text(
                serde_json::to_string(&message)
                    .expect("Failed to encode message")
            );
            sender.send_message(&message).expect("Failed to send message");

            for message in receiver.incoming_messages() {
                let decoded = match message.expect("Failed to get control message") {
                    OwnedMessage::Text(data) => {
                        serde_json::from_str::<ControlMessage>(&data)
                            .expect("Failed to decode control message")
                    },
                    OwnedMessage::Close(_) => {
                        println!("Client disconnected");
                        break 'outer;
                    }
                    msg => {
                        panic!("Got websocket message of unexpected type: {:?}", msg)
                    }
                };

                println!("Got message: {:?}", decoded);
            }

        }
    }
}



