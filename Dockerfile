# Based on https://github.com/RHsyseng/container-rhel-examples/blob/master/starter-rhel-atomic/Dockerfile
FROM registry.centos.org/centos/centos7-atomic:latest
MAINTAINER Pablo Iranzo <piranzo@redhat.com>

LABEL name="citellus/citellus" \
      maintainer="piranzo@redhat.com" \
      vendor="Citellus" \
      version="1.0" \
      release="1" \
      summary="System configuration validation program" \
      description="Citellus is a program that should help with system configuration validation on either live system or any sort of snapshot of the filesystem."

ENV USER_NAME=citellus \
    USER_UID=10001

# Required for useradd command and pip
RUN PRERREQ_PKGS="shadow-utils \
      libsemanage \
      ustr \
      audit-libs \
      libcap-ng \
      epel-release" && \
    microdnf install --nodocs ${PRERREQ_PKGS} && \
    microdnf install --nodocs python-pip && \
    useradd -l -u ${USER_UID} -r -g 0 -s /sbin/nologin \
      -c "${USER_NAME} application user" ${USER_NAME} && \
    microdnf remove ${PRERREQ_PKGS} && \
    microdnf clean all

RUN pip install citellus --no-cache-dir && \
    mkdir -p /data

USER 10001
VOLUME /data
ENTRYPOINT ["/usr/bin/citellus.py"]
CMD ["-h"]
