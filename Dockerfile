# syntax=docker/dockerfile:1

FROM alpine:3.23.3

LABEL org.opencontainers.image.title="labhost-lite"
LABEL org.opencontainers.image.description="Alpine-based SSH'able image for containerlab"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source="https://github.com/CapnCheapo/labhost-lite"

RUN apk add --no-cache \
    bash \
    bind-tools \
    busybox-extras \
    ca-certificates \
    curl \
    ethtool \
    fping \
    iperf3 \
    iproute2 \
    iputils \
    jq \
    mtr \
    net-tools \
    openssh-client \
    openssh-server \
    socat \
    sudo \
    tcpdump \
    tini \
    tshark \
    vim

RUN adduser -D -h /home/lab lab && \
    mkdir -p /home/lab && chown -R lab:lab /home/lab

RUN echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel && \
    chmod 0440 /etc/sudoers.d/wheel

RUN addgroup lab wheel && \
    addgroup lab wireshark

RUN ssh-keygen -A && \
    echo "lab:lab" | chpasswd && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

RUN rm /etc/motd

EXPOSE 22

ENTRYPOINT ["/sbin/tini","--"]

CMD ["/usr/sbin/sshd","-D","-e"]
