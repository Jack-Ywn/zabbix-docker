#!/bin/bash

#交互式内容1
echo "请选择容器底层系统："
echo "1. Alpine"
echo "2. CentOS"
read -p "输入选项（1或2）: " os_choice

#根据用户的选择设置yaml文件的名称
if [ "$os_choice" == "1" ]; then
    compose_file="docker-compose_v3_alpine.yaml"
elif [ "$os_choice" == "2" ]; then
    compose_file="docker-compose_v3_centos.yaml"
else
    echo "无效的选项，请输入 1 或 2。"
    exit 1
fi

#交互式内容2
read -p "是否安装全功能版本？（y/n）: " install_all

#根据用户的选择执行不同的命令
if [ "$install_all" == "y" ]; then
    docker-compose -f "$compose_file" --profile=all up -d
else
    docker-compose -f "$compose_file" up -d
fi

echo "耐心等待初始化此期间web页面会报错数据库连接错误"
echo "访问地址：https://localhost"
echo "用户密码：Admin zabbix"

