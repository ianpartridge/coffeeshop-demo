#!/bin/sh
kubectl create ns kafka
kubectl create ns coffeeshop-demo
kubectl apply -f strimzi-0.14.0/cluster-operator/ -n kafka
kubectl apply -f strimzi-0.14.0/cluster-operator/020-RoleBinding-strimzi-cluster-operator.yaml -n coffeeshop-demo
kubectl apply -f strimzi-0.14.0/cluster-operator/032-RoleBinding-strimzi-cluster-operator-topic-operator-delegation.yaml -n coffeeshop-demo
kubectl apply -f strimzi-0.14.0/cluster-operator/031-RoleBinding-strimzi-cluster-operator-entity-operator-delegation.yaml -n coffeeshop-demo
kubectl apply -f kafka-strimzi.yml -n coffeeshop-demo