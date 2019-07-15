FROM alpine:latest
RUN apk add --update --no-cache \
    bash \
    lvm2 \
    grub \
    device-mapper \
    e2fsprogs \
    util-linux 

ADD create_image.sh /usr/local/bin/create_image

ENTRYPOINT [ "create_image" ]
