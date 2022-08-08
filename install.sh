#!/usr/bin/env arch -x86_64 bash

TARGET_NAME="Sims4.app"

sudo rsync -l -a -r ${PWD}/TEMPLATE.app/ ${PWD}/${TARGET_NAME}/

export WINEPREFIX="${PWD}/${TARGET_NAME}/Contents/SharedSupport/prefix"
wineskinlauncher(){ ${PWD}/${TARGET_NAME}/Contents/MacOS/wineskinlauncher "${@}";}
wineboot(){ wineskinlauncher WSS-wineprefixcreate >/dev/null 2>&1;}
winetricks(){ wineskinlauncher WSS-winetricks "${@}";}
override_dll(){ ${PWD}/${TARGET_NAME}/Wineskin.app/Contents/Resources/wine reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v "${@}" /d native,builtin /f >/dev/null 2>&1;}

echo "==> Removing Gatekeeper quarantine from downloaded wrapper. You may need to enter your password."
sudo xattr -drs com.apple.quarantine "${PWD}/${TARGET_NAME}" &>/dev/null

echo "==> Downloading winetricks."
curl -o ${PWD}/${TARGET_NAME}/Wineskin.app/Contents/Resources/winetricks https://raw.githubusercontent.com/The-Wineskin-Project/winetricks/macOS/src/winetricks &>/dev/null
chmod +x ${PWD}/${TARGET_NAME}/Wineskin.app/Contents/Resources/winetricks &>/dev/null




# Failsafe as git doesn't remove even empty directories
rm -rf ${WINEPREFIX} &>/dev/null

echo "===> Creating wineprefix"
wineboot

while true; do
  read -p "===> Do you own Sims4 through Steam or Origin? Please Type the Origin or Steam and hit Enter: " -r platform
  case $platform in
    Origin | origin ) platform=origin; break;;
    Steam | steam ) platform=steam; break;;
    * ) printf "Invalid option.\n";;
  esac
done

if [ $platform == origin ]; then
  echo "===> Installing Origin"
  winetricks -q -f origin
  cp -f ${PWD}/configs/Origin.plist ${PWD}/${TARGET_NAME}/Contents/Info.plist
elif [ $platform == steam ]; then
  echo "===> Installing Steam"
  winetricks -q -f origin steam
  cp -f ${PWD}/configs/Steam.plist ${PWD}/${TARGET_NAME}/Contents/Info.plist
fi



echo "==> Moving Sims4.app to your Applications folder"
sudo rsync -l -a -r ${PWD}/${TARGET_NAME}/ /Applications/${TARGET_NAME}
rm -rf ${TARGET_NAME}
