#!/bin/bash
set -e

export PATH=${GRADLE_HOME}/bin:${PATH}

while true; do
	#if ! /usr/local/lsws/bin/lswsctrl status | grep 'litespeed is running with PID *' > /dev/null; then
	#	break
	#fi
	sleep 60
done