#!/bin/sh
kubectl delete deployment.apps/barista-http --namespace=coffeeshop-demo
kubectl delete deployment.apps/barista-kafka --namespace=coffeeshop-demo
kubectl delete deployment.apps/coffeeshop-service --namespace=coffeeshop-demo
kubectl delete deployment.apps/kafka --namespace=coffeeshop-demo
kubectl delete deployment.apps/zookeeper --namespace=coffeeshop-demo
kubectl delete service/barista-http --namespace=coffeeshop-demo
kubectl delete service/barista-kafka --namespace=coffeeshop-demo
kubectl delete service/coffeeshop-service --namespace=coffeeshop-demo
kubectl delete service/kafka --namespace=coffeeshop-demo
kubectl delete service/zookeeper --namespace=coffeeshop-demo