FROM centos:7
MAINTAINER Hiroaki Nakamura <hnakamur@gmail.com>

RUN yum -y install rpmdevtools rpm-build \
 && rpmdev-setuptree

RUN yum -y install epel-release \
 && yum -y install python-pip \
 && pip install copr-cli

ADD nodejs.spec /root/rpmbuild/SPECS/
ADD node-js.*patch /root/rpmbuild/SOURCES/

RUN version=`awk '$1=="Version:" {print $2}' /root/rpmbuild/SPECS/nodejs.spec` \
 && curl -sL -o /root/rpmbuild/SOURCES/node-v${version}.tar.xz https://nodejs.org/dist/v${version}/node-v${version}.tar.xz \
 && rpmbuild -bs /root/rpmbuild/SPECS/nodejs.spec

ADD copr-build.sh /root/
ENTRYPOINT ["/bin/bash", "/root/copr-build.sh"]
