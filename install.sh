#!/usr/bin/env arch -x86_64 bash

WINESKIN_TARGET_NAME="Sims4.app"

export WINEPREFIX="${PWD}/${WINESKIN_TARGET_NAME}/Contents/SharedSupport/prefix"
wineskinlauncher(){ ${PWD}/${WINESKIN_TARGET_NAME}/Contents/MacOS/wineskinlauncher "${@}";}
wineboot(){ wineskinlauncher WSS-wineprefixcreate >/dev/null 2>&1;}
winetricks(){ wineskinlauncher WSS-winetricks "${@}";}
override_dll(){ ${PWD}/${WINESKIN_TARGET_NAME}/Wineskin.app/Contents/Resources/wine reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v "${@}" /d native,builtin /f >/dev/null 2>&1;}

echo "==> Removing Gatekeeper quarantine from downloaded wrapper. You may need to enter your password."
sudo xattr -drs com.apple.quarantine "${PWD}/${WINESKIN_TARGET_NAME}" &>/dev/null

echo "==> Downloading winetricks."
curl -o ${PWD}/${WINESKIN_TARGET_NAME}/Wineskin.app/Contents/Resources/winetricks https://raw.githubusercontent.com/The-Wineskin-Project/winetricks/macOS/src/winetricks &>/dev/null
chmod +x ${PWD}/${WINESKIN_TARGET_NAME}/Wineskin.app/Contents/Resources/winetricks &>/dev/null




echo "===> Creating wineprefix"
wineboot

echo "===> Installing Origin"
winetricks -q -f origin

# override_dll function example
#override_dll d3dcompiler_47

echo "==> Moving Sims4.app to your Applications folder"
sudo rsync -l -a -r ${PWD}/${WINESKIN_TARGET_NAME}/ /Applications/Sims4.app
