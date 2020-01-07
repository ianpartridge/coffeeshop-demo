:: Display overall system state for kafka and coffee namespaces
kubectl get all -n kafka
kubectl get all -n coffee

:: Get NodePort for coffeeshop-service
FOR /F "tokens=* USEBACKQ" %%F IN (`kubectl get -o jsonpath^="{.spec.ports[0].nodePort}" services coffee-v1-coffeeshop-service --namespace coffee`) DO (
    SET NODE_PORT=%%F
)
FOR /F "tokens=* USEBACKQ" %%F IN (`kubectl get nodes -o jsonpath^="{ $.items[*].status.addresses[?(@.type=='ExternalIP')].address }"`) DO (
    SET NODE_IP=%%F
)
echo "Order coffees at http://%NODE_IP%:%NODE_PORT%/"
