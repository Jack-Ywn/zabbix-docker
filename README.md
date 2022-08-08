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



## `docker-compose`部署Zabbix

- [官方启动yaml文件（参考）](https://github.com/zabbix/zabbix-docker)
- [本人启动yaml文件（推荐）](https://github.com/Jack-Ywn/zabbix-docker)        

- [下载并且导入容器镜像](https://drive.yangwn.top/AliDrive/Linux/Docker/Zabbix/images)

```shell
#网络状况比较好的情况可以不用导入

#导入alpine系统的容器镜像（默认的）
wget --no-check-certificate https://drive.yangwn.top/d/AliDrive/Linux/Docker/Zabbix/images/zabbix-image-6.0.tar.gz
tar xf zabbix-image-6.0.tar.gz
cd zabbix-image-6.0
./docker_load.sh
docker image ls -a

#导入centos系统的容器镜像（需要修改docker-compose.yaml的启动镜像）
wget --no-check-certificate https://drive.yangwn.top/d/AliDrive/Linux/Docker/Zabbix/images/zabbix-image-6.0-centos.tar.gz
tar xf zabbix-image-6.0-centos.tar.gz
cd zabbix-image-6.0-centos
./docker_load.sh
docker image ls -a
```

- 下载并且解压部署文件

```shell
wget --no-check-certificate https://drive.yangwn.top/d/AliDrive/Linux/Docker/Zabbix/zabbix-docker.tar.gz
tar xf zabbix-docker.tar.gz
cd zabbix-docker
```

- 部署基础功能版本

```shell
#切换部署版本
git checkout 6.0 

#运行Zabbix容器（必须要和启动yaml文件在同级目录）
docker-compose up -d

#关闭Zabbix容器（必须要和启动yaml文件在同级目录）
docker-compose down

#修改使用centos系统的容器镜像（默认使用alpine系统的容器镜像）
sed -i 's#alpine-6.0#centos-6.0#g' docker-compose.yaml
```

- 部署完整功能版本

```shell
#切换部署版本
git checkout 6.0 

#运行Zabbix容器（必须要和启动yaml文件在同级目录）
docker-compose --profile=all up -d

#关闭Zabbix容器（必须要和启动yaml文件在同级目录）
docker-compose --profile=all down

#修改使用centos系统的容器镜像（默认使用alpine系统的容器镜像）
sed -i 's#alpine-6.0#centos-6.0#g' docker-compose.yaml
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
#通过脚本安装Agent2（支持CentOS7、Centos8）
wget --no-check-certificate https://drive.yangwn.top/d/AliDrive/Shell/install-agent2.sh

sh install-agent2.sh
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



## 解决`Docker Compose`部署时候`Zabbix Server`无法启动（已经优化）

```shell
#打开zabbix后看见下方提示
#zabbix server is not running: the information displayed may not be current
docker logs -f zabbix-server

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

#将字体目录映射到宿主机
vim docker-compose.yaml
 zabbix-web-nginx-mysql:
  image: zabbix/zabbix-web-nginx-mysql:centos-6.0-latest
  container_name: zabbix-web-nginx
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

#关闭Zabbix容器
docker-compose --profile=all down

#运行Zabbix容器
docker-compose --profile=all up -d

#将字体拷贝到容器内部
wget --no-check-certificate https://drive.yangwn.top/d/AliDrive/Linux/Docker/Zabbix/msyh.ttc
mv msyh.ttc ./zbx_env/usr/share/zabbix/assets/fonts/DejaVuSans.ttf
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
