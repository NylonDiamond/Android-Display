# Display Android Script
*Mirror and control your android phone from your computer.*

---

**Mac Steps:**
1. Run the install script `./Install-Requirements.sh` in your terminal.
2. Run `./show-phone.sh --setup` and follow the setup process.
3. Run `./show-phone.sh --wifi` for wireless mirroring or `./show-phone.sh --usb` for wired mirroring.
4. Enjoy 🤙️

---

*Usage: `./show-phone.sh [options]`*

**Plug in your Android device and run the application with the --setup flag.**
**After setup, you may run the application with the --wifi flag to mirror your device on your computer.**

**Keyboard and mouse supported. Check scrcpy documentation for keyboard shortcuts and additional flags.**

`--setup, -s`
        Initial setup for wireless casting to computer.

`--wifi, -w`
        Mirror an Android device that is already set up.

`--usb, -u`
        Mirror an Android device that in plugged in via USB.
 
`--show, -sh`
        Show currently set up devices and their information.
 
`--reset, -r`
        Remove saved phones and start from scratch.

`--settings, -st`
        Setup to use Null keyboard or Keep screen off.

---

**Null keyboard**

If you don't want the keyboard to show on your screen while mirroring, Download "Null Input Method" from here: https://play.google.com/store/apps/details?id=com.apedroid.hwkeyboardhelperfree&hl=en_US . My script will switch your phone's keyboard to "Null Input Method" if you have it installed and you have the "Use Null keyboard" setting set to `yes`. You can do this by running `./show-phone.sh --settings`.