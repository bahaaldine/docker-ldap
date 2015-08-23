#
# VERSION               0.0.2

FROM  ubuntu:trusty

MAINTAINER Bahaaldine Azarmi "baha@elastic.co"

# install slapd in noninteractive mode
RUN echo 'slapd/root_password password password' | debconf-set-selections &&\
    echo 'slapd/root_password_again password password' | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y slapd ldap-utils

ADD files /ldap

RUN service slapd start ;\
    cd /ldap &&\
	ldapadd -Y EXTERNAL -H ldapi:/// -f back.ldif &&\
	ldapadd -Y EXTERNAL -H ldapi:/// -f sssvlv_load.ldif &&\
  ldapadd -Y EXTERNAL -H ldapi:/// -f sssvlv_config.ldif &&\
  ldapadd -x -D cn=admin,dc=elastic,dc=co -w password -c -f front.ldif &&\
  ldapadd -x -D cn=admin,dc=elastic,dc=co -w password -c -f more.ldif

EXPOSE 389

CMD slapd -h 'ldap:/// ldapi:///' -g openldap -u openldap -F /etc/ldap/slapd.d -d stats
