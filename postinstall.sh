#!/bin/bash

# Display overall system state for kafka and coffee namespaces
kubectl get all -n kafka
kubectl get all -n coffee

# Get NodePort for coffeeshop-service
export NODE_PORT=$(kubectl get -o jsonpath="{.spec.ports[0].nodePort}" services coffee-v1-coffeeshop-service --namespace coffee)
export NODE_IP=$(kubectl get nodes -o jsonpath='{ $.items[*].status.addresses[?(@.type=="ExternalIP")].address }')
echo "Order coffees at http://${NODE_IP}:${NODE_PORT}/"
