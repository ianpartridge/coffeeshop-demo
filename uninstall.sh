#!/bin/sh

# Uninstall coffeeshop-demo and kafka cluster
helm uninstall coffee-v1 -n coffee

# Delete coffee namespace
kubectl delete ns coffee

# Delete Kafka cluster
kubectl delete -f kafka-strimzi.yml -n kafka

# Uninstall Strimzi Helm chart
helm uninstall strimzi -n strimzi

# Delete namespaces for Strimzi and Kafka
kubectl delete ns strimzi
kubectl delete ns kafka
