@ECHO OFF
REM From: https://github.com/kubernetes/ingress-nginx/blob/master/docs/deploy/index.md

echo "Creating ingress-nginx service"

@ECHO ON
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud-generic.yaml

