FROM ubuntu:16.04 AS aosp
ENV DEBIAN_FRONTEND noninteractive
ENV VERSION_ANDROID android-9.0.0_r16
RUN apt-get update && apt-get install -y git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /lineage/src/prebuilts/clang/host \
    && git clone -b $VERSION_ANDROID https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/ /lineage/src/prebuilts/clang/host/linux-x86


FROM ubuntu:16.04
ENV DEBIAN_FRONTEND noninteractive
ENV USE_CCACHE 1
ENV CCACHE_SIZE "50G"
ENV CCACHE_COMPRESS 1
ENV CCACHE_DIR /ccache
ENV CCACHE_PREFIX distcc
ENV DISTCCD_PATH=/lineage/src

RUN apt-get update && apt-get install -y \
    ccache distcc python \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
COPY --from=aosp /lineage/src/prebuilts/clang/host/linux-x86 $DISTCCD_PATH/prebuilts/clang/host/linux-x86
RUN ccache -M $CCACHE_SIZE && ccache -s
WORKDIR $DISTCCD_PATH
ENTRYPOINT ["/usr/bin/distccd"]
CMD ["--log-stderr","--no-detach","--user","distccd","--allow","0.0.0.0/0"]
EXPOSE 3632
