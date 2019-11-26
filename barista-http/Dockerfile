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

# Start with OL runtime.
FROM open-liberty

# Copy app binaries

COPY --from=build --chown=1001:0 /project/barista-http/target/barista-http-1.0-SNAPSHOT.war /opt/ol/wlp/usr/servers/defaultServer/apps
COPY --from=build --chown=1001:0 /project/barista-http/src/main/liberty/config/server.xml /opt/ol/wlp/usr/servers/defaultServer

EXPOSE 8082
