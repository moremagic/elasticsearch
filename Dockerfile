FROM centos:7
MAINTAINER moremagic<itoumagic@gmail.com>

# Install
RUN yum -y update
RUN yum -y install wget tar java-1.8.0-*

# ssh
RUN yum install -y passwd openssh-* initscripts \
	&& echo 'root:root' | chpasswd \
	&& /usr/sbin/sshd-keygen

# Elasticsearch install
RUN rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
ADD elasticsearch.repo /etc/yum.repos.d/
RUN yum update && yum install -y elasticsearch
RUN echo network.host: _site_$'\n'node.name: $'${HOSTNAME}' >> /etc/elasticsearch/elasticsearch.yml

# elasticsearch config
WORKDIR /usr/share/elasticsearch

# elasticsearch-head config
RUN bin/plugin install mobz/elasticsearch-head

# kuromoji config
RUN bin/plugin install analysis-kuromoji
RUN echo index.analysis.analyzer.default.type: custom  >> /etc/elasticsearch/elasticsearch.yml
RUN echo index.analysis.analyzer.default.tokenizer: kuromoji_tokenizer >> /etc/elasticsearch/elasticsearch.yml

# discovery-multicast config
RUN bin/plugin install discovery-multicast
RUN echo cluster.name: docker.elasticsearch>> /etc/elasticsearch/elasticsearch.yml
RUN echo discovery.zen.ping.multicast.enabled: true>> /etc/elasticsearch/elasticsearch.yml
RUN echo network.bind_host: _site_>> /etc/elasticsearch/elasticsearch.yml
RUN echo network.publish_host: '_eth0:ipv4_'>> /etc/elasticsearch/elasticsearch.yml

EXPOSE 22 9200 9300 9300/udp
CMD /etc/init.d/elasticsearch start; \
	/usr/sbin/sshd -D
