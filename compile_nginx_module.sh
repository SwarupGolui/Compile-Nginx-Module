#!/bin/bash 

#set versions
nginx_version="1.26.3"
zlib_version="1.3.1"
pcre_version="10.45"
openssl_version="3.4.1"

sudo add-apt-repository ppa:maxmind/ppa
apt-get update
apt-get install wget git make gcc build-essential zlib1g-dev libpcre3 libpcre3-dev unzip uuid-dev libmaxminddb0 libmaxminddb-dev mmdb-bin -y
sudo add-apt-repository --remove ppa:maxmind/ppa

cd ./
wget "https://nginx.org/download/nginx-$nginx_version.tar.gz" -O - | tar -xz

# brotili
git clone --recurse-submodules -j8 https://github.com/google/ngx_brotli
cd ngx_brotli/deps/brotli
mkdir out && cd out
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_CXX_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_INSTALL_PREFIX=./installed ..
cmake --build . --config Release --target brotlienc
cd ../../../..


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


# Download zlib pcre2 openssl
wget "https://github.com/madler/zlib/archive/refs/tags/v$zlib_version.tar.gz" -O - | tar -xz
wget "https://github.com/PhilipHazel/pcre2/releases/download/pcre2-$pcre_version/pcre2-$pcre_version.tar.gz" -O - | tar -xz
wget "https://www.openssl.org/source/openssl-$openssl_version.tar.gz" -O - | tar -xz


cd ./nginx-$nginx_version/

./configure --with-compat --add-dynamic-module=../ngx_brotli --with-zlib=../zlib-$zlib_version --add-dynamic-module=../headers-more-nginx-module --add-dynamic-module=../nginx-module-vts --add-dynamic-module=../echo-nginx-module --add-dynamic-module=../ngx_cache_purge --add-dynamic-module=../ngx_http_geoip2_module --with-pcre=../pcre2-$pcre_version --with-openssl=../openssl-$openssl_version 
make modules
cd ..
tar -cvf ./modules.tar.gz ./nginx-$nginx_version/objs/*.so
