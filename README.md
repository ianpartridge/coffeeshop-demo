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

# Instructions to run containers using Docker

1. Build Docker Images
   Use the following script to build the Docker images for the three microservices:
    ```bash
    ./build.bat
    ```
    or 
    ```bash
    ./build.sh
    ```
1. Run Kafka and the microservices together using Docker Compose:
    ```bash
    docker-compose up
    ```
1. Clean up docker
    ```bash
    docker-compose down
    ```

# Instructions to run containers using Kubernetes

1. Build docker images
    ```bash
    ./build.bat
    ```
    or 
    ```bash
    ./build.sh
    ```
1. Run the kubernetes deployments and services
    ```bash
    ./apply-kubernetes.bat
    ```
    or
    ```bash
    ./apply-kubernetes.sh
    ```
1. Expose the coffeeshop-service to be accessible externally
    ```bash
    kubectl port-forward <COFFEESHOP POD> 8080:8080

    ```
1. Clean up kubernetes resource when done
    ```bash
    ./delete-kubernetes.bat
    ```
    or
    ```bash
    ./delete-kubernetes.sh
    ```

# Instructions to run containers using Kubernetes and Strimzi operators

1. Build docker images
    ```bash
    ./build.bat
    ```
    or 
    ```bash
    ./build.sh
    ```
1. Start Strimzi
    ```bash
    ./start-strimzi.bat
    ```
    or
    ```bash
    ./start-strimzi.sh
    ```
1. Run the kubernetes deployments and services
    ```bash
    ./apply-kubernetes.bat
    ```
    or
    ```bash
    ./apply-kubernetes.sh
    ```
1. Expose the coffeeshop-service to be accessible externally
    ```bash
    kubectl port-forward <COFFEESHOP POD> 8080:8080

    ```
1. Clean up kubernetes resource when done
    ```bash
    ./delete-kubernetes.bat
    ```
    or
    ```bash
    ./delete-kubernetes.sh
    ```

# Helm (v3)

Note: current problems: Although Strimzi's kafkatopics resource creates the 'orders' topic with multiple partitions, the partition count then seems to get reset to 1, which means Keda can't scale the barista. As a workaround, changing the partition count and then upgrading the chart seems to resolve this (usually).

### Installing
1. Install Strimzi
```
kubectl create ns strimzi
kubectl create ns kafka
helm repo add strimzi https://strimzi.io/charts
helm install strimzi strimzi/strimzi-kafka-operator -n strimzi --set watchNamespaces={kafka}
```
2. Install coffeeshop chart
```
kubectl create ns coffee
cd coffeeshop-chart
helm dependency update
helm install coffee-v1 . -n coffee
```

### Upgrades
Eg. if you have changed something in the chart:
```
helm upgrade coffee-v1 . -n coffee
```

### Removal
Eg. if you want to clear out everything that was created by the chart:
```
helm uninstall coffee-v1 -n coffee
kubectl delete kafkatopics -n kafka --all
kubectl delete hpa -n coffee --all
kubectl delete scaledobjects -n coffee --all
```