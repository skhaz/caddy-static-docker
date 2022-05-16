FROM golang:1.18-alpine AS builder

ARG LZMA_HASH=c6c2fc49e2ac6f3fc82762c6d3703969274d48de
ARG UPX_HASH=a54bef20057d72ab020df3812e90542bdcf56e1f
ARG CADDY_HASH=4b4e99bdb2e327d553a5f773f827f624181714af

RUN apk add bash perl build-base binutils ucl-dev zlib-dev

WORKDIR /opt/upx/src/lzma-sdk
RUN wget -qO- github.com/upx/upx-lzma-sdk/archive/"$LZMA_HASH".tar.gz | tar zx --strip-components=1

WORKDIR /opt/upx
RUN wget -qO- github.com/upx/upx/archive/"$UPX_HASH".tar.gz | tar zx --strip-components=1
RUN make -j$(nproc)
RUN install /opt/upx/src/upx.out /usr/local/bin/upx

WORKDIR /opt/caddy
RUN wget -qO- github.com/caddyserver/caddy/archive/"$CADDY_HASH".tar.gz | tar zx --strip-components=1
RUN cd cmd/caddy && CGO_ENABLED=0 go build && strip --strip-unneeded caddy && upx --lzma caddy

FROM alpine
COPY --from=builder /opt/caddy/cmd/caddy/caddy /usr/local/bin

CMD caddy file-server --browse --listen :$PORT