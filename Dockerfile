FROM tier/shibboleth_sp

# Define args and set a default value
ARG maintainer=tier
ARG imagename=grouper
ARG version=2.3.0
ARG tierversion=180401

MAINTAINER $maintainer
LABEL Vendor="Internet2"
LABEL ImageType="Base"
LABEL ImageName=$imagename
LABEL ImageOS=centos7
LABEL Version=$version

ENV VERSION=$version
ENV TIERVERSION=$tierversion
ENV IMAGENAME=$imagename
ENV MAINTAINER=$maintainer

ENV TOMCAT_VERSION="8.5.29"
ENV WAIT_TIME=60

LABEL Build docker build --rm --tag $maintainer/$imagename .

ADD container_files /opt
ONBUILD ADD additional_container_files /opt

RUN mkdir -p /opt/grouper/$VERSION \
      && mv /opt/etc/grouper.installer.properties /opt/grouper/$VERSION/. \
      && mv /opt/etc/MariaDB.repo /etc/yum.repos.d/MariaDB.repo \
      && curl -o /opt/grouper/$VERSION/grouperInstaller.jar https://software.internet2.edu/grouper/release/$VERSION/grouperInstaller.jar \
      && yum -y update \
      && yum -y install --setopt=tsflags=nodocs \
        dos2unix \
        MariaDB-client \
	telnet \
	emacs  \
        mlocate \
      && yum clean all \
      && /opt/autoexec/bin/onbuild.sh \
      && rm /opt/grouper/$version/grouper.apiBinary-$version/conf/grouper.hibernate.properties && \
    cp /opt/etc/grouper.hibernate.pointer.properties /opt/grouper/$version/grouper.apiBinary-$version/conf/grouper.hibernate.properties && \
      rm /opt/grouper/$version/grouper.ws-$version/grouper-ws/build/dist/grouper-ws/WEB-INF/classes/grouper.hibernate.properties && \
    cp /opt/etc/grouper.hibernate.pointer.properties /opt/grouper/$version/grouper.ws-$version/grouper-ws/build/dist/grouper-ws/WEB-INF/classes/grouper.hibernate.properties && \
    rm /opt/grouper/$version/grouper.ui-$version/dist/grouper/WEB-INF/classes/grouper.hibernate.properties && \
    cp /opt/etc/grouper.hibernate.pointer.properties /opt/grouper/$version/grouper.ui-$version/dist/grouper/WEB-INF/classes/grouper.hibernate.properties && \
    ln -sf /opt/bin/run.sh /usr/local/bin/run.sh && \
    updatedb

    #/opt/grouper/2.3.0/grouper.apiBinary-2.3.0/conf/grouper.hibernate.properties
    
# Export this variable so that shibd can find it's CURL library
RUN LD_LIBRARY_PATH="/opt/shibboleth/lib64"
RUN export LD_LIBRARY_PATH
	
# The installer creates a HSQL DB which we ignore later

WORKDIR /opt/grouper/$version

#VOLUME /opt/grouper/2.3.0/apache-tomcat-$TOMCAT_VERSION/logs

EXPOSE 8080 8009 8005 

ADD files/bin/setenv.sh /opt/tier/setenv.sh
RUN chmod +x /opt/tier/setenv.sh
ADD files/bin/startup.sh /usr/bin/startup.sh
RUN chmod +x /usr/bin/startup.sh
ADD files/bin/sendtierbeacon.sh /usr/bin/sendtierbeacon.sh
RUN chmod +x /usr/bin/sendtierbeacon.sh


CMD ["/usr/bin/startup.sh"]
