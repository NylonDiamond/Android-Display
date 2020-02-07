#!/bin/bash
devicenumber1=""
deviceactualname1=""
phoneip1=""
phonekeyboard1=""

devicenumber2=""
deviceactualname2=""
phoneip2=""
phonekeyboard2=""

devicenumber3=""
deviceactualname3=""
phoneip3=""
phonekeyboard3=""

connect() {
        # change to not show on screen keyboard
        null_keyboard="true"
        # keep screen off physical device to save battery
        screen_off="false"
        if [[ $1 == "wifi" ]]; then
                echo "Connecting to $4 by ip : $3..." # todo: disconnect device from usb automatically if trying to run in wifi mode
                adb connect "$3"
                if [[ $null_keyboard == "true" ]]; then
                        # set keyboard to an empty keyboard. List available keyboards > (adb shell ime list -a)
                        # Null Input Method keyboard > https://play.google.com/store/apps/details?id=com.apedroid.hwkeyboardhelperfree&hl=en_US
                        adb -s "$3" shell ime set com.apedroid.hwkeyboardhelperfree/.HWKeyboardHelperIME
                fi

                # additional flags >> --show-touches --turn-screen-off
                portonly="$(echo "$3" | sed 's/.*://')"
                iponly="$(echo "$3" | sed 's/:.*//')"
                if [[ $screen_off == "true" ]]; then
                        scrcpy -s $iponly -p $portonly --turn-screen-off &>/dev/null # mirror and send output to nowhere
                else
                        scrcpy -s $iponly -p $portonly &>/dev/null # mirror and send output to nowhere
                fi
        else
                echo "Connecting to ${4} by USB ..."
                # adb connect "$2"

                if [[ $1 != "usb_unknown" ]]; then
                        if [[ $null_keyboard == "true" ]]; then
                                # set keyboard to an empty keyboard. List available keyboards > (adb shell ime list -a)
                                # Null Input Method keyboard > https://play.google.com/store/apps/details?id=com.apedroid.hwkeyboardhelperfree&hl=en_US
                                adb -s "$2" shell ime set com.apedroid.hwkeyboardhelperfree/.HWKeyboardHelperIME
                        fi
                        portonly="$(echo "$3" | sed 's/.*://')"
                else
                        portonly=$3
                fi
                # additional flags >> --show-touches --turn-screen-off
                if [[ $screen_off == "true" ]]; then
                        scrcpy -s $2 -p $portonly --turn-screen-off &>/dev/null # mirror and send output to nowhere
                else
                        scrcpy -s $2 -p $portonly &>/dev/null # mirror and send output to nowhere
                fi
        fi
        wait # waits for a process to finish
}
ctrl_c() {
        # Stuff to do before disconnecting
        null_keyboard_reset="true"
        # disconnect devices
        if [[ ${1:-"empty"} != "empty" ]]; then
                if [[ $null_keyboard_reset == "true" ]] && [[ ${4:-"empty"} != "empty" ]] && [[ ${5:-"empty"} == "empty" ]]; then
                        # set keyboard back to gBoard keyboard ('adb shell ime list -a'  > shows all available keyboards)
                        # get your current keyboard >  adb shell settings get secure default_input_method
                        adb -s "$1" shell ime set "$4"
                fi
                if [[ ${5:-"empty"} != "empty" ]]; then
                        if [[ $5 == "usb_unknown" ]]; then
                                echo "$2 is now disconnected."
                        else
                                # adb -s "$1" shell ime set "$phonekeyboard1"
                                adb -s "$3" shell ime set "$4"
                                echo "$2 is now disconnected."
                        fi
                else
                        adb disconnect $1
                        # list connected devices
                        # adb devices
                        echo "$2 is now disconnected."
                fi

        fi
}
if [[ $1 == "--wifi" || $1 == "-w" ]]; then
        trap "ctrl_c" EXIT                                                               # info on trap: https://www.linuxjournal.com/content/bash-trap-command
        if [[ -z "$devicenumber1" && -z "$devicenumber2" && -z "$devicenumber3" ]]; then # all empty
                echo "No devices set up (Run >>> ./show-phone.sh --setup)"
                exit 1
        elif [[ -n "$devicenumber1" && -z "$devicenumber2" && -z "$devicenumber3" ]]; then # if 2 and 3 are empty, just choose #1
                trap "ctrl_c $phoneip1 $deviceactualname1 $devicenumber1 $phonekeyboard1" EXIT
                connect "wifi" $devicenumber1 $phoneip1 $deviceactualname1 $phonekeyboard1
        elif [[ ${devicenumber1:-"empty"} != "empty" || ${devicenumber2:-"empty"} != "empty" || ${devicenumber3:-"empty"} != "empty" ]]; then # one of them is not empty
                if [[ ${2:-"empty"} != "empty" ]] && [[ "${2}" -eq "1" || "${2}" -eq "2" || "${2}" -eq "3" ]]; then                           # choose phone index to connect to without prompt
                        devicechoice="$2"
                else
                        echo "Which device do you want to connect to? "
                        echo "1 > $deviceactualname1 : $devicenumber1"
                        echo "2 > $deviceactualname2 : $devicenumber2"
                        echo "3 > $deviceactualname3 : $devicenumber3"
                        # wait for user to choose a device
                        read -p "Select a device: " devicechoice
                fi
                if [ "$devicechoice" == "1" ]; then
                        trap "ctrl_c $phoneip1 $deviceactualname1 $devicenumber1 $phonekeyboard1" EXIT
                        connect "wifi" $devicenumber1 $phoneip1 $deviceactualname1 $phonekeyboard1
                        wait
                elif [ "$devicechoice" == "2" ]; then
                        trap "ctrl_c $phoneip2 $deviceactualname2 $devicenumber2 $phonekeyboard2" EXIT
                        connect "wifi" $devicenumber2 $phoneip2 $deviceactualname2 $phonekeyboard2
                        wait
                elif [ "$devicechoice" == "3" ]; then
                        trap "ctrl_c $phoneip3 $deviceactualname3 $devicenumber3 $phonekeyboard3" EXIT
                        connect "wifi" $devicenumber3 $phoneip3 $deviceactualname3 $phonekeyboard3
                        wait
                else
                        echo "Not a valid choice.. Try again"
                fi
        fi
elif [[ "$1" == "--setup" || "$1" == "-su" ]]; then
        # list available devices
        echo "Available devices:"
        devices="$(adb devices -l | sed '1d')" # sed 1d removes the first useless line
        export IFS=$'\n'
        declare -a devicemap
        i=1
        # save device info in an array
        for word in $devices; do
                devicemap+=("$(echo "$word" | awk '{print $1}')")
                echo "[$i] --> $(echo "$word" | awk '{print $5}' | sed 's/model://g')"
                i=$((i + 1))
        done
        numberofdevices="${#devicemap[@]}"
        # echo "$numberofdevices"
        if [ "$numberofdevices" = 0 ]; then
                echo "No devices detected. Plug in your android device with a usb cable and make sure you're in usb debugging mode."
                exit 1
        fi
        # wait for user to choose the device
        read -p "Choose android device: " choice

        # ask where to store phone details 1,2 or 3?
        echo "Available locations to store phone info: "
        echo "1 > $deviceactualname1    $devicenumber1"
        echo "2 > $deviceactualname2    $devicenumber2"
        echo "3 > $deviceactualname3    $devicenumber3"

        # wait for user input to choose location
        read -p "Select postition to store phone details: " storechoice

        # chosen device id
        device=${devicemap[choice - 1]}
        devicename="$(adb devices -l | grep "$device" | awk '{print $4}' | cut -d: -f2)"
        devicemodel="$(adb devices -l | grep "$device" | awk '{print $5}' | cut -d: -f2)"

        echo "Connecting to $device $devicename $devicemodel..."
        tcpipportend=$(($storechoice + 4))
        currentkeyboard="$(adb shell settings get secure default_input_method | sed 's/\//\\\//g')" # grab current keyboard for ya. Also needed to escape forward shash for sed use later.

        # restart adb in tcpip mode for the device
        $(adb -s $device tcpip 555${tcpipportend})
        # wait for adb to restart
        sleep 5s
        {                                                                                                                 # try
                ip="$(adb -s $device shell ip -f inet addr show wlan0 | grep "inet" | awk '{print $2}' | sed 's/\/.*//')" # grab the ip for ya
        } || {                                                                                                            # catch
                read -p "Enter your phone's IP Address (uaually under about phone): " ip                                  # if failure grabbing ip, do it manually. Under about phone probably.
        }

        # replace first occourence of strings near beginning of script. Creates a temp file, changes the fields and renames to current file name, replacing it. :I
        sed -i '' -e "1s/devicenumber${storechoice}=.*/devicenumber${storechoice}=\"${device}\"/;t" -e "1,/devicenumber${storechoice}.*/s//devicenumber${storechoice}=\"${device}\"/" -e "1s/phonekeyboard${storechoice}=.*/phonekeyboard${storechoice}=\"${currentkeyboard}\"/;t" -e "1,/phonekeyboard${storechoice}.*/s//phonekeyboard${storechoice}=\"${currentkeyboard}\"/" -e "1s/phoneip${storechoice}=.*/phoneip${storechoice}=\"${ip}\"/;t" -e "1,/phoneip${storechoice}=.*/s//phoneip${storechoice}=\"${ip}\:555${tcpipportend}\"/" -e "1s/deviceactualname${storechoice}=.*/deviceactualname${storechoice}=\"${devicemodel}\"/;t" -e "1,/deviceactualname${storechoice}=.*/s//deviceactualname${storechoice}=\"${devicemodel}\"/" "$0"

        echo "Cool, good to go. Run with --wifi or --usb"

elif [[ "$1" == "--usb" || "$1" == "-u" ]]; then
        # list available devices
        echo "Available devices:"
        devices="$(adb devices -l | sed '1d')" # sed 1d removes the first useless line
        export IFS=$'\n'
        declare -a devicemap
        i=1
        # save device info in an array
        for word in $devices; do
                devicemap+=("$(echo "$word" | awk '{print $1}')")
                echo "[$i] --> $(echo "$word" | awk '{print $5}' | sed 's/model://g')"
                i=$((i + 1))
        done
        numberofdevices="${#devicemap[@]}"
        # echo "$numberofdevices"
        if [ "$numberofdevices" = 0 ]; then
                echo "No devices detected. Plug in your android device with a usb cable and make sure you're in usb debugging mode."
                exit 1
        fi
        # wait for user input to choose device
        read -p "Choose an Android device: " choice

        # chosen device id
        devicenumber=${devicemap[choice - 1]}
        devicename="$(adb devices -l | grep $devicenumber | awk '{print $4}' | cut -d: -f2)"
        devicemodel="$(adb devices -l | grep $devicenumber | awk '{print $5}' | cut -d: -f2)"
        defaultkeyboard="$(adb shell settings get secure default_input_method | sed 's/\//\\\//g')"

        if [[ $devicenumber == $devicenumber1 || $devicenumber == $devicenumber2 || $devicenumber == $devicenumber2 ]]; then
                if [[ $devicenumber == $devicenumber1 ]]; then
                        trap "ctrl_c $phoneip1 $deviceactualname1 $devicenumber1 $phonekeyboard1 'usb'" EXIT
                        connect "usb" $devicenumber1 $phoneip1 $deviceactualname1 $phonekeyboard1
                elif [[ $devicenumber == $devicenumber2 ]]; then
                        trap "ctrl_c $phoneip2 $deviceactualname2 $devicenumber2 $phonekeyboard2 'usb'" EXIT
                        connect "usb" $devicenumber2 $phoneip2 $deviceactualname2 $phonekeyboard2
                else
                        trap "ctrl_c $phoneip3 $deviceactualname3 $devicenumber3 $phonekeyboard3 'usb'" EXIT
                        connect "usb" $devicenumber3 $phoneip3 $deviceactualname3 $phonekeyboard3
                fi
        else
                # sed -i '' -e "1s/currentkeyboard=.*/currentkeyboard=\"${defaultkeyboard}\"/;t" -e "1,/currentkeyboard.*/s//currentkeyboard=\"${defaultkeyboard}\"/" "$0"

                trap "ctrl_c $devicenumber $devicemodel $devicenumber $phonekeyboard1 'usb'" EXIT
                connect "usb_unknown" $devicenumber "555${choice}" $devicemodel $phonekeyboard1
        fi
        wait
elif [[ "$1" == "--show" || "$1" == "-sh" ]]; then
        echo "Saved devices: "
        if [[ ${devicenumber1:-"empty"} == "empty" && ${devicenumber2:-"empty"} == "empty" && ${devicenumber3:-"empty"} == "empty" ]]; then
                echo "No devices setup. Run the application with the --setup flag."
        fi
        if [[ ${devicenumber1:-"empty"} != "empty" ]]; then
                echo "1 > $deviceactualname1  -- Device Number: $devicenumber1 -- Ip: $phoneip1"
        else
                echo "1 > empty"
        fi
        if [[ ${devicenumber2:-"empty"} != "empty" ]]; then
                echo "2 > $deviceactualname2  -- Device Number: $devicenumber2 -- Ip: $phoneip2"
        else
                echo "2 > empty"
        fi
        if [[ ${devicenumber3:-"empty"} != "empty" ]]; then
                echo "3 > $deviceactualname3  -- Device Number: $devicenumber3 -- Ip: $phoneip3"
        else
                echo "3 > empty"
        fi
        echo "You can overwrite devices by running --setup again."
elif [[ "$1" == "--reset" || "$1" == "-r" ]]; then
        # wait for user input to choose device
        read -p "Do you want to remove all setup phones? yes - no : " choice
        if [[ "$choice" == "yes" ]]; then
                for i in {1..3}; do
                        sed -i '' -e "1s/devicenumber${i}=.*/devicenumber${i}=\"\"/;t" -e "1,/devicenumber${i}.*/s//devicenumber${i}=\"\"/" -e "1s/phoneip${i}=.*/phoneip${i}=\"\"/;t" -e "1,/phoneip${i}=.*/s//phoneip${i}=\"\"/" -e "1s/deviceactualname${i}=.*/deviceactualname${i}=\"\"/;t" -e "1,/deviceactualname${i}=.*/s//deviceactualname${i}=\"\"/" -e "1s/phonekeyboard${i}=.*/phonekeyboard${i}=\"\"/;t" -e "1,/phonekeyboard${i}.*/s//phonekeyboard${i}=\"\"/" "$0"
                done
        else
                echo "Nothing reset"
        fi
elif [[ "$1" == "--settings" || "$1" == "-st" ]]; then
        # wait for user input to choose device
        read -p "Do you want to use the Null keyboard? yes - no : " choice1
        if [[ "$choice1" != "yes" ]] && [[ "$choice1" != "no" ]]; then
                echo "only -yes- or -no- are accepted answers... Try again."
                exit 0
        else
                if [[ "$choice1" == "yes" ]]; then
                        sed -i '' -e "1s/null_keyboard$=.*/null_keyboard=\"true\"/;t" -e "1,/null_keyboard.*/s//null_keyboard=\"true\"/" "$0"
                        sed -i '' -e "1s/null_keyboard_reset$=.*/null_keyboard_reset=\"true\"/;t" -e "1,/null_keyboard_reset.*/s//null_keyboard_reset=\"true\"/" "$0"
                else
                        sed -i '' -e "1s/null_keyboard$=.*/null_keyboard=\"false\"/;t" -e "1,/null_keyboard.*/s//null_keyboard=\"false\"/" "$0"
                        sed -i '' -e "1s/null_keyboard_reset$=.*/null_keyboard_reset=\"false\"/;t" -e "1,/null_keyboard_reset.*/s//null_keyboard_reset=\"false\"/" "$0"
                fi
        fi
        read -p "Do you want to keep the screen off? yes - no : " choice2
        if [[ "$choice2" != "yes" ]] && [[ "$choice2" != "no" ]]; then
                echo "only -yes- or -no- are accepted answers... Try again."
                exit 0
        else
                if [[ "$choice2" == "yes" ]]; then
                        sed -i '' -e "1s/screen_off$=.*/screen_off=\"true\"/;t" -e "1,/screen_off.*/s//screen_off=\"true\"/" "$0"
                else
                        sed -i '' -e "1s/screen_off$=.*/screen_off=\"false\"/;t" -e "1,/screen_off.*/s//screen_off=\"false\"/" "$0"
                fi
        fi
        echo "Settings updated!"

elif [[ -z "$1" || "$1" == "--help" || "$1" == "-h" ]]; then
        echo ""
        echo "          Usage: ./show-phone.sh [options]"
        echo ""
        echo "           Plug in your Android device and run the application with the --setup flag.
                After setup, you may run the application with the --wifi flag to mirror your device on your computer.
                Keyboard and mouse supported. Check scrcpy documentation for keyboard shortcuts and additional flags."
        echo ""
        echo "        --setup, -s"
        echo "                Initial setup for wireless casting to computer."
        echo "        "
        echo "        --wifi, -w"
        echo "                Mirror an Android device that is already set up."
        echo "        "
        echo "        --usb, -u"
        echo "                Mirror an Android device that in plugged in via USB."
        echo "         "
        echo "        --show, -sh"
        echo "                Show currently set up devices and their information."
        echo "         "
        echo "        --reset, -r"
        echo "                Remove saved phones and start from scratch."
        echo "         "
        echo "        --settings, -st"
        echo "                Setup to use Null keyboard or Keep screen off."
        exit 0
else
        echo "Flag '$1' is not supported!"
fi
