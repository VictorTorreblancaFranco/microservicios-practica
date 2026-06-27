# Kubernetes

Manifiestos con el mismo orden trabajado en clase:

- `00-VictorTorreblanca-namespace.yml`: namespace del proyecto.
- `01-VictorTorreblanca-secret.yml`: passwords de Neon en base64.
- `02-VictorTorreblanca-configmap.yml`: variables no sensibles.
- `03-VictorTorreblanca-deployment.yml`: deployments de `ms-productos` y `ms-pedidos`.
- `04-VictorTorreblanca-service.yml`: services NodePort para ambos microservicios.

Para reemplazar las contrasenas en el Secret:

```bash
echo -n "PASSWORD_DB_PRODUCTOS" | base64
echo -n "PASSWORD_DB_PEDIDOS" | base64
```

Luego pega los valores generados en:

- `productos-password`
- `pedidos-password`

Aplicar manifiestos:

```bash
kubectl apply -f k8s/00-VictorTorreblanca-namespace.yml
kubectl apply -f k8s/01-VictorTorreblanca-secret.yml
kubectl apply -f k8s/02-VictorTorreblanca-configmap.yml
kubectl apply -f k8s/03-VictorTorreblanca-deployment.yml
kubectl apply -f k8s/04-VictorTorreblanca-service.yml
```

Verificar:

```bash
kubectl get namespaces
kubectl get secrets -n victortorreblanca
kubectl get configmaps -n victortorreblanca
kubectl get deployments -n victortorreblanca
kubectl get pods -n victortorreblanca -o wide
kubectl get services -n victortorreblanca
kubectl get all -n victortorreblanca
```

Probar por port-forward:

```bash
kubectl port-forward service/victortorreblanca-productos-service 9081:8081 -n victortorreblanca
kubectl port-forward service/victortorreblanca-pedidos-service 9082:8082 -n victortorreblanca
```
