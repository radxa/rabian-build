#!/bin/sh -e

BOARD=$1
TODAY=$(date +"%y%m%d")

if [ -z ${BOARD} ]; then
	echo "$0 board [local]"
	exit 1
fi

mkdir -p ${TODAY} && cd ${TODAY}


if [ "local" = "$2" ]; then
	LB_URL="git@x1:radxa-lb.git"
	BSP_URL="git@x1:github/rock-bsp.git"

else
	LB_URL="git@git.radxa.com:x1/radxa-lb.git"
	BSP_URL="git@github.com:radxa/rock-bsp.git"
fi

if [ ! -d radxa-lb/.git ]; then
	git clone ${LB_URL}
fi

if [ ! -d rock-bsp/.git ]; then
	git clone ${BSP_URL}
fi

if [ "local" = "$2" ]; then
	cp -vf ../bootstrap_local radxa-lb/${BOARD}/bootstrap
	echo "deb http://172.168.1.3/apt.radxa.us/rabian-stable/ jessie main" > radxa-lb/${BOARD}/archives/apt-radxa-us.list
	cp -vf ../defconfig_local rock-bsp/configs/defconfig
	cp -vf ../${BOARD}_config_local rock-bsp/configs/${BOARD}_config
fi

if [ ! -e radxa-lb/.${BOARD}_lb_done ]; then
	cd radxa-lb && make clean && make $BOARD && touch ./.${BOARD}_lb_done && cd -
fi

IMAGE=$(basename radxa-lb/rabian_${BOARD}_*.ext4)

cp -vf radxa-lb/$IMAGE rock-bsp/rootfs/

echo "BOARD_ROOTFS=${IMAGE}" >> rock-bsp/configs/${BOARD}_config

cd rock-bsp && ./config.sh $BOARD && make && cd -
