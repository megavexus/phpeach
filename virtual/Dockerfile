FROM jenkins

USER root

RUN apt-get update && apt-get -y upgrade && apt-get -y install git php5-cli php5-xdebug php5-xsl

RUN apt-get clean && apt-get purge && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

USER jenkins

COPY plugins.txt /plugins.txt
COPY install-php-job.sh /install-php-job.sh
COPY phpeach-job.xml /phpeach-job.xml

RUN /usr/local/bin/plugins.sh /plugins.txt
