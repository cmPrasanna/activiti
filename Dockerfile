FROM ubuntu:15.10
MAINTAINER Shan <shanmuga_karna@yahoo.com>

#Install Oracle Java 8
#RUN apt-get update && apt-get -y upgrade && \
#    apt-get install -y python-software-properties software-properties-common wget unzip && \
#    add-apt-repository -y ppa:webupd8team/java && \
#    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
#    apt-get update && apt-get install -y oracle-java8-installer
#ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

#Install OpenJDK 8 JRE Headless
RUN apt-get update && apt-get install -y openjdk-8-jre-headless wget unzip
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

#Install Apache Tomcat 9.0
WORKDIR /opt
RUN wget http://www.us.apache.org/dist/tomcat/tomcat-8/v8.0.30/bin/apache-tomcat-8.0.30.tar.gz && mkdir tomcat && tar -xf apache-tomcat-8.0.30.tar.gz -C ./tomcat --strip-components=1 && rm -rf apache-tomcat-8.0.30.tar.gz

#Download Activiti and deploy to Tomcat
RUN wget https://github.com/Activiti/Activiti/releases/download/activiti-5.19.0/activiti-5.19.0.zip && unzip  activiti-5.19.0.zip && mv activiti-5.19.0 activiti && rm -rf activiti-5.19.0.zip
RUN mkdir /opt/tomcat/webapps/activiti-explorer && unzip /opt/activiti/wars/activiti-explorer.war -d /opt/tomcat/webapps/activiti-explorer/ 
RUN mkdir /opt/tomcat/webapps/activiti-rest && unzip /opt/activiti/wars/activiti-rest.war -d /opt/tomcat/webapps/activiti-rest/
RUN wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.38.tar.gz && tar -C /opt/tomcat/lib/ -xf mysql-connector-java-5.1.38.tar.gz mysql-connector-java-5.1.38/mysql-connector-java-5.1.38-bin.jar  --strip-components=1 && rm -rf mysql-connector-java-5.1.38.tar.gz

#Disable demo user creation in Activiti and remove unwanted tomcat apps
RUN sed -i 's/create.demo.users=true/create.demo.users=false/g;s/create.demo.definitions=true/create.demo.definitions=false/g;s/create.demo.models=true/create.demo.models=false/g;s/create.demo.reports=true/create.demo.reports=flase/g' /opt/tomcat/webapps/activiti-explorer/WEB-INF/classes/engine.properties
RUN sed -i 's/create.demo.users=true/create.demo.users=false/g;s/create.demo.definitions=true/create.demo.definitions=false/g;s/create.demo.models=true/create.demo.models=false/g;s/create.demo.reports=true/create.demo.reports=flase/g' /opt/tomcat/webapps/activiti-rest/WEB-INF/classes/engine.properties
RUN rm -rf /opt/tomcat/webapps/examples
RUN rm -rf /opt/tomcat/webapps/docs

#Install MySQL Client Libraries
RUN apt install --no-install-recommends -y mysql-client && apt-get clean && rm -rf /var/lib/apt/lists/*

ADD . ./
#Start Activiti
CMD [/start]
