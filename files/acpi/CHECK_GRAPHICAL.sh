#!/usr/bin/env bash

# Exit if running in a graphical environment
# i.e. if active tty doesn't have any X11/Xwayland/etc processes running
ACTIVE_TTY=$(fgconsole)
IS_GRAPHICAL=$(ps -e -o tty,comm | grep "tty${ACTIVE_TTY}" | grep -E 'Xorg|Xwayland|Hyprland|gnome-shell|sway|kwin_wayland')

if [[ "$IS_GRAPHICAL" ]]; then
	echo "Session is graphical, skipping acpid handling"
	exit 1
fi

