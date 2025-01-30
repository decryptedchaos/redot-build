ARG source_image
FROM ${source_image} as files

ADD files /root/files

FROM ${source_image}

ENV OSX_SDK=15.2

COPY --from=files /root/files/  /root/files/

RUN dnf -y install --setopt=install_weak_deps=False \
      automake autoconf bzip2-devel cmake gcc gcc-c++ libdispatch libicu-devel libtool \
      libxml2-devel openssl-devel uuid-devel yasm

RUN git clone --progress https://github.com/tpoechtrager/osxcross && \
    cd /root/osxcross && \
    git checkout 29fe6dd35522073c9df5800f8cd1feb4b9a993a8 && \
    curl -LO https://github.com/tpoechtrager/osxcross/pull/441.patch && \
    git apply 441.patch && \
    ln -s /root/files/MacOSX${OSX_SDK}.sdk.tar.xz /root/osxcross/tarballs && \
    export UNATTENDED=1 && \
    export SDK_VERSION=${OSX_SDK} && \
    # Custom build Apple Clang to ensure compatibility.
    # Find the equivalent LLVM version for the SDK from:
    # https://en.wikipedia.org/wiki/Xcode#Toolchain_versions
    CLANG_VERSION=17.0.0 ENABLE_CLANG_INSTALL=1 INSTALLPREFIX=/usr ./build_apple_clang.sh && \
    ./build.sh && \
    ./build_compiler_rt.sh && \
    rm -rf /root/osxcross/build && \
    rm -rf /root/files

ENV OSXCROSS_ROOT=/root/osxcross
ENV PATH="/root/osxcross/target/bin:${PATH}"

CMD /bin/bash
