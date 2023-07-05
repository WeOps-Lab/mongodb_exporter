#!/bin/bash

# 部署监控对象
object=mongodb
object_versions=("3.6.23" "4.0.27" "4.2.21" "4.4.0" "5.0" "6.0.7")
value_file="bitnami_values.yaml"
sharded_value_file="bitnami_shared_values.yaml"
# 设置起始端口号
port=27017

for version in "${object_versions[@]}"; do
    version_suffix="v$(echo "$version" | grep -Eo '[0-9]{1,2}\.[0-9]{1,2}' | tr '.' '-')"

    # 单点
    helm install $object-standalone-$version_suffix --namespace $object -f ./values/$value_file ./$object \
    --set image.tag=$version \
    --set architecture="standalone" \
    --set commonLabels.object_version=$version_suffix \
    --set service.nodePorts.mongodb=$port
     ((port++))

    # 集群
    helm install $object-rs-$version_suffix --namespace $object -f ./values/$value_file ./$object \
    --set image.tag=$version \
    --set architecture="replicaset" \
    --set commonLabels.object_version=$version_suffix

    # 分片
    helm install $object-sd-$version_suffix --namespace $object -f ./values/$sharded_value_file ./mongodb-sharded \
    --set image.tag=$version \
    --set commonLabels.object_version=$version_suffix \
    --set service.nodePorts.mongodb=$port
     ((port++))
done

