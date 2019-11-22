kubectl create namespace keda
kubectl apply -f ../keda/deploy/crds/keda.k8s.io_scaledobjects_crd.yaml
kubectl apply -f ../keda/deploy/crds/keda.k8s.io_triggerauthentications_crd.yaml
kubectl apply -f ../keda/deploy/
kubectl apply -f barista-kafka-scaler.yml -n coffeeshop-demo