FROM centos:7
MAINTAINER moremagic<itoumagic@gmail.com>

# Install
RUN yum -y update
RUN yum -y install wget tar java-1.7.0-*

# ssh
RUN yum install -y passwd openssh-server initscripts \
	&& echo 'root:root' | chpasswd \
	&& /usr/sbin/sshd-keygen

# Elasticsearch install
RUN rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
ADD elasticsearch.repo /etc/yum.repos.d/
RUN yum update && yum install -y elasticsearch

WORKDIR /usr/share/elasticsearch
RUN bin/plugin install analysis-kuromoji
RUN bin/plugin install mobz/elasticsearch-head

RUN echo network.host: 0.0.0.0$'\n'node.name: $'${HOSTNAME}' >> /etc/elasticsearch/elasticsearch.yml

EXPOSE 22 9200
CMD /etc/init.d/elasticsearch start; \
	/usr/sbin/sshd -D
