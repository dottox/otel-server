# OpenTelemtry to Instana in EKS

Reqs:
- Una instancia de Instana
- Cuenta en AWS con capacidad de crear un clúster de eks

--------------------
## Crear el clúster en EKS

Recomendado para cuentas free
- 10 nodes: `t3.small`

Solo 3 add-ons son necesarios: CDN, VPC CNI, kube-proxy


Vincular la CLI con el cluster:
```bash
aws eks update-kubeconfig --name <cluster-name> --region <cluster-region>
```

--------------------
## Instalar [HELM](https://helm.sh/docs/intro/install/)

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

--------------------
## Instalar el operador del agente de Instana

// Para agregar



--------------------
## Instalar el agente de Instana

Configurar el instanaAgent.yaml

```bash
kubectl apply -f instanaAgent.yaml
```

--------------------
## Instalar el operador del agente de OTEL

### Instalar el [cert manager](https://cert-manager.io/docs/installation/)

```bash
helm install \
  cert-manager oci://quay.io/jetstack/charts/cert-manager \
  --version v1.18.2 \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true
```

### Instalar el [operador](https://opentelemetry.io/docs/platforms/kubernetes/operator/)

#### Crear namespace para el Operator

```bash
kubectl create namespace opentelemetry-operator
```

#### Agregar repo de Helm y actualizar

```bash
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update
```

#### Instalar el Operator

```bash
helm install otel-operator open-telemetry/opentelemetry-operator --namespace opentelemetry-operator
```

--------------------
## (opcional) Crear el Instrumentation resource

Se encarga de definir la auto-instrumentation.
Funciona mediante el monkey patching, cambiando el código en runtime para poder enviar logs, métricas y traces hacia los exporters.

> [!IMPORTANT]
> Esto es necesario SOLO si la aplicación no se inicia con el auto-instrumentation.

```bash
kubectl apply -f otelInstrumentation.yaml
```


--------------------
## Instalar el collector de OTEL

Las pipelines pueden ser modificadas. Todos los recursos se definen y luego se llaman mediante el nombre. Las listas indican que pueden haber más de un recurso de cada tipo en las pipelines.
- **Receivers**: lo que se encarga de recibir los datos, acá usaremos el 0.0.0.0:4317 y :4318 para recibir los datos enviados al collector.
- **Processors**: la manera en que se procesan los datos recibidos, el batch permite enviar los datos de a montones.
- **Exporters**: hacia donde viajarán los datos, en este caso hacia nuestro Instana agent.

```bash
kubectl apply -f otelCollector.yaml
```


--------------------
## Desplegar la aplicación

Configurar la aplicación para que utilice tu imágen. Pueden utilizar la mia sin problemas igual.

```bash
kubectl apply -f otelServerApp.yaml
```

--------------------
## Testear la aplicación

// Se puede crear un load generator.

Hacer un port-forward al svc otel-service y hacer un while con curl hacia localhost:8082/server_request

Se deberían ver métricas de OTEL en Instana.


