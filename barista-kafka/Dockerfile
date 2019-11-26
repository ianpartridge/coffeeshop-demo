FROM adoptopenjdk/openjdk8-openj9:x86_64-ubi-minimal-jdk8u232-b09_openj9-0.17.0 AS build
WORKDIR /

# Install maven
RUN curl -LO https://www-us.apache.org/dist/maven/maven-3/3.6.2/binaries/apache-maven-3.6.2-bin.tar.gz && tar -xzf apache-maven-3.6.2-bin.tar.gz && export PATH=/apache-maven-3.6.2/bin:$PATH && mvn -version
ENV PATH=/apache-maven-3.6.2/bin:$PATH

WORKDIR /project

# Copy project POM
COPY barista-kafka/pom.xml /project/barista-kafka/pom.xml
COPY pom.xml /project/

# Download dependencies
RUN mvn -q -f barista-kafka/pom.xml clean dependency:resolve

# Copy application sources
COPY barista-kafka/src /project/barista-kafka/src

# Build and package
RUN mvn -q -f barista-kafka/pom.xml package

## Create Image
FROM adoptopenjdk/openjdk8-openj9:x86_64-ubi-minimal-jre8u232-b09_openj9-0.17.0
COPY --from=build /project/barista-kafka/target/lib /project/lib
COPY --from=build /project/barista-kafka/target/*-runner.jar /project/app.jar
WORKDIR /project

EXPOSE 8090

CMD ["java", "-Dkafka.bootstrap.servers=kafka:9093", "-jar", "app.jar"]
