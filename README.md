# Coffeeshop Demo with Quarkus

This directory contains a set of demo around _reactive_ in Quarkus with Kafka.
It demonstrates the elasticity and resilience of the system.

## Build

```bash
mvn clean package
```

## Prerequisites

Install Kafka locally for the Kafka tools e.g.

```bash
brew install kafka
```

Run Kafka with:

```bash
docker-compose up
```

In case of previous run, you can clean the state with

```bash
docker-compose down
docker-compose rm
```

Then, create the `orders` topic with `./create-topics.sh`

# Run the demo

You need to run:

* the coffee shop service
* the HTTP barista
* the Kafka barista

Im 3 terminals: 

```bash
cd coffeeshop-service
mvn compile quarkus:dev
```

```bash
cd barista-http
java -Dbarista.name=tom -jar target/barista-http-1.0-SNAPSHOT-runner.jar
```

```bash
cd barista-kafka
mvn compile quarkus:dev
```

# Execute with HTTP

The first part of the demo shows HTTP interactions:

* Barista code: `me.escoffier.quarkus.coffeeshop.BaristaResource`
* CoffeeShop code: `me.escoffier.quarkus.coffeeshop.CoffeeShopResource.http`
* Generated client: `me.escoffier.quarkus.coffeeshop.http.BaristaService`

Order coffees with:

```bash
while [ true ]
do
http POST :8080/http product=latte name=clement
http POST :8080/http product=expresso name=neo
http POST :8080/http product=mocha name=flore
done
```

Stop the HTTP Barista, you can't order coffee anymore.

# Execute with Kafka

* Barista code: `me.escoffier.quarkus.coffeeshop.KafkaBarista`: Read from `orders`, write to `queue`
* Bridge in the CoffeeShop: `me.escoffier.quarkus.coffeeshop.messaging.CoffeeShopResource#messaging` just enqueue the orders in a single thread (one counter)
* Get prepared beverages on `me.escoffier.quarkus.coffeeshop.dashboard.BoardResource` and send to SSE

* Open browser to http://localhost:8080/
* Order coffee with:

```bash
http POST :8080/messaging product=latte name=clement
http POST :8080/messaging product=expresso name=neo
http POST :8080/messaging product=mocha name=flore
```

# Baristas do breaks

1. Stop the Kafka barista
1. Continue to enqueue order
```bash
http POST :8080/messaging product=frappuccino name=clement
http POST :8080/messaging product=chai name=neo
http POST :8080/messaging product=hot-chocolate name=flore
```
1. On the dashboard, the orders are in the "IN QUEUE" state
1. Restart the barista
1. They are processed

# 2 baristas are better

1. Start a second barista with: 
```bash
java -Dquarkus.http.port=9095 -Dbarista.name=tom -jar target/barista-kafka-1.0-SNAPSHOT-runner.jar
```
1. Order more coffee
```bash
http POST :8080/messaging product=frappuccino name=clement
http POST :8080/messaging product=chai name=neo
http POST :8080/messaging product=hot-chocolate name=flore
http POST :8080/messaging product=latte name=clement
http POST :8080/messaging product=expresso name=neo
http POST :8080/messaging product=mocha name=flore
```

The dashboard shows that the load is dispatched among the baristas.

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

1. Install Strimzi
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
1. Install coffeeshop chart
```bash
kubectl create ns coffee
helm dependency update ./coffeeshop-chart
helm install coffee-v1 ./coffeeshop-chart -n coffee --wait --timeout 300s
```

Once installed, you can access the service either using the NodePort, or you can set up port forwarding:
```bash
kubectl port-forward service/coffee-v1-coffeeshop-service 8080:8080 -n coffee
```

### Validating

You can validate that the install is successful using the `ci-test.sh` script (that is used by the Travis job):
```bash
./ci-test.sh 8080 coffee
```
- if using the NodePort, substitute the port number instead of 8080 above.

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