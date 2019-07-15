#!/bin/bash
#

IMAGE="$1"

docker export -o rootfs.tar `docker run -d "$IMAGE" /bin/true`

docker build -t builder builder

mkdir -p output

docker run -it \
  -v "$PWD/rootfs.tar:/rootfs.tar" \
  -v "$PWD/output:/output" \
  --cap-add SYS_ADMIN \
  --privileged \
  --device /dev/loop0 \
  builder

