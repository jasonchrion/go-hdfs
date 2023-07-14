# Build the hdfs binary
FROM golang:1.17-alpine as builder
ENV GOPROXY "https://goproxy.cn,direct"
WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

# Copy the go source
COPY . .

# Build
RUN CGO_ENABLED=0 GOOS=linux go build -a -o hdfs ./cmd/hdfs

FROM alpine:3.17.4
ENV HADOOP_CONF_DIR=/etc/hadoop
RUN apk update && apk add -U tzdata curl krb5 && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/shanghai" > /etc/timezone && mkdir -p /etc/hadoop

WORKDIR /
COPY --from=builder /workspace/hdfs /usr/bin/

ENTRYPOINT ["hdfs"]
