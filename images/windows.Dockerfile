ARG source_image
FROM ${source_image}

RUN dnf -y install --setopt=install_weak_deps=False \
      mingw32-gcc mingw32-gcc-c++ mingw32-winpthreads-static mingw64-gcc mingw64-gcc-c++ mingw64-winpthreads-static && \
    curl -LO https://github.com/mstorsjo/llvm-mingw/releases/download/20240619/llvm-mingw-20240619-ucrt-ubuntu-20.04-x86_64.tar.xz && \
    tar xf llvm-mingw-20240619-ucrt-ubuntu-20.04-x86_64.tar.xz && \
    rm -f llvm-mingw-20240619-ucrt-ubuntu-20.04-x86_64.tar.xz && \
    mv -f llvm-mingw-20240619-ucrt-ubuntu-20.04-x86_64 /root/llvm-mingw

CMD /bin/bash
