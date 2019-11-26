#!/bin/sh

images="barista-kafka barista-http coffeeshop-service"
registry="localhost:5000"

for image in $images; do
  docker image tag ${image} ${registry}/${image} && docker push ${registry}/${image}
done
