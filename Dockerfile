FROM ubuntu:26.04@sha256:f144425ff09be612d6d9ad965196e9cdc23dae1f42110a8a11a3e9a8198759f7 AS base

# Update the OS, fetch build requirements.
RUN apt-get update && \
    apt-get --yes --no-install-recommends install \
        autoconf build-essential ca-certificates curl jq \
        libdb-dev libgmp-dev libncurses5-dev ranger tar && \
    rm -rf /var/lib/apt/lists/*

# Fetch cobolcheck
FROM base AS download
WORKDIR /bin/
COPY bin/fetch-cobolcheck /bin/
RUN /bin/fetch-cobolcheck

# Set up the runner
FROM base
COPY --from=download /bin/cobolcheck /bin/cobolcheck

# Build gnucobol
WORKDIR /tmp/gnucobol_build
ENV COB_LD_FLAGS='-Wl, --no-as-needed'
RUN curl -sLk https://sourceforge.net/projects/open-cobol/files/gnu-cobol/3.2/gnucobol-3.2.tar.gz | tar xz && \
    cd gnucobol-3.2 && ./configure --prefix=/usr && make && make install && ldconfig && \
    cd /tmp/ && rm -rf /tmp/gnucobol_build

# Set up the test runner environment.
WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
