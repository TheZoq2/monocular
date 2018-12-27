use websocket::sync::{Server, Reader};
use websocket::message::OwnedMessage;
use serde_json;

use std::sync::mpsc::{Sender, Receiver};
use std::sync::{Arc, Mutex};
use std::thread;
use std::net::TcpStream;

use crate::types::{WebMessage, ControlMessage};


pub fn server(
    address: &str,
    reading_receiver: Receiver<WebMessage>,
    control_sender: Sender<ControlMessage>
) {
    let server = Server::bind(address).expect("Failed to start websocket server");

    for connection in server.filter_map(Result::ok) {
        let client = connection.accept().expect("Failed to accept client");

        let (receiver, mut sender) = client.split().expect("Failed to split client");

        let disconnected_mutex = Arc::new(Mutex::new(false));

        start_websocket_read(receiver, disconnected_mutex.clone(), control_sender.clone());

        println!("Got new client");
        loop {
            let message = reading_receiver.recv()
                .expect("Reading->Websocket sender disconnected");

            let message = OwnedMessage::Text(
                serde_json::to_string(&message)
                    .expect("Failed to encode message")
            );
            sender.send_message(&message).expect("Failed to send message");

            if *disconnected_mutex.lock().unwrap() == true {
                break;
            }


        }
    }
}

fn start_websocket_read(
    mut receiver: Reader<TcpStream>,
    disconnected_mutex: Arc<Mutex<bool>>,
    control_sender: Sender<ControlMessage>
) {
    thread::spawn(move || {
        for message in receiver.incoming_messages() {
            match message.expect("Failed to get control message") {
                OwnedMessage::Text(data) => {
                    let decoded = serde_json::from_str::<ControlMessage>(&data)
                        .expect("Failed to decode control message");

                    println!("Got message: {:?}", decoded);
                    control_sender.send(decoded)
                        .expect("Failed to send control message, did the receiver disconnect?");
                },
                OwnedMessage::Close(_) => {
                    println!("Client disconnected");
                    *disconnected_mutex.lock().unwrap() = true;
                }
                msg => {
                    panic!("Got websocket message of unexpected type: {:?}", msg)
                }
            };
        }
    });
}



