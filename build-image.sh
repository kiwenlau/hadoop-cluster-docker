#!/bin/bash

echo -e "\nbuild docker hadoop-base image\n"
sudo docker build -f hadoop-base/Dockerfile -t kiwenlau/hadoop-base:1.0.0 ./hadoop-base

echo ""


echo -e "\nbuild docker hadoop-master image\n"
sudo docker build -f hadoop-master/Dockerfile -t kiwenlau/hadoop-master:1.0.0 ./hadoop-master

echo ""

echo -e "\nbuild docker hadoop-slave image\n"
sudo docker build -f hadoop-slave/Dockerfile -t kiwenlau/hadoop-slave:1.0.0 ./hadoop-slave

echo ""