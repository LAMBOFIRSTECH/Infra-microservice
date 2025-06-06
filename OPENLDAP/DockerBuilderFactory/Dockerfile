# Étape 1 : Téléchargement de  l'image docker du registry privé 
FROM lambops/phpadminldap:no-vuln-alpine3.21

# Étape 2 : Configuration PHP-FPM
RUN sed -i 's/^;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php82/php.ini \
    && sed -i '/class page {/a \
    public $index = null; \
    protected $_block = []; \
    protected $sysmsg = []; \
    ' /var/www/localhost/htdocs/lib/page.php \
    && sed -i 's/^memory_limit = 128M/memory_limit = 256M/' /etc/php82/php.ini \
    && sed -i 's/^expose_php = On/expose_php = Off/' /etc/php82/php.ini 

# Étape 3 : Copie des fichiers de configuration de base pour phpLDAPadmin et Apache SSL
COPY config.php /var/www/localhost/htdocs/config/config.php
COPY Query.php /var/www/localhost/htdocs/lib/Query.php
COPY import_functions.php /var/www/localhost/htdocs/lib/import_functions.php
COPY functions.php /var/www/localhost/htdocs/lib/functions.php
COPY Template.php /var/www/localhost/htdocs/lib/Template.php
COPY TemplateRender.php /var/www/localhost/htdocs/lib/TemplateRender.php
COPY AJAXTree.php /var/www/localhost/htdocs/lib/AJAXTree.php
COPY HTMLTree.php /var/www/localhost/htdocs/lib/HTMLTree.php
COPY BinaryAttribute.php /var/www/localhost/htdocs/lib/BinaryAttribute.php 
COPY DateAttribute.php /var/www/localhost/htdocs/lib/DateAttribute.php 
COPY DnAttribute.php /var/www/localhost/htdocs/lib/DnAttribute.php 
COPY GidAttribute.php /var/www/localhost/htdocs/lib/GidAttribute.php 
COPY JpegAttribute.php /var/www/localhost/htdocs/lib/JpegAttribute.php
COPY MultiLineAttribute.php /var/www/localhost/htdocs/lib/MultiLineAttribute.php
COPY MassRender.php /var/www/localhost/htdocs/lib/MassRender.php
COPY ObjectClassAttribute.php /var/www/localhost/htdocs/lib/ObjectClassAttribute.php
COPY PageRender.php /var/www/localhost/htdocs/lib/PageRender.php
COPY PasswordAttribute.php /var/www/localhost/htdocs/lib/PasswordAttribute.php
COPY QueryRender.php /var/www/localhost/htdocs/lib/QueryRender.php
COPY RandomPasswordAttribute.php /var/www/localhost/htdocs/lib/RandomPasswordAttribute.php
COPY SambaPasswordAttribute.php /var/www/localhost/htdocs/lib/SambaPasswordAttribute.php
COPY SelectionAttribute.php /var/www/localhost/htdocs/lib/SelectionAttribute.php
COPY ShadowAttribute.php   /var/www/localhost/htdocs/lib/ShadowAttribute.php
COPY common.php   /var/www/localhost/htdocs/lib/common.php
COPY ds_ldap.php   /var/www/localhost/htdocs/lib/ds_ldap.php
COPY ds_ldap_pla.php   /var/www/localhost/htdocs/lib/ds_ldap_pla.php
COPY hooks.php   /var/www/localhost/htdocs/lib/hooks.php
COPY query_functions.php   /var/www/localhost/htdocs/lib/query_functions.php
COPY template_functions.php   /var/www/localhost/htdocs/lib/template_functions.php
COPY PLAAttribute.php /var/www/localhost/htdocs/lib/PLAAttribute.php

COPY httpd.conf /etc/apache2/httpd.conf
COPY ssl.conf /etc/apache2/sites-available/ssl.conf
COPY supervisord.conf /etc/supervisord.conf 

# Étape 4 : Répertoires et permissions Apache
RUN apk add apache2-proxy \
    && apk add --no-cache supervisor \
    && apk add --no-cache openrc \
    && mkdir -p /var/log/php82 && chown -R www-data:www-data /var/log/php82 \
    && mkdir -p /var/www/logs && chown -R www-data:www-data /var/www/logs \
    && mkdir -p /run/php/ && chown -R www-data:www-data /run/php \
    && sed -i 's|^listen = .*|listen = /run/php/php82-fpm.sock|' /etc/php82/php-fpm.d/www.conf \
    && echo -e "listen.owner = www-data\nlisten.group = www-data\nlisten.mode = 0660" >> /etc/php82/php-fpm.d/www.conf \
    && sed -i 's|^;php_admin_value\[error_log\] =.*|php_admin_value[error_log] = /var/log/php82/error.log|' /etc/php82/php-fpm.d/www.conf \
    && sed -i 's|^;php_admin_flag\[log_errors\] =.*|php_admin_flag[log_errors] = on|' /etc/php82/php-fpm.d/www.conf \
    && ln -sf /etc/apache2/sites-available/ssl.conf /etc/apache2/conf.d/ssl.conf \
    && touch /run/supervisord.sock

# Étape 5 : Exposer les ports 80 et 443 pour HTTP et HTTPS
EXPOSE 80 443
# Commande par défaut pour démarrer PHP-FPM avec Apach
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]