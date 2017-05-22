FROM jenkins
USER root

RUN apt-get update

#install PHP xvfb
RUN apt-get install -y php5 php5-curl php5-gd  xvfb

# Install Selenium
RUN mkdir -p /opt/selenium
RUN wget --no-verbose -O /opt/selenium/selenium-server-standalone-2.53.1.jar http://selenium-release.storage.googleapis.com/2.53/selenium-server-standalone-2.53.1.jar
#RUN ln -fs /opt/selenium/selenium-server-standalone-2.53.1.jar /opt/selenium/selenium-server-standalone.jar
RUN chmod +x /opt/selenium/selenium-server-standalone-2.53.1.jar

# Install Chrome WebDriver
RUN wget --no-verbose -O /tmp/chromedriver_linux64.zip http://chromedriver.storage.googleapis.com/2.28/chromedriver_linux64.zip
RUN mkdir -p /opt/chromedriver-2.28
RUN unzip /tmp/chromedriver_linux64.zip -d /opt/chromedriver-2.28
RUN chmod +x /opt/chromedriver-2.28/chromedriver
RUN rm /tmp/chromedriver_linux64.zip
RUN ln -fs /opt/chromedriver-2.28/chromedriver /opt/selenium/chromedriver


# Install Google Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
RUN apt-get -y update
RUN apt-get -y install google-chrome-stable

# Path Google Chrome
COPY google-chrome /opt/google/chrome/
RUN chmod +x /opt/google/chrome/google-chrome

# Install composer
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN curl -sS https://getcomposer.org/installer | php -- \
        --filename=composer \
        --install-dir=/usr/local/bin
RUN composer global require --optimize-autoloader \
        "hirak/prestissimo"
RUN php -v


# Install FireFox
RUN touch /etc/apt/sources.list.d/debian-mozilla.list
RUN echo "deb http://mozilla.debian.net/ jessie-backports firefox-release" > /etc/apt/sources.list.d/debian-mozilla.list   
RUN wget mozilla.debian.net/pkg-mozilla-archive-keyring_1.1_all.deb
RUN dpkg -i pkg-mozilla-archive-keyring_1.1_all.deb
RUN apt-get update
RUN apt-get install -y  firefox  

# Install Codeception
RUN touch /usr/local/bin/codecept
RUN curl http://codeception.com/releases/2.2.8/codecept.phar -o /usr/local/bin/codecept
RUN chmod +x /usr/local/bin/codecept
#RUN php codecept.phar bootstrap 

# ADD start.sh
COPY start.sh /usr/local/bin
ENTRYPOINT ["/bin/bash"]
CMD ["/usr/local/bin/start.sh"]
