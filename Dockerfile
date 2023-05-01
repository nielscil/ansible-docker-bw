FROM devture/ansible:latest

ENV BW_SERVER=https://vault.bitwarden.com
ENV BW_USERNAME=
ENV BW_PASSWORD=

ENV SSH_KEY_PATH=
ENV SSH_KEY_PASSPHASE=

ENV GIT_CONFIG_SAFE_DIR=

RUN apk add --no-cache \
        curl && \
   wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
   curl -L https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-2.34-r0.apk --output /tmp/glibc.apk && \
   curl -L https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-bin-2.34-r0.apk --output /tmp/glibc-bin.apk && \
   apk add --no-cache --force-overwrite /tmp/glibc.apk /tmp/glibc-bin.apk && \ 
   curl -L "https://vault.bitwarden.com/download/?app=cli&platform=linux" --output "/tmp/bw.zip" && \
   unzip /tmp/bw.zip -d /tmp && \
   install /tmp/bw /usr/bin && \
   rm /tmp/bw.zip

RUN ansible-galaxy collection install community.general

ADD ./start.sh .
ADD ./ssh-key-passphase-from-env.sh .

RUN chmod u+x ./start.sh && \
    chmod u+x ./ssh-key-passphase-from-env.sh

ENTRYPOINT ["/start.sh"]
CMD ["/bin/sh"]
