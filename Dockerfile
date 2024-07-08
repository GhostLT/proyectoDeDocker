# usa la imagen oficial de nginx
FROM nginx:alpine
ADD nginx.conf /etc/nginx/nginx.conf
ADD conf.d/default.conf /etc/nginx/conf.d/default.conf

# Instalar bash y nano
RUN apt-get update \
    && apt-get install -y bash nano \
    && rm -rf /var/lib/apt/lists/*

# Instalar bash y nano en MySQL
FROM mysql:5.7
RUN apt-get update \
    && apt-get install -y bash nano \
    && rm -rf /var/lib/apt/lists/*

# Usa la imagen base oficial PHP 8.0 FPM 
FROM php:8.0-fpm
 
# Declaramos la carpeta de trabajo
WORKDIR /var/www/html
 
# Instala dependencias
RUN apt-get update && apt-get install -y \
    nginx \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
   sendmail libpng-dev \
   libzip-dev \
   zlib1g-dev \
   libonig-dev \
    locales \
    zip \
    unzip \
    && apt-get clean
 
# Instalar MYSQL extensiones
RUN docker-php-ext-install mysqli
# Include alternative DB driver
RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_mysql
 
# Instalar extensiones de Docker
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install zip
RUN docker-php-ext-install gd
 
# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd mysqli pdo_mysql opcache
 
# Remueve el archivo de configuracion por default de Nginx
#RUN rm /etc/nginx/nginx.conf
 
# Copia el archivo de configuracion personalizado de Nginx
#COPY nginx.conf /etc/nginx/nginx.conf
 
# Asegura archivos y carpetas para que esten accesibles
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html
 
# Expone el puerto 9000 e inicia php-fpm server
EXPOSE 9000
 
CMD ["php-fpm"]
 
# permite a Nginx ser ejecutado to be run
CMD ["nginx", "-g", "daemon off;"]
 
