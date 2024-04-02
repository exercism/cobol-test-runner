FROM alpine AS download
COPY bin/fetch-cobolcheck /bin/
RUN apk add --no-cache curl coreutils bash
WORKDIR /bin/
RUN /bin/fetch-cobolcheck 

FROM ubuntu:20.04

# TODO: install packages required to run the tests
RUN apt-get update && \
    apt-get -y install jq curl tar libncurses5-dev libgmp-dev libdb-dev ranger autoconf build-essential && \
    curl -sLk https://sourceforge.net/projects/open-cobol/files/gnu-cobol/3.2/gnucobol-3.2.tar.gz | tar xz && \
    cd gnucobol-3.2 && ./configure --prefix=/usr &&  make &&  make install && ldconfig && cd /tmp/ && rm -rf ./* && \
    rm -rf /var/lib/apt/lists/*

COPY --from=download /bin/cobolcheck /bin/cobolcheck

WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
