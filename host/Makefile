PI_URL=boats.local

build:
	cargo build --target armv7-unknown-linux-gnueabihf
	scp target/armv7-unknown-linux-gnueabihf/debug/host "boats.local:bin/monocular"

