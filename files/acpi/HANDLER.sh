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
	button/kbdillumdown)
		source "${SCRIPTS_DIR}/KbdBrightnessDown.sh";;
	button/kbdillumup)
		source "${SCRIPTS_DIR}/KbdBrightnessUp.sh";;
	cd/prev) # TODO: Check if these actually work in tty with mpd set up
		source "${SCRIPTS_DIR}/AudioPrev.sh";;
	cd/play)
		source "${SCRIPTS_DIR}/AudioPlay.sh";;
	cd/next)
		source "${SCRIPTS_DIR}/AudioNext.sh";;
	*)
		echo "No behavior defined for event: ${EVENT}"
		exit 1
		;;
esac

