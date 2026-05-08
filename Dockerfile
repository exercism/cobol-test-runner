FROM alpine:3.23.4@sha256:5b10f432ef3da1b8d4c7eb6c487f2f5a8f096bc91145e68878dd4a5019afde11 AS download
COPY bin/fetch-cobolcheck /bin/
RUN apk add --no-cache curl coreutils bash
WORKDIR /bin/
RUN /bin/fetch-cobolcheck 

FROM ubuntu:24.04@sha256:c4a8d5503dfb2a3eb8ab5f807da5bc69a85730fb49b5cfca2330194ebcc41c7b

# TODO: install packages required to run the tests
ENV export COB_LD_FLAGS='-Wl, --no-as-needed'
RUN apt-get update && \
    apt-get -y install jq curl tar libncurses5-dev libgmp-dev libdb-dev ranger autoconf build-essential && \
    curl -sLk https://sourceforge.net/projects/open-cobol/files/gnu-cobol/3.2/gnucobol-3.2.tar.gz | tar xz && \
    cd gnucobol-3.2 && ./configure --prefix=/usr &&  make &&  make install && ldconfig && cd /tmp/ && rm -rf ./* && \
    rm -rf /var/lib/apt/lists/*

COPY --from=download /bin/cobolcheck /bin/cobolcheck

WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
