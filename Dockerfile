
FROM debian:bookworm

## Update the repository and install utils
RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
		sudo \
		bzip2 \
		unzip \
		xz-utils \
		python3 \
		curl \
		dpkg \
		wget \
		git \
		patch \
		cpio \
		build-essential \
		binutils \
		gcc \
		gcc-multilib \
		g++-multilib \
		qemu-system \
		bison \
		flex \
		bc \
		ruby \
		make \
		cmake \
		autoconf \
		automake \
		autotools-dev \
		libtool \
		libmpc-dev \
		telnet \
		ntp \
		psmisc \
		net-tools \
		iproute2 \
		iptables \
		iputils-ping

## Install python2 (deprecated)
COPY bullseye.list /etc/apt/sources.list.d/
RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
	python2 \
	python-is-python2 && \
	apt-get clean && \
	rm -rf /var/lib/apt /var/cache/apt && \
	rm /etc/apt/sources.list.d/bullseye.list

## Install crosscompilers
RUN for a in aarch64-elf arm-none-eabi i386-elf microblaze-elf mips-mti-elf powerpc-elf riscv64-unknown-elf sparc-elf; do \
	curl -k -L "https://github.com/embox/crosstool/releases/download/2.42-13.3.0-14.2/$a-toolchain.tar.bz2" | \
		tar -jxC /opt; \
	done

## Set environment variables
ENV PATH=$PATH:\
/opt/aarch64-elf-toolchain/bin:\
/opt/arm-none-eabi-toolchain/bin:\
/opt/i386-elf-toolchain/bin:\
/opt/microblaze-elf-toolchain/bin:\
/opt/mips-mti-elf-toolchain/bin:\
/opt/powerpc-elf-toolchain/bin:\
/opt/riscv64-unknown-elf-toolchain/bin:\
/opt/sparc-elf-toolchain/bin

## Set working directory
VOLUME /embox
WORKDIR /embox

## Default command
CMD ["/usr/bin/bash"]
