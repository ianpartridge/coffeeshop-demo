#!/bin/bash


while true; do
  (kubectl get pods -n coffee ; echo "" ; kubectl get hpa -n coffee ; echo "") &
  sleep 5
done
