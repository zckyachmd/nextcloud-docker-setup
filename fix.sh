docker-compose exec nextcloud bash -c 'echo -e "<IfModule mod_headers.c>\n    Header always set Strict-Transport-Security \"max-age=15552000; includeSubDomains\"\n</IfModule>" >> /var/www/html/.htaccess'

docker-compose exec nextcloud bash -c "php /var/www/html/occ maintenance:repair --include-expensive"

docker-compose exec nextcloud bash -c "php /var/www/html/occ db:add-missing-indices"

docker-compose exec nextcloud bash -c "php /var/www/html/occ maintenance:mode --off"

docker-compose exec nextcloud bash -c "php /var/www/html/occ config:system:set maintenance_window_start --type=integer --value=1"

docker-compose exec nextcloud bash -c "php /var/www/html/occ config:system:set default_phone_region --value='ID'"
