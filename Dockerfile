
FROM debian:bookworm
MAINTAINER Anton Kozlov <drakon.mega@gmail.com>

## python2 (deprecated)
RUN echo "deb http://deb.debian.org/debian bullseye main"          > /etc/apt/sources.list.d/bullseye.list
RUN echo "deb http://deb.debian.org/debian bullseye-updates main" >> /etc/apt/sources.list.d/bullseye.list
RUN echo "deb http://security.debian.org bullseye-security main"  >> /etc/apt/sources.list.d/bullseye.list

## Container utils
RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
		sudo \
		iptables \
		openssh-server \
		iproute2 \
		bzip2 \
		unzip \
		xz-utils \
		python3 \
		python2 \
		python-is-python2 \
		curl \
		dpkg \
		make \
		patch \
		cpio \
		build-essential \
		binutils \
		gcc \
		gcc-multilib \
		g++-multilib \
		gdb \
		qemu-system \
		ruby \
		bison \
		flex \
		bc \
		autoconf \
		pkg-config \
		mtd-utils \
		ntfs-3g \
		autotools-dev \
		automake \
		xutils-dev \
		libtool \
		rpcbind \
		nfs-kernel-server \
		nfs-common \
		samba \
		mkisofs \
		net-tools \
		isc-dhcp-server \
		iputils-ping \
		telnet \
		ntp \
		openbsd-inetd \
		psmisc \
		wget \
		expect \
		snmp \
		xvfb \
		xauth \
		tigervnc-standalone-server \
		tigervnc-common \
		tigervnc-viewer \
		ffmpeg \
		git \
		mime-support \
		dosfstools && \
	apt-get clean && \
	rm -rf /var/lib/apt /var/cache/apt && \
	rm /etc/apt/sources.list.d/bullseye.list

## arm crosscompiler
RUN curl -k -L "https://developer.arm.com/-/media/Files/downloads/gnu-rm/6-2017q2/gcc-arm-none-eabi-6-2017-q2-update-linux.tar.bz2" | \
	tar -jxC /opt

## aarch64 crosscompiler
RUN curl -k -L "https://developer.arm.com/-/media/Files/downloads/gnu-a/8.3-2019.03/binrel/gcc-arm-8.3-2019.03-x86_64-aarch64-elf.tar.xz" | \
	tar -xJC /opt

## risc-v crosscompiler
RUN curl -k -L -s "https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.2.0-2019.05.3-x86_64-linux-ubuntu14.tar.gz" | \
	tar -xzC /opt

## other crosscompilers
RUN for a in microblaze mips powerpc sparc; do \
	curl -k -L "https://github.com/embox/crosstool/releases/download/2.42-13.2.0-14.2/$a-elf-toolchain.tar.bz2" | \
		tar -jxC /opt; \
	done

## Set environment variables
ENV PATH=$PATH:\
/opt/gcc-arm-none-eabi-6-2017-q2-update/bin:\
/opt/gcc-arm-8.3-2019.03-x86_64-aarch64-elf/bin:\
/opt/riscv64-unknown-elf-gcc-8.2.0-2019.05.3-x86_64-linux-ubuntu14/bin:\
/opt/microblaze-elf-toolchain/bin:\
/opt/mips-elf-toolchain/bin:\
/opt/powerpc-elf-toolchain/bin:\
/opt/sparc-elf-toolchain/bin

## Allow members of group sudo to execute any command
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

## x86/test/fs
RUN for i in $(seq 0 9); do \
	mknod /dev/loop$i -m0660 b 7 $i; done

## x86/test/fs nfs
RUN mkdir -p -m 777 /var/nfs_test
COPY exports /etc/

## x86/test/fs cifs
RUN mkdir -p -m 777 /var/cifs_test
COPY smb.conf.public /etc/samba/
RUN cat /etc/samba/smb.conf.public >> /etc/samba/smb.conf && \
	rm /etc/samba/smb.conf.public

## x86/test/net
COPY dhcpd.conf /etc/dhcp/
COPY isc-dhcp-server /etc/default/
COPY ntp.conf /etc/

CMD mount -t tmpfs none /var/nfs_test && \
	systemctl restart rpcbind && \
	systemctl restart nfs-kernel-server && \
	systemctl restart nmbd && \
	systemctl restart smbd && \
	systemctl restart ntp && \
	systemctl restart inetd
