#!/bin/bash

# 部署监控对象
object=mongodb
object_versions=("3.6.23" "4.0.27" "4.2.21" "4.4.0" "5.0" "6.0.7")
value_file="bitnami_values.yaml"

for version in "${object_versions[@]}"; do
    version_suffix="v$(echo "$version" | grep -Eo '[0-9]{1,2}\.[0-9]{1,2}' | tr '.' '-')"

    # 单点
    helm install $object-standalone-$version_suffix --namespace $object -f ./values/$value_file ./$object \
    --set image.tag=$version \
    --set architecture="standalone" \
    --set commonLabels.object_version=$version_suffix \
    --set service.nodePorts.mongodb=

    # 副本
    helm install $object-rs-$version_suffix --namespace $object -f ./values/$value_file ./$object \
    --set image.tag=$version \
    --set architecture="replicaset" \
    --set commonLabels.object_version=$version_suffix \

done

