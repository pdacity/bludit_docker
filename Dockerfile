FROM alpine:3.9

MAINTAINER Dmitry Malinin <dmitry.malinin@gmail.com>

ENV nginx_conf /etc/nginx/nginx.conf
ENV php_conf /etc/php7/php.ini
ENV fpm_conf /etc/php7/php-fpm.conf
ENV fpm_pool /etc/php7/php-fpm.d/www.conf

RUN apk add --no-cache nginx php-fpm php-gd php-json php-dom php-xml php-zip php-mbstring 
RUN apk add supervisor unzip jq curl

# Configs files
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" ${php_conf} && \
    sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" ${php_conf} && \
    sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" ${php_conf} && \
    sed -i -e "s/variables_order = \"GPCS\"/variables_order = \"EGPCS\"/g" ${php_conf}

RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" ${fpm_conf}

RUN sed -i -e "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g" ${fpm_pool} && \
    sed -i -e "s/;listen.owner = nobody/listen.owner = nginx/g" ${fpm_pool} && \
    sed -i -e "s/;listen.group = nobody/listen.group = nginx/g" ${fpm_pool} && \
    sed -i -e "s/user = nobody/user = nginx/g" ${fpm_pool} && \
    sed -i -e "s/group = nobody/group = nginx/g" ${fpm_pool}


# Disable run nginx in daemon mode
RUN echo "daemon off;" >> ${nginx_conf}

RUN mkdir -p /var/lib/php7/session && \
    chown -R nginx:nginx /var/lib/php7/session

# Cleaning
RUN rm -rf /etc/nginx/conf.d/* && \
    rm -rf /var/cache/*

## forward request and error logs to docker log collector
#RUN ln -sf /dev/stdout /var/log/nginx/access.log
#RUN ln -sf /dev/stderr /var/log/nginx/error.log

# Configurations files
ADD conf/default.conf /etc/nginx/conf.d/default.conf
ADD conf/nginx.conf /etc/nginx/nginx.conf
ADD conf/supervisord.conf /etc/supervisord.conf

# Nginx logs to Docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# Bludit installation
RUN cd /tmp/ && \
    curl -o /tmp/bludit.zip `curl --silent https://version.bludit.com | jq -r .stable.downloadLink` && \
    unzip /tmp/bludit.zip && \
    rm -rf /var/www && \
    mv bludit-* /var/www && \
    chown -R nginx:nginx /var/www && \
    chmod 755 /var/www/bl-content && \
    rm -f /tmp/bludit.zip

EXPOSE 80

CMD ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisord.conf"]


