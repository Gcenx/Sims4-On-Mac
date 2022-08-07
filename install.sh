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




# Failsafe as git doesn't remove even empty directories
# rm -rf ${WINEPREFIX} &>/dev/null

echo "===> Creating wineprefix"
# wineboot

while true; do
  read -p "===> Do you own Sims4 through Steam or Origin? Please Type the Origin or Steam and hit Enter: " -r platform
  case $platform in
    Origin | origin ) platform=origin; break;;
    Steam | steam ) platform=steam; break;;
    * ) printf "Invalid option.\n";;
  esac
done

if [ $platform == origin ]
  then
    echo "===> Installing Origin"
    winetricks -q -f origin
    cp ./configs/Origin.plist ./Sims4.app/Contents/Info.plist
  elif [ $platform == steam ]
  then
    echo "===> Installing Steam"
    winetricks -q steam
    cp ./configs/Steam.plist ./Sims4.app/Contents/Info.plist
fi



echo "==> Moving Sims4.app to your Applications folder"
sudo rsync -l -a -r ${PWD}/${WINESKIN_TARGET_NAME}/ /Applications/Sims4.app
