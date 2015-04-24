#!/bin/sh -e

BOARD=$1
TODAY=$(date +"%y%m%d")

if [ -z ${BOARD} ]; then
	echo "$0 board"
	exit 1
fi

mkdir -p ${TODAY} && cd ${TODAY}

if [ ! -d radxa-lb/.git ]; then
	git clone git@git.radxa.com:x1/radxa-lb.git
fi

if [ ! -d rock-bsp/.git ]; then
	git clone git@github.com:radxa/rock-bsp.git
fi

if [ "local" = $2 ]; then
	cat ../bootstrap_local > radxa-lb/${BOARD}/bootstrap
	echo "deb http://172.168.1.3/apt.radxa.us/rabian-stable/ jessie main" > radxa-lb/${BOARD}/archives/apt-radxa-us.list

fi

cd radxa-lb && make clean && make $BOARD && cd -

IMAGE=$(basename radxa-lb/rabian_${BOARD}_*.ext4)

cp -vf radxa-lb/$IMAGE rock-bsp/rootfs/

echo "BOARD_ROOTFS=${IMAGE}" >> rock-bsp/configs/${BOARD}_config

cd rock-bsp && ./config.sh $BOARD && make && cd -
