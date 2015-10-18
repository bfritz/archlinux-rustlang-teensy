#!/bin/sh

set -e

cd ~
gpg --keyserver pgp.mit.edu --recv-keys 5CB4A9347B3B09DC
curl -s https://aur.archlinux.org/cgit/aur.git/snapshot/rust-nightly-bin.tar.gz \
    | tar xvfz -
cd rust-nightly-bin
# match rust versions in last successful Travis CI version at
# https://travis-ci.org/hackndev/zinc/jobs/85287261
sed -i '
  s/^_date=2015-10-17/_date=2015-10-12/
  s/^pkgver=1.5.0_2015.10.16/pkgver=1.5.0_2015.10.11/
' PKGBUILD
PKGEXT=.pkg.tar makepkg --syncdeps --install --noconfirm


# libpng12 for teensyduino
cd ~
curl -s https://aur.archlinux.org/cgit/aur.git/snapshot/libpng12.tar.gz \
    | tar xvfz -
cd libpng12
PKGEXT=.pkg.tar makepkg --syncdeps --install --noconfirm


# teensyduino for k20 (cortex-m4) toolchain
cd ~
curl -s https://aur.archlinux.org/cgit/aur.git/snapshot/teensyduino.tar.gz \
    | tar xvfz -
cd teensyduino
sudo pacman -S icoutils libxft xdotool xorg-server-xvfb --noconfirm
PKGEXT=.pkg.tar makepkg --nodeps
sudo pacman -U teensyduino*.pkg.tar --assume-installed java-runtime=any --noconfirm
# --nodeps and --assume-installed above to avoid pulling down Java


# zinc.rs with blink example for k20 / Teensy
cd ~
git clone --branch=master https://github.com/hackndev/zinc.git hackndev/zinc
cd hackndev/zinc
export PLATFORM=k20
export PATH=$PATH:/usr/share/arduino/hardware/tools/arm/bin

rustc --version
cargo --version

patch -p1 < /vagrant/teensy_led_gpio.patch
./support/build-jenkins.sh

OUT=examples/blink_k20/target/thumbv7em-none-eabi/release/blink
ls -l $OUT
file $OUT

arm-none-eabi-objcopy -Oihex -R .eeprom -R .fuse -R .lock -R .signature $OUT blink.hex
cp -p blink.hex /vagrant/

echo "Install with: ./teensy-loader-cli --mcu=mk20dx256 -w blink.hex"
