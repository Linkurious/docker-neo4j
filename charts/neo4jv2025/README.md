# Neo4J LKE chart

## Neo4j documentation

<https://neo4j.com/docs/operations-manual/current/kubernetes/helm-charts-setup/>

Values file:
<https://github.com/neo4j/helm-charts/blob/dev/neo4j/values.yaml>

## Installing the chart

To directly use neo4j chart:

```bash
helm upgrade --install --namespace=neo4j-dev neo4j-enys neo4j/neo4j -f neo4j-values.yaml --render-subchart-notes
```

To use our internal chart, with preprod values:

```bash
helm upgrade --install --namespace=neo4j-dev neo4j-enys charts/neo4jv2025-internal -f charts/neo4jv2025-internal/values.preprod.yaml --render-subchart-notes
```

## Restoring data

see <https://github.com/neo4j-contrib/neo4j-helm/blob/master/templates/core-statefulset.yaml> and <https://github.com/neo4j-contrib/neo4j-helm/blob/master/tools/restore/restore.sh> for restore script.
We have implemented our own restore script based on this.

## Connecting

```bash
kubectl run --rm -it --namespace "neo4j-dev" --image "neo4j:4.4.3" cypher-shell \
     -- cypher-shell -a "neo4j://neo4j-enys.neo4j-dev.svc.cluster.local:7687" -u neo4j -p "PASSWORD"
```

Connection info is also provided by neo4j helm chart notes

<https://neo4j.com/docs/operations-manual/current/kubernetes/accessing-cluster/>
Port forward svc to localhost:

```bash
kubectl port-forward svc/<release-name> tcp-bolt tcp-http tcp-https
```

## SSO

<https://neo4j.com/docs/operations-manual/current/tutorial/tutorial-sso-configuration/>
SSo is setup, see values files.
However, wildcard urls do not work.
You will have to get your admin to authorize your url in Azure
