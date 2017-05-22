#!/bin/bash

set -x

cat $0

echo "=== Install selenium server"
apt-get install php5-curl
apt-get install default-jdk
apt-get install php5-imagick
xvfb-run -a -s "-screen 0" firefox &


INITIAL_DIR=$(pwd)
mkdir -p /var/selenium/
cd /var/selenium/
curl -LO http://selenium-release.storage.googleapis.com/2.53/selenium-server-standalone-2.53.1.jar
cd $INITIAL_DIR

java -jar /var/selenium/selenium-server-standalone-2.53.1.jar &>/dev/null &


echo "=== Fix timezone in php.ini"
# PHP Warning:  Unknown: It is not safe to rely on the system's timezone settings. You are *required* to use the date.timezone setting or the date_default_timezone_set() function. In case you used any of those methods and you are still getting this warning, you most likely misspelled the timezone identifier. We selected the timezone 'UTC' for now, but please set date.timezone to select your timezone. in Unknown on line 0
#PHP_INI_FILE=$(php -i | grep php.ini$ | awk '{ print $5 }')
sed -i "s/;date.timezone =.*/date.timezone = UTC/g" $PHP_INI_FILE

echo "=== Get list of domains ==="
echo "Current directory is $(pwd)"
DOMAINS=()
for i in $(ls -d */); do
  echo ${i%%/}
  DOMAINS+=("${i%%/}")
done

echo "=== Install dependencies using composer ==="
cd ../tests
echo "Current directory is $(pwd)"
composer install
composer dumpautoload -o

PATH=$PATH:$(pwd)/vendor/bin

echo "=== Tests ==="
for DOMAIN in $DOMAINS; do
#  FULL_DOMAIN="http://${DOMAIN}"
#  php reconfig_cc_url.php ${FULL_DOMAIN} ./tests/functional.suite.yml
#  codecept run functional --steps -g canonicals --env default
  FULL_DOMAIN="https://${DOMAIN}"
  echo "=== Set environment to ${FULL_DOMAIN}"
  php reconfig_cc_url.php ${FULL_DOMAIN} ./tests/functional.suite.yml
  echo "=== Current environment"
  cat ./tests/functional.suite.yml
  echo "=== Launch test"
  echo "${FULL_DOMAIN}" > test.txt
 # codecept run functional  --steps -g errors --env default
  codecept run functional --steps -g canonicals -g description -g titles -g nofollows -g robots -g redirects -g errors --html  --env default

  echo "=== Seo tests are done"

#  php reconfig_cc_url.php ${FULL_DOMAIN} ./tests/acceptance.suite.yml
#  echo "=== Current environment for screens"
#  cat ./tests/acceptance.suite.yml
#  echo "=== Launch acceptance tests"
#  echo "${FULL_DOMAIN}" > test.txt
#  URL_NAME=$(echo ${FULL_DOMAIN} | sed -e 's/https\?:\/\///g')
  codecept run acceptance -g ${DOMAIN} --env default -n

done