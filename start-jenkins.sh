#!/bin/bash

PATH_PWD=$(pwd)
SCRIPT_PATH=$(dirname $(realpath $0))
SCRIPT_NAME=$(basename $(realpath $0))

docker build -t oxkhar/phpeach -f ${SCRIPT_PATH}/virtual/Dockerfile ${SCRIPT_PATH}/virtual

docker run --name phpeach -v $(pwd):/var/jenkins_home/workspace/phpeach -d -p 8080:8080 oxkhar/phpeach

for a in $(seq 1 60); do echo -n .; sleep 1; done

docker exec -t -u root phpeach chown -R jenkins:jenkins /var/jenkins_home/workspace

docker exec -t phpeach /install-php-job.sh
