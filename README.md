# MacBookPro9,x

This repository contains various resources to running Linux (specifically Arch) on the MacBook Pro mid-2012 [13-inch](https://support.apple.com/en-us/111958) and [15-inch](https://support.apple.com/en-us/112568) "unibody" models.

These are also known by the model identifiers [MacBookPro9,1](https://everymac.com/ultimate-mac-lookup/?search_keywords=MacBookPro9,1) and [MacBookPro9,2](https://everymac.com/ultimate-mac-lookup/?search_keywords=MacBookPro9,2).


# General

General resources common between both models. The relevant Arch Wiki for these models can be found [here](https://wiki.archlinux.org/title/MacBookPro9,x).


## Installation

The Arch install ISO defaults the keyboard layout to `us`. This can be relatively easily changed with the `loadkeys` command:

    $ loadkeys dk-latin1

This loads the `nodeadkeys` version of a Danish keyboard (for information about "dead keys" see [here](https://en.wikipedia.org/wiki/Dead_key)).
However, most, if not all regular `xx` or `xx-latin1` language keymaps does not follow a Mac layout, and thus causes issue.
To get a list of keymaps that might work out of the box for you, you can list all keymaps with the `localectl` command:

    $ localectl list-keymaps

Load the relevant keymap with the `loadkeys` command:

    $ loadkeys mac-dk-latin1

**NOTE:** `mac-dk-latin1` is currently broken, and messes up the keyboard completely.
This has been discussed [here](https://bbs.archlinux.org/viewtopic.php?id=156453) with no solution yet.
I have made a solution, but it requires being on an actual installation, and *not* in the install ISO (solutions are discussed later for [graphical sessions](#keyboard-layout-fix-graphical-session) and [tty](#keyboard-layout-fix-tty)).
During the install, I recommend finding a similar enough layout that can get you through the installation.
In my case, the Norweigan keyboard layout `mac-no-latin1` was similar enough.

Another issue during installation is internet connectivity.
Ethernet works without issue, but the Wi-Fi most likely does not.
To quickly test, launch [`iwctl`](https://wiki.archlinux.org/title/Iwd#iwctl):

    $ iwctl

In the interactive prompt, type:

    $ device list

If nothing shows up, you can try unloading and reloading some modules, as mentioned on the [MacBookPro9,x page](https://wiki.archlinux.org/title/MacBookPro9,x#Installation):

    $ rmmod b43 bcma ssb wl
    $ modprobe wl

You can go back and retry the `iwctl` steps and see if it shows up in the device list now.
If it still does not show up, you can try switching the state back to `up`:

    $ ip link set wlan0 down
    $ ip link set wlan0 up

If this still does not make the device show up, you might have to rely on Ethernet throughout the installation.
In my case, I got the device to show up the first time I unloaded and reloaded the modules, but failed to get this result again in ~6 attempts afterwards.
I restorted to Ethernet throughout the installation.


## Wireless

Once booted in the new installation, install the proper driver for the wireless chip.
The wireless chip should be the same between the 13-inch and 15-inch models, if it has not been [upgraded](https://www.intriguingindustries.co.uk/product/12-6-adapter/).
The stock chips for both models should be `BCM4331`. You can double check with the following command:

    $ lspci -vnn -d 14e4:

If the wireless chip model number indeed is `BCM4331`, it should work simply by installing `broadcom-wl` or `broadcom-wl-dkms`:

    sudo pacman -S broadcom-wl-dkms

If your Wireless chip model name is *NOT* listed as `BCM4331`, `broadcom-wl`/`broadcom-wl-dkms` *should* still work. If not, you can try one of the [different dirvers](https://wiki.archlinux.org/title/Broadcom_wireless#Driver_selection).


### broadcom-wl-dkms

TODO: Setup instructions


## Keyboard

The keyboard especially can have a few issues, even moreso if you use a somewhat niche layout.
The Arch wiki page for Apple Keyboards can be found [here](https://wiki.archlinux.org/title/Apple_Keyboard).


### Keyboard layout fix (graphical session)

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


### Keyboard layout fix (tty)

However, this is only true for graphical sessions, such as a `hyprland` session. A proper keymap file still need to exist to load a similar layout in a tty.
Conveniently it is possible to compile an a keymap based on these XKB values.
To do this the [ckbcomp package](https://aur.archlinux.org/packages/ckbcomp) (AUR) needs to be installed with your AUR helper of choice ([yay](https://github.com/Jguer/yay) in my case):

    $ yay -S ckbcomp

After installing, a keymap file can be compiled and packed with `gzip`:

    $ ckbcomp -compact -layout dk -variant mac -option lvl3:ralt_switch | gzip > mac_dk.map.gz

For the newly created `mac_dk.map.gz` keymap file to be easily loadable with `loadkeys`, it should be moved to a relavant folder in `/usr/share/kbd/keymaps/`:

    $ sudo mv mac_dk.map.gz /usr/share/kbd/keymaps/mac/all/mac_dk.map.gz

The newly compiled keymap can be checked for issues by loading the keymap with `loadkeys`:

    $ loadkeys /usr/share/kbd/keymaps/mac/all/mac_dk.map.gz

For the changes to be persistent after a reboot, the `KEYMAP` variable can be changed in `/etc/vconsole.conf`:

    KEYMAP=mac_dk.map.gz

You can now freely reboot your MacBook and load into a tty to see the effects.


### Restoring FN functionality

Many of the function keys such as screen brightness, keyboard backlight, etc. will not work out of the box.
In my case, only the **Mute**, **Lower Volume**, and **Increase Volume** buttons worked out of the box.
If they do not, it might be required to install an audio library, such as `pipewire`:

    $ sudo pacman -S pipewire

For the screen brightness and keyboard backlight, it is required to install `brightnessctl`:

    $ sudo pacman -S brightnessctl

For the **Pause/Play**, **Previous**, and **Next** buttons to work, `playerctl` must be installed:

    $ sudo pacman -S playerctl

With the dependencies installed, it might be required to configure keybinds in the settings of your graphical session.
In my case for `hyprland`, I have the following keybinds set:
    
    # Audio
    bindel = ,XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT\_AUDIO\_SINK@ 5%+
    bindel = ,XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT\_AUDIO\_SINK@ 5%-
    bindel = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT\_AUDIO\_SINK@ toggle
    # Screen brightness
    bindel = ,XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+
    bindel = ,XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-
    # Player buttons
    bindl = , XF86AudioNext, exec, playerctl next
    bindl = , XF86AudioPause, exec, playerctl play-pause
    bindl = , XF86AudioPlay, exec, playerctl play-pause
    bindl = , XF86AudioPrev, exec, playerctl previous
    # Keyboard brightness
    # TODO

Since **Mission Control** (Fn+F3) and **Launchpad** (Fn+F4) are not commonly used features, you can probably rebind them to other functionality like done above.
In my case I have them configured as such:

    # TODO


### Changing `Fn` mode

There's 2 (relevant) `Fn` modes that exists for the [`hid_apple` module](https://wiki.archlinux.org/title/Apple_Keyboard#hid_apple_module_options).
Out of the box, the value is `3` (`auto`) which defaults to mode `1`, which is `Fn` keys being **media keys**, which switch to **function keys** while `Fn` is held down.
The other mode (`2`) reverses this: mainly **function keys**, switchable to **media keys** while `Fn` is held down.
To change this permanently, at the following line in `/etc/modprobe.d/hid_apple.conf`:

    options hid_apple fnmode=2

Make sure to have `modconf` included in the `HOOKS` variable in your **mkinitcpio configuration** (`/etc/mkinitcpio.conf`).
Also remember to regenerate the **initramfs** by running the followng:

    $ sudo mkinicpio -P


# MacBookPro9,1 (15-inch)

TODO: Resources that specifically apply to the MacBookPro9,1 (15-inch) model.


# MacBookPro9,2 (13-inch)

TODO: Resources that specifically apply to the MacBookPro9,2 (13-inch) model.

