FROM cerebello/spark:2.1.1
MAINTAINER Robson Júnior <bsao@cerebello.co> (@bsao)

###########################################
#### USERS
###########################################
USER root
ARG HADOOP_USER=zeppelin
ARG HADOOP_GROUP=zeppelin
ARG HADOOP_UID=4000
ARG HADOOP_GID=4000
ARG HADOOP_USER=${HADOOP_USER}
ARG HADOOP_GROUP=${HADOOP_GROUP}
ARG HADOOP_UID=${HADOOP_UID}
ARG HADOOP_GID=${HADOOP_GID}
RUN addgroup -g ${HADOOP_GID} -S ${HADOOP_GROUP} && \
    adduser -u ${HADOOP_UID} -D -S -G ${HADOOP_USER} ${HADOOP_GROUP} && \
    usermod -a -G ${SPARK_GROUP} ${HADOOP_USER} && \
    echo "hadoop    ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

##########################################
### ARGS AND ENVS
##########################################
ARG HADOOP_VERSION=2.8.0
ARG HADOOP_LZO=0.4.20
ENV OPT_HOME=/opt
ENV HADOOP_HOME=${OPT_HOME}/hadoop
ENV HADOOP_CONF_DIR=${HADOOP_HOME}/conf
ENV HADOOP_LOGS_DIR=${HADOOP_HOME}/logs
ENV HADOOP_LIBS_DIR=${OPT_HOME}/lib
ENV HADOOP_NAMENODE=${OPT_HOME}/datanode
ENV HADOOP_DATANODE=${OPT_HOME}/data
ENV HADOOP_VERSION=${HADOOP_VERSION}
LABEL name="HADOOP" version=${HADOOP_VERSION}

###########################################
#### DIRECTORIES
###########################################
RUN mkdir -p ${HADOOP_HOME} && \
    mkdir -p ${HADOOP_HOME}/logs && \
    mkdir -p ${HADOOP_NAMENODE} && \
    mkdir -p ${HADOOP_DATANODE} && \
    mkdir -p ${HADOOP_LOGS_DIR} && \
    mkdir -p ${HADOOP_LIBS_DIR} && \
    mkdir -p ${HADOOP_CONF_DIR}

###########################################
#### INSTALL HADOOP
###########################################
RUN wget http://artfiles.org/apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar -xvf hadoop-${HADOOP_VERSION}.tar.gz -C ${HADOOP_HOME} --strip=1 && \
    rm -rf hadoop-${HADOOP_VERSION}.tar.gz
RUN wget http://maven.twttr.com/com/hadoop/gplcompression/hadoop-lzo/${HADOOP_LZO}/hadoop-lzo-${HADOOP_LZO}.jar -P ${HADOOP_LIBS_DIR}/ && \
    wget http://central.maven.org/maven2/org/apache/hadoop/hadoop-streaming/${HADOOP_VERSION}/hadoop-streaming-${HADOOP_VERSION}.jar && \
    cp hadoop-streaming-${HADOOP_VERSION}.jar ${HADOOP_LIBS_DIR}/hadoop-streaming.jar && \
    rm hadoop-streaming-${HADOOP_VERSION}.jar

##########################################
### VOLUME PERMISSIONS
##########################################
RUN chown -R ${HADOOP_USER}:${HADOOP_USER} ${OPT_HOME}

##########################################
### CONFIGURATION VOLUMES
##########################################
VOLUME ${HADOOP_CONF_DIR}
WORKDIR ${OPT_HOME}
CMD ["bash"]