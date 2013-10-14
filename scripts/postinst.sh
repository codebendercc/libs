#!/bin/bash

sudo cp /opt/codebender/@PACKAGENAME@/apache-config /etc/apache2/sites-available/codebender
cd /etc/apache2/sites-enabled
sudo ln -s ../sites-available/codebender 00-codebender

sudo a2enmod rewrite
sudo a2enmod alias
sudo service apache2 restart

cd /opt/codebender/@PACKAGENAME@/Symfony
sudo curl -s http://getcomposer.org/installer | sudo php
sudo php composer.phar install


sudo rm -rf /opt/codebender/@PACKAGENAME@/Symfony/app/cache/*
sudo rm -rf /opt/codebender/@PACKAGENAME@/Symfony/app/logs/*

sudo dd if=/dev/zero of=/opt/codebender/@PACKAGENAME@/cache-fs bs=1024 count=0 seek=200000
sudo dd if=/dev/zero of=/opt/codebender/@PACKAGENAME@/logs-fs bs=1024 count=0 seek=200000

yes | sudo mkfs.ext4 /opt/codebender/@PACKAGENAME@/cache-fs
yes | sudo mkfs.ext4 /opt/codebender/@PACKAGENAME@/logs-fs

echo "/opt/codebender/@PACKAGENAME@/cache-fs /opt/codebender/@PACKAGENAME@/Symfony/app/cache ext4 loop,acl 0 0" | sudo tee -a /etc/fstab > /dev/null 2>&1
echo "/opt/codebender/@PACKAGENAME@/logs-fs /opt/codebender/@PACKAGENAME@/Symfony/app/logs ext4 loop,acl 0 0" | sudo tee -a /etc/fstab > /dev/null 2>&1

sudo mount /opt/codebender/@PACKAGENAME@/Symfony/app/cache/
sudo mount /opt/codebender/@PACKAGENAME@/Symfony/app/logs/

sudo rm -rf /opt/codebender/@PACKAGENAME@/Symfony/app/cache/*
sudo rm -rf /opt/codebender/@PACKAGENAME@/Symfony/app/logs/*

sudo setfacl -R -m u:www-data:rwX -m u:`whoami`:rwX /opt/codebender/@PACKAGENAME@/Symfony/app/cache /opt/codebender/@PACKAGENAME@/Symfony/app/logs
sudo setfacl -dR -m u:www-data:rwx -m u:`whoami`:rwx /opt/codebender/@PACKAGENAME@/Symfony/app/cache /opt/codebender/@PACKAGENAME@/Symfony/app/logs

