#!/bin/sh
#
# Push locally built images to the local registry that was created
# by local-cluster.sh

images="ianpartridge/coffeeshop-demo:barista-kafka ianpartridge/coffeeshop-demo:barista-http ianpartridge/coffeeshop-demo:coffeeshop-service"
registry="localhost:5000"

for image in $images; do
  docker image tag ${image} ${registry}/${image} && docker push ${registry}/${image}
done
