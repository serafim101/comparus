FROM jenkins/inbound-agent:latest
USER root
RUN set -eux && \
    apt-get update && \
    apt-get install -y  curl sudo docker.io && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.24.0/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && mv ./kubectl /usr/local/bin && \
    usermod -a jenkins -Gdocker
USER jenkins
