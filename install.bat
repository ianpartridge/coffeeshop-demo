:: Create namespaces for Strimzi and Kafka
kubectl create ns strimzi
kubectl create ns kafka

:: Install Strimzi Helm chart
helm repo add strimzi https://strimzi.io/charts
helm install strimzi strimzi/strimzi-kafka-operator -n strimzi --set watchNamespaces={kafka} --wait --timeout 300s

:: Install Strimzi custom resource, and wait for cluster creation
kubectl apply -f kafka-strimzi.yml -n kafka
kubectl wait --for=condition=Ready kafkas/my-cluster -n kafka --timeout 180s

:: Install coffeeshop-demo into coffee namespace. Chart defaults to
:: installing kafka cluster into kafka namespace.
kubectl create ns coffee
helm dependency update ./coffeeshop-chart
helm install coffee-v1 ./coffeeshop-chart -n coffee --wait --timeout 300s
:: To pull images from a remote repo, override the image repository.
:: Eg: --set baristaKafka.image.repository=registry:5000/barista-kafka --set baristaHttp.image.repository=registry:5000/barista-http --set coffeeshopService.image.repository=registry:5000/coffeeshop-service

:: Display overall system state for kafka and coffee namespaces
kubectl get all -n kafka
kubectl get all -n coffee

:: Get NodePort for coffeeshop-service
FOR /F "tokens=* USEBACKQ" %%F IN (`kubectl get -o jsonpath^="{.spec.ports[0].nodePort}" services coffee-v1-coffeeshop-service --namespace coffee`) DO (
    SET NODE_PORT=%%F
)
echo "Order coffees at http://localhost:%NODE_PORT%/"
