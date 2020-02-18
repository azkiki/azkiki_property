#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

installBase(){
    yum -y install openssh-server  
    yum -y provides semanage
    yum -y install policycoreutils-python.x86_64
    yum -y install semanage
    yum -y install wget
}

change_port(){
    wget -O /etc/ssh/sshd_config https://raw.githubusercontent.com/azkiki/azkiki_property/master/sshd_config
    semanage port -a -t ssh_port_t -p tcp 12300
    firewall-cmd --zone=public --add-port=12300/tcp --permanent
    firewall-cmd --reload
}

edit_sshdconfig(){
    chmod 600 /root/.ssh/authorized_keys
    chmod 700 /root/.ssh/
    restorecon -R -v /home
    systemctl restart sshd.service
}

new_rsa(){
    if [ ! -d "/root/.ssh" ]; then
        mkdir /root/.ssh
    fi
    if [ ! -d "/root/ssh_rsa" ]; then
        mkdir /root/ssh_rsa
    fi
    ssh-keygen -t rsa -f /root/cert_temp
    cat  /root/cert_temp.pub >> /root/.ssh/authorized_keys
    cat  /root/cert_temp >> /root/ssh_rsa/privatekey
    edit_sshdconfig
    change_port
    echo "执行成功，私钥文件已保存到 /root/ssh_rsa/privatekey ，请将其保存到本地用于后续登录操作。"
    rm -f /root/cert_temp
    rm -f /root/cert_temp.pub
}

exist_rsa(){
    if [ ! -d "/root/.ssh" ]; then
        mkdir /root/.ssh
    fi
    read -p " 请指定公钥文件(绝对路径): " pubfile
    cat "$pubfile" >> /root/.ssh/authorized_keys
    edit_sshdconfig
    change_port
    echo "执行成功"
}

default_rsa(){
    if [ ! -d "/root/.ssh" ]; then
        mkdir /root/.ssh
    fi
    if [ ! -d "/root/ssh_rsa" ]; then
        mkdir /root/ssh_rsa
    fi
    wget -O /root/.ssh/authorized_keys https://raw.githubusercontent.com/azkiki/azkiki_property/master/cert.pub
    edit_sshdconfig
    change_port
    echo "执行成功。"
}

start(){
    echo -e "【本程序将修改SSH端口为12300，并改为用RSA密钥登录】\n"
    echo -e "1:新建密钥\n"
    echo -e "2:使用已有公钥\n"
    echo -e "3:使用默认密钥\n"
    echo -e "4:退出\n"
    read -p "请选择(默认3): " num
    case "$num" in
        1)
        installBase
        new_rsa
        ;;
        2)
        installBase
        exist_rsa
        ;;
        3)
        installBase
        default_rsa
        ;;
        4)
        exit 1
        ;;
        *)
        installBase
        default_rsa
        ;;
    esac
}

start



