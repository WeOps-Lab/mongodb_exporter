#
# build container
#
FROM --platform=linux/amd64 golang:1.19-alpine as builder
WORKDIR /

COPY mongodb_exporter /mongodb_exporter

EXPOSE     9216
ENTRYPOINT [ "/mongodb_exporter" ]
