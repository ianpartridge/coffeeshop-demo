#!/bin/sh
kubectl delete deployment.apps/barista-http
kubectl delete deployment.apps/barista-kafka
kubectl delete deployment.apps/coffeeshop-service
kubectl delete deployment.apps/kafka
kubectl delete deployment.apps/zookeeper
kubectl delete service/barista-http
kubectl delete service/barista-kafka
kubectl delete service/coffeeshop-service
kubectl delete service/kafka
kubectl delete service/kubernetes
kubectl delete service/zookeeper