apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongodb-exporter-{{ARCHITECTURE}}-{{VERSION}}
  namespace: mongodb
spec:
  serviceName: mongodb-exporter-{{ARCHITECTURE}}-{{VERSION}}
  replicas: 1
  selector:
    matchLabels:
      app: mongodb-exporter-{{ARCHITECTURE}}-{{VERSION}}
  template:
    metadata:
      annotations:
        telegraf.influxdata.com/interval: 1s
        telegraf.influxdata.com/inputs: |+
          [[inputs.cpu]]
            percpu = false
            totalcpu = true
            collect_cpu_time = true
            report_active = true

          [[inputs.disk]]
            ignore_fs = ["tmpfs", "devtmpfs", "devfs", "iso9660", "overlay", "aufs", "squashfs"]

          [[inputs.diskio]]

          [[inputs.kernel]]

          [[inputs.mem]]

          [[inputs.processes]]

          [[inputs.system]]
            fielddrop = ["uptime_format"]

          [[inputs.net]]
            ignore_protocol_stats = true

          [[inputs.procstat]]
          ## pattern as argument for mongodbrep (ie, mongodbrep -f <pattern>)
            pattern = "exporter"
        telegraf.influxdata.com/class: opentsdb
        telegraf.influxdata.com/env-fieldref-NAMESPACE: metadata.namespace
        telegraf.influxdata.com/limits-cpu: '300m'
        telegraf.influxdata.com/limits-memory: '300Mi'
      labels:
        app: mongodb-exporter-{{ARCHITECTURE}}-{{VERSION}}
        exporter_object: mongodb
        object_mode: {{ARCHITECTURE}}
        object_version: {{VERSION}}
        pod_type: exporter
    spec:
      nodeSelector:
        node-role: worker
      shareProcessNamespace: true
      containers:
      - name: mongodb-exporter-{{ARCHITECTURE}}-{{VERSION}}
        image: registry-svc:25000/library/mongodb-exporter:latest
        imagePullPolicy: Always
        securityContext:
          allowPrivilegeEscalation: false
          runAsUser: 0
        args:
          - --collect-all
          - --mongodb.global-conn-pool
          - --compatible-mode
        env:
        - name: MONGODB_URI
          value: "mongodb://root:123456@mongodb-rs-{{VERSION}}-headless.mongodb:27017/admin"
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
          limits:
            cpu: 300m
            memory: 300Mi
        ports:
        - containerPort: 9216

---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: mongodb-exporter-{{ARCHITECTURE}}-{{VERSION}}
  name: mongodb-exporter-{{ARCHITECTURE}}-{{VERSION}}
  namespace: mongodb
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "9216"
    prometheus.io/path: '/metrics'
spec:
  ports:
  - port: 9216
    protocol: TCP
    targetPort: 9216
  selector:
    app: mongodb-exporter-{{ARCHITECTURE}}-{{VERSION}}