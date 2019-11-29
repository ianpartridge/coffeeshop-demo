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

# Test order completion. Wait for 6 seconds for a response in the stream
# (it should only take around 5 seconds for barista-kafka to respond, but
# may take longer in a CI environment)
eventStream=`curl -s --max-time 6 http://localhost:${SERVICE_PORT}/queue | grep 'data'`
responseRegex='"state" *: *"READY"'

if [[ "$eventStream" =~ $responseRegex ]]; then
  echo "Order was successfully processed"
else
  echo "Order completion not detected"
  false
fi
