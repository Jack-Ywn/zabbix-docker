## 基于Zabbix官方进行的优化

- 传参文件优化记录

```shell
#传参文件夹下面的文件为隐藏文件每个服务的配置选项和参数

#env_vars/.env_agent
ZBX_HOSTNAME=zabbix-server
ZBX_SERVER_HOST=0.0.0.0/0
ZBX_SERVER_HOST=172.16.239.0/24 #仅允许zbx_net_backend的网络段进行通信（更加安全）

#env_vars/.env_web
PHP_TZ=Asia/Shanghai

#env_vars/.env_srv
ZBX_CACHESIZE=1024M
```

- docker-compose启动文件优化记录

```shell
#Agent调整为HOST网络模式（容器运行的方式不方便固定Agent的具体IP地址）
 zabbix-agent:
  privileged: true
  pid: "host"
  network_mode: "host"
  stop_grace_period: 5s

#MySQL调整连接数量
 mysql-server:
  image: mysql:8.0
  command:
   - mysqld
   - --port=3306
   - --character-set-server=utf8
   - --collation-server=utf8_bin
   - --default-authentication-plugin=mysql_native_password
   - --max_connections=1000
   - --mysqlx_max_connections=1000 

#删除db_data_mysql

#仅保留zabbix-web-nginx-mysql删除zabbix-web-apache-mysql

#提供2种容器底层系统镜像的部署
alpine占用空间小
centos占用空间大
```



## 如何启动项目

- [官方启动yaml文件](https://github.com/zabbix/zabbix-docker)
- [国内离线容器镜像](https://drive.swireb.cn/Linux/Docker/Zabbix/images)
- 系统要安装docker和docker-compose

```shell
#rhel7-9的系统可以使用下面的脚本对系统进行初始化安装（前提是全新的系统并且是最小化安装）
bash <(curl -sSL https://drive.swireb.cn/d/Shell/system.sh)

#会优化系统YUM源、优化系统文件句柄、时区、开启时间同步
#安装常用软件
#安装docker和docker-compose
#支持CentOS7.9、CentOS stream 8、CentOS stream 9、Rocky Linux 8、Rocky Linux 9
```

- 运行Zabbix容器

```shell
#下载启动yaml文件
git clone https://github.com/Jack-Ywn/zabbix-docker.git

#进入到项目目录
cd zabbix-docker

#切换部署版本（通过切换分支实现部署不同的版本）
git checkout 6.0 

#启动容器
sh start.sh 
请选择容器底层系统：
1. Alpine
2. CentOS
输入选项（1或2）: 1
是否安装全功能版本？（y/n）: n

#关闭容器
sh stop.sh 
请选择需要停止的容器底层系统：
1. Alpine
2. CentOS
输入选项（1或2）: 1
是否为全功能版本？（y/n）: n
```

- 无特殊要求无需选择全功能版本

```shell
#选择全功能版本需要拉取的镜像偏多

#需要代理相关的功能组件则选择全功能版本
```



## 解决报错`Zabbix agent is not available (for 3m)`

- Web界面修改zabbix-server主机的IP地址

```shell
#由于Agent已经调整为HOST模式
将127.0.0.1修改为宿主机的实际IP地址即可
```

- 其他主机运行Agent容器

```shell
#根据实际情况指定具体版本  
docker run --name zabbix-agent \
      -p 10050:10050 \
      -e ZBX_HOSTNAME="被监控主机的名称" \
      -e ZBX_SERVER_HOST="IP地址" \
      -e ZBX_SERVER_PORT=10051 \
      -d zabbix/zabbix-agent:alpine-6.0-latest  
```



## 解决中文乱码

```shell
#拷贝Windows字体（微软雅黑、仿宋常规字体均可以解决）
C:\Windows\Fonts

#将字体目录映射到宿主机
vim docker-compose.yaml
 zabbix-web-nginx-mysql:
  image: zabbix/zabbix-web-nginx-mysql:centos-6.0-latest
  restart: always
  ports:
   - "80:8080"
#   - "443:8443"
  volumes:
   - /etc/localtime:/etc/localtime:ro
   - /etc/timezone:/etc/timezone:ro
   - ./zbx_env/etc/ssl/nginx:/etc/ssl/nginx:ro
   - ./zbx_env/usr/share/zabbix/modules/:/usr/share/zabbix/modules/:ro
   - ./zbx_env/usr/share/zabbix/assets/fonts/:/usr/share/zabbix/assets/fonts/:ro #字体目录

#将字体拷贝到容器内部
wget --no-check-certificate https://drive.swireb.cn/d/Linux/Docker/Zabbix/msyh.ttc
mv msyh.ttc ./zbx_env/usr/share/zabbix/assets/fonts/DejaVuSans.ttf

#重新启动服务
docker-compose --profile=all down
docker-compose --profile=all up -d
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
docker exec -it  zabbix-docker-mysql-server-1 bash

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
