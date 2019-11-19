kubectl apply -f zookeeper-deployment.yaml
kubectl apply -f kafka-deployment.yaml
kubectl apply -f barista-http/deployment.yml
kubectl apply -f barista-kafka/deployment.yml
kubectl apply -f coffeeshop-service/deployment.yml

kubectl apply -f zookeeper-service.yaml
kubectl apply -f kafka-service.yaml
kubectl apply -f barista-http/service.yml
kubectl apply -f barista-kafka/service.yml
kubectl apply -f coffeeshop-service/service.yml