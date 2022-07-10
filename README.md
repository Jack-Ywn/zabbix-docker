## 先决条件

- 基础`YUM`源和优化系统

```shell
#此脚本能优化CentOS6、7、8的系统
curl -L https://drive.yangwn.top/d/AliDrive/Shell/system.sh | sh

#docker软件源
wget -O /etc/yum.repos.d/docker-ce.repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```

- 安装`docker`并运行

```shell
#安装docker
yum clean all && yum makecache
yum -y install docker-ce

#修改docker配置文件（可选优化操作）
mkdir /etc/docker

cat << EOF | tee /etc/docker/daemon.json
{
  "graph": "/data/docker",
  "registry-mirrors": ["http://hub-mirror.c.163.com", "https://docker.mirrors.ustc.edu.cn"],
  "live-restore": true
}
EOF

#启动docker服务
systemctl daemon-reload && systemctl enable --now docker
```

- 安装`docker-compose`命令

```shell
#下载二进制文件
curl -L https://get.daocloud.io/docker/compose/releases/download/v2.6.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose

#赋予执行权限
chmod +x /usr/local/bin/docker-compose

#确认版本
docker-compose -v
```



## `docker-compose`启动`yaml`文件

- [官方启动yaml文件](https://github.com/zabbix/zabbix-docker)
- [本人启动yaml文件](https://github.com/Jack-Ywn/zabbix-docker)

```shell
docker-compose_v3_alpine_mysql_latest.yaml	#运行基于Alpine Linux的Zabbix最新版本的组件
docker-compose_v3_alpine_mysql_local.yaml	#本地构建和运行基于Alpine Linux的Zabbix最新版本的组件
docker-compose_v3_alpine_pgsql_latest.yaml	#运行基于Alpine Linux的Zabbix最新版本的组件
docker-compose_v3_alpine_pgsql_local.yaml	#本地构建和运行基于Apline Linux的Zabbix最新版本的组件
docker-compose_v3_centos_mysql_latest.yaml	#运行基于CentOS的Zabbix最新版本的组件
docker-compose_v3_centos_mysql_local.yaml	#本地构建和运行基于CentOS的Zabbix最新版本的组件
docker-compose_v3_centos_pgsql_latest.yaml	#运行基于 CentOS的Zabbix最新版本的组件
docker-compose_v3_centos_pgsql_local.yaml	#本地构建和运行基于CentOS的Zabbix最新版本的组件
docker-compose_v3_ubuntu_mysql_latest.yaml	#运行基于Ubuntu的Zabbix最新版本的组件
docker-compose_v3_ubuntu_mysq l_local.yaml	#本地构建和运行基于Ubuntu的Zabbix最新版本的组件
docker-compose_v3_ubuntu_pgsql_latest.yaml	#运行基于Ubuntu的Zabbix最新版本的组件
docker-compose_v3_ubuntu_pgsql_local.yaml	#本地构建和运行基于Ubuntu的Zabbix最新版本的组件          
```



## [使用国内下载站点部署](https://drive.yangwn.top/AliDrive/Linux/Docker/Zabbix)

- 下载并且导入镜像

```shell
wget https://drive.yangwn.top/d/AliDrive/Linux/Docker/Zabbix/zabbix-image-6.0.tar.gz
tar xf zabbix-image-6.0.tar.gz
cd zabbix-image-6.0
./docker_load.sh
docker image ls -a
```

- 下载并且解压部署文件

```shell
wget https://drive.yangwn.top/d/AliDrive/Linux/Docker/Zabbix/zabbix-docker.tar.gz
tar xf zabbix-docker.tar.gz
cd zabbix-docker
```

- 部署基础功能版本

```shell
#切换部署版本
git checkout 6.0 

#运行Zabbix容器
docker-compose up -d

#关闭Zabbix容器
docker-compose down
```

- 部署完整功能版本

```shell
#切换部署版本
git checkout 6.0 

#运行Zabbix容器
docker-compose --profile=all up -d

#关闭Zabbix容器
docker-compose --profile=all down
```



## 解决报错`Zabbix agent is not available (for 3m)`

- 容器部署Agent

```shell
#查看Agent的IP地址
docker inspect zabbix-agent | grep IPAddress 

#Web控制修改Zabbix server主机IP地址
修改为zabbix-agent容器的IP地址
```

- [二进制部署Agent](https://www.zabbix.com/documentation/current/zh/manual/appendix/config/zabbix_agentd)

```shell
#使用官方YUM仓库在宿主机安装Zabbix agent
rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
yum clean all

#仅安装Zabbix agent
yum install zabbix-agent

#修改Zabbix agent配置文件（允许和容器zabbix-server的网段通信）
vim /etc/zabbix/zabbix_agentd.conf
Server=127.0.0.1,172.16.238.0/24

#运行Zabbix agent服务并设置开机自启
systemctl enable --now zabbix-agent.service

#Web控制修改Zabbix server主机IP地址
修改为服务器实际IP地址（宿主机IP地址）
```

- 其他主机运行Agent容器

```shell
#ZBX_SERVER_HOST指定Zabbix server宿主机IP地址   
docker run --name zabbix-agent -it \
      -p 10050:10050 \
      -e ZBX_HOSTNAME="zabbix-server" \
      -e ZBX_SERVER_HOST="宿主机IP地址" \
      -e ZBX_SERVER_PORT=10051 \
      -d zabbix/zabbix-agent:alpine-6.0-latest  
```



## 解决`Docker Compose`部署时候`Zabbix Server`无法启动

```shell
#打开zabbix后看见下方提示zabbix server is not running: the information displayed may not be current
docker logs -f zabbix-server
Starting Zabbix Server. Zabbix 6.0.1 (revision a80cb13).
Press Ctrl+C to exit.
     8:20220313:155643.869 Starting Zabbix Server. Zabbix 6.0.1 (revision a80cb13).
     8:20220313:155643.869 ****** Enabled features ******
     8:20220313:155643.869 SNMP monitoring:           YES
     8:20220313:155643.869 IPMI monitoring:           YES
     8:20220313:155643.869 Web monitoring:            YES
     8:20220313:155643.869 VMware monitoring:         YES
     8:20220313:155643.869 SMTP authentication:       YES
     8:20220313:155643.869 ODBC:                      YES
     8:20220313:155643.869 SSH support:               YES
     8:20220313:155643.869 IPv6 support:              YES
     8:20220313:155643.869 TLS support:               YES
     8:20220313:155643.869 ******************************
     8:20220313:155643.869 using configuration file: /etc/zabbix/zabbix_server.conf
     8:20220313:155643.884 current database version (mandatory/optional): 06000000/06000000
     8:20220313:155643.884 required mandatory version: 06000000
   208:20220313:155643.896 starting HA manager
   208:20220313:155643.912 HA manager started in active mode
     8:20220313:155643.913 server #0 started [main process]
   209:20220313:155643.913 server #1 started [service manager #1]
   210:20220313:155643.913 server #2 started [configuration syncer #1]
   210:20220313:155644.911 __mem_malloc: skipped 0 asked 48 skip_min 18446744073709551615 skip_max 0
   210:20220313:155644.911 [file:dbconfig.c,line:89] __zbx_mem_malloc(): out of memory (requested 48 bytes)   #报错内存不足
   210:20220313:155644.911 [file:dbconfig.c,line:89] __zbx_mem_malloc(): please increase CacheSize configuration parameter
   210:20220313:155644.911 === memory statistics for configuration cache ===
   210:20220313:155644.912 free chunks of size     24 bytes:      121
   210:20220313:155644.912 free chunks of size     32 bytes:        6
   210:20220313:155644.912 min chunk size:         24 bytes
   210:20220313:155644.912 max chunk size:         32 bytes
   210:20220313:155644.912 memory of total size 29247184 bytes fragmented into 269180 chunks
   210:20220313:155644.912 of those,       3096 bytes are in      127 free chunks
   210:20220313:155644.912 of those,   29244088 bytes are in   269053 used chunks
   210:20220313:155644.912 of those,    4306864 bytes are used by allocation overhead
   210:20220313:155644.912 ================================
   210:20220313:155644.912 backtrace is not available for this platform
     8:20220313:155644.915 One child process died (PID:210,exitcode/signal:1). Exiting ...
   208:20220313:155644.915 HA manager has been paused
   208:20220313:155644.937 HA manager has been stopped
     8:20220313:155644.938 Zabbix Server stopped. Zabbix 6.0.1 (revision a80cb13).

#出现zabbix server is not running的两种原因
mysql连接数量受限制
zabbix server的缓存大小受限制

#zabbix server的缓存大小调整
ZBX_CACHESIZE=2048M

#mysql连接数量调整
max_connections=2000
mysqlx_max_connections=2000

#重新启动服务
docker-compose --profile=all restart
```



## 解决中文乱码

```shell
#拷贝Windows字体（微软雅黑、仿宋常规字体均可以解决）
C:\Windows\Fonts

#容器名称
zabbix-web-nginx

#将字体拷贝到容器内部
wget https://drive.yangwn.top/d/Onedrive/Linux/Docker/Zabbix/msyh.ttc
docker cp msyh.ttc zabbix-web-nginx:/usr/share/zabbix/assets/fonts/DejaVuSans.ttf
```



## 拓扑图链路延迟Label示例

```shell
#4.0版本
IN:{主机名称:键值.last(0)}
OUT:{主机名称:键值.last(0)}
IN:{A1 Switch:net.if.in[ifHCInOctets.369098752].last(0)}
OUT:{A1 Switch:net.if.out[ifHCOutOctets.369098752].last(0)}


#6.0版本
IN:{?last(/主机名称/键值)}
OUT:{主机名称:键值.last(0)}
IN:{?last(/A1 Switch/net.if.in[ifHCInOctets.369098752])}
OUT:{?last(/A1 Switch/net.if.out[ifHCOutOctets.369098752])}

#参考博文
https://cloud.tencent.com/developer/article/1956234
```



## 清理Zabbix数据库binlog

```shell
#进入数据库的容器
docker exec -it zabbix-db bash

#使用root用户连接数据库（默认密码root_pwd）
mysql -u root -proot_pwd
mysql> show master logs;
+---------------+------------+-----------+
| Log_name      | File_size  | Encrypted |
+---------------+------------+-----------+
| binlog.000039 |   12134083 | No        |
| binlog.000040 |     378418 | No        |
| binlog.000041 | 1073756828 | No        |
| binlog.000042 | 1073744872 | No        |
| binlog.000043 |  664549489 | No        |
+---------------+------------+-----------+
18 rows in set (0.02 sec)

#binlog过期时间（数值为0则不会自动清理）
mysql> show variables like 'expire_logs_days';
+------------------+-------+
| Variable_name    | Value |
+------------------+-------+
| expire_logs_days | 0     |
+------------------+-------+
1 row in set (0.01 sec)

#手动删除binlog.000040以前的日志文件
mysql> purge binary logs to 'binlog.000037';
Query OK, 0 rows affected (0.07 sec)
```

