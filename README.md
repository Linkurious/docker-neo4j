# Dockerized repository

## Configuration
  - Configure variables in .env. See .env.example for template.
Reasonable defaults are provided.

## Usage
  - Run with docker-compose
    ```
    $ docker-compose up -d
    ```
## Neo4j v3 restore
```
docker-compose -f docker-compose.yml -f docker-compose.shell.yml run --rm neo4j bash
```
From dev env:
```
docker-compose -f docker-compose.yml  -f docker-compose.override.yml -f docker-compose.shell.yml run --rm neo4j bash
```

## Backup and restore
see https://neo4j.com/docs/operations-manual/current/backup/

When working localy, docker-compose.override.yml adds a local bind mount to the /backupes folder.


Create an online backup:
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
CREATE DATABASE `crunchbase` WAIT
```

### offline load
neo4j-admin load --from=/datasets/crunch.3.5.15  --database=crunchbase-1.0.0
CREATE DATABASE crunchbase


### Aura
## load db
From a shell, stoped database :
```
bin/neo4j-admin push-to-cloud --bolt-uri neo4j+s://XXXXX.databases.neo4j.io --database=fincrime-1.0.0 --overwrite
```


