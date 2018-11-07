FROM lsiobase/alpine.nginx:3.8

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
    git \
    composer \
    yarn && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
    curl \
	php7 \
    php7-pdo \
	php7-pdo_sqlite \
	php7-tokenizer && \
 echo "**** install grocy ****" && \
 mkdir -p /app/grocy && \
 if [ -z ${grocy_RELEASE+x} ]; then \
	grocy_RELEASE=$(curl -sX GET "https://api.github.com/repos/grocy/grocy/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/grocy.tar.gz -L \
	"https://github.com/grocy/grocy/archive/${grocy_RELEASE}.tar.gz" && \
 tar xf \
 /tmp/grocy.tar.gz -C \
	/app/grocy/ --strip-components=1 && \
 echo "**** install composer packages ****" && \
 cd /app/grocy && \
 composer install --no-dev && \
 echo "**** install yarn packages ****" && \
 cd /app/grocy && \
 yarn && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/root/.cache \
	/tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8000
VOLUME /config
