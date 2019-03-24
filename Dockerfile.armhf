FROM lsiobase/nginx:arm32v7-3.9

# set version label
ARG BUILD_DATE
ARG VERSION
ARG GROCY_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips, homerr"

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
 if [ -z ${GROCY_RELEASE+x} ]; then \
	GROCY_RELEASE=$(curl -sX GET "https://api.github.com/repos/grocy/grocy/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
	/tmp/grocy.tar.gz -L \
	"https://github.com/grocy/grocy/archive/${GROCY_RELEASE}.tar.gz" && \
 tar xf \
	/tmp/grocy.tar.gz -C \
	/app/grocy/ --strip-components=1 && \
 cp -R /app/grocy/data/plugins \
	/defaults/plugins && \
 echo "**** install composer packages ****" && \
 composer install -d /app/grocy --no-dev && \
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
EXPOSE 6781
VOLUME /config
