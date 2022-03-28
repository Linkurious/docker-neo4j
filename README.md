# Dockerized repository

## Configuration
  - Configure variables in .env. See .env.example for template.
Reasonable defaults are provided. Simply use them when working localy.
    ```
    $ ln -s .env.example .env
    ```
    Do the same for others .env* files.
    
## Usage
  - Run with docker-compose
    ```
    $ docker-compose up -d
    ```

## Browse database when working localy

Go to http://localhost:7474 and connect with the following parameters:

- Connect URL: bolt://localhost:7687
- Database: _leave empty_
- Authentication type: Username / Password
- Username: neo4j
- Password: neo3j

## Neo4j v3 restore
```
docker-compose -f docker-compose.yml -f docker-compose.shell.yml run --rm neo4j bash
```
From dev env:
```
docker-compose -f docker-compose.yml  -f docker-compose.override.yml -f docker-compose.shell.yml run --rm neo4j bash
```

## Backup and restore (Neo4j V4)
see https://neo4j.com/docs/operations-manual/current/backup/

When working localy, docker-compose.override.yml adds a local bind mount to the /backups folder.

Backups can be downloaded from Nexus. They have to be decompressed in the ./backups bind mounted folder.

Create an online backup (command to be executed in the context of the neo4j container, with `docker-compose exec neo4j`):
```
neo4j-admin backup --backup-dir /backups --database crunchbase-1.0.0
```

Restore/create from dataset:
```
neo4j-admin restore --from /datasets/4.2.0/crunchbase --database crunchbase-1.0.0  --verbose
```

Restore from backup:
```
neo4j-admin restore --from /backups/4.2.0/crunchbase --database crunchbase-1.0.0 --verbose
```
in v3.5.x
```
neo4j-admin restore --from /backups/3.5.15/fincrime-1.0.0/ --database graph.db
```

On first creation of a db, you will have to:
```
:use system
CREATE DATABASE `crunchbase-1.0.0` WAIT;
```

You can then check that the db has succesfully been restored with:
```
:use crunchbase-1.0.0
match (n) return n limit 10
```

### offline load
```
neo4j-admin load --from=/datasets/crunch.3.5.15  --database=crunchbase-1.0.0
```
and with cypher-shell (the credential are specified in the env) :
```
CREATE DATABASE crunchbase;
```

## Plugins
### Apoc
see https://neo4j.com/labs/apoc/4.2/installation/

Download the appropriate version of apoc plugin and drop it in the plugins folder:
```
curl -L https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/4.2.0.1/apoc-4.2.0.1-all.jar -o plugins/apoc-4.2.0.1-all.jar
```
Warning: Check the matching version for your version of Neo4J

### Aura
## load db
From a shell, stoped database :
```
bin/neo4j-admin push-to-cloud --bolt-uri neo4j+s://XXXXX.databases.neo4j.io --database=fincrime-1.0.0 --overwrite
```

### Nexus datasets


## Manual upload for large datasets
```
export dataset_name=fincrime-sales
export dataset_version=1.0.0
curl -L -v --user user@linkurio.us:${USER_PWD} --upload-file ${dataset_name}-${dataset_version}.tgz https://nexus3.linkurious.net/repository/datasets/com/linkurious/neo4j/4.2.4/${dataset_name}/${dataset_name}-${dataset_version}.tgz
```
## Download dataset
```
export dataset_name=fincrime-sales
export dataset_version=1.0.0
curl -L -v --user user@linkurio.us:${USER_PWD} https://nexus3.linkurious.net/repository/datasets/com/linkurious/neo4j/4.2.4/${dataset_name}/${dataset_name}-${dataset_version}.tgz
```

