upstream backend-website {
    server unix:/run/php/php7.2-website.sock;
}

server {
    listen [::]:80;
    listen 80;
    server_name example.my;
    access_log /home/website/logs/nginx_access.log;
    error_log /home/website/logs/nginx_error.log;

    gzip on;
    # Минимальная длина ответа, при которой модуль будет жать, в байтах
    gzip_min_length 1000;
    # Разрешить сжатие для всех проксированных запросов
    gzip_proxied any;
    # MIME-типы которые необходимо жать
    gzip_types text/plain application/xml application/x-javascript text/javascript text/css text/json;
    # Запрещает сжатие ответа методом gzip для IE6 (старый вариант gzip_disable "msie6";)
    gzip_disable "MSIE [1-6]\.(?!.*SV1)";
    # Уровень gzip-компрессии
    gzip_comp_level 6;


    root /home/website/example.my/www;
    index index.php;

    location ~ ^/core/.* {
        deny all;
        return 403;
    }

    location / {
        try_files $uri $uri/ @rewrite;
    }
    location @rewrite {
        rewrite ^/(.*)$ /index.php?q=$1;
    }

    location ~ \.php$ {
    	try_files  $uri =404;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass backend-website;
    }


    location ~* \.(jpg|jpeg|gif|png|css|js|woff|woff2|ttf|eot|zip|tgz|gz|rar|bz2|doc|xls|exe|pdf|ppt|tar|wav|bmp|rtf|swf|ico|flv|txt|docx|xlsx)$ {
        try_files $uri @rewrite;
        access_log off;
        expires 10d;
        break;
    }

    location ~ /\.ht {
        deny all;
    }

}