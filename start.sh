#!bin/bash
 
xvfb-run java -jar /opt/selenium/selenium-server-standalone-2.53.1.jar  -Dwebdriver.chrome.driver=/opt/selenium/chromedriver &>/dev/null &
/bin/tini -- /usr/local/bin/jenkins.sh
 
 