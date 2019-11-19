FROM adoptopenjdk/openjdk8-openj9:x86_64-ubi-minimal-jdk8u232-b09_openj9-0.17.0 AS build
WORKDIR /

# Install maven
RUN curl -LO https://www-us.apache.org/dist/maven/maven-3/3.6.2/binaries/apache-maven-3.6.2-bin.tar.gz && tar -xzf apache-maven-3.6.2-bin.tar.gz && export PATH=/apache-maven-3.6.2/bin:$PATH && mvn -version
ENV PATH=/apache-maven-3.6.2/bin:$PATH

WORKDIR /project

# Copy project POM
COPY coffeeshop-service/pom.xml /project/coffeeshop-service/pom.xml
COPY pom.xml /project/

# Download dependencies
RUN mvn -f coffeeshop-service/pom.xml clean dependency:resolve

# Copy application sources
COPY coffeeshop-service/src /project/coffeeshop-service/src

# Build and package
RUN mvn -f coffeeshop-service/pom.xml package

## Create Image
FROM adoptopenjdk/openjdk8-openj9:x86_64-ubi-minimal-jre8u232-b09_openj9-0.17.0
COPY --from=build /project/coffeeshop-service/target/lib /project/lib
COPY --from=build /project/coffeeshop-service/target/*-runner.jar /project/app.jar
WORKDIR /project

EXPOSE 8080

CMD ["java", "-Dkafka.bootstrap.servers=kafka:9093", "-Dme.escoffier.quarkus.coffeeshop.http.BaristaService/mp-rest/url=http://barista-http_1:8082", "-jar", "app.jar"]
