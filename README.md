# Reactive Coffeeshop Demo 

This is a demo of a reactive system built with Liberty, Kafka and Keda.

# Run locally in containers using Docker Compose

To perform a simple local run of the demo, use:
```
docker-compose up
```
...wait until the 'ready' stage completes (with the message `coffeeshop-service is ready!`), then order coffees at http://localhost:8080/

# Run with Strimzi and Keda, using Helm

The Coffeeshop demo and its prerequisites can be installed into a Kubernetes cluster using Helm (v3).

### Prereqs

- Install Helm v3: https://helm.sh/docs/intro/install/
- Ensure you have a Kubernetes cluster. For running locally, you could use:
  - [Docker Desktop on Windows](https://docs.docker.com/docker-for-windows/kubernetes/) or [Mac](https://docs.docker.com/docker-for-mac/kubernetes/),
  - [Minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/), or 
  - [kind](https://kind.sigs.k8s.io/docs/user/quick-start/).
  - _Kind is nice because it's quick and easy to create / teardown a temporary cluster, but there are a couple of additional steps required if you want to use it. Take a look at the Travis job (which uses kind) for details._

### Installing

You can install everything using Helm by running the supplied `install.sh` (or `install.bat`) script.  Removal can be performed with `uninstall.sh` / `uninstall.bat`.

To install manually, the steps are:

1. Install the Strimzi operator
```bash
kubectl create ns strimzi
kubectl create ns kafka
helm repo add strimzi https://strimzi.io/charts
helm install strimzi strimzi/strimzi-kafka-operator -n strimzi --set watchNamespaces={kafka} --wait --timeout 300s
```
1. Install the custom resource to create a Kafka
```bash
kubectl apply -f kafka-strimzi.yml -n kafka
kubectl wait --for=condition=Ready kafkas/my-cluster -n kafka --timeout 180s
```
1. Install the Keda operator
```bash
kubectl create ns keda
helm repo add kedacore https://kedacore.github.io/charts
helm install keda kedacore/keda -n keda --wait --timeout 300s
```
1. Install coffeeshop chart
```bash
kubectl create ns coffee
helm install coffee-v1 ./coffeeshop-chart -n coffee --wait --timeout 300s
```

Once installed, you can access the service either using the NodePort, or you can set up port forwarding:
```bash
kubectl port-forward service/coffee-v1-coffeeshop-service 8080:8080 -n coffee
```

### Obtaining the node IP and port

If installing to a remote cluster, the `postinstall.sh` (and `postinstall.bat`) script will query Kubernetes to obtain the external IP and NodePort and provide you with the corresponding coffeeshop URL.  This is run at the end of the provided install script.

### Validating

You can validate that the install is successful using the `ci-test.sh` script (that is used by the Travis job):
```bash
./ci-test.sh 8080 coffee
```
- if using the NodePort, substitute the port number instead of 8080 above.

### Testing

Access the coffeeshop dashboard in a web browser, either using the cluster IP and node port or by port forwarding as described above.

You can order coffees via either the HTTP or Kafka baristas.  When ordering using the Kafka barista, there will be a short delay the first time while the barista starts. If you order several coffees, Keda will scale up the baristas and you should see coffees prepared by multiple baristas. 

### Upgrades

If you have changed something in the chart:
```bash
helm upgrade coffee-v1 ./coffeeshop-chart -n coffee
```

### Removal

If you want to clear out everything that was created by the chart, either use the `uninstall.sh`, or:

```bash
helm uninstall coffee-v1 -n coffee
kubectl delete ns coffee

helm uninstall keda -n keda
kubectl delete ns keda

kubectl delete -f kafka-strimzi.yml -n kafka
kubectl delete ns kafka

helm uninstall strimzi -n strimzi
kubectl delete ns strimzi
```

Keda seems to leave some artifacts around even after the chart has been uninstalled. To clean these up:
```bash
kubectl delete apiservice v1alpha1.keda.k8s.io
kubectl delete crd scaledobjects.keda.k8s.io
kubectl delete crd triggerauthentications.keda.k8s.io
```
