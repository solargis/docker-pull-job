ARG UBUNTU_VERSION=18.04
FROM ubuntu:$UBUNTU_VERSION
RUN apt-get update \
    && apt-get install -y --no-install-recommends openssh-client rsync gosu \
    && rm -rf /var/lib/apt/lists/*
COPY entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "bash" ]
