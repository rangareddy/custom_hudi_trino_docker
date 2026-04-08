#  Licensed to the Apache Software Foundation (ASF) under one
#  or more contributor license agreements.  See the NOTICE file
#  distributed with this work for additional information
#  regarding copyright ownership.  The ASF licenses this file
#  to you under the Apache License, Version 2.0 (the
#  "License"); you may not use this file except in compliance
#  with the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
# limitations under the License.

ARG JAVA_VERSION
FROM eclipse-temurin:${JAVA_VERSION}-jdk-jammy

RUN apt-get update && apt-get install -y less curl python3 nano wget awscli --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/python3 /usr/bin/python

ARG TRINO_VERSION
RUN if [ -z "${TRINO_VERSION}" ]; then \
        echo "Error: TRINO_VERSION build argument is required"; \
        exit 1; \
    fi && \
    echo "Building Trino Docker image with version: ${TRINO_VERSION}"

ENV TRINO_VERSION=${TRINO_VERSION} \
    TRINO_HOME=/opt/trino-server

COPY jars/trino-server-${TRINO_VERSION}.tar /opt/trino-server-${TRINO_VERSION}.tar
RUN tar -xf /opt/trino-server-${TRINO_VERSION}.tar -C /opt/ \
	&& ln -s /opt/trino-server-${TRINO_VERSION} ${TRINO_HOME} \
	&& rm /opt/trino-server-${TRINO_VERSION}.tar \
	&& mkdir -p $TRINO_HOME/etc \
	&& mkdir -p $TRINO_HOME/etc/catalog

COPY jars/trino-cli-${TRINO_VERSION}-executable.jar /opt/
RUN mv /opt/trino-cli-${TRINO_VERSION}-executable.jar trino-cli \
	&& chmod +x trino-cli

RUN wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.16.1/jmx_prometheus_javaagent-0.16.1.jar \
	&& chmod +x jmx_prometheus_javaagent-0.16.1.jar \
	&& mv jmx_prometheus_javaagent-0.16.1.jar /opt/jmx_prometheus_javaagent-0.16.1.jar

COPY conf/trino/catalog/config.yaml /opt/config.yaml
COPY conf/trino/catalog/jvm.config /opt/trino-server/etc/jvm.config
COPY conf/trino/catalog/config.properties /opt/trino-server/etc/config.properties
COPY conf/trino/catalog/node.properties /opt/trino-server/etc/node.properties
COPY conf/trino/catalog/tpcds.properties /opt/trino-server/etc/catalog/tpcds.properties
COPY conf/trino/catalog/memory.properties /opt/trino-server/etc/catalog/memory.properties
COPY conf/trino/catalog/hudi.properties /opt/trino-server/etc/catalog/hudi.properties
COPY conf/trino/catalog/hive.properties /opt/trino-server/etc/catalog/hive.properties
COPY conf/trino/catalog/mysql.properties /opt/trino-server/etc/catalog/mysql.properties

RUN rm -f /opt/trino-server/plugin/hudi/hudi-*.jar || true
RUN rm -f /opt/trino-server/plugin/hive/hudi-*.jar || true

COPY jars/ /tmp/jars-copy/
RUN mkdir -p /tmp/hudi-bundle-dir && \
    if ls /tmp/jars-copy/hudi-trino-bundle-*.jar 1> /dev/null 2>&1; then \
        cp /tmp/jars-copy/hudi-trino-bundle-*.jar /tmp/hudi-bundle-dir/ && \
        cp /tmp/hudi-bundle-dir/hudi-trino-bundle-*.jar /opt/trino-server/plugin/hudi/ && \
        cp /tmp/hudi-bundle-dir/hudi-trino-bundle-*.jar /opt/trino-server/plugin/hive/ && \
        rm -rf /tmp/hudi-bundle-dir /tmp/jars-copy && \
        echo "✓ Copied Hudi bundle to plugins"; \
    else \
        echo "⚠ Warning: Hudi bundle jar not found in jars/ directory, skipping"; \
        rm -rf /tmp/hudi-bundle-dir /tmp/jars-copy || true; \
    fi

COPY conf/trino/catalog/autoconfig_and_launch.sh /opt/autoconfig_and_launch.sh
RUN chmod a+x /opt/autoconfig_and_launch.sh
CMD ["/opt/autoconfig_and_launch.sh"]
