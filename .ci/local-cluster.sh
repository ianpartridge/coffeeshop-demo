#!/bin/sh
#
# Set up a local kind cluster connected to a local docker registry.
# This enables us to access images that we have built locally from
# our kind cluster.
#
# See: https://kind.sigs.k8s.io/docs/user/local-registry/
#
set -o errexit

# create registry container unless it already exists 
CLUSTER_NAME="kind"   # desired cluster name; default is "kind"
REGISTRY_CONTAINER_NAME='kind-registry'
REGISTRY_PORT='5000'
if [ "$(docker inspect -f '{{.State.Running}}' "${REGISTRY_CONTAINER_NAME}")" != 'true' ]; then
  docker run -d -p "${REGISTRY_PORT}:5000" --restart=always --name "${REGISTRY_CONTAINER_NAME}" registry:2
fi

# create a cluster with the local registry enabled in containerd
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches: 
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."registry:${REGISTRY_PORT}"]
    endpoint = ["http://registry:${REGISTRY_PORT}"]
EOF

# add the registry to /etc/hosts on each node
for node in $(kind get nodes --name ${CLUSTER_NAME}); do
  docker exec "${node}" sh -c "echo $(docker inspect --format '{{.NetworkSettings.IPAddress }}' "${REGISTRY_CONTAINER_NAME}") registry >> /etc/hosts"
done
