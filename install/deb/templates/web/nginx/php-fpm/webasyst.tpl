#=========================================================================#
# Default Web Domain Template                                             #
# DO NOT MODIFY THIS FILE! CHANGES WILL BE LOST WHEN REBUILDING DOMAINS   #
# https://hestiacp.com/docs/server-administration/web-templates.html      #
#=========================================================================#

server {
	listen      %ip%:%web_port%;
	server_name %domain_idn% %alias_idn%;
	root        %sdocroot%;
	index       index.php index.html index.htm;
	access_log  /var/log/nginx/domains/%domain%.log combined;
	access_log  /var/log/nginx/domains/%domain%.bytes bytes;
	error_log   /var/log/nginx/domains/%domain%.error.log error;

	include %home%/%user%/conf/web/%domain%/nginx.hsts.conf*;

	location = /favicon.ico {
		log_not_found off;
		access_log off;
	}

	location = /robots.txt {
		try_files $uri $uri/ /index.php?$args;
		log_not_found off;
		access_log off;
	}

	location ~ /\.(?!well-known\/) {
		deny all;
		return 404;
	}

    try_files $uri $uri/ /index.php?$query_string;

    location /index.php {
        include /etc/nginx/fastcgi_params;
        fastcgi_param SCRIPT_FILENAME   $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO         $fastcgi_path_info;
        fastcgi_pass %backend_lsnr%;
    }

    # for install only
    location /install.php {
        include /etc/nginx/fastcgi_params;
        fastcgi_param SCRIPT_FILENAME   $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO         $fastcgi_path_info;
        fastcgi_pass %backend_lsnr%;
    }

    location /api.php {
        fastcgi_split_path_info  ^(.+\.php)(.*)$;
        include /etc/nginx/fastcgi_params;
        fastcgi_param SCRIPT_FILENAME   $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO         $fastcgi_path_info;
        fastcgi_pass %backend_lsnr%;
    }

    location ~ /(oauth.php|link.php|payments.php|captcha.php) {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ^~ /wa-data/protected/ {
        internal;
    }

    location ~ /wa-content {
        allow all;
    }

    location ~ /wa-apps/[^/]+/(plugins/[^/]+/)?(lib|locale|templates)/ {
        deny all;
    }

    location ~ /(wa-plugins/([^/]+)|wa-widgets)/.+/(lib|locale|templates)/ {
        deny all;
    }

    location ~* ^/wa-(cache|config|installer|log|system)/ {
        return 403;
    }

    location ~* ^/wa-data/public/contacts/photos/[0-9]+/ {
        root /var/www/fw/;
        access_log off;
        expires  30d;
        error_page   404  =  @contacts_thumb;
    }

    location @contacts_thumb {
        include /etc/nginx/fastcgi_params;
        fastcgi_pass %backend_lsnr%;
        fastcgi_param SCRIPT_FILENAME   $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO         $fastcgi_path_info;
        fastcgi_param SCRIPT_NAME       /wa-data/public/contacts/photos/thumb.php;
        fastcgi_param SCRIPT_FILENAME   $document_root/wa-data/public/contacts/photos/thumb.php;
    }

    # photos app
    location ~* ^/wa-data/public/photos/[0-9]+/ {
        access_log   off;
        expires      30d;
        error_page   404  =  @photos_thumb;
    }

    location @photos_thumb {
        include /etc/nginx/fastcgi_params;
        fastcgi_pass %backend_lsnr%;
        fastcgi_param SCRIPT_FILENAME   $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO         $fastcgi_path_info;        
        fastcgi_param SCRIPT_NAME       /wa-data/public/photos/thumb.php;
        fastcgi_param SCRIPT_FILENAME   $document_root/wa-data/public/photos/thumb.php;
    }
    # end photos app

    # shop app
    location ~* ^/wa-data/public/shop/products/[0-9]+/ {
        access_log   off;
        expires      30d;
        error_page   404  =  @shop_thumb;
    }
    location @shop_thumb {
        include /etc/nginx/fastcgi_params;
        fastcgi_pass %backend_lsnr%;
        fastcgi_param SCRIPT_FILENAME   $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO         $fastcgi_path_info;
        fastcgi_param SCRIPT_NAME       /wa-data/public/shop/products/thumb.php;
        fastcgi_param SCRIPT_FILENAME   $document_root/wa-data/public/shop/products/thumb.php;
    }

    location ~* ^/wa-data/public/shop/promos/[0-9]+ {
        access_log   off;
        expires      30d;
        error_page   404  =  @shop_promo;
    }
    location @shop_promo {
        include /etc/nginx/fastcgi_params;
        fastcgi_pass %backend_lsnr%;
        fastcgi_param SCRIPT_FILENAME   $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO         $fastcgi_path_info;        
        fastcgi_param SCRIPT_NAME       /wa-data/public/shop/promos/thumb.php;
        fastcgi_param SCRIPT_FILENAME   $document_root/wa-data/public/shop/promos/thumb.php;
    }
    # end shop app

    # mailer app
    location ~* ^/wa-data/public/mailer/files/[0-9]+/ {
        access_log   off;
        error_page   404  =  @mailer_file;
    }
    location @mailer_file {
        include /etc/nginx/fastcgi_params;
        fastcgi_pass %backend_lsnr%;
        fastcgi_param SCRIPT_FILENAME   $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO         $fastcgi_path_info;        
        fastcgi_param SCRIPT_NAME       /wa-data/public/mailer/files/file.php;
        fastcgi_param SCRIPT_FILENAME   $document_root/wa-data/public/mailer/files/file.php;
    }
    # end mailer app

    # tasks app
    location ~* ^/wa-data/public/tasks/tasks/[0-9]+/ {
        access_log   off;
        expires      30d;
        error_page   404  =  @tasks_thumb;
    }

    location @tasks_thumb {
        include /etc/nginx/fastcgi_params;
        fastcgi_pass %backend_lsnr%;
        fastcgi_param SCRIPT_FILENAME   $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO         $fastcgi_path_info;        
        fastcgi_param SCRIPT_NAME       /wa-data/public/tasks/tasks/thumb.php;
        fastcgi_param SCRIPT_FILENAME   $document_root/wa-data/public/tasks/tasks/thumb.php;
    }
    # end tasks app

    location ~* ^.+\.(jpg|jpeg|gif|png|webp|js|css)$ {
        access_log   off;
        expires      30d;
    }

## ---

	location /error/ {
		alias %home%/%user%/web/%domain%/document_errors/;
	}

	location /vstats/ {
		alias   %home%/%user%/web/%domain%/stats/;
		include %home%/%user%/web/%domain%/stats/auth.conf*;
	}

	proxy_hide_header Upgrade;

	include /etc/nginx/conf.d/phpmyadmin.inc*;
	include /etc/nginx/conf.d/phppgadmin.inc*;
	include %home%/%user%/conf/web/%domain%/nginx.conf_*;
}
