#!/bin/bash

#交互式内容1
echo "请选择需要停止的容器底层系统："
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
read -p "是否为全功能版本？（y/n）: " install_all

#根据用户的选择执行不同的命令
if [ "$install_all" == "y" ]; then
    docker-compose -f "$compose_file" --profile=all down
else
    docker-compose -f "$compose_file" down
fi

echo "服务已经停止"
echo "zbx_env和mysql目录切勿随意删除"

