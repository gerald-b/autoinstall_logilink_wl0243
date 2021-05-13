#!/bin/bash -x

read -n1 -r -p "Press any key to continue..." key

NSTATE=DOWN

if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; then
  NSTATE=UP
fi
# NSTATE=DOWN

cd ~
# read -n1 -r -p "Press any key to continue..." key

# Cleanup
mkdir -p ~/rtl88x2bu
touch ~/rtl88x2bu/dkms.conf
sudo modprobe -r 88x2bu
cd rtl88x2bu
VER=$(sed -n 's/\PACKAGE_VERSION="\(.*\)"/\1/p' dkms.conf)
cd ..
if [ ${NSTATE} == "UP" ]; then
  rm -rf ~/rtl88x2bu
fi

if [ "${VER}" == "" ]; then
	if [ "$(dkms status rtl88x2bu)" -eq "1" ]; then
		VER=$(dkms status rtl88x2bu | awk -F',' '{print $2}' | xargs)
		sudo dkms uninstall -m rtl88x2bu -v ${VER}
	fi
else
	sudo dkms uninstall -m rtl88x2bu -v ${VER}
	sudo dkms remove -m rtl88x2bu -v ${VER} --all
fi
rm -rf /usr/src/rtl88x2bu-${VER}
# read -n1 -r -p "Press any key to continue..." key

# rebuild
cd ~
if [ ${NSTATE} == "UP" ]; then
  git clone https://github.com/cilynx/rtl88x2bu
fi
cd ~/rtl88x2bu
VER=$(sed -n 's/\PACKAGE_VERSION="\(.*\)"/\1/p' dkms.conf)
sudo rsync -rvhP ./ /usr/src/rtl88x2bu-${VER}
sudo dkms add -m rtl88x2bu -v ${VER}
sudo dkms build -m rtl88x2bu -v ${VER}
sudo dkms install -m rtl88x2bu -v ${VER}
sudo modprobe 88x2bu

read -n1 -r -p "Press any key to continue..." key
