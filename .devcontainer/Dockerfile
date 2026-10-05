FROM node:24-bookworm

ARG HUGO_VERSION="0.167.0"
ARG DART_SASS_VERSION="1.105.1"

RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        HUGO_BINARY="hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"; \
        SASS_ARCH="x64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        HUGO_BINARY="hugo_extended_${HUGO_VERSION}_linux-arm64.tar.gz"; \
        SASS_ARCH="arm64"; \
    else \
        echo "Unsupported architecture: $ARCH" >&2 && exit 1; \
    fi && \
    wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY} && \
    tar xzf ${HUGO_BINARY} && \
    rm -r ${HUGO_BINARY} && \
    mv hugo /usr/bin && \
    chmod 755 /usr/bin/hugo && \
    wget -qO- https://github.com/sass/dart-sass/releases/download/${DART_SASS_VERSION}/dart-sass-${DART_SASS_VERSION}-linux-${SASS_ARCH}.tar.gz | tar -xz -C /opt

ENV PATH="/opt/dart-sass:${PATH}"
