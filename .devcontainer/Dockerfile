FROM golang:1.22-bookworm

RUN apt-get update && apt-get install -y ca-certificates curl gnupg && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ARG HUGO_VERSION="0.152.2"

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
