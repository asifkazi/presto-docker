#!/bin/bash
# Populate node.id from uuidgen by replacing template with the node uuid
nodeid() {
  sed -i 's@$(NODE_UUID)@'$(uuidgen)'@g' ${PRESTO_CONF_DIR}/node.properties
  sed -i 's@$(PRESTO_HOME)@'${PRESTO_HOME}'@g' ${PRESTO_CONF_DIR}/node.properties
  sed -i 's@$(PRESTO_CONF_DIR)@'${PRESTO_CONF_DIR}'@g' ${PRESTO_CONF_DIR}/node.properties
}

coordinator_config() {
  (
    echo "coordinator=true"
    echo "node-scheduler.include-coordinator=false"
    echo "http-server.http.port=${HTTP_SERVER_PORT}"
    echo "query.max-memory=${PRESTO_MAX_MEMORY}GB"
    echo "query.max-memory-per-node=${PRESTO_MAX_MEMORY_PER_NODE}GB"
    echo "discovery-server.enabled=true"
    echo "discovery.uri=http://localhost:${HTTP_SERVER_PORT}"
  ) >${PRESTO_CONF_DIR}/config.properties
}

worker_config() {
  (
    echo "coordinator=false"
    echo "http-server.http.port=${HTTP_SERVER_PORT}"
    echo "query.max-memory=${PRESTO_MAX_MEMORY}GB"
    echo "query.max-memory-per-node=${PRESTO_MAX_MEMORY_PER_NODE}GB"
    echo "discovery-server.enabled=true"
    echo "discovery.uri=http://${COORDINATOR}:${HTTP_SERVER_PORT}"
  ) >${PRESTO_CONF_DIR}/config.properties
}

jvm_config() {
  sed -i "s/-Xmx.*G/-Xmx${PRESTO_JVM_HEAP_SIZE}G/" ${PRESTO_CONF_DIR}/jvm.config
}

hive_catalog_config() {
  (
    echo "connector.name=hive-hadoop2"
    echo "hive.metastore.uri=thrift://${HIVE_METASTORE_HOST}:${HIVE_METASTORE_PORT}"
    echo "hive.s3.aws-access-key=${AWS_ACCESS_KEY_ID}"
    echo "hive.s3.aws-secret-key=${AWS_SECRET_ACCESS_KEY_ID}"
  ) >${PRESTO_CONF_DIR}/catalog/hive.properties
}

mysql_catalog_config() {
  (
    echo "connector.name=mysql"
    echo "connection-url=jdbc:mysql://${MYSQL_HOST}:${MYSQL_PORT}?useSSL=false"
    echo "connection-user=${MYSQL_USER}"
    echo "connection-password=${MYSQL_PASSWORD}"
  ) >${PRESTO_CONF_DIR}/catalog/mysql.properties
}

nodeid

# Update the Presto config.properties file with values for the coordinator and
# workers. Only if the following 3 parameters are set.
[[ -n "${HTTP_SERVER_PORT}" && -n "${PRESTO_MAX_MEMORY}" && -n "${PRESTO_MAX_MEMORY_PER_NODE}" ]] && \
if [[ -z "${COORDINATOR}" ]]; then coordinator_config; else worker_config; fi

# Update the JVM configuration for any node. Only if the PRESTO_JVM_HEAP_SIZE
# parameter is set.
[[ -n "${PRESTO_JVM_HEAP_SIZE}" ]] && jvm_config


# Create a Hadoop connector as metastore. Only if the metastore host and port
# parameters are set.
[[ -n "${HIVE_METASTORE_HOST}" && -n "${HIVE_METASTORE_PORT}" && -n "${AWS_ACCESS_KEY_ID}" && -n "${AWS_SECRET_ACCESS_KEY_ID}" ]] && hive_catalog_config

# Create a MySQL connector, only if the mysql url, user and password parameters
# are set.
[[ -n "${MYSQL_HOST}" && -n "${MYSQL_PORT}" && -n "${MYSQL_USER}" && -n "${MYSQL_PASSWORD}" ]] && mysql_catalog_config

exec $@
