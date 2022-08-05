#!/usr/bin/env arch -x86_64 bash

WINESKIN_TARGET_NAME="Sims4.app"

wineskinlauncher(){ ${PWD}/${WINESKIN_TARGET_NAME}/Contents/MacOS/wineskinlauncher "${@}";}
winetricks(){ wineskinlauncher WSS-winetricks "${@}";}

echo "==> Removing Gatekeeper quarantine from downloaded wrapper. You may need to enter your password."
sudo xattr -drs com.apple.quarantine "${PWD}/${WINESKIN_TARGET_NAME}" &>/dev/null

echo "==> Verifying winetricks is installed within wrapper."
${PWD}/${WINESKIN_TARGET_NAME}/Wineskin.app/Contents/Resources/winetricks list-installed &>/dev/null
isWorkingEnv=$?

if [ "$isWorkingEnv" != "0" ]; then
    echo "==> Could not find winetricks, downloading."
    curl -o ${PWD}/${WINESKIN_TARGET_NAME}/Wineskin.app/Contents/Resources/winetricks https://raw.githubusercontent.com/The-Wineskin-Project/winetricks/macOS/src/winetricks &>/dev/null
    chmod +x ${PWD}/${WINESKIN_TARGET_NAME}/Wineskin.app/Contents/Resources/winetricks &>/dev/null
fi




echo "===> Installing Origin"
winetricks -q -f origin

echo "==> Moving Sims4.app to your Applications folder"
sudo rsync -l -a -r ${PWD}/${WINESKIN_TARGET_NAME}/ /Applications/Sims4.app
