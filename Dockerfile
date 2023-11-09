FROM devture/ansible:latest

ENV BW_SERVER=https://vault.bitwarden.com
ENV BWS_ACCESS_TOKEN=

ENV SSH_KEY_PATHS=
ENV SSH_KEY_PASSPHASES=

ENV GIT_CONFIG_SAFE_DIR=

RUN ansible-galaxy collection install community.general:8.0.1

RUN apk add --no-cache curl bash && apk add --upgrade curl
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    curl -L https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-2.34-r0.apk --output /tmp/glibc.apk && \
    curl -L https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-bin-2.34-r0.apk --output /tmp/glibc-bin.apk && \
    apk add --no-cache --force-overwrite /tmp/glibc.apk /tmp/glibc-bin.apk && \ 
    curl -L $(curl -s https://api.github.com/repos/bitwarden/sdk/releases/latest | grep "browser_download_url*" | grep "bws-x86_64-unknown-linux-gnu-.*zip" | cut -d : -f 2,3 | tr -d \") --output "/tmp/bws.zip" && \
    unzip /tmp/bws.zip -d /tmp && \
    install /tmp/bws /usr/bin && \
    rm /tmp/bws.zip

ADD ./start.sh .

RUN chmod u+x ./start.sh 

ENTRYPOINT ["/start.sh"]
CMD ["/bin/bash"]
