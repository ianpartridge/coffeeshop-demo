#!/bin/sh
sed -i'' -e's#image: *\([^/]*\)$#image: registry:5000/\1#' */deployment.yml
