#!/bin/bash

echo -e "\n\nInstalling job..."

curl -L https://raw.githubusercontent.com/sebastianbergmann/php-jenkins-template/master/config.xml | \
     java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 create-job php-template


