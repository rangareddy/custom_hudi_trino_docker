#!/bin/bash

set -e

# cp /opt/trino-server/etc/node.properties.template /opt/trino-server/etc/node.properties
# echo "node.id=$HOSTNAME" >> /opt/trino-server/etc/node.properties
# echo "node.environment=test" >> /opt/trino-server/etc/node.properties
# cp /opt/trino-server/etc/catalog/hive.properties.template /opt/trino-server/etc/catalog/hive.properties
# echo "hive.s3.aws-access-key=$AWS_ACCESS_KEY_ID" >> /opt/trino-server/etc/catalog/hive.properties
# echo "hive.s3.aws-secret-key=$AWS_SECRET_ACCESS_KEY" >> /opt/trino-server/etc/catalog/hive.properties

# rm /opt/trino-server/plugin/hive/hudi-*.jar
# rm /opt/trino-server/plugin/hudi/hudi-*.jar
# aws s3 cp s3://eks-manual/trino/hudi/ /opt/trino-server/plugin/hive/ --recursive
# aws s3 cp s3://eks-manual/trino/hudi/ /opt/trino-server/plugin/hudi/ --recursive

/opt/trino-server/bin/launcher run
# /usr/lib/trino/bin/run-trino
