#!/bin/sh
#
# Replace local image names with references to the images pushed to
# our local registry in local-registry.sh
# - note, we have associated the IP address of our local registry
#   with the hostname 'registry' in our nodes.
#
# see: https://kind.sigs.k8s.io/docs/user/local-registry/

sed -i'' -e's#image: *\([^/]*\)$#image: registry:5000/\1#' */deployment.yml
