# maz-raspi-config

A [script](maz-raspi-config.sh?raw=1) to automate the use of [raspi-config](https://www.raspberrypi.com/documentation/computers/configuration.html#raspi-config) to quickly apply a common set of defaults across multiple [Raspberry Pi OS](https://www.raspberrypi.com/software/) deployments.

Specifically - with current defaults - used to quickly reset the UK-based localization options (preset within the OS distribution) to US:

* Locale
* Timezone
* Keyboard
* WLAN Country

Also - with current defaults - sets the GPU Memory Split to the minimum allowed of 16 MB for optimzed used in headless deployments.

## Author

Mark A. Ziesemer

* <https://www.ziesemer.com>
