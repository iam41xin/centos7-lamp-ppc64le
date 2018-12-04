FROM centos:7
MAINTAINER iam41xin

# install http
# RUN yum install epel-release
RUN rpm -Uvh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# install httpd
RUN yum -y install httpd vim-enhanced bash-completion unzip wget git

# install maraidb
RUN yum install -y mariadb-server mariadb-client
RUN echo "NETWORKING=yes" > /etc/sysconfig/network
# start mariadb to create initial tables
RUN systemctl start mariadb

# install php
RUN yum install -y php php-mysql php-devel php-gd php-pecl-memcache php-pspell php-snmp php-xmlrpc php-xml

# install supervisord
RUN yum install -y python-pip && pip install --upgrade pip
RUN pip install supervisor

# install sshd
RUN yum install -y openssh-server openssh-clients passwd

RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key

# We need to modify 'changeme' to your own passwd
RUN sed -ri 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config && echo 'root:changeme' | chpasswd

# Put your own public key at id_rsa.pub for key-based login.
RUN mkdir -p /root/.ssh && touch /root/.ssh/authorized_keys && chmod 700 /root/.ssh
#ADD id_rsa.pub /root/.ssh/authorized_keys

# DiscuzX version 3.4
WORKDIR /tmp
RUN git clone https://gitee.com/ComsenzDiscuz/DiscuzX.git
WORKDIR /tmp/DiscuzX
RUN cp -r upload/* /var/www/html/ && cd /var/www/html/ && chmod a+w -R config data uc_server/data uc_client/data

ADD phpinfo.php /var/www/html/
ADD supervisord.conf /etc/
EXPOSE 22 80 443

ENTRYPOINT ["supervisord", "-n"]
