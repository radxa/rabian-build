#!/bin/sh -e

BOARD_IMG=$1
DELETE_STRING=${BOARD_IMG%_sdcard*}
TARGET_BOARD=${DELETE_STRING%_lvds*}
OUT=$2

TODAY=$(date +"%y%m%d")

LB_URL="https://github.com/radxa/radxa-lb.git"
BSP_URL="https://github.com/radxa/rock-bsp.git"

if [ -z ${BOARD_IMG} ]; then
	echo "$0 board [output]"
	exit 1
fi

if [ ! -z ${OUT} ]; then
	mkdir -p ${OUT}/${BOARD_IMG}/${TODAY}
fi

mkdir -p ${TODAY} && cd ${TODAY}

if [ ! -d radxa-lb/.git ]; then
	git clone ${LB_URL}
fi

if [ ! -d rock-bsp/.git ]; then
	git clone ${BSP_URL}
fi

if [ -e ../.local ]; then
	cp -vf ../bootstrap_local radxa-lb/common_config/bootstrap
	cp -Rf ../apt-radxa-us.list.local radxa-lb/common_config/archives/apt-radxa-us.list
	cp -vf ../defconfig_local rock-bsp/configs/defconfig
	cp -vf ../${BOARD_IMG}_config_local rock-bsp/configs/${BOARD_IMG}_config
fi

if [ ! -e radxa-lb/.${TARGET_BOARD}_lb_done ]; then
	cd radxa-lb && make clean && make ${TARGET_BOARD} && touch ./.${TARGET_BOARD}_lb_done && cd -
fi

cp -vf radxa-lb/rabian_${TARGET_BOARD}.ext4 rock-bsp/rootfs/

echo "BOARD_ROOTFS=rabian_${TARGET_BOARD}.ext4" >> rock-bsp/configs/${BOARD_IMG}_config

cd rock-bsp && ./config.sh $BOARD_IMG && make && mv boards/${BOARD_IMG}/rockdev ${OUT}/${BOARD_IMG}/${TODAY}/ && cd -

if [ ! -z ${OUT} ]; then
	IMAGE_NAME="`basename ${OUT}/${BOARD_IMG}/${TODAY}/rockdev/${BOARD_IMG}_*.img`"
	cd ${OUT}/${BOARD_IMG}/${TODAY}/rockdev && xz -z ${IMAGE_NAME} && cd -
fi
