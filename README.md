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
### ofline
neo4j-admin load --from=/datasets/crunch.3.5.15  --database=crunchbase
CREATE DATABASE crunchbase


neo4j-admin backup --backup-dir /backups --database crunchbase 
neo4j-admin restore --from /data/backups/crunchbase-3.5.15/ --name crunchbase --verbose
