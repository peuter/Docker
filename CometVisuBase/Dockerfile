FROM php:7.2-apache as builder

##################
# Compile knxd 0.0.5.1
RUN apt-get -qq update \
 && apt-get install -y python python-dev python-pip python-virtualenv \
 && apt-get install -y build-essential gcc git rsync cmake make g++ binutils automake flex bison patch wget libtool \
 && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

ENV KNXDIR /usr
ENV INSTALLDIR $KNXDIR/local
ENV SOURCEDIR  $KNXDIR/src
ENV LD_LIBRARY_PATH $INSTALLDIR/lib

WORKDIR $SOURCEDIR

# build pthsem
ENV PTHSEM_DOWNLOAD_SHA256 4024cafdd5d4bce2b1778a6be5491222c3f6e7ef1e43971264c451c0012c5c01
RUN wget -O pthsem_2.0.8.tar.gz "https://osdn.net/frs/g_redir.php?m=kent&f=bcusdk%2Fpthsem%2Fpthsem_2.0.8.tar.gz" \
 && echo "$PTHSEM_DOWNLOAD_SHA256 pthsem_2.0.8.tar.gz" | sha256sum -c - \
 && tar -xzf pthsem_2.0.8.tar.gz \
 && cd pthsem-2.0.8 && ./configure --prefix=$INSTALLDIR/ && make && make test && make install

# build knxd
ENV KNXD_DOWNLOAD_SHA256 f47a02efd8618dc1ec5837e08017dabbaa2712a9b9c36af7784426cc9429455e
RUN wget -O knxd_0.0.5.1.tar.gz "https://github.com/knxd/knxd/archive/0.0.5.1.tar.gz" \
 && echo "$KNXD_DOWNLOAD_SHA256 knxd_0.0.5.1.tar.gz" | sha256sum -c - \
 && tar -xzf knxd_0.0.5.1.tar.gz \
 && cd knxd-0.0.5.1 && ./bootstrap.sh \
 && ./configure --enable-onlyeibd --enable-eibnetip --enable-eibnetiptunnel --disable-eibnetipserver \
    --disable-ft12 --disable-pei16 --disable-tpuart --disable-pei16s  --disable-tpuarts --disable-usb --disable-ncn5120 \
    --enable-groupcache --disable-java \
    --disable-shared --enable-static \
    --prefix=$INSTALLDIR/ --with-pth=$INSTALLDIR/ \
 && make && make install

##############
# Run environment
FROM php:7.2-apache

ARG TRAVIS_JOB_NUMBER
ARG TRAVIS_JOB_WEB_URL
ARG TRAVIS_BUILD_WEB_URL
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION_TAG

# Own labels
LABEL maintainer="http://www.cometvisu.org/"
LABEL org.cometvisu.pthsem.version="2.0.8"
LABEL org.cometvisu.knxd.version="0.0.5.1"
LABEL org.cometvisu.travis-job-number=$TRAVIS_JOB_NUMBER
LABEL org.cometvisu.travis-job-web-url=$TRAVIS_JOB_WEB_URL
LABEL org.cometvisu.travis-build-web-url=$TRAVIS_BUILD_WEB_URL
# Labels according to http://label-schema.org/rc1/
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="CometVisu"
LABEL org.label-schema.description="The CometVisu visualistion"
LABEL org.label-schema.usage="README.md"
LABEL org.label-schema.url="https://www.cometvisu.org"
LABEL org.label-schema.vcs-url="https://github.com/CometVisu/CometVisu"
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.vendor="The CometVisu project"
LABEL org.label-schema.version=$VERSION_TAG

COPY --from=builder /usr/local/bin/knxd /usr/bin/knxd
COPY --from=builder /usr/local/lib/libpthsem.so.20 /usr/lib/
COPY --from=builder /usr/src/knxd-0.0.5.1/src/examples/busmonitor1 /usr/src/knxd-0.0.5.1/src/examples/vbusmonitor1 /usr/src/knxd-0.0.5.1/src/examples/vbusmonitor1time /usr/src/knxd-0.0.5.1/src/examples/vbusmonitor2 /usr/src/knxd-0.0.5.1/src/examples/groupswrite /usr/src/knxd-0.0.5.1/src/examples/groupwrite /usr/src/knxd-0.0.5.1/src/examples/groupread /usr/src/knxd-0.0.5.1/src/examples/groupreadresponse /usr/src/knxd-0.0.5.1/src/examples/groupcacheread /usr/src/knxd-0.0.5.1/src/examples/groupsocketread /usr/local/bin/
COPY --from=builder /usr/src/knxd-0.0.5.1/src/examples/eibread-cgi /usr/lib/cgi-bin/r
COPY --from=builder /usr/src/knxd-0.0.5.1/src/examples/eibwrite-cgi /usr/lib/cgi-bin/w

##################

# Overwrite package default - allow index
RUN { \
    echo '<FilesMatch \.php$>'; \
    echo '\tSetHandler application/x-httpd-php'; \
    echo '</FilesMatch>'; \
    echo; \
    echo 'DirectoryIndex enabled'; \
    echo 'DirectoryIndex index.php index.html'; \
    echo; \
    echo '<Directory /var/www/>'; \
    echo '\tOptions +Indexes'; \
    echo '\tAllowOverride All'; \
    echo '</Directory>'; \
    } | tee "$APACHE_CONFDIR/conf-available/cm-docker-php.conf" \
 && a2disconf docker-php \
 && a2enconf cm-docker-php \
 && { \
    echo "#!/bin/sh"; \
    echo "echo Content-Type: text/plain"; \
    echo "echo"; \
    echo 'echo "{ \"v\":\"0.0.1\", \"s\":\"SESSION\" }"'; \
    } | tee "/usr/lib/cgi-bin/l" \
 && chmod +x /usr/lib/cgi-bin/l \
 && a2enmod cgi \
 && a2enmod headers

COPY cometvisu-entrypoint /usr/local/bin/cometvisu-entrypoint
ENTRYPOINT ["cometvisu-entrypoint"]

ENV KNX_INTERFACE iptn:172.17.0.1:3700
ENV KNX_PA 1.1.238
ENV KNXD_PARAMETERS -u -d/var/log/eibd.log -c

ENV CGI_URL_PATH /cgi-bin/
ENV BACKEND_PROXY_SOURCE ""
ENV BACKEND_PROXY_TARGET ""

# TODO:
# HEALTHCHECK

CMD ["apache2-foreground"]
