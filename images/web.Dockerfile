ARG img_version
FROM redot-fedora:${img_version}

ENV EMSCRIPTEN_VERSION=3.1.64

RUN git clone --branch ${EMSCRIPTEN_VERSION} --progress https://github.com/emscripten-core/emsdk && \
    emsdk/emsdk install ${EMSCRIPTEN_VERSION} && \
    emsdk/emsdk activate ${EMSCRIPTEN_VERSION}

CMD /bin/bash
