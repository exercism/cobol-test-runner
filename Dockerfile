FROM ubuntu:24.04@sha256:c4a8d5503dfb2a3eb8ab5f807da5bc69a85730fb49b5cfca2330194ebcc41c7b AS base

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
ENV export COB_LD_FLAGS='-Wl, --no-as-needed'
RUN curl -sLk https://sourceforge.net/projects/open-cobol/files/gnu-cobol/3.2/gnucobol-3.2.tar.gz | tar xz && \
    cd gnucobol-3.2 && ./configure --prefix=/usr && make && make install && ldconfig && \
    cd /tmp/ && rm -rf /tmp/gnucobol_build

# Set up the test runner environment.
WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
