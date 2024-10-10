# Use the official PHP image with Apache
FROM php:8.3-apache

# Set environment variables
ENV COMPOSER_ALLOW_SUPERUSER=1 \
    APP_ENV=local \
    DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /var/www/html

# Install necessary dependencies, enable extensions, and set up Composer in one layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    curl \
    libpq-dev \
    libzip-dev \
    default-mysql-client \
    vim \
    nano \
    libmcrypt-dev \
    && docker-php-ext-install \
    date \
    dom \
    filter \
    gd \
    hash \
    json \
    pcre \
    pdo \
    session \
    SimpleXML \
    SPL \
    tokenizer \
    xml \
    zip \
    && a2enmod rewrite \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Clone the LocalGov Drupal repository
RUN git clone https://github.com/localgovdrupal/localgov.git /var/www/html

# Allow necessary Composer plugins
RUN composer config --no-plugins allow-plugins.cweagans/composer-patches true \
    && composer config --no-plugins allow-plugins.phpstan/extension-installer true \
    && composer config --no-plugins allow-plugins.dealerdirect/phpcodesniffer-composer-installer true

# Install PHP dependencies with Composer
RUN composer install --no-interaction --optimize-autoloader

# Set appropriate permissions for Apache
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Expose port 80 for the web server
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]
