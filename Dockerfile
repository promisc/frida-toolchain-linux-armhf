FROM ghcr.io/promisc/toolchain-armhf:glibc_2_19 as frida-builder

# Deps from https://github.com/frida/frida-ci/blob/master/images/worker-ubuntu-20.04-x86_64/Dockerfile
USER root
WORKDIR /root
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        coreutils \
        curl \
        file \
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
    && rm -rf /var/lib/apt/lists/*

USER builder
WORKDIR /home/builder
RUN git clone --recurse-submodules https://github.com/frida/frida
WORKDIR /home/builder/frida
RUN git checkout 5b9d256f645a2c76ccc2941ba7d1e67370143da0 \
    && git submodule update \
    && sed -i 's,FRIDA_V8 ?= auto,FRIDA_V8 ?= disabled,' config.mk \
    && sed -i 's,host_arch_flags="-march=armv7-a",host_arch_flags="-march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16",g' releng/setup-env.sh
ENV FRIDA_HOST=linux-armhf
COPY --chown=builder:builder log-on-error.sh /home/builder/frida/

FROM frida-builder as frida-toolchain-builder
USER builder
WORKDIR /home/builder/frida
RUN /home/builder/frida/log-on-error.sh make -f Makefile.toolchain.mk
RUN /home/builder/frida/log-on-error.sh make -f Makefile.sdk.mk

FROM ubuntu:20.04 as final-frida-toolchain-image
RUN adduser --disabled-password --gecos '' builder
USER builder
WORKDIR /home/builder
COPY --from=frida-toolchain-builder --chown=builder:builder /home/builder/frida/build/toolchain-linux-armhf.tar.bz2 /home/builder/toolchain-linux-armhf.tar.bz2
COPY --from=frida-toolchain-builder --chown=builder:builder /home/builder/frida/build/sdk-linux-armhf.tar.bz2 /home/builder/sdk-linux-armhf.tar.bz2
COPY --from=frida-toolchain-builder --chown=builder:builder /home/builder/x-tools /home/builder/x-tools
ENV PATH=${PATH}:/home/builder/x-tools/arm-linux-gnueabihf/bin
