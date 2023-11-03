
1. Add HELM Repository
```
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update
```

2. Install the Nginx controller

```
helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace
kubectl get pods -n ingress-nginx
```

3. Create app services and pods

```
# Create staging namespace
kubectl create namespace staging

kubectl apply -f apple.yml
kubectl apply -f banana.yml

```
4. Install cert manager && issuer
```
# Install cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.13.1 --set installCRDs=true
kubectl get pods -n cert-manager

# Deploy issuser
kubectl create -f issuer.yml
kubectl describe issuer letsencrypt -n staging
```

5. Install ingress resources
```
# Get the name of the ingress class
kubectl get ingressclass -n ingress-nginx -o yaml

# Config spec.ingressClassName: nginx in the ingress.yaml file and run apply
kubectl apply -f ingress.yml
```

6. Check on the website https://staging.khanhpham.uk


7. Clean things up
```bash
helm list -Aa
helm uninstall cert-manager jetstack/cert-manager --namespace cert-manager
helm uninstall ingress-nginx --namespace ingress-nginx
kubectl delete -f apple.yml && kubectl delete -f banana.yml
```
