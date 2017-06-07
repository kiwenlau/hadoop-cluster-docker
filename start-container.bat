:: This is bat script version of https://github.com/kiwenlau/hadoop-cluster-docker/blob/master/start-container.sh
:: Written by Vu Ngoc Trong (vungoctrong@gmail.com)
:: 04/02/2017
@echo off
rem default number of nodes = 3
SET N=3
rem re-create hadoop network
echo "create hadoop network..."
docker network rm hadoop 2> nul
docker network create --driver=bridge hadoop	

rem 1st docker should be master node
docker rm -f hadoop-master 2> nul
echo "start hadoop-master container..."
	docker run -itd --net=hadoop -p 50070:50070 -p 8088:8088 --name hadoop-master --hostname hadoop-master kiwenlau/hadoop:1.0

rem reduce 1 for master node
set /a N-=1
FOR /L %%i IN (1,1,%N%) DO (
		docker rm -f hadoop-slave%%i 2> nul
		echo "start hadoop-slave%%i container..."
		docker run -itd --net=hadoop --name hadoop-slave%%i --hostname hadoop-slave%%i kiwenlau/hadoop:1.0
)
docker exec -it hadoop-master bash