FROM golang:1.15.2-alpine3.12 as builder

ENV PILOT_DIR /go/src/github.com/wangr927/log-pilot
ARG GOOS=linux
ARG GOARCH=amd64
RUN set -ex && apk add --no-cache make git
WORKDIR $PILOT_DIR
COPY . $PILOT_DIR
RUN go install 
# 注意这里需要使用alpine 3.6，过高版本的镜像中python有不兼容的情况
FROM alpine:3.6

ENV FILEBEAT_VERSION=6.1.1-3
COPY assets/glibc/glibc-2.26-r0.apk /tmp/
COPY assets/filebeat-6.8.2.tar.gz /tmp/
RUN apk update && \ 
    apk add python && \
    apk add ca-certificates && \
    apk add wget && \
    update-ca-certificates && \
    mkdir -p /etc/filebeat /var/lib/filebeat /var/log/filebeat && \
    tar zxf /tmp/filebeat-6.8.2.tar.gz -C /tmp/ && \
    cp -rf /tmp/filebeat-6.8.2-linux-x86_64/filebeat /usr/bin/ && \
    cp -rf /tmp/filebeat-6.8.2-linux-x86_64/fields.yml /etc/filebeat/ && \
    cp -rf /tmp/filebeat-6.8.2-linux-x86_64/kibana /etc/filebeat/ && \
    cp -rf /tmp/filebeat-6.8.2-linux-x86_64/module /etc/filebeat/ && \
    cp -rf /tmp/filebeat-6.8.2-linux-x86_64/modules.d /etc/filebeat/ && \
    apk add --allow-untrusted /tmp/glibc-2.26-r0.apk && \
    rm -rf /var/cache/apk/* /tmp/filebeat-6.8.2-linux-x86_64.tar.gz /tmp/filebeat-6.8.2-linux-x86_64 /tmp/glibc-2.26-r0.apk

COPY --from=builder /go/bin/log-pilot /pilot/pilot
COPY assets/entrypoint assets/config.filebeat assets/filebeat.tpl assets/healthz /pilot/

RUN chmod +x /pilot/pilot /pilot/entrypoint /pilot/healthz /pilot/config.filebeat

HEALTHCHECK CMD /pilot/healthz

VOLUME /var/log/filebeat
VOLUME /var/lib/filebeat

WORKDIR /pilot/
ENV PILOT_TYPE=filebeat
ENTRYPOINT ["/pilot/entrypoint"]
