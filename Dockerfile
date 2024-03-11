FROM devture/ansible:latest

ENV BWS_ACCESS_TOKEN=

ENV SSH_KEY_PATHS=
ENV SSH_KEY_PASSPHASES=

ENV GIT_CONFIG_SAFE_DIR=

RUN apk add --no-cache py-pip rust cargo bash
RUN pip install bitwarden-sdk --break-system-packages
RUN ansible-galaxy collection install bitwarden.secrets

ADD ./start.sh .

RUN chmod u+x ./start.sh 

ENTRYPOINT ["/start.sh"]
CMD ["/bin/bash"]
