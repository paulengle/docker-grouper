FROM tier/shibboleth_sp

# Define args and set a default value
ARG maintainer=tier
ARG imagename=grouper
ARG version=2.3.0

MAINTAINER $maintainer
LABEL Vendor="Internet2"
LABEL ImageType="Base"
LABEL ImageName=$imagename
LABEL ImageOS=centos7
LABEL Version=$version
ENV VERSION=$version
ENV TOMCAT_VERSION="6.0.35"
ENV WAIT_TIME=60

LABEL Build docker build --rm --tag $maintainer/$imagename .

ADD container_files /opt
ONBUILD ADD additional_container_files /opt

RUN mkdir -p /opt/grouper/$VERSION \
      && mv /opt/etc/grouper.installer.properties /opt/grouper/$VERSION/. \
      && mv /opt/etc/MariaDB.repo /etc/yum.repos.d/MariaDB.repo \
      && curl -o /opt/grouper/$VERSION/grouperInstaller.jar http://software.internet2.edu/grouper/release/$VERSION/grouperInstaller.jar \
      && yum -y update \
      && yum -y install --setopt=tsflags=nodocs \
        dos2unix \
        MariaDB-client \
        mlocate \
      && yum clean all
      
RUN /opt/autoexec/bin/onbuild.sh

# The installer creates a HSQL DB which we ignore later

WORKDIR /opt/grouper/$version

#VOLUME /opt/grouper/2.3.0/apache-tomcat-$TOMCAT_VERSION/logs

EXPOSE 8080 8009 8005 
CMD ["/opt/bin/start.sh"]