#!/bin/bash

for version in v3-6 v4-0 v4-2 v4-4 v5-0 v6-0; do
  # 单点
  standalone_output_file="standalone_${version}.yaml"
  sed "s/{{VERSION}}/${version}/g;" standalone.tpl > ../standalone/${standalone_output_file}

  # 集群
  cluster_output_file="cluster_${version}.yaml"
  sed "s/{{VERSION}}/${version}/g;" cluster.tpl >> ../cluster/${cluster_output_file}
done
