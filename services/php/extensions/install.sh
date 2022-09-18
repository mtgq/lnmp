#!/bin/sh

export MC="-j$(nproc)"

apk --update add --no-cache --virtual .build-deps autoconf g++ libtool make curl-dev gettext-dev linux-headers \
    && docker-php-ext-install ${MC} pdo_mysql \
    && docker-php-ext-install ${MC} mysqli \
    && docker-php-ext-install ${MC} session \
    && docker-php-ext-install ${MC} pcntl \
    && docker-php-ext-install ${MC} bcmath \
    && docker-php-ext-install ${MC} calendar \
    && docker-php-ext-install ${MC} exif \
    && docker-php-ext-install ${MC} sockets \



#
# Check if current php version is greater than or equal to
# specific version.
#
# For example, to check if current php is greater than or
# equal to PHP 7.0:
#
# isPhpVersionGreaterOrEqual 7 0
#
# Param 1: Specific PHP Major version
# Param 2: Specific PHP Minor version
# Return : 1 if greater than or equal to, 0 if less than
#
isPhpVersionGreaterOrEqual()
 {
    local PHP_MAJOR_VERSION=$(php -r "echo PHP_MAJOR_VERSION;")
    local PHP_MINOR_VERSION=$(php -r "echo PHP_MINOR_VERSION;")

    if [[ "$PHP_MAJOR_VERSION" -gt "$1" || "$PHP_MAJOR_VERSION" -eq "$1" && "$PHP_MINOR_VERSION" -ge "$2" ]]; then
        return 1;
    else
        return 0;
    fi
}


#
# Install extension from package file(.tgz),
# For example:
#
# installExtensionFromTgz redis-5.2.2
#
# Param 1: Package name with version
# Param 2: enable options
#
installExtensionFromTgz()
{
    tgzName=$1
    extensionName="${tgzName%%-*}"

    mkdir ${extensionName}
    tar -xf ${tgzName}.tgz -C ${extensionName} --strip-components=1
    ( cd ${extensionName} && phpize && ./configure && make ${MC} && make install )

    docker-php-ext-enable ${extensionName} $2
}

echo "---------- Install gd ----------"
isPhpVersionGreaterOrEqual 7 4

if [[ "$?" = "1" ]]; then
    # "--with-xxx-dir" was removed from php 7.4,
    # issue: https://github.com/docker-library/php/issues/912
    options="--with-freetype --with-jpeg --with-webp"
else
    options="--with-gd --with-freetype-dir=/usr/include/ --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-webp-dir=/usr/include/"
fi

apk add --no-cache \
    freetype \
    freetype-dev \
    libpng \
    libpng-dev \
    libjpeg-turbo \
    libjpeg-turbo-dev \
libwebp-dev \
&& docker-php-ext-configure gd ${options} \
&& docker-php-ext-install ${MC} gd \
&& apk del \
    freetype-dev \
    libpng-dev \
    libjpeg-turbo-dev

echo "---------- Install zip ----------"
# Fix: https://github.com/docker-library/php/issues/797
apk add --no-cache libzip-dev

isPhpVersionGreaterOrEqual 7 4
if [[ "$?" != "1" ]]; then
    docker-php-ext-configure zip --with-libzip=/usr/include
fi

docker-php-ext-install ${MC} zip


echo "---------- Install phalcon ----------"
isPhpVersionGreaterOrEqual 7 2

if [[ "$?" = "1" ]]; then
    printf "\n" | pecl install phalcon
    docker-php-ext-enable psr
    docker-php-ext-enable phalcon
else
    echo "---------- PHP Version>= 7.2----------"
fi

apk del .build-deps \
    && docker-php-source delete
