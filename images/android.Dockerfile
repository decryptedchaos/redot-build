ARG source_image
FROM ${source_image}

ENV ANDROID_SDK_ROOT=/root/sdk
ENV ANDROID_NDK_VERSION=23.2.8568313
ENV ANDROID_NDK_ROOT=${ANDROID_SDK_ROOT}/ndk/${ANDROID_NDK_VERSION}

RUN dnf -y install --setopt=install_weak_deps=False \
      java-17-openjdk-devel ncurses-compat-libs && \
    mkdir -p sdk && cd sdk && \
    export CMDLINETOOLS=commandlinetools-linux-11076708_latest.zip && \
    curl -LO https://dl.google.com/android/repository/${CMDLINETOOLS} && \
    unzip ${CMDLINETOOLS} && \
    rm ${CMDLINETOOLS} && \
    yes | cmdline-tools/bin/sdkmanager --sdk_root="${ANDROID_SDK_ROOT}" --licenses && \
    cmdline-tools/bin/sdkmanager --sdk_root="${ANDROID_SDK_ROOT}" "ndk;${ANDROID_NDK_VERSION}" 'cmdline-tools;latest' 'build-tools;34.0.0' 'platforms;android-34' 'cmake;3.22.1'

CMD /bin/bash
