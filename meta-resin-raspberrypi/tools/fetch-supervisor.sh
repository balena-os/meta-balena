#!/bin/bash

set -e

if [ -z "$1" ]; then
	echo "Please provide a branch of rpi-supervisor to embed into the image."
	exit 1
fi

rm -rf build/tmp/deploy/images/raspberrypi/noobs/resin/resin-rpi-supervisor
mkdir -p build/tmp/deploy/images/raspberrypi/noobs/resin/resin-rpi-supervisor

export OLDDIR=`pwd`

cd build/tmp/deploy/images/raspberrypi/noobs/resin/resin-rpi-supervisor



echo Embedding resin/rpi-supervisor:$1 in the image.

docker pull resin/rpi-supervisor:$1

docker tag -f resin/rpi-supervisor:$1 resin/rpi-supervisor:latest

docker history -q --no-trunc=true resin/rpi-supervisor:latest | sed '1!G;h;$!d' > history.list
docker save resin/rpi-supervisor:latest | tar x
find . -type f \( -name "*.tar" \) -exec pixz -9 {} \;

cd $OLDDIR

# Add the meta-resin hash
cd meta-resin && echo -n `git describe --always --abbrev=6`- > ../build/tmp/deploy/images/raspberrypi/noobs/VERSION && cd ..

# Add meta-raspberrypi hash.
cd meta-raspberrypi && echo -n `git describe --always --abbrev=6`- >> ../build/tmp/deploy/images/raspberrypi/noobs/VERSION && cd ..

# Add supervisor version.
echo -n `docker inspect resin/rpi-supervisor:latest  | grep VERSION | head -n 1 | tr -d " " | tr -d "\"" | tr -d "VERSION="` >> build/tmp/deploy/images/raspberrypi/noobs/VERSION
