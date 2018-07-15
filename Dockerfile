FROM centos

RUN yum -y install \
        --setopt=tsflags=nodocs \
        --disableplugin=fastestmirror \
        mkisofs syslinux file &&\
    yum clean all && rm -rf /var/cache/yum

WORKDIR /work
COPY ./work/* ./

VOLUME /iso
VOLUME /target

CMD ["/bin/bash","startup.sh"]
