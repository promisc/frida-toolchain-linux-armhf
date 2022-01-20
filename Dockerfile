FROM ghcr.io/promisc/toolchain-armhf:glibc_2_19

# Deps from https://github.com/frida/frida-ci/blob/master/images/worker-ubuntu-20.04-x86_64/Dockerfile
USER root
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		build-essential \
		curl \
		git \
		lib32stdc++-9-dev \
		libc6-dev-i386 \
		libgl1-mesa-dev \
		locales \
		nodejs \
		npm \
		p7zip \
		python3-dev \
		python3-pip \
		python3-requests \
		python3-setuptools \
    && rm -rf /var/lib/apt/lists/* \
    && adduser --disabled-password --gecos '' builder

USER builder
WORKDIR /home/builder
RUN git clone --recurse-submodules https://github.com/frida/frida
WORKDIR /home/builder/frida
RUN git checkout 5b9d256f645a2c76ccc2941ba7d1e67370143da0

ENV FRIDA_HOST=linux-armhf

RUN sed -i 's,FRIDA_V8 ?= auto,FRIDA_V8 ?= disabled,' config.mk \
    && sed -i 's,host_arch_flags="-march=armv7-a",host_arch_flags="-march=armv7-a -mfloat-abi=hard -mfpu=vfpv3-d16",g' releng/setup-env.sh

RUN make -f Makefile.toolchain.mk
# outputs: build/toolchain-linux-armhf.tar.bz2
RUN make -f Makefile.sdk.mk
# outputs: build/sdk-linux-armhf.tar.bz2

RUN make core-linux-armhf
# RUN make check-core-linux-armhf

