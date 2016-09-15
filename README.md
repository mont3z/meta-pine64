## DEPENDENCIES ##

  This layer depends on:

  **poky** 
  URI: git://git.yoctoproject.org/poky.git 
  branch: krogoth 
  revision: HEAD 

  **meta-openembedded (meta-oe)** 
  URI: git://git.openembedded.org/meta-openembedded 
  subdirectory: meta-oe 
  branch: krogoth 
  revision: HEAD 

  **meta-linaro** 
  URI: https://git.linaro.org/openembedded/meta-linaro.git 
  subdirectory: meta-linaro
  branch: krogoth 
  revision: HEAD 


## INSTALLATION ##

  For the following instructions we assume you are on a Linux Ubuntu or Debian distribution compatible with Yocto Krogoth.
  However, most of the instructions should also be valid for other Linux systems.

  Install required packages for Yocto:

  ```shell
    sudo apt-get install gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat libsdl1.2-dev xterm
  ```

  Download the required sources to some folder in your home directory.
  For these instructions, we use the folder ~/yocto:

  ```shell
    mkdir ~/yocto && cd ~/yocto
    git clone -b krogoth git://git.yoctoproject.org/poky.git
    git clone -b krogoth git://git.openembedded.org/meta-openembedded
    git clone https://git.linaro.org/openembedded/meta-linaro.git
    git clone https://github.com/mont3z/meta-pine64.git

  ```

  Download and untar linaro gnueabihf toolchain which will be used for compiling u-boot:
  (Note: this toolchain is for 64-bits host machines, if your PC is not 64 bits you need to compile a 32 bits linaro toolchain.)

  ```shell
    mkdir ~/linaro-gnueabihf && cd ~/linaro-gnueabihf
    wget https://releases.linaro.org/components/toolchain/binaries/latest-5/arm-linux-gnueabihf/gcc-linaro-5.3.1-2016.05-x86_64_arm-linux-gnueabihf.tar.xz
    tar xvf gcc-linaro-5.3.1-2016.05-x86_64_arm-linux-gnueabihf.tar.xz --strip 1
  ```

  To initialize the build environment of Yocto, execute:

  ```shell
    cd ~/yocto/poky
    . oe-init-build-env
  ```

  The script oe-init-build-env creates an initial build folder at ~/yocto/poky/build and corresponding build configuration files at ~/yocto/poky/build/conf.

  The file ~/yocto/poky/build/conf/bblayers.conf defines the location of Yocto meta layers.
  Edit this file and add the absolute paths to the layers needed by meta-pine64 to the variable BBLAYERS. For example, for a user "ME" the
  absolute paths to these meta layers would be:

  ```shell
    BBLAYERS ?= " \
      /home/ME/yocto/poky/meta \
      /home/ME/yocto/poky/meta-poky \
      /home/ME/yocto/poky/meta-yocto-bsp \
      /home/ME/yocto/meta-openembedded/meta-networking \
      /home/ME/yocto/meta-openembedded/meta-oe \
      /home/ME/yocto/meta-openembedded/meta-python \
      /home/ME/yocto/meta-linaro/meta-linaro \
      /home/ME/yocto/meta-linaro/meta-linaro-toolchain \
      /home/ME/yocto/meta-linaro/meta-ilp32 \
      /home/ME/yocto/meta-pine64 \
    "
  ```

  The variable MACHINE of local.conf defines the target hardware for which we will cross-compile.
  Make sure it is set to

  ```shell
    MACHINE ?= "pine64"
  ```

  Additionally, add the following line to your local.conf to opt for linaro toolchain:

  ```shell
    GCCVERSION = "linaro-5.3"
    SDKGCCVERSION = "linaro-5.3"
    # Substitute ME by your username or whatever path you unpacked linaro gnu eabihf
    LINARO_EABIHF_PATH = "/home/ME/linaro-gnueabihf"
  ```

## USAGE ##

  To initialize the build environment, execute:

  ```shell
    cd ~/yocto/poky
    . oe-init-build-env
  ```

  Your configuration setup at ~/yocto/poky/build/conf will be preserved.

  To create a minimal system, in your build folder ~/yocto/poky/build execute the following command. This image only has a
  login interface in UART. You'll need a RS-232 to USB converter to see it. Login with the user "root" (no password).

  ```shell
    bitbake core-image-minimal
  ```

  To create a yocto sato image, in your build folder ~/yocto/poky/build execute the following command. Image with Sato, a mobile 
  environment and visual style for mobile devices. It uses pine64 HDMI output and supports X11 with a Sato theme, Pimlico applications, 
  and contains terminal, editor, and file manager. 

  ```shell
    bitbake core-image-sato
  ```

## BURNING IMAGE TO SDCARD ##

  Under Linux, insert a USB flash drive.  Assuming the USB flash drive takes device /dev/sdf, use dd to copy the live image to it. 
  For example:

  WARNING: dd can destroy your HDD data if not used with the proper device path.

  ```shell
    cd ~/yocto/poky/build/tmp/deploy/images/pine64/
    # for image minimal
    sudo dd if=core-image-minimal-pine64.pine64-sdimg of=/dev/sdf
    # for image sato
    sudo dd if=core-image-sato-pine64.pine64-sdimg of=/dev/sdf
    sync
  ```

### Notes ###
  This README file was adapted from:
    * https://github.com/bmwcarit/dpc/blob/master/README.md
    * https://wiki.yoctoproject.org/wiki/Web_Application_for_Interactive_Kiosk_Devices

