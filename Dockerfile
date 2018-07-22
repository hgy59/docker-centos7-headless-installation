FROM centos

RUN yum -y install \
        --setopt=tsflags=nodocs \
        --disableplugin=fastestmirror \
        mkisofs syslinux pykickstart file isomd5sum createrepo &&\
    yum clean all && rm -rf /var/cache/yum

WORKDIR /work
COPY ./work/* ./
RUN chmod +x ./*.sh

VOLUME /iso
VOLUME /target
VOLUME /custom

CMD ["/bin/bash","startup.sh"]
