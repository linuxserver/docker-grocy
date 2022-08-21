FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.15

# set version label
ARG BUILD_DATE
ARG VERSION
ARG GROCY_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips, homerr"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    composer \
    git \
    yarn && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    curl \
    php8-ctype \
    php8-curl \
    php8-gd \
    php8-iconv \
    php8-intl \
    php8-json \
    php8-ldap \
    php8-pdo \
    php8-pdo_sqlite \
    php8-phar \
    php8-tokenizer \
    php8-zip && \
  echo "**** install grocy ****" && \
  mkdir -p /app/www && \
  if [ -z ${GROCY_RELEASE+x} ]; then \
    GROCY_RELEASE=$(curl -sX GET "https://api.github.com/repos/grocy/grocy/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/grocy.tar.gz -L \
    "https://github.com/grocy/grocy/archive/${GROCY_RELEASE}.tar.gz" && \
  tar xf \
    /tmp/grocy.tar.gz -C \
    /app/www/ --strip-components=1 && \
  cp -R /app/www/data/plugins \
    /defaults/plugins && \
  echo "**** install composer packages ****" && \
  composer install -d /app/www --no-dev && \
  echo "**** install yarn packages ****" && \
  cd /app/www && \
  yarn --production && \
  yarn cache clean && \
  mv /app/www/public/node_modules /defaults/node_modules && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /root/.composer \
    /root/.cache \
    /tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 80 443
VOLUME /config
