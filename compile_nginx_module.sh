#!/bin/bash 

#set versions
nginx_version="1.24.0"
zlib_version="1.2.13"
pcre_version="10.42"
openssl_version="3.0.8"

sudo add-apt-repository ppa:maxmind/ppa
apt-get update
apt-get install wget git make gcc build-essential zlib1g-dev libpcre3 libpcre3-dev unzip uuid-dev libmaxminddb0 libmaxminddb-dev mmdb-bin -y
sudo add-apt-repository --remove ppa:maxmind/ppa

cd ./
wget "https://nginx.org/download/nginx-$nginx_version.tar.gz" -O - | tar -xz

# brotili
git clone --recurse-submodules https://github.com/google/ngx_brotli.git

# headers-more
git clone https://github.com/openresty/headers-more-nginx-module.git

# nginx-module-vts
git clone https://github.com/vozlt/nginx-module-vts.git

# echo-nginx-module
git clone https://github.com/openresty/echo-nginx-module.git

# nginx_cache_purge
git clone https://github.com/nginx-modules/ngx_cache_purge.git

# ngx_http_geoip2_module
git clone https://github.com/leev/ngx_http_geoip2_module.git

# pagespeed $ PSOL
git clone --depth=1 https://github.com/apache/incubator-pagespeed-ngx.git
wget http://www.tiredofit.nl/psol-jammy.tar.xz
tar xvf psol-jammy.tar.xz
mv psol incubator-pagespeed-ngx



# Download zlib
wget "https://github.com/madler/zlib/archive/refs/tags/v$zlib_version.tar.gz" -O - | tar -xz
wget "https://github.com/PhilipHazel/pcre2/releases/download/pcre2-$pcre_version/pcre2-$pcre_version.tar.gz" -O - | tar -xz
wget "https://www.openssl.org/source/openssl-$openssl_version.tar.gz" -O - | tar -xz


cd ./nginx-$nginx_version/

./configure --with-compat --add-dynamic-module=../ngx_brotli --with-zlib=../zlib-$zlib_version --add-dynamic-module=../headers-more-nginx-module --add-dynamic-module=../nginx-module-vts --add-dynamic-module=../echo-nginx-module --add-dynamic-module=../ngx_cache_purge --add-dynamic-module=../ngx_http_geoip2_module --add-dynamic-module=../incubator-pagespeed-ngx --with-pcre=../pcre2-$pcre_version --with-openssl=../openssl-$openssl_version 
make modules
cd ..
tar -cvf ./modules.tar.gz ./nginx-$nginx_version/objs/*.so
