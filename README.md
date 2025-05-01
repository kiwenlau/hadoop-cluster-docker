## Présentation

Ces contenaires ont été initialement issus de https://github.com/kiwenlau/hadoop-cluster-docker

Un cluster de trois contenaires est créé, avec comme plateformes installées:

  * [Apache Hadoop](http://hadoop.apache.org/) Version: 2.7.2
  * [Apache Spark](https://spark.apache.org/) Version: 2.2.1
  * [Apache Kafka](https://kafka.apache.org/) Version 2.11-1.0.2 
  * [Apache HBase](https://hbase.apache.org/) Version 1.4.8


## Lancement des contenaires

- Vous pouvez soit utiliser les scripts dans le répertoire `scripts`.

```python
scripts/
        |- build-image.sh # la créarion de l'image docker
        |- resize-cluser.sh # pour définir le nombre d'esclaves
        |- start-container.sh # lancer les contenaires
```
- Vous pouvez utiliser docker compose pour lancer les services déclaré dans le ficher `docker_compose/docker-compose.yml` 

```sh
cd docker_compose
docker compose up
```

Pour des tutoriaux détaillés sur la façon d'utiliser ces contenaires, visiter:
https://insatunisia.github.io/TP-BigData

Bonne lecture!