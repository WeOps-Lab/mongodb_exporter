#!/bin/bash

# 删除监控对象
object=mongodb

# 删除 Helm chart
echo "Uninstalling $object releases ..."
for RELEASE in $(helm list -n $object --short)
do
  helm uninstall -n $object $RELEASE
done