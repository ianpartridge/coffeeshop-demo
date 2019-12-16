ARG scc_dir="/tmp/scc"
ARG scc_opts="-Xshareclasses:name=coffeeshop,cacheDir=${scc_dir},cacheDirPerm=0777"

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
ARG scc_opts

COPY --from=build --chown=1001:0 /project/barista-kafka/target/barista-kafka-1.0-SNAPSHOT.war /opt/ol/wlp/usr/servers/defaultServer/apps
COPY --from=build --chown=1001:0 /project/barista-kafka/src/main/liberty/config/server.xml /opt/ol/wlp/usr/servers/defaultServer

# Copy utility for generating random Barista name
COPY barista-kafka/barista-name.sh /tmp

# Clear Liberty's default java options (scc) so ours do not conflict
ENV IBM_JAVA_OPTIONS=

# Start and stop Liberty to create the shared class cache
#ENV JAVA_TOOL_OPTIONS="${scc_opts} -Xscmx20m -Xtune:virtualized"
ENV JAVA_TOOL_OPTIONS="${scc_opts}"
RUN /opt/ol/wlp/bin/server start defaultServer && sleep 5 && /opt/ol/wlp/bin/server stop defaultServer && (java ${scc_opts},printStats || echo "OK")

EXPOSE 8090

# We inherit the CMD to start Liberty from the open-liberty image.
