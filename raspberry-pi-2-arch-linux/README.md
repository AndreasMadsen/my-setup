
# Setup arch

Resouces:

- https://wiki.archlinux.org/index.php/Beginners%27_guide
- https://wiki.archlinux.org/index.php/General_recommendations
- https://wiki.archlinux.org/index.php/Raspberry_Pi

## Flash the SD card on Mac

#### 1. Format SD from Mac

Format the SD card to FAT32 from mac, this will make it easier to find.

#### 2. Create a virtual box:
http://www.psychocats.net/ubuntu/virtualbox

#### 3. Setup ssh to the virtual box:
http://stackoverflow.com/questions/5906441/how-to-ssh-to-a-virtualbox-guest-externally-through-a-host

```bash
VBoxManage modifyvm ${vm-name} --natpf1 “ssh,tcp,,3022,,22”
ssh -p 3022 user@127.0.0.1
```

#### 4. Mount SD card
http://www.geekytidbits.com/mount-sd-card-virtualbox-from-mac-osx/

if linux starts failing shutdown and mount SD card from mac to virtual box again.

#### 5. Format SD card from Linux
run "fdisk -l" look for FAT32 and 7.4G
http://archlinuxarm.org/platforms/armv7/broadcom/raspberry-pi-2

don’t extract using bsdtar, do this:
http://archlinuxarm.org/forum/viewtopic.php?f=53&t=7758

```
1. Start fdisk to partition the SD card:
    fdisk /dev/sdX
2. At the fdisk prompt, delete old partitions and create a new one:
    a. Type o. This will clear out any partitions on the drive.
    b. Type p to list partitions. There should be no partitions left.
    c. Type n, then p for primary, 1 for the first partition on the drive, press ENTER to accept the default first sector, then type +100M for the last sector.
    d. Type t, then c to set the first partition to type W95 FAT32 (LBA).
    e. Type n, then p for primary, 2 for the second partition on the drive, and then press ENTER twice to accept the default first and last sector.
    f. Write the partition table and exit by typing w.
3. Create and mount the FAT filesystem:
    mkfs.vfat /dev/sdX1
    mkdir boot
    mount /dev/sdX1 boot
4. Create and mount the ext4 filesystem:
    mkfs.ext4 /dev/sdX2
    mkdir root
    mount /dev/sdX2 root
5. Download and extract the root filesystem (as root, not via sudo):
    cd root
    wget http://archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz
    tar -xzvf ArchLinuxARM-rpi-2-latest.tar.gz
    rm ArchLinuxARM-rpi-2-latest.tar.gz
    sync
6. Move boot files to the first partition:
    cd ..
    mv root/boot/* boot
    sync
7. Unmount the two partitions:
    umount boot root
8. Insert the SD card into the Raspberry Pi, connect ethernet, and apply 5V power.
```

## Login

username: `root`
password: `root`

## setup keybord

https://wiki.archlinux.org/index.php/Keyboard_configuration_in_console

```bash
touch /etc/vconsole.conf
localectl list-keymaps # select a $keymap from this list
localectl set-keymap $keymap
```

## Connect to root using ssh

Edit `/etc/ssh/sshd_config` and set

```
PermitRootLogin yes
```

## setup wifi

#### 1. Configure WiFi SSID and password

Configure /etc/netctl/home manually (using nano), this says how (keep the ‘ qoutes).
https://wiki.archlinux.org/index.php/Netctl

```bash
$ cat /etc/netctl/home
Description='Home WiFI'
Interface=wlan0
Connection=wireless

Security=wpa
IP=dhcp

ESSID='UUID'
# Prepend hexadecimal keys with \"
# If your key starts with ", write it as '""<key>"'
# See also: the section on special quoting rules in netctl.profile(5)
Key='PASSWORD'
# Uncomment this if your ssid is hidden
#Hidden=yes
# Set a priority for automatic profile selection
#Priority=10
```

#### 2. Connect to WiFi

```bash
ip link set wlan0 down
netctl start home
```

#### 3. Setup autoconnection

Setup automation (Basic Method) with:
https://wiki.archlinux.org/index.php/Netctl#Automatic_operation

```bash
netctl enable home
```

## Setup clock

#### 1. Modify timesyncd

https://wiki.archlinux.org/index.php/Time
https://wiki.archlinux.org/index.php/Systemd-timesyncd

modify /etc/systemd/timesyncd.conf
- to http://www.pool.ntp.org/zone/dk
- and arch FallbackNTP

```bash
$ cat /etc/systemd/timesyncd.conf

[Time]
NTP=0.dk.pool.ntp.org 1.dk.pool.ntp.org 2.dk.pool.ntp.org 3.dk.pool.ntp.org
FallbackNTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org
```

Start Systemd-timesyncd daemon

```bash
timedatectl set-ntp true
```

#### 2. Set Timezone

https://wiki.archlinux.org/index.php/Time#Time_zone

```bash
timedatectl set-timezone Europe/Copenhagen
```

#### 3. Check clock

```bash
timedatectl status
```

## Set Hostname

```bash
hostnamectl set-hostname pi-1
```

# Set Locale

https://wiki.archlinux.org/index.php/Locale

edit /etc/locale.gen by uncommenting:

```
en_US.UTF-8 UTF-8
en_DK.UTF-8 UTF-8
```

Now generate locales by executing

```bash
locale-gen
```

`locale -a` should show the currently available locales.

Set the currently selected locale:

```bash
localectl set-locale LANG=en_US.UTF-8
reboot
```

To check settings type `locale`.

## Setup USB drive

* http://askubuntu.com/questions/154180/how-to-mount-a-new-drive-on-startup
* http://www.raspberrypi-spy.co.uk/2014/05/how-to-mount-a-usb-flash-disk-on-the-raspberry-pi/

#### 1. Format USB drive

Use `fdisk -l` to find the disk path (usually `/dev/sda`). Setup partitions:

```
$ fdisk /dev/sda

a. Type o. This will clear out any partitions on the drive.
b. Type p to list partitions. There should be no partitions left.
c. Type n, then p for primary, 1 for the first partition on the drive, press ENTER to accept the default first sector, then type +4G for the last sector.
d. Type t, then 82 to set the first partition to type Linux swap / Solaris.
e. Type n, then p for primary, 2 for the second partition on the drive, and then press ENTER twice to accept the default first and last sector.
f. Write the partition table and exit by typing w.
```

Format disk:

```bash
mkswap /dev/sda1
mkfs.ext4 /dev/sda2
```

Activate swap

```
swapon /dev/sda1
```

#### 2. Setup to mount on boot
https://wiki.archlinux.org/index.php/Fstab

Find the UUIDs by `ls -l /dev/disk/by-uuid/` (e.g. `c0f6c63b-aae7-4dca-b8a6-504e0a325bdf`).

```
$ cat /etc/fstab

# <file system>                            <dir> <type> <options>         <dump> <pass>
/dev/mmcblk0p1                             /boot vfat   defaults,noatime  0      2
/dev/mmcblk0p2                             /     ext4   defaults,noatime  0      1
UUID=c0f6c63b-aae7-4dca-b8a6-504e0a325bdf  /home ext4   defaults          0      2
UUID=1170b246-1ddd-4054-8511-bf48f66f90d4  none  swap   defaults          0      0
```

## Enable Firewall
https://wiki.archlinux.org/index.php/Firewalls
https://wiki.archlinux.org/index.php/Iptables
https://wiki.archlinux.org/index.php/Simple_stateful_firewall

```
$ cat /etc/iptables/iptables.rules

# Generated by iptables-save v1.4.18 on Sun Mar 17 14:21:12 2013
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
:TCP - [0:0]
:UDP - [0:0]
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m conntrack --ctstate INVALID -j DROP
-A INPUT -p icmp -m icmp --icmp-type 8 -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p udp -m conntrack --ctstate NEW -j UDP
-A INPUT -p tcp --tcp-flags FIN,SYN,RST,ACK SYN -m conntrack --ctstate NEW -j TCP
-A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
-A INPUT -p tcp -j REJECT --reject-with tcp-reset
-A INPUT -j REJECT --reject-with icmp-proto-unreachable
-A TCP -p tcp --dport 22 -j ACCEPT
COMMIT
# Completed on Sun Mar 17 14:21:12 2013
```

Append the rules with:

```bash
iptables-restore < /etc/iptables/iptables.rules
```

## Create user
https://wiki.archlinux.org/index.php/Users_and_groups
https://wiki.archlinux.org/index.php/Sudo

```bash
useradd -m -g wheel pi
chfn pi  # Enter Andreas Madsen, Home
passwd pi
```

To allow sudo install it:

```bash
pacman -Syu sudo
```

To make `pi` a sudoer, with `visudo -f /etc/sudoers` uncomment:

```
%wheel ALL=(ALL) ALL
```

## Setup ssh
https://wiki.archlinux.org/index.php/Secure_Shell

add (by uncomment and edit) the following lines to `/etc/ssh/sshd_config`

```
PermitRootLogin no
```

## Setup vim, git, zsh

#### 1. install

```bash
sudo pacman -Syu gvim git zsh
```

#### 2. vim

```bash
curl http://j.mp/spf13-vim3 -L -o - | sh
```

#### 3. git

```bash
git config --global core.editor /usr/bin/vim
git config --global user.name "Andreas Madsen"
git config --global user.email amwebdk@gmail.com
git config --global color.ui auto
```

#### 4. zsh

```bash
curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
chsh -s $(grep /zsh$ /etc/shells | tail -1)
```

## Pacman

enable colors

```
sudo sed -i 's/#Color/Color/' /etc/pacman.conf # Add color to pacman
```

update packages

```bash
sudo pacman -Syu
```

## GUI

#### 1. setup xfce4

* https://archlinuxarm.org/forum/viewtopic.php?f=9&t=7334
* https://wiki.archlinux.org/index.php/Xfce

to install `xfce4`

```bash
sudo pacman -Syu xorg-server xorg-xinit xf86-video-fbdev
sudo pacman -Syu xfce4
```

and set:

```bash
cat ~/.xinitrc
exec startxfce4
```

to start run `xinit`.

#### 2. setup lighdm and greeter

To automatically start on boot, run:

```bash
sudo pacman -Syu lightdm lightdm-gtk-greeter
sudo systemctl enable lightdm.service
```

and set:
```
cat /etc/lightdm/lightdm.conf

[Seat:*]
greeter-session=lightdm-gtk-greeter
```

#### 3. set lighdm background

Just for fun the `lightdm` background can be set to: 

```
cat /etc/lightdm/lightdm-gtk-greeter.conf

[greeter]
background=/usr/share/backgrounds/xfce/xfce-teal.jpg
```

## Audio

_There is a lot of noise, I'm not sure why._

* https://wiki.archlinux.org/index.php/Raspberry_Pi
* https://github.com/phortx/Raspberry-Pi-Setup-Guide
* https://github.com/raspberrypi/firmware/issues/380

```
sudo pacman -Syu alsa-firmware alsa-lib alsa-utils
sudo pacman -Syu xfce4-mixer
```

and add:

```
cat /boot/config.txt
...
dtparam=audio=on
disable_audio_dither=1
```

## Yaourt

Install the AUR package manager

```shell
wget https://aur.archlinux.org/cgit/aur.git/snapshot/package-query.tar.gz
tar -xvzf package-query.tar.gz
cd package-query
makepkg -si
cd ..
wget https://aur.archlinux.org/cgit/aur.git/snapshot/yaourt.tar.gz
tar -xvzf yaourt.tar.gz
cd yaourt
makepkg -si

cd ../
rm -rf package-query/ package-query.tar.gz yaourt/ yaourt.tar.gz
```

## Powerline

#### 1. Install font

```
git clone https://github.com/powerline/fonts.git
cd fonts
sh install.sh
cd ..
rm -rf fonts
```

#### 2. Setup terminal

Select `Source Code Pro for Powerline, Regular, 10pt` in `Edit -> Preferences -> Appearance -> Font`.

Edit `~/.zshrc`

```
cat ~/.zshrc
...
ZSH_THEME="agnoster"
DEFAULT_USER="pi"
```

#### 3. Setup vim

Edit `~/.vimrc` such
* uncomment `let g:airline_powerline_fonts=1`
* prepend `Source\ Code\ Pro\ for\ Powerline\ 10,` to `set guifont` such it is:

```
set guifont=Source\ Code\ Pro\ for\ Powerline\ 10,Andale\ Mono\ Regular\ 12,Menlo\ Regular\ 11,Consolas\ Regular\ 12,Courier\ New\ Regular\ 14
```

## TODO: Customize LED
http://www.midwesternmac.com/blogs/jeff-geerling/controlling-both-pwr-and-act
