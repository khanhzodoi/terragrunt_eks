1. Create namespace and install helm chart to test database connection to MySQL 5.7

```bash
kubectl create namespace demo
helm install database-connection-test ./2-test-database-connection
helm list -Aa
```

2. Test jobs run sucessfully and pods print out database list from the logs

```
kubectl describe jobs 2-test-database-connection -n demo
kubectl logs <2-test-database-connection-...> -n demo
```

3. Cleaning up stuffs

```
helm uninstall 2-test-database-connection
```