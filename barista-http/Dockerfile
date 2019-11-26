FROM adoptopenjdk/openjdk8-openj9:x86_64-ubi-minimal-jdk8u232-b09_openj9-0.17.0 AS build
WORKDIR /

# Install maven
RUN curl -LO https://www-us.apache.org/dist/maven/maven-3/3.6.2/binaries/apache-maven-3.6.2-bin.tar.gz && tar -xzf apache-maven-3.6.2-bin.tar.gz && export PATH=/apache-maven-3.6.2/bin:$PATH && mvn -version
ENV PATH=/apache-maven-3.6.2/bin:$PATH

WORKDIR /project

# Copy project POM
COPY barista-http/pom.xml /project/barista-http/pom.xml
COPY pom.xml /project/

# Download dependencies
RUN mvn -q -f barista-http/pom.xml clean dependency:resolve

# Copy application sources
COPY barista-http/src /project/barista-http/src

# Build and package
RUN mvn -q -f barista-http/pom.xml package

## Create Image
FROM adoptopenjdk/openjdk8-openj9:x86_64-ubi-minimal-jre8u232-b09_openj9-0.17.0
COPY --from=build /project/barista-http/target/lib /project/lib
COPY --from=build /project/barista-http/target/*-runner.jar /project/app.jar
WORKDIR /project

EXPOSE 8082

CMD ["java", "-Dkafka.bootstrap.servers=kafka:9093", "-jar", "app.jar"]
