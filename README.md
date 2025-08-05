# MacBookPro9,x

This repository contains various resources to running Linux (specifically Arch) on the MacBook Pro mid-2012 [13-inch](https://support.apple.com/en-us/111958) and [15-inch](https://support.apple.com/en-us/112568) "unibody" models.

These are also known by the model identifiers [MacBookPro9,1](https://everymac.com/ultimate-mac-lookup/?search_keywords=MacBookPro9,1) and [MacBookPro9,2](https://everymac.com/ultimate-mac-lookup/?search_keywords=MacBookPro9,2).


# General

General resources common between both models. The relevant Arch Wiki for these models can be found [here](https://wiki.archlinux.org/title/MacBookPro9,x).


## Installation

The Arch install ISO defaults the keyboard layout to `us`. This can be relatively easily changed with the `loadkeys` command:

    `$ loadkeys dk-latin1`

This loads the `nodeadkeys` version of a Danish keyboard (for information about "dead keys" see [here](https://en.wikipedia.org/wiki/Dead_key)).
However, most, if not all regular `xx` or `xx-latin1` language keymaps does not follow a Mac layout, and thus causes issue.
To get a list of keymaps that might work out of the box for you, you can list all keymaps with the `localectl` command:

    `$ localectl list-keymaps`

Load the relevant keymap with the `loadkeys` command:

    `$ loadkeys mac-dk-latin1`

**NOTE:** `mac-dk-latin1` is currently broken, and messes up the keyboard completely.
This has been discussed [here](https://bbs.archlinux.org/viewtopic.php?id=156453) with no solution yet.
I have made a solution, but it requires being on an actual installation, and *not* in the install ISO (solution discussed [here](TODO)).
During the install, I recommend finding a similar enough layout that can get you through the installation.
In my case, the Norweigan keyboard layout `mac-no-latin1` was similar enough.

Another issue during installation is internet connectivity.
Ethernet works without issue, but the Wi-Fi most likely does not.
To quickly test, launch [`iwctl`](https://wiki.archlinux.org/title/Iwd#iwctl):

    `$ iwctl`

In the interactive prompt, type:

    `$ device list`

If nothing shows up, you can try unloading and reloading some modules, as mentioned on the [MacBookPro9,x page](https://wiki.archlinux.org/title/MacBookPro9,x#Installation):

    `$ rmmod b43 bcma ssb wl`
    `$ modprobe wl`

You can go back and retry the `iwctl` steps and see if it shows up in the device list now.
If it still does not show up, you can try switching the state back to `up`:

    `$ ip link set wlan0 down`
    `$ ip link set wlan0 up`

If this still does not make the device show up, you might have to rely on Ethernet throughout the installation.
In my case, I got the device to show up the first time I unloaded and reloaded the modules, but failed to get this result again in ~6 attempts afterwards.
I restorted to Ethernet throughout the installation.


## Wireless

Once booted in the new installation, install the proper driver for the wireless chip.
The wireless chip should be the same between the 13-inch and 15-inch models, if it has not been [upgraded](https://www.intriguingindustries.co.uk/product/12-6-adapter/).
The stock chips for both models should be `BCM4331`. You can double check with the following command:

    `$ lspci -vnn -d 14e4:`

If the wireless chip model number indeed is `BCM4331`, it should work simply by installing `broadcom-wl` or `broadcom-wl-dkms`:

    `sudo pacman -S broadcom-wl-dkms`


### broadcom-wl-dkms

TODO: Setup instructions


## Keyboard layout fix (graphical session)

Most graphical environments use the [X11 Keyboard Extension/XKB](https://www.x.org/releases/current/doc/xorg-docs/input/XKB-Config.html).
If you had problems with the keyboard layout, define the proper proper parameters using your preferred XKB configuration method.
For `hyprland`, it can be achieved by setting the `kb_layout`, `kb_variant`, and `kb_options` [input variables](https://wiki.hypr.land/Configuring/Variables/#input):

    input {
        kb_layout = dk
        kb_variant = mac
        kb_options = lvl3:ralt_switch
    }

This makes the keyboad use the Mac variant of the Danish layout, while mapping Right Alt to AltGr.
This makes it possible to type special characters such as square brackets, curly braces, etc. by holding down Right Alt and pressing the corresponding key.


## Keyboard layout fix (tty)

However, this is only true for graphical sessions, such as a `hyprland` session. A proper keymap file still need to exist to load a similar layout in a tty.
Conveniently it is possible to compile an a keymap based on these XKB values.
To do this the [ckbcomp package](https://aur.archlinux.org/packages/ckbcomp) (AUR) needs to be installed with your AUR helper of choice ([yay](https://github.com/Jguer/yay) in my case):

    `$ yay -S ckbcomp`

After installing, a keymap file can be compiled and packed with `gzip`:

    `$ ckbcomp -compact -layout dk -variant mac -option lvl3:ralt_switch | gzip > mac_dk.map.gz`

For the newly created `mac_dk.map.gz` keymap file to be easily loadable with `loadkeys`, it should be moved to a relavant folder in `/usr/share/kbd/keymaps/`:

    `$ sudo mv mac_dk.map.gz /usr/share/kbd/keymaps/mac/all/mac_dk.map.gz`

For the changes to be persistent after a reboot, the `KEYMAP` variable can be changed in `/etc/vconsole.conf`:

    KEYMAP=mac_dk.map.gz

You can now freely reboot your MacBook and load into a tty to see the changed.


# MacBookPro9,1 (15-inch)

TODO: Resources that specifically apply to the MacBookPro9,1 (15-inch) model.


# MacBookPro9,2 (13-inch)

TODO: Resources that specifically apply to the MacBookPro9,2 (13-inch) model.

