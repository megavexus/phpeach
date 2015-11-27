#!/bin/bash

echo -e "\n\nInstalling job..."

composer global require oxkhar/phpeach && rm -rf  ~/.composer/cache

cat phpeach-job.xml | \
  java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 create-job phpeach
