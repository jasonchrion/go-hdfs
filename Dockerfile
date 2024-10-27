FROM golang:1.17.13-alpine3.16 AS hdfs

WORKDIR /

RUN apk update && \
    apk add --no-cache -U curl git

RUN git clone https://github.com/jasonchrion/go-hdfs.git

WORKDIR go-hdfs

RUN go mod download

RUN CGO_ENABLED=0 GOOS=linux go build -a -o /hdfs ./cmd/hdfs

FROM alpine:3.18.9

ENV HADOOP_CONF_DIR=/etc/hadoop \
    TZ=Asia/Shanghai

RUN set -ex && \
    apk update && apk add --no-cache -U bash tzdata curl bind-tools iperf3 mysql-client postgresql-client apache2-utils krb5 && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/shanghai" > /etc/timezone && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /etc/hadoop && \
    curl -Lo /usr/bin/wait-for-it.sh https://github.com/vishnubob/wait-for-it/raw/master/wait-for-it.sh && chmod +x /usr/bin/wait-for-it.sh

WORKDIR /

COPY --chmod=755 --from=hdfs /hdfs /usr/bin/hdfs

ENTRYPOINT ["hdfs"]
