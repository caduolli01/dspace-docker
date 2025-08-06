FROM openjdk:8-jdk

RUN apt-get update && apt-get install -y wget tar

ENV JAVA_HOME=/usr/local/openjdk-8
ENV CATALINA_HOME=/opt/tomcat
ENV PATH="$JAVA_HOME/bin:$CATALINA_HOME/bin:$PATH"

WORKDIR /opt

RUN wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.107/bin/apache-tomcat-9.0.107.tar.gz && \
    tar -xzf apache-tomcat-9.0.107.tar.gz && \
    mv apache-tomcat-9.0.107 tomcat && \
    rm apache-tomcat-9.0.107.tar.gz

EXPOSE 8080

# Entrypoint para copiar webapps e iniciar Tomcat
ENV CATALINA_OPTS="-Ddspace.dir=/build/dspace-6.3-src-release/dspace/target/dspace-installer"

CMD sh -c "cp -r /build/dspace-6.3-src-release/dspace/target/dspace-installer/webapps/* /opt/tomcat/webapps/ && \
          /opt/tomcat/bin/catalina.sh run"


