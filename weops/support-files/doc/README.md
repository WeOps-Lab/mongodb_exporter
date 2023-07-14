## 嘉为蓝鲸mongoDB插件使用说明

## 使用说明

### 插件功能  
MongoDB Exporter是一个用于监控MongoDB数据库的工具，它通过解析MongoDB监控命令并循环遍历诊断命令中的字段来提取监控数据。  
这个工具可以将获取到的数据转换为易于理解和分析的监控指标，从而方便用户监视和评估MongoDB实例的性能。  
通过使用MongoDB Exporter，你可以轻松地收集各种有关数据库的关键指标，并根据这些指标进行性能优化和故障排查。  

目前已实现以下指标源：

- $collStats  
- $indexStats  
- getDiagnosticData  
- replSetGetStatus  
- serverStatus  

### 版本支持

操作系统支持: linux, windows

是否支持arm: 支持

**组件支持版本：**

mongoDB版本: >= 3.6  

**注意** 
mongodb低于3.6版本(例如3.4)可能会缺少部分监控指标，还可能出现连接不兼容等问题。  

部署模式支持: 单机(Standalone), 集群(Replicaset), 分片(Sharded)  

**是否支持远程采集:**

是

### 参数说明

| **参数名**              | **含义**                                                                                                        | **是否必填** | **使用举例**                                       |
|----------------------|---------------------------------------------------------------------------------------------------------------|----------|------------------------------------------------|
| MONGODB_URI          | mongodb URI参数，在连接mongodb时，需要提供一个连接字符串，例如： mongodb://username:password@host:port/database_name **注意！该参数为环境变量** | 是        | mongodb://weops:Weops123@127.0.0.1:27017/weops |
| --collect-all        | 是否采集所有collectors的指标，默认采集所有                                                                                    | 是        | true                                           |  |
| --timeout            | 连接mongodb超时时间(seconds), 默认为10s                                                                                | 否        | 5                                              |
| --log.level          | 日志级别                                                                                                          | 否        | info                                           |
| --web.listen-address | exporter监听id及端口地址                                                                                             | 否        | 127.0.0.1:9601                                 |

#### 额外参数说明
，mongoDB插件支持的额外参数如下:
- collect-all默认使用采集以下所有collector指标，如果不需要采集所有，可选择赋值--collect-all=false并单独启用以下的collector, 若启用则赋值true  
   --collector.diagnosticdata: getDiagnosticData类指标  
   --collector.replicasetstatus: replSetGetStatus类指标  
   --collector.dbstats: dbStats类指标  
   --collector.topmetrics: top admin command类指标  
   --collector.indexstats: $indexStats类指标  
   --collector.collstats: $collStats类指标  


### 使用指引

1. 连接mongoDB
   - 输入连接指令后输入对应的账户配置即可进入。有多种方式进入MongoDB，下面列出常用的使用方式
      ```shell
      # 常用
      mongo -u [username] -p [password] --host [host] --port [port]
    
     # 连接MongoDB并指定端口
      mongo 127.0.0.1:27017
      
      # 使用用户名和密码连接到指定的MongoDB数据库
      mongo 127.0.0.1:27017/test -u [username] -p [password]
      ```
   
   - 如果没有mongo命令，可尝试使用mongosh命令，具体使用方式与上面mongo连接命令方式一致，MongoDB Shell下载地址:  https://www.mongodb.com/try/download/shell  

2. 创建账户及授权    
   - 需要注意auth授权的账户密码是管理员, 创建的用户是新的账户密码 
   - 管理员授权命令若失败，可尝试直接创建账户，一般管理员为admin  
   - 创建账户  
     创建在admin下的账户  
     ```
     use admin;
     db.auth('admin', '管理员密码');
     db.createUser({
       user: 'weops',
       pwd: 'Weops123',
       roles: [{ role: 'read', db: 'admin' }, 'clusterMonitor'],
       mechanisms: ['SCRAM-SHA-256']
     });
     ```  
     
     创建在其他数据库下的账号  
     ```
     use admin;
     db.auth('admin', '管理员密码');
     use weops;
     db.createUser({
       user: 'weops',
       pwd: 'Weops123',
       roles: [{ role: 'read', db: 'weops' }],
       mechanisms: ['SCRAM-SHA-256']
     });
     db.grantRolesToUser('weops', [{ role: 'clusterMonitor', db: 'admin' }]);
     ```

     需要注意mongodb的版本，`mechanisms: ['SCRAM-SHA-256']` 身份认证一般用于 >= 4.0，
     若mongodb < 4.0 (比如3.6), 那么可以去掉 `mechanisms: ['SCRAM-SHA-256']` , 或者使用 `mechanisms: ['SCRAM-SHA-1']`  

3. mongo相关命令指引 
   - 查询特定数据库下的用户属性  
     ```
     use weops;
     db.getUser('weops');
  
     # 执行命令返回的用户信息
     {
       "_id" : "weops.weops",
       "userId" : UUID("2a14dcf6-fd72-4247-9a45-092ea128c775"),
       "user" : "weops",
       "db" : "weops",
       "roles" : [
           {
           "role" : "read",
           "db" : "weops"
           },
           {
           "role" : "clusterMonitor",
           "db" : "admin"
           }
       ],
       "mechanisms" : [
           "SCRAM-SHA-256"
       ]
     }
   ```

- 查看全局所有用户 `db.system.users.find().pretty();`  

- 查看所有数据库 `show dbs;`  

### 指标简介
| **指标ID**                                            | **指标中文名**               | **维度ID**                                  | **维度含义**                 | **单位**                 |
|-----------------------------------------------------|-------------------------|-------------------------------------------|--------------------------|------------------------|
| mongodb_up                                          | MongoDB运行状态             | -                                         | -                        | -                      |
| mongodb_version_info                                | MongoDB版本信息             | mongodb                                   | 版本                       | -                      |
| mongodb_ss_uptime                                   | MongoDB已运行时间            | -                                         | -                        | s                      |
| mongodb_ss_mem_virtual                              | MongoDB虚拟内存使用大小         | -                                         | -                        | mebibytes              |
| mongodb_ss_mem_resident                             | MongoDB常驻内存使用大小         | -                                         | -                        | mebibytes              |
| mongodb_ss_opcounters                               | MongoDB操作计数器总数          | legacy_op_type                            | 操作类型                     | -                      |
| mongodb_ss_metrics_document                         | MongoDB文档数              | doc_op_type                               | 文档操作类型                   | -                      |
| mongodb_ss_asserts                                  | MongoDB断言数              | assert_type                               | 断言类型                     | -                      |
| mongodb_ss_connections                              | MongoDB连接数信息            | conn_type                                 | 连接类型                     | -                      |
| mongodb_ss_metrics_getLastError_wtime_totalMillis   | MongoDB写操作等待超时时间        | -                                         | -                        | ms                     |
| mongodb_ss_extra_info_page_faults                   | MongoDB实例中的页面错误总数       | -                                         | -                        | -                      |
| mongodb_ss_metrics_getLastError_wtime_num           | MongoDB写操作等待超时次数        | -                                         | -                        | -                      |
| mongodb_ss_metrics_cursor_open                      | MongoDB打开的游标数           | csr_type                                  | 游标类型                     | -                      |
| mongodb_ss_metrics_cursor_timedOut                  | MongoDB游标超时次数           | -                                         | -                        | -                      |
| mongodb_top_writeLock_count                         | MongoDB top 写入锁数量       | collection, datname                       | 集合名称, 数据库名称              | -                      |
| mongodb_ss_globalLock_activeClients_total           | MongoDB全局锁活跃中的总客户端数     | -                                         | -                        | -                      |
| mongodb_ss_globalLock_activeClients_readers         | MongoDB全局锁活跃中的读取客户端数    | -                                         | -                        | -                      |
| mongodb_ss_globalLock_activeClients_writers         | MongoDB全局锁活跃中的写入客户端数    | -                                         | -                        | -                      |
| mongodb_ss_globalLock_currentQueue                  | MongoDB全局锁当前队列长度        | count_type                                | 计数类型                     | -                      |
| mongodb_ss_network_numRequests                      | MongoDB网络请求数            | -                                         | -                        | -                      |
| mongodb_ss_network_bytesOut                         | MongoDB发送的网络流量          | -                                         | -                        | bytes                  |
| mongodb_ss_network_bytesIn                          | MongoDB接收的网络流量          | -                                         | -                        | bytes                  |
| mongodb_dbstats_dataSize                            | MongoDB数据大小             | datname                                   | 数据库名称                    | bytes                  |
| mongodb_dbstats_collections                         | MongoDB集合数量             | datname                                   | 数据库名称                    | -                      |
| mongodb_dbstats_indexes                             | MongoDB索引数量             | datname                                   | 数据库名称                    | -                      |
| mongodb_dbstats_indexSize                           | MongoDB索引大小             | datname                                   | 数据库名称                    | bytes                  |
| mongodb_dbstats_fsUsedSize                          | MongoDB文件系统使用大小         | datname                                   | 数据库名称                    | bytes                  |
| mongodb_dbstats_totalSize                           | MongoDB数据总大小            | datname                                   | 数据库名称                    | bytes                  |
| mongodb_dbstats_objects                             | MongoDB对象数量             | datname                                   | 数据库名称                    | -                      |
| mongodb_dbstats_views                               | MongoDB视图数量             | datname                                   | 数据库名称                    | -                      |
| mongodb_rs_members_optimeDate                       | MongoDB Oplog时间戳        | member_state                              | 成员角色                     | datetime(milliseconds) |
| mongodb_mongod_replset_oplog_head_timestamp         | MongoDB副本集操作日志头部的时间戳    | -                                         | -                        | datetime(seconds)      |
| mongodb_mongod_replset_oplog_tail_timestamp         | MongoDB副本集操作日志尾部的时间戳    | -                                         | -                        | datetime(seconds)      |
| mongodb_oplog_stats_size                            | MongoDB Oplog大小         | -                                         | -                        | bytes                  |
| mongodb_rs_votingMembersCount                       | MongoDB副本集可投票成员数量       | -                                         | -                        | -                      |
| mongodb_ss_metrics_commands_replSetHeartbeat_failed | MongoDB副本集心跳操作失败的次数     | -                                         | -                        | -                      |
| mongodb_rs_myState                                  | MongoDB副本集当前成员状态        | -                                         | -                        | -                      |
| mongodb_rs_members_state                            | MongoDB副本集成员状态          | member_idx, member_state, rs_nm, rs_state | 成员ID, 成员角色, 副本集名称, 副本集状态 | -                      |
| mongodb_rs_members_health                           | MongoDB副本集成员健康状态        | member_idx, member_state, rs_nm, rs_state | 成员ID, 成员角色, 副本集名称, 副本集状态 | -                      |
| mongodb_members_pingMs                              | MongoDB副本集中成员之间的心跳延迟平均值 | member_state                              | 成员角色                     | ms                     |
| process_cpu_seconds_total                           | MongoDB探针进程CPU秒数总计      | -                                         | -                        | s                      |
| process_max_fds                                     | MongoDB探针进程最大文件描述符数     | -                                         | -                        | -                      |
| process_open_fds                                    | MongoDB探针进程打开文件描述符数     | -                                         | -                        | -                      |
| process_resident_memory_bytes                       | MongoDB探针进程常驻内存大小       | -                                         | -                        | bytes                  |
| process_virtual_memory_bytes                        | MongoDB探针进程虚拟内存大小       | -                                         | -                        | bytes                  |
| collector_scrape_time_ms                            | MongoDB监控探针最近一次抓取时长     | collector, exporter                       | 采集器, 探针类型                | ms                     |

### 版本日志

#### weops_mongodb_exporter 3.3.2

- weops调整

添加“小嘉”微信即可获取mongoDB监控指标最佳实践礼包，其他更多问题欢迎咨询

<img src="https://wedoc.canway.net/imgs/img/小嘉.jpg" width="50%" height="50%">
