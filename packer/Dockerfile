FROM hashicorp/packer:latest

USER root

# Install build dependencies and Azure CLI
RUN apk add --no-cache python3 py3-pip bash curl gcc python3-dev musl-dev linux-headers && \
    rm -f /usr/lib/python*/EXTERNALLY-MANAGED && \
    pip3 install --upgrade pip && \
    pip3 install azure-cli && \
    apk del gcc python3-dev musl-dev linux-headers

# Install PowerShell (for running scripts)
RUN apk add --no-cache \
    ca-certificates \
    less \
    ncurses-terminfo-base \
    krb5-libs \
    libgcc \
    libintl \
    libssl1.1 \
    libstdc++ \
    tzdata \
    userspace-rcu \
    zlib \
    icu-libs && \
    apk -X https://dl-cdn.alpinelinux.org/alpine/edge/main add --no-cache lttng-ust && \
    curl -L https://github.com/PowerShell/PowerShell/releases/download/v7.3.4/powershell-7.3.4-linux-alpine-x64.tar.gz -o /tmp/powershell.tar.gz && \
    mkdir -p /opt/microsoft/powershell/7 && \
    tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7 && \
    chmod +x /opt/microsoft/powershell/7/pwsh && \
    ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh && \
    rm /tmp/powershell.tar.gz

WORKDIR /workspace

ENTRYPOINT ["packer"]
