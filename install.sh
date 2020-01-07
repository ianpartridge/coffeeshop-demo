#!/bin/sh

# Create namespaces for Strimzi and Kafka
kubectl create ns strimzi
kubectl create ns kafka

# Install Strimzi Helm chart
helm repo add strimzi https://strimzi.io/charts
helm install strimzi strimzi/strimzi-kafka-operator -n strimzi --set watchNamespaces={kafka} --wait --timeout 300s

# Install Strimzi custom resource, and wait for cluster creation
kubectl apply -f kafka-strimzi.yml -n kafka
kubectl wait --for=condition=Ready kafkas/my-cluster -n kafka --timeout 180s

# Create namespace for Keda
kubectl create ns keda

# Install Keda Helm chart
helm repo add kedacore https://kedacore.github.io/charts
helm install keda kedacore/keda -n keda --wait --timeout 300s

# Install coffeeshop-demo into coffee namespace. Requires that Kafka cluster
# is already created. Contains custom resources:
# - Strimzi: CRs for orders and queue topics (installed into kafka ns)
# - Keda: ScaledObject for barista-kafka service (installed into coffee ns)
kubectl create ns coffee
helm install coffee-v1 ./coffeeshop-chart -n coffee --wait --timeout 300s
# To pull images from a remote repo, override the image repository.
# Eg: --set baristaKafka.image.repository=registry:5000/barista-kafka --set baristaHttp.image.repository=registry:5000/barista-http --set coffeeshopService.image.repository=registry:5000/coffeeshop-service

./postinstall.sh
