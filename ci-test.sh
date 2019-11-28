#!/bin/bash

set -ex

# Test POSTing an order
response=`curl -s -d"{\"name\":\"Travis\",\"product\":\"frappuccino\"}" -H "Content-Type: application/json" http://localhost:8080/messaging`
responseRegex='orderId" *: *"[a-z0-9-]+"'

if [[ "$response" =~ $responseRegex ]]; then
  echo "Order ID assigned"
else
  echo "Order ID not found"
  false
fi

# Test order completion
eventStream=`curl -s --max-time 10 http://localhost:8080/queue | grep 'data'`
responseRegex='"state" *: *"READY"'

if [[ "$eventStream" =~ $responseRegex ]]; then
  echo "Order was successfully processed"
else
  echo "Order completion not detected"
  false
fi
