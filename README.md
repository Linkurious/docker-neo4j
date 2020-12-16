# Dockerized repository

## Configuration
  - Configure variables in .env. See .env.example for template.
Reasonable defaults are provided.

## Usage
  - Run with docker-compose
    ```
    $ docker-compose up -d
    ```

docker-compose -f docker-compose.yml -f docker-compose.shell.yml run --rm neo4j bash
## Backup and restore
see https://neo4j.com/docs/operations-manual/current/backup/

Create an online backup:
```
neo4j-admin backup --backup-dir /backups --database crunchbase
```

Restore/create from dataset:
```
neo4j-admin restore --from /datasets/4.2.0/crunchbase --database crunchbase  --verbose
```

Restore from backup:
```
neo4j-admin restore --from /backups/4.2.0/crunchbase --database crunchbase --verbose
```

On first creation of a db, you will have to:
```
CREATE DATABASE crunchbase
```

### offline load
neo4j-admin load --from=/datasets/crunch.3.5.15  --database=crunchbase
CREATE DATABASE crunchbase


