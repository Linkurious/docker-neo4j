# Neo4J LKE chart

## Neo4j documentation

https://neo4j.com/docs/operations-manual/current/kubernetes/quickstart-standalone/create-value-file/
https://github.com/neo4j/helm-charts/blob/4.4/neo4j-standalone/values.yaml

## Installing the chart

```
helm upgrade --install --namespace=neo4j-dev neo4j-enys neo4j/neo4j-standalone -f neo4j-values.yaml --render-subchart-notes
```

## Restoring data
see https://github.com/neo4j-contrib/neo4j-helm/blob/master/templates/core-statefulset.yaml and https://github.com/neo4j-contrib/neo4j-helm/blob/master/tools/restore/restore.sh for restore script

## Connecting
```
kubectl run --rm -it --namespace "neo4j-dev" --image "neo4j:4.4.3" cypher-shell \
     -- cypher-shell -a "neo4j://neo4j-enys.neo4j-dev.svc.cluster.local:7687" -u neo4j -p "PASSWORD"
```

Connection info is also provided by neo4j helm chart notes

https://neo4j.com/docs/operations-manual/current/kubernetes/accessing-cluster/
kubectl port-forward svc/<release-name> tcp-bolt tcp-http tcp-https

## SSO
SSo is setup, see values files.
However, wildcard urls do not work.
You will have to get your admin to authorize your url in AZure
