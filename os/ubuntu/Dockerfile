FROM ubuntu:18.04
RUN apt-get update -y
RUN apt-get -y install \
  linux-image-virtual \
  grub-pc \
  grub-efi-amd64-bin \
  vim \
  systemd-sysv
RUN echo "root:root" | chpasswd

