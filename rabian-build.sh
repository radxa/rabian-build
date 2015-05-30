#!/bin/sh -e

BOARD=$1
OUT=$2

TODAY=$(date +"%y%m%d")

LB_URL="https://github.com/radxa/radxa-lb.git"
BSP_URL="https://github.com/radxa/rock-bsp.git"

if [ -z ${BOARD} ]; then
	echo "$0 board [output]"
	exit 1
fi

if [ ! -z ${OUT} ]; then
	mkdir -p ${OUT}/${BOARD}/${TODAY}
fi

mkdir -p ${TODAY} && cd ${TODAY}

if [ ! -d radxa-lb/.git ]; then
	git clone ${LB_URL}
fi

if [ ! -d rock-bsp/.git ]; then
	git clone ${BSP_URL}
fi

if [ -e ../.local ]; then
	cp -vf ../bootstrap_local radxa-lb/${BOARD}/bootstrap
	cp -vf ../apt-radxa-us.list.local radxa-lb/${BOARD}/archives/apt-radxa-us.list
	cp -vf ../defconfig_local rock-bsp/configs/defconfig
	cp -vf ../${BOARD}_config_local rock-bsp/configs/${BOARD}_config
fi

if [ ! -e radxa-lb/.${BOARD}_lb_done ]; then
	cd radxa-lb && make clean && make $BOARD && touch ./.${BOARD}_lb_done && cd -
fi

IMAGE=$(basename radxa-lb/rabian_${BOARD}_*.ext4)

cp -vf radxa-lb/$IMAGE rock-bsp/rootfs/

echo "BOARD_ROOTFS=${IMAGE}" >> rock-bsp/configs/${BOARD}_config

cd rock-bsp && ./config.sh $BOARD && make && mv boards/${BOARD}/rockdev ${OUT}/${BOARD}/${TODAY}/ && cd -

IMAGE_NAME="`basename ${OUT}/${BOARD}/${TODAY}/rockdev/${BOARD}_*.img`"

cd ${OUT}/${BOARD}/${TODAY}/rockdev && tar Jcvf ${IMAGE_NAME}.tar.xz ${IMAGE_NAME} && cd -
