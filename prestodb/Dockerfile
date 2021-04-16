FROM openjdk:8

LABEL Maintainer="Asif Kazi asif.kazi@gmail.com"
LABEL Description="Presto Server"
LABEL Version="0.1.0"

ARG REPO="https://repo1.maven.org/maven2/com/facebook/presto"
ARG PRESTO_VERSION="0.250"
ARG PRESTO_BIN="${REPO}/presto-server/${PRESTO_VERSION}/presto-server-${PRESTO_VERSION}.tar.gz"
ARG PRESTO_CLI_BIN="${REPO}/presto-cli/${PRESTO_VERSION}/presto-cli-${PRESTO_VERSION}-executable.jar"

##Update OS and Dependencies##
USER root
 
RUN apt-get update &&\
    apt-get install -y --allow-unauthenticated curl wget vim less uuid-runtime software-properties-common python3 python3-pip ca-certificates python3-dev util-linux &&\
    pip3 install --upgrade pip 

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/*


#Presto environment variables
ENV PRESTO_HOME /opt/presto
ENV PRESTO_USER presto
ENV PRESTO_CONF_DIR ${PRESTO_HOME}/etc
ENV PATH $PATH:$PRESTO_HOME/bin

#MySQL environment variables
ENV MYSQL_HOST=mysql
ENV MYSQL_PORT=3306
ENV MYSQL_USER=dbuser
ENV MYSQL_PASSWORD=dbuser

##Create presto user and directories##
RUN useradd \
        --create-home \
        --home-dir ${PRESTO_HOME} \
        --shell /bin/bash \
        ${PRESTO_USER}

RUN mkdir -p ${PRESTO_HOME}

##Extract the tar files##
RUN wget --quiet $PRESTO_BIN && \
    tar xzf presto-server-${PRESTO_VERSION}.tar.gz && \
    rm -rf presto-server-${PRESTO_VERSION}.tar.gz && \
    mv presto-server-${PRESTO_VERSION}/* ${PRESTO_HOME} && \
    rm -rf presto-server-${PRESTO_VERSION} && \
    mkdir -p ${PRESTO_CONF_DIR}/catalog/ && \
    mkdir -p ${PRESTO_HOME}/data && \
    cd ${PRESTO_HOME}/bin && \
    wget --quiet ${PRESTO_CLI_BIN} && \
    mv presto-cli-${PRESTO_VERSION}-executable.jar presto && \
    chmod +x presto && \
    chown -R ${PRESTO_USER}:${PRESTO_USER} ${PRESTO_HOME} 

# Copy default Presto configuration files and simple/default connectors
COPY config/*  ${PRESTO_CONF_DIR}
COPY catalog/* ${PRESTO_CONF_DIR}/catalog/
COPY etc/init.d/presto /etc/init.d/presto
RUN chmod 0755 /etc/init.d/presto
COPY entrypoint.sh /usr/local/bin/
RUN chmod 0755 /usr/local/bin/entrypoint.sh
COPY startup.sh /usr/local/bin/
RUN chmod 0755 /usr/local/bin/startup.sh

EXPOSE 8080
WORKDIR ${PRESTO_HOME} 

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD /usr/local/bin/startup.sh
