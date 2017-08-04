# stream oriented kurento
#
# VERSION               4.4.3

FROM ubuntu:trusty
LABEL maintainer="roma.gordeev@gmail.com"

RUN apt-get update \
  && apt-get -y dist-upgrade \
  && apt-get install -y wget

RUN echo "deb http://ubuntu.kurento.org/ trusty kms6" | tee /etc/apt/sources.list.d/kurento.list \
  && wget -O - http://ubuntu.kurento.org/kurento.gpg.key | apt-key add - \
  && apt-get update \
  && apt-get -y install kurento-media-server-6.0 \
  && apt-get -y install kms-pointerdetector-6.0 \
  && apt-get -y install gnutls-bin \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

EXPOSE 8888 0-65535/udp 8433 3478

RUN certtool --generate-privkey --outfile /etc/kurento/defaultCertificate.pem
RUN echo 'organization = your organization name' > /etc/kurento/certtool.tmpl
RUN certtool --generate-self-signed --load-privkey /etc/kurento/defaultCertificate.pem --template /etc/kurento/certtool.tmpl >> /etc/kurento/defaultCertificate.pem
RUN chown kurento /etc/kurento/defaultCertificate.pem

COPY ./kurento.conf.json /etc/kurento/kurento.conf.json
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV GST_DEBUG=Kurento*:5

ENTRYPOINT ["/entrypoint.sh"]
