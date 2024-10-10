# Use the official PHP image with Apache
FROM php:8.1-apache

# Set environment variables
ENV COMPOSER_ALLOW_SUPERUSER=1 \
    APP_ENV=local \
    DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /var/www/html

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
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
    default-mysql-client \   # Updated: use default-mysql-client instead of mysql-client
    vim \
    nano \
    libmcrypt-dev \
    && docker-php-ext-install pdo pdo_mysql pdo_pgsql zip gd


# Enable Apache rewrite module for Drupal
RUN a2enmod rewrite

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Clone the LocalGov Drupal repository
RUN git clone https://github.com/localgovdrupal/localgov.git /var/www/html

# Install PHP dependencies with Composer
RUN composer install --no-interaction --optimize-autoloader

# Set appropriate permissions for Apache
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Expose port 80 for the web server
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]
