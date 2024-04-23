
FROM ubuntu:16.04

## Update the repository and install utils
RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
		sudo \
		iptables \
		openssh-server \
		iproute2 \
		bzip2 \
		unzip \
		xz-utils \
		python \
		curl \
		make \
		patch \
		cpio \
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
		xvnc4viewer \
		ffmpeg \
		git \
		dosfstools && \
	apt-get clean && \
	rm -rf /var/lib/apt /var/cache/apt

## Install crosscompilers
RUN for a in aarch64-elf arm-none-eabi microblaze-elf mips-mti-elf powerpc-elf riscv64-unknown-elf sparc-elf; do \
	curl -k -L "https://github.com/embox/crosstool/releases/download/2.42-13.2.0-14.2/$a-toolchain.tar.bz2" | \
		tar -jxC /opt; \
	done

## Set environment variables
ENV PATH=$PATH:\
/opt/aarch64-elf-toolchain/bin:\
/opt/arm-none-eabi-toolchain/bin:\
/opt/microblaze-elf-toolchain/bin:\
/opt/mips-mti-elf-toolchain/bin:\
/opt/powerpc-elf-toolchain/bin:\
/opt/riscv64-unknown-elf-toolchain/bin:\
/opt/sparc-elf-toolchain/bin

COPY create_matching_user.sh /usr/local/sbin/
COPY docker_start.sh /usr/local/sbin/

COPY id_rsa.pub /home/user/.ssh/authorized_keys
COPY user.bashrc /home/user/.bashrc
COPY user.bash_profile /home/user/.bash_profile
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

## x86/test/fs
RUN for i in $(seq 0 9); do \
		mknod /dev/loop$i -m0660 b 7 $i; \
	done

# x86/test/fs nfs
RUN mkdir -p -m 777 /var/nfs_test
COPY exports /etc/

# x86/test/fs cifs
RUN mkdir -p -m 777 /var/cifs_test
COPY smb.conf /etc/samba/

# x86/test/net
COPY dhcpd.conf /etc/dhcp/
COPY isc-dhcp-server /etc/default/
COPY ntp.conf /etc/
RUN useradd -u 65534 -o -ms /bin/bash rlogin_user
RUN /bin/echo -e "rlogin\nrlogin" | passwd rlogin_user

CMD mount -t tmpfs none /var/nfs_test && \
	service rpcbind restart && \
	/etc/init.d/nfs-kernel-server restart && \
	/etc/init.d/nmbd restart && \
	/etc/init.d/smbd restart && \
	/etc/init.d/ntp restart && \
	inetd && \
	/usr/local/sbin/docker_start.sh
