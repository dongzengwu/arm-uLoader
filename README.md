![Beuth Hochschule für Technik Berlin](http://www.beuth-hochschule.de/fileadmin/templates/css/img/kopf_logo.gif)
arm-uLoader
===========

Project for advanced arm programming.

Code documentation is done via [Doxygen](http://www.stack.nl/~dimitri/doxygen/).

Project documentation is done via [Latex](http://wiki.ubuntuusers.de/LATEX).

---

### How to install the needed Tools in Ubuntu 14.04

##### GNU ARM Embedded Toolchain

`sudo apt-get remove binutils-arm-none-eabi gcc-arm-none-eabi`

`sudo add-apt-repository ppa:terry.guo/gcc-arm-embedded`

`sudo apt-get update`

`sudo apt-get install gcc-arm-none-eabi=4.8.4.2014q3-0trusty11`

##### STLINK

`sudo apt-get install autoconf pkg-config libusb-1.0 git`

`cd ~`

`git clone https://github.com/texane/stlink.git`

##### STM32 Libraries and Example

`cd ~`

`git clone https://github.com/rowol/stm32_discovery_arm_gcc`

##### Weitere Links

[arm gcc toolchain](https://launchpad.net/~terry.guo/+archive/ubuntu/gcc-arm-embedded)

[stlink repository](https://github.com/texane/stlink)

[stm32 Bare Metal Examples and Install instructions](http://www.wolinlabs.com/blog/linux.stm32.discovery.gcc.html)

[Blog about ARM Bare Metal programming in Linux](http://hertaville.com/2013/09/02/stm32f0discovery-part-1-linux/)
