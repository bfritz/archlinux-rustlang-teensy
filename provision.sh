#!/bin/sh

pacman -Syy
pacman -S --noconfirm --needed \
  git \
  avr-gcc avr-binutils avr-libc avrdude

su - vagrant -c '/bin/sh /vagrant/zinc.sh'
