#!/usr/bin/env bash

EVENT=$1
SCRIPTS_DIR=$(dirname $(readlink -f "$0"))

# Exit if graphical session is active
source "${SCRIPTS_DIR}/CHECK_GRAPHICAL.sh"

echo "Handling event: ${EVENT}"

case $EVENT in
	video/brightnessdown)
		source "${SCRIPTS_DIR}/MonBrightnessDown.sh";;
	video/brightnessup)
		source "${SCRIPTS_DIR}/MonBrightnessUp.sh";;
	*)
		echo "No behavior defined for event: ${EVENT}"
		exit 1
		;;
esac

