# Étape 1 : Téléchargement de  l'image docker du registry privé 
FROM lambops/phpadminldap:no-vuln-alpine3.21

# Étape 2 : Configuration PHP-FPM
RUN sed -i 's/^;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php82/php.ini

# Étape 3 : Copie des fichiers de configuration de base pour phpLDAPadmin et Apache SSL
COPY config.php /var/www/localhost/htdocs/config/config.php
COPY httpd.conf /etc/apache2/httpd.conf
COPY ssl.conf /etc/apache2/sites-available/ssl.conf
COPY entrypoint.sh /entrypoint.sh
COPY supervisord.conf /etc/supervisord.conf
RUN ln -sf /etc/apache2/sites-available/ssl.conf /etc/apache2/conf.d/ssl.conf 

# Étape 4 : Répertoires et permissions Apache
RUN apk add apache2-proxy \
    &&  apk add --no-cache supervisor \
    && mkdir -p /var/log/php82 && chown -R www-data:www-data /var/log/php82 \
    && mkdir -p /var/www/logs && chown -R www-data:www-data /var/www/logs \
    && sed -i 's/^memory_limit = 128M/memory_limit = 256M/' /etc/php82/php.ini \
    && sed -i 's/^expose_php = On/expose_php = Off/' /etc/php82/php.ini \
    && mkdir -p /run/php/ && chown -R www-data:www-data /run/php \
    && sed -i 's|^listen = .*|listen = /run/php/php82-fpm.sock|' /etc/php82/php-fpm.d/www.conf \
    && echo -e "listen.owner = www-data\nlisten.group = www-data\nlisten.mode = 0660" >> /etc/php82/php-fpm.d/www.conf \
    && sed -i 's|^;php_admin_value\[error_log\] =.*|php_admin_value[error_log] = /var/log/php82/error.log|' /etc/php82/php-fpm.d/www.conf \
    && sed -i 's|^;php_admin_flag\[log_errors\] =.*|php_admin_flag[log_errors] = on|' /etc/php82/php-fpm.d/www.conf 
 

# Étape 5 : Exposer les ports 80 et 443 pour HTTP et HTTPS
EXPOSE 80 443
# Commande par défaut pour démarrer PHP-FPM avec Apach
#CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
ENTRYPOINT [ "/entrypoint.sh" ]