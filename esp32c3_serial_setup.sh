#!/bin/bash

# docs:
# 1)	IBM stty reference https://www.ibm.com/docs/en/zvm/7.4.0?topic=commands-stty-set-display-terminal-options
# 2)	espressif https://docs.espressif.com/projects/esp-idf/en/v4.3/esp32c3/get-started/establish-serial-connection.html#windows-and-linux


# extract the esp's ttyUSB device (often ttyUSB0)
file_name=$(./tty_lsusb_assosiate.sh | grep ".*Silicon_Labs.*" |sed  "s/\([a-zA-Z0-9/]*\).*/\1/")


# Sets up the serial port's mode as mentioned in their docs
# baud rate 115200
# data bits = 8			-> cs8
# stop bits = 1			-> -cstopb
# no parity setting	-> -parenb
stty -F $file_name 115200 cs8 -parenb -cstopb

echo "Done. Try running cat $file_name."
echo "If the device was flashed with an app that prints to stdout you should see legible output, else try pressing the reset button"
