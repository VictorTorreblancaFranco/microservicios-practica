# S16 - Entrega final de actividad

Alumno: Victor Torreblanca  
Numero: 40

## 1. Conceptos utilizados

En la actividad se utilizaron microservicios con Spring Boot WebFlux, programacion reactiva con Reactor, comunicacion HTTP con WebClient, persistencia reactiva con R2DBC PostgreSQL, contenedores Docker y despliegue en Kubernetes mediante manifiestos YAML.

Kubernetes permite ejecutar cada microservicio como un Deployment y exponerlo mediante Services. Para mantener el formato trabajado en clase, se usa un namespace del proyecto, un Secret, un ConfigMap y archivos separados para Deployments y Services. La comunicacion interna usa el DNS del Service: `http://victortorreblanca-productos-service:8081`.

## 2. Microservicios desarrollados

### ms-productos

Puerto local: `8081`  
Base de datos: `db_productos`  
Endpoints principales:

```text
GET    /api/productos
GET    /api/productos/{id}
POST   /api/productos
PUT    /api/productos/{id}
DELETE /api/productos/{id}
PATCH  /api/productos/{id}/decreaseStock?quantity={cantidad}
```

### ms-pedidos

Puerto local: `8082`  
Base de datos: `db_pedidos`  
Endpoint de comunicacion: consume `ms-productos` con WebClient.  
Endpoints principales:

```text
GET   /api/pedidos
GET   /api/pedidos/{id}
POST  /api/pedidos
PATCH /api/pedidos/{id}/cancel
```

## 3. Testeo local sin Docker

Crear tablas en Neon antes de ejecutar:

```bash
psql 'URL_POSTGRES_DB_PRODUCTOS' -f sql/db_productos.sql
psql 'URL_POSTGRES_DB_PEDIDOS' -f sql/db_pedidos.sql
```

Ejecutar `ms-productos`:

```bash
cd ms-productos
DB_PASSWORD='PASSWORD_DB_PRODUCTOS' SERVER_PORT=8081 ./mvnw spring-boot:run
```

Ejecutar `ms-pedidos` en otra terminal:

```bash
cd ms-pedidos
DB_PASSWORD='PASSWORD_DB_PEDIDOS' SERVER_PORT=8082 PRODUCTOS_SERVICE_URL=http://localhost:8081 ./mvnw spring-boot:run
```

Crear un producto:

```bash
curl -X POST http://localhost:8081/api/productos \
  -H 'Content-Type: application/json' \
  -d '{"name":"Laptop","price":2500.0,"stock":10}'
```

Listar productos:

```bash
curl http://localhost:8081/api/productos
```

Crear un pedido que comunica `ms-pedidos` con `ms-productos`:

```bash
curl -X POST http://localhost:8082/api/pedidos \
  -H 'Content-Type: application/json' \
  -d '{"productId":1,"quantity":2}'
```

Verificar que el stock disminuyo:

```bash
curl http://localhost:8081/api/productos/1
```

## 4. Imagenes Docker

Construir imagen de productos:

```bash
docker build -t victortorreblancafranco/ms-productos:latest ./ms-productos
```

Construir imagen de pedidos:

```bash
docker build -t victortorreblancafranco/ms-pedidos:latest ./ms-pedidos
```

Publicar en Docker Hub:

```bash
docker login
docker push victortorreblancafranco/ms-productos:latest
docker push victortorreblancafranco/ms-pedidos:latest
```

Alternativa exportada:

```bash
docker save victortorreblancafranco/ms-productos:latest -o ms-productos.tar
docker save victortorreblancafranco/ms-pedidos:latest -o ms-pedidos.tar
```

## 5. Kubernetes

Los manifiestos estan en la carpeta `k8s`.

Archivos utilizados:

- `00-VictorTorreblanca-namespace.yml`: namespace del proyecto.
- `01-VictorTorreblanca-secret.yml`: passwords de Neon en base64.
- `02-VictorTorreblanca-configmap.yml`: variables no sensibles.
- `03-VictorTorreblanca-deployment.yml`: deployments de `ms-productos` y `ms-pedidos`.
- `04-VictorTorreblanca-service.yml`: services NodePort para ambos microservicios.

Antes de aplicar el Secret, generar los valores en base64:

```bash
echo -n "PASSWORD_DB_PRODUCTOS" | base64
echo -n "PASSWORD_DB_PEDIDOS" | base64
```

Luego reemplazar los valores de `productos-password` y `pedidos-password` en `01-VictorTorreblanca-secret.yml`.

Aplicar manifiestos:

```bash
kubectl apply -f k8s/00-VictorTorreblanca-namespace.yml
kubectl apply -f k8s/01-VictorTorreblanca-secret.yml
kubectl apply -f k8s/02-VictorTorreblanca-configmap.yml
kubectl apply -f k8s/03-VictorTorreblanca-deployment.yml
kubectl apply -f k8s/04-VictorTorreblanca-service.yml
```

Verificar recursos:

```bash
kubectl get namespaces
kubectl describe namespace victortorreblanca
kubectl get secrets -n victortorreblanca
kubectl describe secret victortorreblanca-secret -n victortorreblanca
kubectl get configmaps -n victortorreblanca
kubectl describe configmap victortorreblanca-config -n victortorreblanca
kubectl get deployments -n victortorreblanca
kubectl get pods -n victortorreblanca -o wide
kubectl get services -n victortorreblanca
kubectl get all -n victortorreblanca
```

Ver logs:

```bash
kubectl logs deployment/victortorreblanca-productos -n victortorreblanca
kubectl logs deployment/victortorreblanca-pedidos -n victortorreblanca
```

Los Services estan configurados como NodePort para poder probarlos desde la maquina local. Tambien se puede usar port-forward:

```bash
kubectl port-forward service/victortorreblanca-productos-service 9081:8081 -n victortorreblanca
kubectl port-forward service/victortorreblanca-pedidos-service 9082:8082 -n victortorreblanca
```

Pruebas con Kubernetes:

```bash
curl http://localhost:9081/api/productos
curl http://localhost:9082/api/pedidos
```

Crear producto en Kubernetes:

```bash
curl -X POST http://localhost:9081/api/productos \
  -H 'Content-Type: application/json' \
  -d '{"name":"Mouse","price":80.0,"stock":20}'
```

Crear pedido en Kubernetes:

```bash
curl -X POST http://localhost:9082/api/pedidos \
  -H 'Content-Type: application/json' \
  -d '{"productId":1,"quantity":3}'
```

## 6. Puertos diferentes

Se demuestra el uso de puertos diferentes mediante la variable `SERVER_PORT`:

- `ms-productos`: `SERVER_PORT=8081`
- `ms-pedidos`: `SERVER_PORT=8082`

En Kubernetes esos valores estan configurados como variables de entorno dentro de cada Deployment y se obtienen desde `02-VictorTorreblanca-configmap.yml`.

## 7. Conclusiones

Se completo la comunicacion entre microservicios usando WebClient. `ms-pedidos` consume el servicio `ms-productos` para validar el producto y disminuir stock antes de registrar un pedido.

El despliegue con Kubernetes separa responsabilidades mediante Namespace, Secret, ConfigMap, Deployments y Services. El Service de productos permite comunicacion dentro del cluster, mientras que ambos NodePort permiten pruebas desde fuera del cluster o mediante port-forward.

Docker permite empaquetar cada microservicio de forma independiente y publicarlo en Docker Hub o exportarlo como archivo `.tar`.

## 8. Guion sugerido para el video

1. Presentar el repositorio y las ramas `main` y `develop`.
2. Explicar los dos microservicios y sus puertos.
3. Mostrar la configuracion de WebClient en `ms-pedidos`.
4. Ejecutar ambos microservicios localmente sin Docker.
5. Crear un producto y luego un pedido con curl.
6. Mostrar Dockerfile de cada microservicio.
7. Construir o mostrar las imagenes Docker.
8. Aplicar los manifiestos Kubernetes.
9. Mostrar Deployments, Services, Pods y logs.
10. Probar la comunicacion en Kubernetes y cerrar con conclusiones.
