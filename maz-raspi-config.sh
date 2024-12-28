#!/usr/bin/env bash

# Mark A. Ziesemer, 2022-02-12, 2024-12-28

set -euo pipefail

if [ "${1:-}" == "--os-version" ]; then
	. /etc/os-release
	echo "OS_ID=$ID"
	echo "OS_VERSION_ID=$VERSION_ID"
	exit
fi

_scriptUser='root'

if [ "${LOGNAME:-$USER}" != "${_scriptUser}" ]; then
	echo "Switching to user: ${_scriptUser}..."
	echo
	exec sudo -u "${_scriptUser}" "$0" "$@"
fi

_gpuMem='16'
_locale='en_US.UTF-8'
_timezone='America/Chicago'
_kxbModel='pc104'
_kxbLayout='us'
_wlanCountry='US'

eval $("$0" --os-version)

# 3. Interface Options

# 3I1. SSH

# Skip for now.

# 4. Performance Options

# 4P2. GPU Memory

if (( $OS_VERSION_ID < 12 )); then
	_gpuMemCur=$(raspi-config nonint get_config_var gpu_mem /boot/config.txt)
	echo "Current GPU Memory Split: $_gpuMemCur"
	if [ "$_gpuMemCur" != "$_gpuMem" ]; then
		echo 'Updating GPU Memory Split...'
		raspi-config nonint do_memory_split "$_gpuMem"
		_gpuMemCur=$(raspi-config nonint get_config_var gpu_mem /boot/config.txt)
		echo "Updated GPU Memory Split: $_gpuMemCur"
	else
		echo 'Not updating GPU Memory Split.'
	fi
else
	echo 'Raspbian / Debian bookworm or above; skipping raspi-config do_memory_split.'
fi
echo

# 5. Localization Options

# 5L1. Locale

echo 'Current Locale:'
locale
if [ "$LANG" != "$_locale" ]; then
	echo 'Updating Locale...'
	raspi-config nonint do_change_locale "$_locale"
	echo 'Reboot to see Locale changes.'
else
	echo 'Not updating locale.'
fi
echo

# 5L2. Timezone

_timezoneCur=$(</etc/timezone)
echo "Current Timezone: $_timezoneCur"
if [ "$_timezoneCur" != "$_timezone" ]; then
	echo 'Updating Timezone...'
	LC_ALL="$_locale" raspi-config nonint do_change_timezone "$_timezone"
	echo "Updated Timezone: $(</etc/timezone)"
else
	echo 'Not updating Timezone.'
fi
echo

# 5L3. Keyboard
echo 'Current Keyboard:'
cat /etc/default/keyboard

if [ "$(sed /etc/default/keyboard -ne 's/^XKBMODEL="\(.*\)"$/\1/p')" != "$_kxbModel" \
		-o "$(sed /etc/default/keyboard -ne 's/^XKBLAYOUT="\(.*\)"$/\1/p')" != "$_kxbLayout" ]; then
	echo 'Updating Keyboard...'
	sed -i /etc/default/keyboard -e "s/^XKBMODEL.*/XKBMODEL=\"$_kxbModel\"/"
	LC_ALL="$_locale" raspi-config nonint do_configure_keyboard "$_kxbLayout"

	echo 'Updated Keyboard:'
	cat /etc/default/keyboard
else
	echo 'Not updating Keyboard.'
fi
echo

# 5L4. WLAN Country

_wlanCountryCur=$(raspi-config nonint get_wifi_country || echo '')
echo "Current WLAN Country: $_wlanCountryCur"
if [ "$_wlanCountryCur" != "$_wlanCountry" ]; then
	echo 'Updating WLAN Country...'
	raspi-config nonint do_wifi_country "$_wlanCountry"
	echo "Updated WLAN Country: $(raspi-config nonint get_wifi_country)"
else
	echo 'Not updating WLAN Country.'
fi
echo
