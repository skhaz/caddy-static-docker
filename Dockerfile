FROM golang:1.19-alpine

RUN apk add build-base cmake

WORKDIR /opt/upx/vendor/doctest
ARG DOCTEST_HASH=5fa2c86db1d1d0d070184ec119724da5b5d523bf
RUN wget -qO- github.com/upx/upx-vendor-doctest/archive/"$DOCTEST_HASH".tar.gz | tar zx --strip-components=1

WORKDIR /opt/upx/vendor/lzma-sdk
ARG LZMA_HASH=ce0e8e923df56495bee234853c7e70adb3b89133
RUN wget -qO- github.com/upx/upx-vendor-lzma-sdk/archive/"$LZMA_HASH".tar.gz | tar zx --strip-components=1

WORKDIR /opt/upx/vendor/ucl
ARG UCL_HASH=7c71ac7c54b8edfcf062a514e0ddf1b412a16883
RUN wget -qO- github.com/upx/upx-vendor-ucl/archive/"$UCL_HASH".tar.gz | tar zx --strip-components=1

WORKDIR /opt/upx/vendor/zlib
ARG ZLIB_HASH=e7bb221cc027cc72a96687d6dabaee7da2285f13
RUN wget -qO- github.com/upx/upx-vendor-zlib/archive/"$ZLIB_HASH".tar.gz | tar zx --strip-components=1

WORKDIR /opt/upx
ARG UPX_HASH=a7156eca5be776cff64382daa244fac6ecf71e76
RUN wget -qO- github.com/upx/upx/archive/"$UPX_HASH".tar.gz | tar zx --strip-components=1
RUN make -j$(nproc)

WORKDIR /opt/caddy
ARG CADDY_HASH=50748e19c34fc90882bbb268c95a2a0acb051752
RUN wget -qO- github.com/caddyserver/caddy/archive/"$CADDY_HASH".tar.gz | tar zx --strip-components=1
RUN cd cmd/caddy && CGO_ENABLED=0 go build && strip --strip-unneeded caddy && /opt/upx/build/release/upx --lzma caddy

FROM alpine
COPY --from=0 /opt/caddy/cmd/caddy/caddy /usr/local/bin
ARG PORT=8000
ENV PORT $PORT
EXPOSE $PORT
CMD caddy file-server --browse --listen :$PORT