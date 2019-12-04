#!/bin/bash

set -ex

# First argument customizes service port (default, 8080)
SERVICE_PORT=${1:-8080}

# Second argument contains coffeeshop namespace (default, coffee)
NAMESPACE=${2:-"coffee"}

# Test POSTing an order
response=`curl -s -d"{\"name\":\"Travis\",\"product\":\"frappuccino\"}" -H "Content-Type: application/json" http://localhost:${SERVICE_PORT}/messaging`
responseRegex='orderId" *: *"[a-z0-9-]+"'

if [[ "$response" =~ $responseRegex ]]; then
  echo "Order ID assigned"
else
  echo "Order ID not found"
  false
fi

# Test order completion. Wait for a response in the stream
# (it should only take around 5 seconds for barista-kafka to respond, but may
# take much longer in a CI environment)
# It may also take longer for the initial response if Keda has scaled the kafka
# barista to zero.
timeout=180

# Stream output from the queue to a temporary file
echo "" > tmp.out
curl -s --no-buffer http://localhost:${SERVICE_PORT}/queue > tmp.out &
curlpid=$!

# Poll the temporary file, looking for a line containing the expected response
set +x
for i in `seq 0 ${timeout}`; do
  eventStream=`grep "READY" tmp.out` && break || sleep 1
  if [ $(($i % 5)) -eq 0 ]; then
    # Display periodic progress while we wait
    echo "Waiting for order completion ($i seconds)"
  fi
  if [ $(($i % 10)) -eq 0 ]; then
    # Occasionally show the status of pods if we're waiting a long time
    kubectl get pods -n $NAMESPACE &
  fi
done
set -x

# Kill the stream
kill $curlpid

# Check that the response contains the expected output
responseRegex='"state" *: *"READY"'

if [[ "$eventStream" =~ $responseRegex ]]; then
  echo "Order was successfully processed after $i seconds"
else
  echo "Order completion not detected"
  false
fi
