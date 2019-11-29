#!/bin/bash

set -ex

# First argument customizes service port (default, 8080)
SERVICE_PORT=${1:-8080}

# Test POSTing an order
response=`curl -s -d"{\"name\":\"Travis\",\"product\":\"frappuccino\"}" -H "Content-Type: application/json" http://localhost:${SERVICE_PORT}/messaging`
responseRegex='orderId" *: *"[a-z0-9-]+"'

if [[ "$response" =~ $responseRegex ]]; then
  echo "Order ID assigned"
else
  echo "Order ID not found"
  false
fi

# Test order completion. Wait for up to 30 seconds for a response in the stream
# (it should only take around 5 seconds for barista-kafka to respond, but may
# take longer in a CI environment)
timeout=30

# Stream output from the queue to a temporary file
echo "" > tmp.out
curl -s --no-buffer http://localhost:${SERVICE_PORT}/queue > tmp.out &
curlpid=$!

# Poll the temporary file, looking for a line containing the expected response
set +x
for i in `seq 1 ${timeout}`; do
  eventStream=`grep "READY" tmp.out` && break || sleep 1
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
