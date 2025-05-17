FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    curl \
    gnupg \
    lsb-release \
    apt-transport-https \
    ca-certificates \
    systemd \
    ssl-cert \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Install Chef
RUN curl -L https://omnitruck.chef.io/install.sh | bash -s -- -v 18

# Set up for nginx testing
RUN mkdir -p /var/log/nginx /var/www/html /var/www/secure.example.com /var/www/site1.example.com /var/www/site2.example.com

COPY . /nginx_cookbook
WORKDIR /nginx_cookbook

CMD ["/bin/bash"]
