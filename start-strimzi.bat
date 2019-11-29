kubectl create ns kafka
curl -L https://github.com/strimzi/strimzi-kafka-operator/releases/download/0.14.0/strimzi-cluster-operator-0.14.0.yaml | sed 's/namespace: .*/namespace: kafka/' | kubectl apply -f - -n kafka
kubectl apply -f kafka-strimzi.yml -n kafka
