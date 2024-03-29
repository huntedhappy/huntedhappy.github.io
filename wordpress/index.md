# The Documentation Wordpress &amp; Nginx Install


NGINX를 사용하여 WORDPRESS를 설치

## 1. NGINX 설치
{{&lt; admonition tip &#34;설치&#34; &gt;}}
#### NGINX 설치
```shell
sudo add-apt-repository ppa:ondrej/nginx -y
sudo apt-get update
sudo apt-get dist-upgrade -y
sudo apt-get install nginx -y

nginx -v
```
#### PHP 설치
```shell
sudo add-apt-repository ppa:ondrej/php -y
sudo apt-get update
sudo apt-get install php8.0-fpm php8.0-common php8.0-mysql \
php8.0-xml php8.0-xmlrpc php8.0-curl php8.0-gd \
php8.0-imagick php8.0-cli php8.0-dev php8.0-imap \
php8.0-mbstring php8.0-opcache php8.0-redis \
php8.0-soap php8.0-zip -y

php-fpm8.0 -v
```

#### NGINX 구성
```shell
cat &lt;&lt; EOF | tee /etc/nginx/sites-available/wordpress.tkg.io
server {
    listen 80;

    server_name wordpress.tkg.io;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    root /var/www/html;
    index index.php;

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.0-fpm.sock;
    }
}
EOF

rm -rf /etc/nginx/sites-available/default
rm -rf /etc/nginx/sites-enabled/default

## Symbolic Link
sudo ln -s /etc/nginx/sites-available/wordpress.tkg.io /etc/nginx/sites-enabled/wordpress.tkg.io

sed -i -e &#34;s/font\/woff2                            woff/font\/woff2                            woff2/g&#34; /etc/nginx/mime.types

## Validataion Check
nginx -t

## Nginx Reload
nginx -s reload
```

#### PHP 파일 수정
```shell
sed -i -e &#34;s/upload_max_filesize = 2M/upload_max_filesize = 64M/g&#34; /etc/php/8.0/fpm/php.ini

sed -i -e &#34;s/post_max_size = 8M/post_max_size = 64M/g&#34; /etc/php/8.0/fpm/php.ini

sudo php-fpm8.0 -t
sudo systemctl restart php8.0-fpm
```
#### MARIADB 설치
```shell
sudo apt-get install software-properties-common
sudo apt-key adv --fetch-keys &#39;https://mariadb.org/mariadb_release_signing_key.asc&#39;
sudo add-apt-repository &#39;deb [arch=amd64,arm64,ppc64el] http://mirrors.up.pt/pub/mariadb/repo/10.4/ubuntu focal main&#39;
sudo apt-get install mariadb-server -y
```
### MARIADB PASSWORD 변경
```shell
mysql -u root -e &#39;create database wordpress character set utf8; grant all privileges on wordpress.* to &#39;root&#39;@&#39;localhost&#39; identified by &#34;WordPress!234&#34;; flush privileges;&#39;
```

#### WordPress 설치
```shell
mkdir /wordpress
cd /wordpress &amp;&amp; wget http://wordpress.org/latest.tar.gz &amp;&amp; tar -xzf /wordpress/latest.tar.gz -C /wordpress --strip-components 1

```
#### WordPress 설정
```shell
cp /wordpress/wp-config-sample.php /wordpress/wp-config.php
sed -i -e &#34;s/database_name_here/wordpress/g&#34; /wordpress/wp-config.php
sed -i -e &#34;s/username_here/root/g&#34; /wordpress/wp-config.php
sed -i -e &#34;s/password_here/WordPress\!234/g&#34; /wordpress/wp-config.php

cp -R * /var/www/html/
```
{{&lt; /admonition &gt;}}

### 완료 화면

{{&lt; figure src=&#34;/images/wordpress/1-1.png&#34; title=&#34;wordpress-install&#34; &gt;}}

---

> Author: Dokyung  
> URL: https://huntedhappy.github.io/wordpress/  

