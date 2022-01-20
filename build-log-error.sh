#!/bin/bash -ux

get_logs () {
    find build -type f -name "*.log" -printf "%T@:%p\n" | sort -n | cut -d ":" -f 2 | xargs -rL 1 -- tail -vn 100
    exit 1
}

make -f Makefile.toolchain.mk || get_logs
# outputs: build/toolchain-linux-armhf.tar.bz2

find build -type f -name "*.log" -exec rm {} +
make -f Makefile.sdk.mk || get_logs
# outputs: build/sdk-linux-armhf.tar.bz2

find build -type f -name "*.log" -exec rm {} +
make core-linux-armhf || get_logs
# RUN make check-core-linux-armhf
