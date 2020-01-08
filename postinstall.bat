@ECHO OFF

:: Display overall system state for kafka and coffee namespaces
kubectl get services -n kafka
kubectl get services -n coffee

:: Get NodePort for coffeeshop-service
SET NODE_PORT=
FOR /F "tokens=* USEBACKQ" %%F IN (`kubectl get -o jsonpath^="{.spec.ports[0].nodePort}" services coffee-v1-coffeeshop-service --namespace coffee`) DO (
    SET NODE_PORT=%%F
)
:: Get external IP address for node (assumes single node).
SET NODE_IP=
FOR /F "tokens=* USEBACKQ" %%F IN (`kubectl get nodes -o jsonpath^="{ $.items[*].status.addresses[?(@.type=='ExternalIP')].address }"`) DO (
    SET NODE_IP=%%F
)
:: If there is no ExternalIP, assume localhost
IF "%NODE_IP%"=="" (
    SET NODE_IP=localhost
)
echo.
echo Order coffees at http://%NODE_IP%:%NODE_PORT%/
