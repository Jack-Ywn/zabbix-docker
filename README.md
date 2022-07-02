## [Docker Compose](https://github.com/zabbix/zabbix-docker)

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

- 下载并且导入容器

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



## 其他主机运行`Zabbix Agent`

- 容器部署Agent

```shell
#ZBX_SERVER_HOST指定Zabbix server宿主机IP地址   
docker run --name zabbix-agent -it \
      -p 10050:10050 \
      -e ZBX_HOSTNAME="zabbix-server" \
      -e ZBX_SERVER_HOST="宿主机IP地址" \
      -e ZBX_SERVER_PORT=10051 \
      -d zabbix/zabbix-agent:alpine-6.0-latest  
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





## 解决报错`Zabbix agent is not available (for 3m)`

```shell
#查看zabbix-agent容器的IP地址
docker inspect zabbix-agent | grep IPAddress 
```

