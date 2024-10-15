FROM enderpokryphen/php-fpm:8.2

COPY docker/development/ssl/WuerthItalia-Root-CA.crt /usr/local/share/ca-certificates
RUN apt-get install -y ca-certificates
RUN update-ca-certificates

RUN install-php-extensions oci8 pdo_oci xdebug

# https://github.com/php-sap/docker-kralik
# Add and extract SAP Netweaver RFC SDK.
RUN curl -u "dockeruser:xJ19kK2tbRcQr7VP8fdWnR2lJXWNMm9fs6Xc7dvc" https://wos.wuerth.it/docker-artifacts/files/sapnwrfc-sdk-7.50.tar.gz -o /sapnwrfc-sdk-7.50.tar.gz
RUN mkdir /usr/sap/ && tar -xvzf /sapnwrfc-sdk-7.50.tar.gz -C /usr/sap/

## Version of Gregor Kraliks SAP Netweaver RFC module source code for PHP 7
ARG SAPNWRFC_VERSION=2.0.0-beta3

RUN set -xe; \
    docker-php-source extract; \
    # SAP netweaver RFC SDK should be installed...
    echo "/usr/sap/nwrfcsdk/lib" > /etc/ld.so.conf.d/sapnwrfc.conf; \
    ldconfig; \
    # Download Gregor Kraliks SAP Netweaver RFC module source code for PHP 7
    cd /usr/src; \
    curl --insecure --fail --location --output "${SAPNWRFC_VERSION}.tar.gz" "https://github.com/gkralik/php7-sapnwrfc/archive/${SAPNWRFC_VERSION}.tar.gz"; \
    # Extract the module sources.
    tar xzf ${SAPNWRFC_VERSION}.tar.gz; \
    cd php7-sapnwrfc-${SAPNWRFC_VERSION}; \
    # Configure and build the module.
    phpize; \
    ./configure --with-sapnwrfc=/usr/sap/nwrfcsdk; \
    make; \
    make install; \
    cd ..; \
    # cleanup
    rm -Rf php7-sapnwrfc-${SAPNWRFC_VERSION}/ ${SAPNWRFC_VERSION}.tar.gz; \
    docker-php-source delete; \
    # Enable freshly compiled SAP Netweaver RFC module.
    # How to enable PHP modules depends on your *nix flavor.
    # The official PHP 7 docker images do it this way.
    docker-php-ext-enable sapnwrfc;

RUN rm -rf /sapnwrfc-sdk-7.50.tar.gz

# Install Node.js
RUN mkdir /usr/local/nvm
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 21.1.0
RUN curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm install --latest-npm \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

WORKDIR /var/www/html/

USER www-data
