#Base image start
#Based on devture/ansible, but with latest alpine version
FROM docker.io/golang:1.26.3-alpine3.23 AS builder-agru

ARG AGRU_VERSION=v0.1.16

RUN apk add --no-cache git just

RUN git clone https://github.com/etkecc/agru.git && \
	cd agru && \
	git checkout ${AGRU_VERSION} && \
	just build


FROM docker.io/alpine:3.23.4 as base-image

COPY --from=builder-agru /go/agru/agru /usr/local/bin/

RUN apk add --no-cache \
	ca-certificates \
	openssh \
	git \
	ansible \
	make \
	just \
	py3-dnspython \
	py3-passlib

#Base image end

#Build sdk because install doesnt work 
FROM base-image as builder-bitwarden
RUN apk add --no-cache rust cargo nodejs npm
RUN git clone https://github.com/bitwarden/sdk-sm.git bitwarden-sdk && \
	  cd bitwarden-sdk
WORKDIR /bitwarden-sdk
RUN npm install && \
	npm run schemas

FROM base-image

ENV BWS_ACCESS_TOKEN=

ENV SSH_KEY_PATHS=
ENV SSH_KEY_PASSPHASES=

ENV GIT_CONFIG_SAFE_DIR=

RUN apk add --no-cache py-pip rust cargo bash
RUN pip install diskcache --break-system-packages
COPY --from=builder-bitwarden /bitwarden-sdk /bitwarden-sdk
RUN pip install /bitwarden-sdk/languages/python --break-system-packages
RUN ansible-galaxy collection install bitwarden.secrets community.docker community.general:11.0.0  --force

ADD ./ansible_cached_lookup.py /root/.ansible/collections/ansible_collections/community/cache/plugins/lookup/lookup.py

ADD ./start.sh .

RUN chmod u+x ./start.sh 

ENTRYPOINT ["/start.sh"]
CMD ["/bin/bash"]
