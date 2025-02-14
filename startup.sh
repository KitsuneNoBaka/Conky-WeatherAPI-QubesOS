#!/bin/bash

set -e

cd $(dirname $0)

USAGE=$(cat<<EOF
Conky WeatherAPI for QubesOS starting script.

USAGE: weatherapi-conky-start.sh [options]
options:
	--no-sleep	- Conky will start witout 2s delay
	--no-log		- Conky start with error output to terminal insead to log file "/tmp/conky.log"
EOF
)

if [[ "$@" =~ '-h' ]] || [[ "$@" =~ '--help' ]]; then
	echo "$USAGE"
	exit 111
fi

# wait for the network and other apps to start
[[ "$@" =~ '--no-sleep' ]] || sleep 2;

# create a new config if there is none
#[[ -f weatherapi-conky-config.lua ]] || cp weatherapi-conky-config.example.lua weatherapi-conky-config.lua


if [[ "$@" =~ '--no-log' ]]; then
	exec conky -c config.lua
else
	conky_log="/tmp/conky.log"
	exec 1>$conky_log
	echo "###         Starting conky ...         ###"
	exec conky -c config.lua >> $conky_log 2>&1
fi

exit 0
