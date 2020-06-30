docker build -f barista-kafka\Dockerfile -t ianpartridge/coffeeshop-demo:barista-kafka .
docker build -f barista-http\Dockerfile -t ianpartridge/coffeeshop-demo:barista-http .
docker build -f coffeeshop-service\Dockerfile -t ianpartridge/coffeeshop-demo:coffeeshop-service .
