#!/bin/sh
kubectl apply -f zookeeper-deployment.yaml --namespace=coffeeshop-demo
kubectl apply -f kafka-deployment.yaml --namespace=coffeeshop-demo
kubectl apply -f barista-http/deployment.yml --namespace=coffeeshop-demo
kubectl apply -f barista-kafka/deployment.yml --namespace=coffeeshop-demo
kubectl apply -f coffeeshop-service/deployment.yml --namespace=coffeeshop-demo

kubectl apply -f zookeeper-service.yaml --namespace=coffeeshop-demo
kubectl apply -f kafka-service.yaml --namespace=coffeeshop-demo
kubectl apply -f barista-http/service.yml --namespace=coffeeshop-demo
kubectl apply -f barista-kafka/service.yml --namespace=coffeeshop-demo
kubectl apply -f coffeeshop-service/service.yml --namespace=coffeeshop-demo