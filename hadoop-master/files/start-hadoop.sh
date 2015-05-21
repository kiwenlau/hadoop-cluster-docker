#!/bin/bash

$HADOOP_INSTALL/sbin/start-dfs.sh

echo -e "\n"
$HADOOP_INSTALL/sbin/start-yarn.sh
