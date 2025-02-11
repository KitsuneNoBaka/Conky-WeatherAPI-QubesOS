#!/bin/bash

cd $(dirname $0)

# wait for the network and other apps to start
[[ "$@" =~ '--no-sleep' ]] || sleep 1;

# create a new config if there is none
#[[ -f weatherapi-conky-config.lua ]] || cp weatherapi-conky-config.example.lua weatherapi-conky-config.lua


if [[ "$@" =~ '--nolog' ]]; then
	exec conky -c weatherapi-conky-config.lua
else
	conky_log="/tmp/conky.log"
	exec 1>>$conky_log
	echo "###         Starting conky ...         ###"
	exec conky -c weatherapi-conky-config.lua >> $conky_log 2>&1
fi
