#!/bin/sh

# Requirements Script for OSX
# To execute: save and `chmod +x ./Install-Requirements.sh` then `./Install-Requirements.sh`

echo "Installing brew..."
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo "Installing brew cask..."
brew tap caskroom/cask

echo "Installing scrcpy"
brew install scrcpy

echo "Installing android tools"
brew cask install android-platform-tools

echo "---   Done :D   ---"