# OpenBSD Autoinstall

This script mounts USB stick, extracts `bsd.rd` filesystem 
and patches it with `auto_install.conf`.

I use it to patch `installXX.img` when updating system
on my laptop. It works for me, but you probably want
to edit few things.

## Installation

Drop the files into `/root`

## Usage

1. Obtain USB stick
2. Download installXX.img and write it, as prescribed in the [FAQ](https://www.openbsd.org/faq/faq4.html).
3. Tune `install.resp`
3. By default `Makefile` assumes USB stick to be `/dev/sd1` - alter if necessary
4. `make site` - create site file from files listed in `site.index`;
   Copy that file to USB stick, alongside other file sets.
5. `make patch` - patches `bsd.rd` with autoinstall file
6. Boot from USB stick

## Limitations

`siteXX` file must be copied by hand.
