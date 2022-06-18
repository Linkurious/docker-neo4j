https://neo4j.com/docs/operations-manual/current/kubernetes/quickstart-standalone/create-value-file/
https://github.com/neo4j/helm-charts/blob/4.4/neo4j-standalone/values.yaml

```
helm upgrade --install --namespace=neo4j-dev neo4j-enys neo4j/neo4j-standalone -f neo4j-values.yaml
```


see https://github.com/neo4j-contrib/neo4j-helm/blob/master/templates/core-statefulset.yaml and https://github.com/neo4j-contrib/neo4j-helm/blob/master/tools/restore/restore.sh for restore script

Connecting
kubectl run --rm -it --namespace "neo4j-dev" --image "neo4j:4.4.3" cypher-shell \
     -- cypher-shell -a "neo4j://neo4j-enys.neo4j-dev.svc.cluster.local:7687" -u neo4j -p "PASSWORD"

https://neo4j.com/docs/operations-manual/current/kubernetes/accessing-cluster/
kubectl port-forward svc/<release-name> tcp-bolt tcp-http tcp-https

