FROM adoptopenjdk/maven-openjdk8-openj9 AS build

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
FROM open-liberty

COPY --from=build --chown=1001:0 /project/barista-kafka/target/barista-kafka-1.0-SNAPSHOT.war /opt/ol/wlp/usr/servers/defaultServer/apps
COPY --from=build --chown=1001:0 /project/barista-kafka/src/main/liberty/config/server.xml /opt/ol/wlp/usr/servers/defaultServer

# Copy utility for generating random Barista name
COPY barista-kafka/barista-name.sh /tmp

# Start and stop Liberty to create the shared class cache
# To capture JVM start options, add: -verbose:gc -Xverbosegclog:/tmp/gc.log.%p
ENV JAVA_TOOL_OPTIONS="${JAVA_TOOL_OPTIONS} -Xquickstart -Xms64m -Xmn48m"
RUN /opt/ol/wlp/bin/server start defaultServer && sleep 5 && /opt/ol/wlp/bin/server stop defaultServer && (java -Xshareclasses:name=liberty-%u,nonfatal,cacheDir=/opt/ol/wlp/output/.classCache,printStats || echo "OK")

EXPOSE 8090

# We inherit the CMD to start Liberty from the open-liberty image.
