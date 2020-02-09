# Display Android Script
*Mirror and control your android phone from your mac.*
---

**Mac Steps:**
1. Run the install script `./Install-Requirements.sh` in your terminal. If you already have Homebrew installed on your machine, Do NOT run the install-requirements script. Run `brew install scrcpy` and `brew install android-platform-tools` to install the dependencies. You can check if you have Homebrew installed by typing `brew --version` into the terminal. If you get a version back, you have it installed.
2. Run `./show-phone.sh --setup` and follow the setup process for up to 3 phones.
3. Run `./show-phone.sh --wifi` for wireless mirroring or `./show-phone.sh --usb` for wired mirroring.
4. Enjoy 🤙️

**Windows Steps**
`n/a` for now...
---

*Usage: `./show-phone.sh [options]`*

**Plug in your Android device and run the application with the --setup flag.**
**After setup, you may run the application with the --wifi flag to mirror your device on your computer.**

**Keyboard and mouse supported. Check scrcpy documentation for keyboard shortcuts and additional flags.**

`--setup, -s`
        Initial setup for wireless casting to computer.

`--wifi, -w`
        Mirror an Android device that is already set up. (can also provide 1-3 as additional parameter for device index. *ex. `./show-phone.sh -w 1`*)

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

If you DON'T want the virtual keyboard to show on your screen, Download "Null Input Method" from here: https://play.google.com/store/apps/details?id=com.apedroid.hwkeyboardhelperfree&hl=en_US . My script will switch your phone's keyboard to "Null Input Method" if you have it installed and you have the "Use Null keyboard" setting set to `yes`. You can do this by running `./show-phone.sh --settings`.

**Tools**

The script uses SCRCPY https://github.com/Genymobile/scrcpy and Android-Platform-Tools https://developer.android.com/studio/releases/platform-tools for the heavy lifting. My script just makes it easier to use those tools to cast your phone to your computer.
