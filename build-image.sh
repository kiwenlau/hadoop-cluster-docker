#!/bin/bash

echo -e "\nbuild docker hadoop-base image\n"
sudo docker build -f hadoop-base/Dockerfile -t kiwenlau/hadoop-base:1.0.0 ./hadoop-base

echo ""