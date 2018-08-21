FROM       sonatype/nexus3:3.13.0
MAINTAINER Brian Auron <briauron@amazon.com>
# lovingly stolen from https://github.com/bradbeck/nexus-https

ENV NEXUS_SSL=${NEXUS_HOME}/etc/ssl
ENV PUBLIC_CERT=${NEXUS_SSL}/cacert.pem \
    PUBLIC_CERT_SUBJ=/CN=nexus-repository.example.com \
    PRIVATE_KEY=${NEXUS_SSL}/cakey.pem \
	PRIVATE_KEY_PASSWORD='very_long_encrypted_password_string_here'
# This secret was generated thusly:
# aws kms encrypt \
#   --key-id some_key_id_here \
#   --plaintext 'WHATEVER_THE_PASSWORD_WAS' \
#   --output text \
#   --query CiphertextBlob \
#   --profile ${whatever_profile_you_use}

ARG GOSU_VERSION=1.10

USER root

RUN yum -y update && yum install -y openssl libxml2 libxslt epel-release && yum clean all

RUN yum install -y python-pip

RUN pip install awscli

RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" \
 && chmod +x /usr/local/bin/gosu

RUN sed \
    -e '/^nexus-args/ s:$:,${jetty.etc}/jetty-https.xml:' \
    -e '/^application-port/a \
application-port-ssl=8443\
' \
    -i ${NEXUS_HOME}/etc/nexus-default.properties

COPY entrypoint.sh ${NEXUS_HOME}/entrypoint.sh
RUN chown nexus:nexus ${NEXUS_HOME}/entrypoint.sh && chmod a+x ${NEXUS_HOME}/entrypoint.sh

VOLUME [ "${NEXUS_SSL}" ]

EXPOSE 8443
WORKDIR ${NEXUS_HOME}

ENTRYPOINT [ "./entrypoint.sh" ]

CMD [ "bin/nexus", "run"]
