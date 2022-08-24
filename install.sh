#!/usr/bin/env arch -x86_64 bash

TARGET_NAME="Sims4.app"
WRAPPER_VERSION=2.9.1.1
ENGINE_VERSION=21.2.0

clear

echo "#########################################################################"
echo "################################ ${TARGET_NAME} ##############################"
echo "#########################################################################"
echo ""
echo "===> Downloading Wrapper Template"
curl -LJO --progress-bar https://github.com/The-Wineskin-Project/Wrapper/releases/download/${WRAPPER_VERSION}/Wineskin-${WRAPPER_VERSION}.app.tar.xz
mkdir -p ${PWD}/${TARGET_NAME}
tar -xf Wineskin-${WRAPPER_VERSION}.app.tar.xz --strip-components=1 -C ${PWD}/${TARGET_NAME}; rm ${PWD}/Wineskin-${WRAPPER_VERSION}.app.tar.xz
echo ""
echo "===> Downloading Engine"
curl -LJO --progress-bar https://github.com/The-Wineskin-Project/Engines/releases/download/v1.0/WS11WineCX64Bit${ENGINE_VERSION}.tar.xz
mkdir -p ${PWD}/${TARGET_NAME}/Contents/SharedSupport/wine
tar -xf WS11WineCX64Bit${ENGINE_VERSION}.tar.xz --strip-components=1 -C ${PWD}/${TARGET_NAME}/Contents/SharedSupport/wine; rm ${PWD}/WS11WineCX64Bit${ENGINE_VERSION}.tar.xz

# Change Winesin.icns to Sims4 logo
cp -f ${PWD}/configs/Sims4.icns ${PWD}/${TARGET_NAME}/Contents/Resources/Wineskin.icns
touch ${PWD}/${TARGET_NAME}

export WINEPREFIX="${PWD}/${TARGET_NAME}/Contents/SharedSupport/prefix"
wineskinlauncher(){ ${PWD}/${TARGET_NAME}/Contents/MacOS/wineskinlauncher "${@}";}
wineboot(){ wineskinlauncher WSS-wineprefixcreate >/dev/null 2>&1;}
winetricks(){ wineskinlauncher WSS-winetricks "${@}";}
override_dll(){ ${PWD}/${TARGET_NAME}/Wineskin.app/Contents/Resources/wine reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v "${@}" /d native,builtin /f >/dev/null 2>&1;}

echo ""
echo "==> Downloading winetricks."
curl --progress-bar -o ${PWD}/${TARGET_NAME}/Wineskin.app/Contents/Resources/winetricks https://raw.githubusercontent.com/The-Wineskin-Project/winetricks/macOS/src/winetricks
chmod +x ${PWD}/${TARGET_NAME}/Wineskin.app/Contents/Resources/winetricks &>/dev/null




echo ""
echo "===> Creating wineprefix"
wineboot

echo ""
echo "===> Do you own The Sims 4 through Steam or Origin?"
while true; do
  read -p "Please Type Origin or Steam and hit Enter: " -r platform
  case $platform in
    Origin | origin ) platform=origin; break;;
    Steam | steam ) platform=steam; break;;
    * ) printf "Invalid option.\n";;
  esac
done

echo ""
if [ $platform == origin ]; then
  echo "===> Installing Origin, this may take a while."
  winetricks -q -f origin
  cp -f ${PWD}/configs/Origin.plist ${PWD}/${TARGET_NAME}/Contents/Info.plist
elif [ $platform == steam ]; then
  echo "===> Installing Steam, this may take a while."
  winetricks -q -f steam
  cp -f ${PWD}/configs/Steam.plist ${PWD}/${TARGET_NAME}/Contents/Info.plist
fi

override_dll d3d9

echo ""
echo "===> Moving Sims4.app to your Applications folder"
mkdir -p $HOME/Applications
rsync -l -a -r ${PWD}/${TARGET_NAME}/ $HOME/Applications/${TARGET_NAME}
rm -rf ${TARGET_NAME}

echo ""
echo "===> launching Sims4.app"
open -a $HOME/Applications/Sims4.app
