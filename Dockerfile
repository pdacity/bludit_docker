FROM alpine:3.7

MAINTAINER Dmitry Malinin <dmitry@malinin.com>

ENV nginx_conf /etc/nginx/nginx.conf
ENV php_conf /etc/php5/php.ini
ENV fpm_conf /etc/php5/php-fpm.conf
ENV bludit_url https://www.bludit.com/releases/bludit-3-9-2.zip

RUN apk add --no-cache nginx php5-fpm php5-gd php5-json php5-dom php5-xml php5-zip supervisor unzip curl 

# Edit config files
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" ${php_conf} && \
    sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" ${php_conf} && \
    sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" ${php_conf} && \
    sed -i -e "s/variables_order = \"GPCS\"/variables_order = \"EGPCS\"/g" ${php_conf} && \
    sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" ${fpm_conf} && \
    sed -i -e "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g" ${fpm_conf} && \
    sed -i -e "s/;listen.owner = nobody/listen.owner = nginx/g" ${fpm_conf} && \
    sed -i -e "s/;listen.group = nobody/listen.group = nginx/g" ${fpm_conf} && \
    sed -i -e "s/user = nobody/user = nginx/g" ${fpm_conf} && \
    sed -i -e "s/group = nobody/group = nginx/g" ${fpm_conf} && \
    sed -i -e "s/;ping.path = \/ping/ping.path = \/fpm-ping/g" ${fpm_conf} && \
    sed -i -e "s/;pm.status_path = \/status/pm.status_path = \/fpm-status/g" ${fpm_conf}

# Fix owner & Cleanup
RUN mkdir -p /var/lib/php/session && \
    chown -R nginx:nginx /var/lib/php/session && \
    rm -rf /etc/nginx/conf.d/* && \
    rm -rf /var/cache/*

# Copy custom config files
ADD conf/default.conf /etc/nginx/conf.d/default.conf
ADD conf/nginx.conf /etc/nginx/nginx.conf
ADD conf/supervisord.conf /etc/supervisord.conf

# Nginx logs to Docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# Bludit installation
RUN cd /tmp/ && \
    curl -o /tmp/bludit.zip ${bludit_url} && \
    unzip /tmp/bludit.zip && \
    rm -rf /var/www && \
    mv bludit-* /var/www && \
    chown -R nginx:nginx /var/www && \
    chmod 755 /var/www/bl-content && \
    rm -f /tmp/bludit.zip

EXPOSE 80

HEALTHCHECK --interval=10s --timeout=3s --retries=3 --start-period=3s CMD curl --silent --fail http://127.0.0.1/fpm-ping

CMD ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisord.conf"]

