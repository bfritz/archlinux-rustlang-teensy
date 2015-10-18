Recipe for Arch Linux x86_64 Vagrant box to build [zinc.rs](http://zinc.rs/) with Rust nightly and blink an LED on a [Teensy 3.1](http://www.pjrc.com/teensy/teensy31.html).  Inspired by [a tweet](https://twitter.com/code0100fun/status/655274382546223105) from [Chase McCarthy](https://twitter.com/code0100fun).

### Prerequisites:

 * [Packer](https://packer.io/), e.g. from [packer-io](https://aur.archlinux.org/packages/packer-io/) or [packer-io-git](https://aur.archlinux.org/packages/packer-io-git/) in AUR on Arch Linux
 * [Vagrant](https://vagrantup.com/), e.g. `sudo pacman -S vagrant`
 * [VirtualBox](https://virtualbox.org/), e.g. `sudo pacman -S virtualbox`

### How I use it:

* Make sure the VirtualBox modules are loaded:
  ```sh
  for m in vboxdrv vboxnetflt vboxnetadp; do
      sudo modprobe $m
  done
  ```

* Build a Vagrant base box named "arch" for Arch Linux using Packer:
  ```sh
  # Clone somewhere with 1-2gb of free disk; will download
  # Arch Linux ISO and build VirtualBox disk image.
  git clone https://github.com/elasticdog/packer-arch.git
  cd packer-arch
  packer-io build -only=virtualbox-iso arch-template.json
  vagrant box add arch packer_arch_virtualbox.box
  ```

* Build a Vagrant virtual machine to compile zinc.rs and the [blink_k20 example](https://github.com/hackndev/zinc/tree/master/examples/blink_k20):
  ```sh
  git clone https://github.com/bfritz/archlinux-rustlang-teensy.git
  cd archlinux-rustlang-teensy
  vagrant up
  ```

  ```
  # after `vagrant up` finish
  ls -l blink.hex
  ```

* Load `blink.hex` onto the Teensy:

  ```sh
  ./teensy-loader-cli --mcu=mk20dx256 -w blink.hex
  # press reset button on Teensy now
  ```
