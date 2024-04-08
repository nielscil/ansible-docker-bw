#Temporary because of panic we need to build bitwarden sdk with fix.
#Should be fixed with https://github.com/bitwarden/sdk/pull/676
FROM devture/ansible:latest as builder
RUN apk add --no-cache rust cargo nodejs npm
RUN git clone --branch ansible-test-2 https://github.com/nielscil/bitwarden-sdk.git && \
	cd bitwarden-sdk
WORKDIR /bitwarden-sdk
RUN npm install && \
	npm run schemas

FROM devture/ansible:latest

ENV BWS_ACCESS_TOKEN=

ENV SSH_KEY_PATHS=
ENV SSH_KEY_PASSPHASES=

ENV GIT_CONFIG_SAFE_DIR=

RUN apk add --no-cache py-pip rust cargo bash
RUN pip install diskcache --break-system-packages
COPY --from=builder /bitwarden-sdk /bitwarden-sdk
RUN pip install /bitwarden-sdk/languages/python --break-system-packages
RUN ansible-galaxy collection install bitwarden.secrets

ADD ./ansible_cached_lookup.py /root/.ansible/collections/ansible_collections/community/cache/plugins/lookup/lookup.py

ADD ./start.sh .

RUN chmod u+x ./start.sh 

ENTRYPOINT ["/start.sh"]
CMD ["/bin/bash"]
