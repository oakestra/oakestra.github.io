FROM node:24-bookworm

ARG HUGO_VERSION="0.167.0"

RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        HUGO_BINARY="hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        HUGO_BINARY="hugo_extended_${HUGO_VERSION}_linux-arm64.tar.gz"; \
    else \
        echo "Unsupported architecture: $ARCH" >&2 && exit 1; \
    fi && \
    wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY} && \
    tar xzf ${HUGO_BINARY} && \
    rm -r ${HUGO_BINARY} && \
    mv hugo /usr/bin && \
    chmod 755 /usr/bin/hugo
