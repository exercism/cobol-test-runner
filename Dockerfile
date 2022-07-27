FROM alpine AS download
COPY bin/fetch-cobolcheck /bin/
RUN apk add --no-cache curl coreutils bash
WORKDIR /bin/
RUN /bin/fetch-cobolcheck 

FROM ubuntu:focal

# TODO: install packages required to run the tests
RUN apt-get update && apt-get install -y \
    jq \
    gnucobol \
    && rm -rf /var/lib/apt/lists/*

COPY --from=download /bin/cobolcheck /bin/cobolcheck

WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
