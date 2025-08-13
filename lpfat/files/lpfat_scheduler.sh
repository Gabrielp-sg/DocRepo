#!/bin/bash

lpfat_versions=`find /opt/tomcat10/webapps/ -type d -name Lp*`

for version in $lpfat_versions;
do 
    echo "Processing folder $version"
    cd $version/WEB-INF/classes
    java -cp .:../lib/* com.ayvens.apragendadortarefa
done