
FROM ubuntu:bionic
MAINTAINER Jim Harner <ejharner@gmail.com>

ARG hadoopversion=2.10.0
ARG hiveversion=2.1.1
ARG sparkversion=3.0.0
ARG javaversion=8
# http://blog.stuart.axelbrooke.com/python-3-on-spark-return-of-the-pythonhashseed
ENV PYTHONHASHSEED 0
ENV PYTHONIOENCODING UTF-8
ENV PIP_DISABLE_PIP_VERSION_CHECK 1
ENV HADOOP_VERSION hadoopversion
ENV HADOOP_HOME /opt/hadoop
ENV HADOOP_CONF_DIR ${HADOOP_HOME}/etc/hadoop
ENV PATH ${HADOOP_HOME}/bin:${PATH}
ENV HADOOP_CMD ${HADOOP_HOME}/bin/hadoop
ENV HADOOP_BIN ${HADOOP_HOME}/bin
ENV HIVE_HOME /opt/hive
ENV HIVE_BIN ${HIVE_HOME}/bin
ENV SPARK_VERSION ${sparkversion}
ENV SPARK_PACKAGE spark-${SPARK_VERSION}-bin-without-hadoop
ENV SPARK_HOME /opt/spark
ENV SPARK_DIST_CLASSPATH "${HADOOP_HOME}/etc/hadoop/*:${HADOOP_HOME}/share/hadoop/common/lib/*:${HADOOP_HOME}/share/hadoop/common/*:${HADOOP_HOME}/share/hadoop/hdfs/*:${HADOOP_HOME}/share/hadoop/hdfs/lib/*:${HADOOP_HOME}/share/hadoop/hdfs/*:${HADOOP_HOME}/share/hadoop/yarn/lib/*:${HADOOP_HOME}/share/hadoop/yarn/*:${HADOOP_HOME}/share/hadoop/mapreduce/lib/*:${HADOOP_HOME}/share/hadoop/mapreduce/*:${HADOOP_HOME}/share/hadoop/tools/lib/*"
ENV R_BASE_VERSION 3.6.3
ENV LD_LIBRARY_PATH $JAVA_HOME/jre/lib/amd64:$JAVA_HOME/jre/lib/amd64/server
ENV PATH=/opt/hadoop/bin:/opt/spark/bin:/opt/hive/bin:${PATH}
ARG DEBIAN_FRONTEND=noninteractive
COPY postgresKey.asc openjdkKey.asc /tmp/

RUN apt-get update && \
    apt-get install -y locales && \
    dpkg-reconfigure -f noninteractive locales && \
    locale-gen en_US.UTF-8 && \
    /usr/sbin/update-locale LANG=en_US.UTF-8 && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
# Install Python 3
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl unzip python3 python3-setuptools python3-pip apt-utils wget ca-certificates apt-transport-https dirmngr gnupg software-properties-common lsb-release unzip && \
    ln -s /usr/bin/python3 /usr/bin/python && \
# JAVA
    apt-key add /tmp/postgresKey.asc && \
    apt-key add /tmp/openjdkKey.asc && \
    add-apt-repository --yes 'deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main' && \
	add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ && \
# Update machine and install
    apt-get update && \
    apt-get install --no-install-recommends -y postgresql-client-${pgversion} libicu-dev adoptopenjdk-${javaversion}-hotspot && \
    update-java-alternatives -s adoptopenjdk-${javaversion}-hotspot-amd64 && \
#	wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - && \
#	add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ && \
	cd /opt && \
    wget https://apache.bintray.com/arrow/$(lsb_release --id --short | tr 'A-Z' 'a-z')/apache-arrow-archive-keyring-latest-$(lsb_release --codename --short).deb && \
    apt-get install -y -V ./apache-arrow-archive-keyring-latest-$(lsb_release --codename --short).deb && \
    apt-get update && \
    apt-get install -y -V libprotobuf-dev libprotobuf-c-dev protobuf-compiler protobuf-c-compiler libprotoc-dev \
                          libarrow-dev libarrow-glib-dev libarrow-dataset-dev libarrow-flight-dev libplasma-dev libplasma-glib-dev \
                          libgandiva-dev libgandiva-glib-dev libparquet-dev libparquet-glib-dev && \
    rm ./apache-arrow-archive-keyring-latest-$(lsb_release --codename --short).deb && \
    python -m pip install py4j pyarrow && \
    wget --quiet https://jdbc.postgresql.org/download/postgresql-42.2.14.jar && \
    echo "JAVA_HOME=/usr/lib/jvm/adoptopenjdk-${javaversion}-hotspot-amd64" >> /etc/profile && \
    export JAVA_HOME=/usr/lib/jvm/adoptopenjdk-${javaversion}-hotspot-amd64 && \
	apt-get clean && \
    rm -rf /var/lib/apt/lists/*

## HADOOP
RUN cd /opt && \
    wget --quiet http://archive.apache.org/dist/hadoop/core/hadoop-${hadoopversion}/hadoop-${hadoopversion}.tar.gz && \
	tar zxf hadoop-${hadoopversion}.tar.gz && \
	mv hadoop-${hadoopversion} hadoop && \
    rm -rf $HADOOP_HOME/share/doc  && \
	rm hadoop-${hadoopversion}.tar.gz && \
	(cd /opt/hadoop; ln -s share/hadoop/tools/lib/hadoop-streaming-${hadoopversion}.jar hadoop-streaming.jar) && \
    chown -R root:root $HADOOP_HOME && \
    mkdir -p /opt/hadoop-data; chown -R root:root /opt/hadoop-data; chmod 700 /opt/hadoop-data && \
## SPARK
    cd /opt  && \
	wget --quiet http://archive.apache.org/dist/spark/spark-${sparkversion}/${SPARK_PACKAGE}.tgz  && \
	tar zxvf ${SPARK_PACKAGE}.tgz  && \
	mv ${SPARK_PACKAGE} spark  && \
	rm ${SPARK_PACKAGE}.tgz  && \
    mkdir /opt/spark-data && \
    chown -R root:root /opt/spark-data && \
	cp /opt/spark/conf/spark-env.sh.template /opt/spark/conf/spark-env.sh  && \
	echo 'export SPARK_DIST_CLASSPATH=/opt/postgresql-42.2.14.jar:$(/opt/hadoop/bin/hadoop classpath)' >> /opt/spark/conf/spark-env.sh && \
    chown -R root:root $SPARK_HOME && \
    echo "JAVA_HOME=/usr/lib/jvm/adoptopenjdk-${javaversion}-hotspot-amd64" >> /opt/hadoop/etc/hadoop/hadoop-env.sh && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

ADD hdfs-site.xml core-site.xml log4j.properties /opt/hadoop/etc/hadoop/
ADD hive-env.sh /etc/profile.d/
ADD hive-site.xml /opt/hive/conf/

ENV LD_LIBRARY_PATH $JAVA_HOME/jre/lib/amd64:$JAVA_HOME/jre/lib/amd64/server

RUN gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
    gpg -a --export E298A3A825C0D65DFD57CBB651716619E084DAB9 | apt-key add - && \
    add-apt-repository -s 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/' && \
## Now install R and littler, and create a link for littler in /usr/local/bin
## Also set a default CRAN repo, and make sure littler knows about it too
    apt-get update && \
###     apt-get install -y --no-install-recommends littler r-cran-littler r-base-${R_BASE_VERSION} r-base-dev-${R_BASE_VERSION} r-recommended=${R_BASE_VERSION} && \
#    apt-get install -y --no-install-recommends littler r-cran-littler r-base r-base-dev r-recommended && \
    apt-get install -y --no-install-recommends r-base r-base-dev r-recommended && \
#    echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"), download.file.method = "libcurl")' >> /etc/R/Rprofile.site && \
#    echo 'source("/etc/R/Rprofile.site")' >> /etc/littler.r && \
#    ln -s /usr/share/doc/littler/examples/install.r /usr/local/bin/install.r && \
#    ln -s /usr/share/doc/littler/examples/install2.r /usr/local/bin/install2.r && \
#    ln -s /usr/share/doc/littler/examples/installGithub.r /usr/local/bin/installGithub.r && \
#    ln -s /usr/share/doc/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r && \
#    install.r docopt && \
#    Rscript -e "install.packages(c(\"arrow\", \"rJava\", \"rjson\", \"RJSONIO\", \"jsonlite\", \"functional\", \"R.methodsS3\", \"caTools\", \"trelliscopejs\", \"RPostgreSQL\", \"RJDBC\", \"housingData\", \"Lahman\", \"nycflights13\", \"flexdashboard\", \"sparklyr\", \"glmnet\", \"reticulate\", \"tensorflow\"), repos = 'http://cran.rstudio.com')" && \
    Rscript -e "install.packages(c(\"arrow\",  \"rJava\", \"rjson\", \"RJSONIO\", \"jsonlite\", \"caTools\", \"trelliscopejs\", \"RPostgreSQL\", \"RJDBC\", \"sparklyr\", \"glmnet\", \"reticulate\", \"tensorflow\"), repos = 'http://cran.rstudio.com')" && \
    rm -rf /tmp/downloaded_packages/ /tmp/*.rds && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD Renviron /usr/local/lib/R/etc/
ADD hdfs-site.xml core-site.xml hive-exec-log4j2.properties hive-log4j2.properties /opt/hadoop/etc/hadoop/
ADD rhdfs.tar.gz rmr.tar.gz /tmp/pkgs/

# Install repository packages
# RUN cd /tmp/pkgs && R CMD INSTALL rmr2 rhdfs

RUN # ln -s /usr/local/bin/Rscript /usr/bin/Rscript && \
# Add path to profile so commands are found if attach to the container
    echo "PATH='/opt/hadoop/bin:/opt/spark/bin:$PATH'" >> /etc/profile && \
    export PATH=/opt/hadoop/bin:/opt/spark/bin:$PATH && \
    echo "PATH='/opt/hadoop/bin:/opt/spark/bin:$PATH'" >> /.bashrc && \
    . /.bashrc

WORKDIR $SPARK_HOME
CMD ["bin/spark-class", "org.apache.spark.deploy.master.Master"]

EXPOSE 7077
EXPOSE 8080
EXPOSE 8081
EXPOSE 4040

## HIVE
#    cd /opt && \
#	wget --quiet http://archive.apache.org/dist/hive/hive-${hiveversion}/apache-hive-${hiveversion}-bin.tar.gz && \
#	tar zxf apache-hive-${hiveversion}-bin.tar.gz && \
#	mv apache-hive-${hiveversion}-bin hive && \
#	ln -s /opt/hive/jdbc/hive-jdbc-${hiveversion}-standalone.jar /opt/hive/lib/ && \
#	ln -s /usr/share/java/postgresql-jdbc4.jar /opt/hive/lib/postgresql-jdbc4.jar && \
#	rm apache-hive-${hiveversion}-bin.tar.gz && \
#	mkdir /opt/hive-data && \
#    mkdir /scripts && \
#    chown -R root:root /opt/hive-data && \
#    chmod 700 /opt/hive-data && \