# Kubernetes

Manifiestos para desplegar los microservicios en Kubernetes.

- `ms-productos`: Deployment + Service ClusterIP, puerto 8081.
- `ms-pedidos`: Deployment + Service LoadBalancer, puerto 8082.
- `secrets.example.yaml`: plantilla para crear las claves de Neon sin subir contrasenas reales.

Antes de aplicar los manifiestos, crea el Secret real:

```bash
kubectl create secret generic neon-secrets \
  --from-literal=productos-password='TU_PASSWORD_DB_PRODUCTOS' \
  --from-literal=pedidos-password='TU_PASSWORD_DB_PEDIDOS'
```

Luego aplica:

```bash
kubectl apply -f k8s/ms-productos.yaml
kubectl apply -f k8s/ms-pedidos.yaml
```
