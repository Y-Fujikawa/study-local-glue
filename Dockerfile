FROM centos:7

RUN yum install -y bzip2 bzip2-devel gcc gcc-c++ make openssl-devel readline-devel zlib-devel wget curl unzip vim epel-release git \
    && yum install -y tig jq vim-enhanced bash-completion net-tools bind-utils \
    && yum install -y python3 python3-libs python3-devel python3-pip \
    && yum install -y java java-1.8.0-openjdk-devel \
    && rm -rf /var/cache/yum/*

RUN localedef -f UTF-8 -i ja_JP ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
ENV LC_CTYPE "ja_JP.UTF-8"
ENV LC_NUMERIC "ja_JP.UTF-8"
ENV LC_TIME "ja_JP.UTF-8"
ENV LC_COLLATE "ja_JP.UTF-8"
ENV LC_MONETARY "ja_JP.UTF-8"
ENV LC_MESSAGES "ja_JP.UTF-8"
ENV LC_PAPER "ja_JP.UTF-8"
ENV LC_NAME "ja_JP.UTF-8"
ENV LC_ADDRESS "ja_JP.UTF-8"
ENV LC_TELEPHONE "ja_JP.UTF-8"
ENV LC_MEASUREMENT "ja_JP.UTF-8"
ENV LC_IDENTIFICATION "ja_JP.UTF-8"
ENV LC_ALL ja_JP.UTF-8

# Glueライブラリ取得
RUN git clone -b master --depth 1  https://github.com/awslabs/aws-glue-libs

# Maven取得
RUN curl -OL https://aws-glue-etl-artifacts.s3.amazonaws.com/glue-common/apache-maven-3.6.0-bin.tar.gz
RUN tar -xzvf apache-maven-3.6.0-bin.tar.gz
RUN mv apache-maven-3.6.0 /opt/
RUN ln -s /opt/apache-maven-3.6.0 /opt/apache-maven
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk/jre/
ENV PATH $PATH:/opt/apache-maven/bin
RUN mvn -version

# Glueアーティファクト取得
RUN curl -OL https://aws-glue-etl-artifacts.s3.amazonaws.com/glue-3.0/spark-3.1.1-amzn-0-bin-3.2.1-amzn-3.tgz
RUN tar -xvf spark-3.1.1-amzn-0-bin-3.2.1-amzn-3.tgz
RUN mv spark-3.1.1-amzn-0-bin-3.2.1-amzn-3 /opt/
RUN ln -s /opt/spark-3.1.1-amzn-0-bin-3.2.1-amzn-3 /opt/spark
ENV SPARK_HOME /opt/spark

# Python3を利用する設定
RUN unlink /bin/python
RUN ln -s /bin/python3 /bin/python
RUN ln -s /bin/pip3 /bin/pip

# 異なるバージョンのjarがsparkとglueに混在するので適切なバージョンのみを見るよう設定
RUN ln -s ${SPARK_HOME}/jars /aws-glue-libs/jarsv1
RUN ./aws-glue-libs/bin/gluepyspark

# guava.jarが14と21の両方インストールされるため古い方を削除
RUN rm -fr ${SPARK_HOME}/jars/guava-14.0.1.jar
ENTRYPOINT ["/bin/sh", "-c", "while :; do sleep 10; done"]
