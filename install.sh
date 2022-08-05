#!/usr/bin/env arch -x86_64 bash

WINESKIN_TARGET_NAME="Sims4.app"

export wineWrappers="${PWD}/${WINESKIN_TARGET_NAME}/Wineskin.app/Contents/Resources"
export winePATH="${PWD}/${WINESKIN_TARGET_NAME}/Contents/SharedSupport/wine/bin"
export PATH="${wineWrappers}:${winePATH}:${PATH}"
export WINEDEBUG="-all"

# Workaround SIP DYLD_stripping
# See https://support.apple.com/en-us/HT204899
# See https://github.com/Winetricks/winetricks/pull/1820
export WINETRICKS_FALLBACK_LIBRARY_PATH="${PWD}/${WINESKIN_TARGET_NAME}/Contents/Frameworks"
export DYLD_FALLBACK_LIBRARY_PATH="${WINETRICKS_FALLBACK_LIBRARY_PATH}"

export WINEPREFIX="${PWD}/${WINESKIN_TARGET_NAME}/"

echo "==> Removing Gatekeeper quarantine from downloaded wrapper. You may need to enter your password."
sudo xattr -drs com.apple.quarantine "${PWD}/${WINESKIN_TARGET_NAME}" &>/dev/null

function install_deps() {
    echo "===> Installing dotnet48"
	winetricks -q -f dotnet48 &>/dev/null
    echo "===> Installing vcrun2015"
	winetricks -q vcrun2015 &>/dev/null
    echo "===> Installing vcrun2012"
	winetricks -q vcrun2012 &>/dev/null
    echo "===> Installing vcrun2010"
	winetricks -q vcrun2010 &>/dev/null
    echo "===> Installing Windows Core Fonts"
  winetricks -q corefonts &>/dev/null

}



echo "==> Verifying winetricks is installed within wrapper."
${PWD}/${WINESKIN_TARGET_NAME}/Wineskin.app/Contents/Resources/winetricks list-installed &>/dev/null
isWorkingEnv=$?

if [ "$isWorkingEnv" != "0" ]; then
    echo "==> Could not find winetricks, downloading."
    curl -o ${PWD}/${WINESKIN_TARGET_NAME}/Wineskin.app/Contents/Resources/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks &>/dev/null
    chmod +x ${PWD}/${WINESKIN_TARGET_NAME}/Wineskin.app/Contents/Resources/winetricks &>/dev/null
fi

echo "==> Installing proprietary dependencies..."
install_deps
echo "==> Finished installing dependencies."

echo "==> Launching Origin installer Please complete the setup manually."
curl -o  ${PWD}/${WINESKIN_TARGET_NAME}/drive_c/OriginThinSetup.exe https://origin-a.akamaihd.net/Origin-Client-Download/origin/live/OriginThinSetup.exe &>/dev/null
wine ${PWD}/${WINESKIN_TARGET_NAME}/drive_c/OriginThinSetup.exe

echo "==> Moving Sims4.app to your Applications folder"
cp -r -P ${PWD}/Sims4.app/ /Applications/
