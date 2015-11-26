#!/bin/bash

echo -e "\n\nInstalling job..."

cat phpeach-job.xml | \
  java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 create-job phpeach
