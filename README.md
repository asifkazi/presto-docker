# Presto Docker Container

Docker image for Presto Server and Presto CLI.

## Supported tags and Dockerfiles

### Presto Server:
* [latest](./prestodb): [Dockerfile](./prestodb/Dockerfile)
* [0.250](./prestodb): [Dockerfile](./prestodb/Dockerfile)


## Quick Start

This repository is integrated with Docker Registry at `asifkazi/prestodb`, any change in the `master` branch will push a new image to Docker Registry.

To get the image use the Docker pull command:

    docker pull asifkazi/presto:0.250

With a Dockerfile you can use:

    FROM asifkazi/presto:0.250

    COPY catalog/Hive.properties /usr/lib/presto/etc/catalog/

    ENV HTTP_SERVER_PORT=8080
    ENV PRESTO_MAX_MEMORY=50
    ENV PRESTO_MAX_MEMORY_PER_NODE=1
    ENV PRESTO_JVM_HEAP_SIZE=8

    CMD /etc/init.d/presto run

Then you can build and run a Presto Server with:

    docker build -t prestodb .
    docker run -it --rm --name presto-docker -d prestodb /bin/sh --login

You can either use the presto cli on the docker container, or download the jar from the prestodb website

    $ presto
    presto>  show catalogs;
      Catalog
    -----------
     blackhole
     jmx
     system
     tpch
    (4 rows)

    Query 20170423_051645_00006_ccijx, FINISHED, 1 node
    Splits: 1 total, 1 done (100.00%)
    0:00 [0 rows, 0B] [0 rows/s, 0B/s]

    presto>

To create a Presto cluster you can use [Docker Compose](./compose/README.md) or [Kubernetes](./compose/README.md).

## Build your own image

To build the new images just execute `make`.

If you which to release/push the new images to a Docker Registry, modify in the Makefile the variable `DOCKER_USER` and execute:

    make release

Optionally, you can pass the Presto Server version to build or release.

    make PRESTO_VERSION=0.250
    make release PRESTO_VERSION=0.250

With the `make` you can also:
* Do it all (build, release and clean): `make all`
* Pull the image: `make pull`
* Create a container and login into it: `make sh`
* Remove any container creted with that image: `make clean`
* Remove container(s) and the image: `make clean-all`
* List all the containers and images: `make ls`
* Open the Presto Dashboar (only Mac OSX): `make presto-dashboard`
* Execute queries: `make query H=coordinator Q='show catalogs;'`, `make query-catalogs H=coordinator`, `make query-workers H=coordinator`
* And, you can list all the options and description with: `make help`

## Environment variables for the container

### Required variables for **every node**

Presto port:

    HTTP_SERVER_PORT=8080

Presto memory settings:

    PRESTO_MAX_MEMORY=50
    PRESTO_MAX_MEMORY_PER_NODE=1
    PRESTO_JVM_HEAP_SIZE=8

### Required variables for **every worker**

Address of the Coordinator (IP address or hostname):

    COORDINATOR=coordinator

### Optional variables:

HIVE metastore parameters, if **all of them** are set a Hive metastore connector will be created:

    HIVE_METASTORE_HOST=hive-hadoop-service
    HIVE_METASTORE_PORT=9083

MySQL parameters, if **all of them** are set a MySQL connector will be created:

    MYSQL_HOST=mysql-service
    MYSQL_PORT=3306
    MYSQL_USER=test
    MYSQL_PASSWORD=test

## What's in the image?

The image contain:
* Latest OpenJDK 8 (`openjdk:8`)
* Python3
* Presto 0.250

The entrypoint will:
* Configure Presto:
  * Update Node Id in `/etc/presto/node.properties`
  * Setup Presto as coordinator or worker, depending of the `COORDINATOR` environment variable
  * Set JVM Heap Size in `/etc/presto/jvm.config`
* Create a Hive Metastore if the `HIVE_METASTORE_*` environment variables are set

## TODO
- [ ] Integrate with Kubernetes
