# =============================================================================
# Stage 1: Build GLPI assets (Node.js + PHP + Composer)
# =============================================================================
FROM debian:12 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl ca-certificates lsb-release gnupg git unzip \
    && curl -sSLo /usr/share/keyrings/sury-php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/sury-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" \
       > /etc/apt/sources.list.d/php.list \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y \
        nodejs \
        php8.3-cli php8.3-mysql php8.3-bz2 php8.3-zip php8.3-curl \
        php8.3-gd php8.3-mbstring php8.3-xml php8.3-ldap php8.3-imap \
        php8.3-intl php8.3-bcmath \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY . .

RUN composer install --ignore-platform-reqs --prefer-dist --no-progress --no-interaction \
    && bin/console tools:locales:compile \
    && npm ci \
    && npm run build \
    && bin/console build:compile_scss \
    && composer update nothing --no-dev --ignore-platform-reqs --no-interaction \
    && bin/console build:generate_code_manifest -a crc32c \
    && rm -rf node_modules tests .git tools stubs .github

# =============================================================================
# Stage 2: Fetch singlesignon plugin from GabrAGM fork
# =============================================================================
FROM debian:12 AS plugin-builder

ARG PLUGIN_REF=master
RUN apt-get update && apt-get install -y curl ca-certificates --no-install-recommends && apt-get clean && \
    mkdir -p /plugins/singlesignon && \
    curl -sL "https://github.com/GabrAGM/glpi-singlesignon/archive/refs/heads/${PLUGIN_REF}.tar.gz" \
      | tar -xz --strip-components=1 -C /plugins/singlesignon

# =============================================================================
# Stage 3: Runtime (Apache + PHP 8.3)
# =============================================================================
FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive
ENV TIMEZONE=UTC

RUN apt-get update && \
    apt-get install -y lsb-release ca-certificates apt-transport-https curl cron jq \
        libldap-2.5-0 libsasl2-2 ldap-utils \
    && curl -sSLo /usr/share/keyrings/sury-php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/sury-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" \
       > /etc/apt/sources.list.d/php.list \
    && apt-get update \
    && apt-get install -y \
        apache2 \
        php8.3 libapache2-mod-php8.3 \
        php8.3-mysql php8.3-bz2 php8.3-zip php8.3-curl php8.3-gd \
        php8.3-mbstring php8.3-xml php8.3-ldap php8.3-imap \
        php8.3-intl php8.3-bcmath php8.3-redis \
        php-cas \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html/glpi

# Copy built GLPI source
COPY --from=builder  --chown=www-data:www-data /build .

# Copy singlesignon plugin
COPY --from=plugin-builder --chown=www-data:www-data /plugins/singlesignon ./plugins/singlesignon

# Ensure runtime directories exist
RUN mkdir -p files/_log files/_sessions files/_uploads files/_tmp \
    && chown -R www-data:www-data /var/www/html/glpi

# Apache config
COPY docker/apache-glpi.conf /etc/apache2/sites-available/glpi.conf
RUN a2ensite glpi && a2dissite 000-default && a2enmod rewrite headers

# Entrypoint
COPY docker/entrypoint.sh /opt/glpi-start.sh
RUN chmod +x /opt/glpi-start.sh

EXPOSE 80 443

ENTRYPOINT ["/opt/glpi-start.sh"]
