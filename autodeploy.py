# -*- coding: utf-8 -*-
# Author : https://github.com/tenyue/ServerStatus
# ServerStatus 自动部署脚本
import os
import sys
import json
import datetime
import hashlib

# 全新部署服务端_客户端
def NewDeploy():
    os.system('yum -y install expect')
    os.system('apt-get -y install expect')
    os.system('clear')

    webdir = ''
    while True:
        print 'Please input the website path for CloudMonitor(Eg: /home/wwwroot/default):'
        webdir = raw_input('the website path is:')
        if os.path.exists(webdir) == True:
            break
        else:
            print 'the website path is\'t exist!'
    if webdir[-1] == '/':
        webdir = webdir[:-1]
    else:
        webdir = webdir

    server_ipstr = raw_input('the server\'s ip address:')
    count = 0
    config_list = []
    while True:
        count += 1
        print 'Deploy the %s client for CloudMonitor: ' % count
        client_ipstr = raw_input('the client\'s ip address: ')
        rootstr = raw_input('the client\'s root: ')
        passwdstr = raw_input('the client\'s password: ')

        name = raw_input('the client\'s name: ')
        type = raw_input('the client\'s type: ')
        host = raw_input('the client\'s host: ')
        location = raw_input('the client\'s location: ')

        xstr = ('CloudMonitor%s' + client_ipstr + rootstr + passwdstr+ str(datetime.datetime.now()))% count
        hash_user = 'CloudMonitor%s' % count
        hash_passwd = hashlib.md5(xstr).hexdigest()

        xjson = {
            "username": hash_user,
            "name": name,
            "type": type,
            "host": host,
            "location": location,
            "password": hash_passwd,
        }
        config_list.append(xjson)

        new_config_str = ''
        # 配置服务端
        mvcomment = 'mv web/* %s' % webdir
        os.system(mvcomment)
        # 读取客户端配置
        with open('client/client.py','r') as f:
            for line in f.readlines():
                if 'SERVER = "127.0.0.1"' in line:
                    new_config_str = new_config_str + ('SERVER = "%s"') % server_ipstr + '\n'
                elif 'USER = "USER"' in line:
                    new_config_str = new_config_str + ('USER = "%s"') % hash_user + '\n'
                elif 'PASSWORD = "PASSWORD"' in line:
                    new_config_str = new_config_str + ('PASSWORD = "%s"') % hash_passwd + '\n'
                else:
                    new_config_str = new_config_str + line
        # 写入临时客户端配置
        with open('client/client-temp.py','wt') as f:
            f.write(new_config_str)
        # 上传配置到客户机,并执行脚本
        scp_put('client/client-temp.py', '/root/', client_ipstr, rootstr, passwdstr)
        # 清理临时客户端配置
        os.remove('client/client-temp.py')
        is_add = raw_input('Whether to continue to add the client(y/n): ')
        if is_add == 'n' or is_add == 'N' or is_add == 'not' or is_add == 'NOT':
            break
    config_dict = {"servers": config_list}
    config_json = json.dumps(config_dict)
    with open('config.json','wt') as f:
        f.write(config_json)

    # 启动主服务
    os.chdir('server')
    os.system('make')
    os.chdir('..')
    if os.path.exists('server/sergate') == True:
        os.system('mv server/sergate %s' % webdir)
        os.system('mv config.json %s' % webdir)
        task_sergate = 'nohup %s/sergate --config=%s/config.json --web-dir=%s &> /dev/null &' % (webdir, webdir, webdir)
        # 立即启动服务
        os.system(task_sergate)
        print 'Successed start CloudMonitor!'
    else:
        print 'Failed start CloudMonitor!'


# 增加客户端
def AddClient():
    while True:
        print 'Please input the website path for CloudMonitor(Eg: /home/wwwroot/default):'
        webdir = raw_input('the website path is:')
        if os.path.exists(webdir) == True:
            break
        else:
            print 'the website path is\'t exist!'
    if webdir[-1] == '/':
        webdir = webdir[:-1]
    else:
        webdir = webdir

    count = 0
    with open('%s/config.json' % webdir, 'rt') as f:
        old_config = json.loads(f)
    for i in old_config["servers"]:
        tempvalue = int(i["username"].split('CloudMonitor')[1])
        if tempvalue > count:
            count = tempvalue

    server_ipstr = raw_input('the server\'s ip address:')
    while True:
        count += 1
        print 'Add the %s client for CloudMonitor: ' % count
        client_ipstr = raw_input('the client\'s ip address: ')
        rootstr = raw_input('the client\'s root: ')
        passwdstr = raw_input('the client\'s password: ')

        name = raw_input('the client\'s name: ')
        type = raw_input('the client\'s type: ')
        host = raw_input('the client\'s host: ')
        location = raw_input('the client\'s location: ')

        xstr = ('CloudMonitor%s' + client_ipstr + rootstr + passwdstr + str(datetime.datetime.now())) % count
        hash_user = 'CloudMonitor%s' % count
        hash_passwd = hashlib.md5(xstr).hexdigest()

        xjson = {
            "username": hash_user,
            "name": name,
            "type": type,
            "host": host,
            "location": location,
            "password": hash_passwd,
        }
        old_config["servers"].append(xjson)

        new_config_str = ''
        # 读取客户端配置
        with open('client/client.py', 'r') as f:
            for line in f.readlines():
                if 'SERVER = "127.0.0.1"' in line:
                    new_config_str = new_config_str + ('SERVER = "%s"') % server_ipstr + '\n'
                elif 'USER = "USER"' in line:
                    new_config_str = new_config_str + ('USER = "%s"') % hash_user + '\n'
                elif 'PASSWORD = "PASSWORD"' in line:
                    new_config_str = new_config_str + ('PASSWORD = "%s"') % hash_passwd + '\n'
                else:
                    new_config_str = new_config_str + line
        # 写入临时客户端配置
        with open('client/client-temp.py', 'wt') as f:
            f.write(new_config_str)
        # 上传配置到客户机,并执行脚本
        scp_put('client/client-temp.py', '/root/', client_ipstr, rootstr, passwdstr)
        # 清理临时客户端配置
        os.remove('client/client-temp.py')
        is_add = raw_input('Whether to continue to add the client(y/n): ')
        if is_add == 'n' or is_add == 'N' or is_add == 'not' or is_add == 'NOT':
            break
    with open('%s/config.json' % webdir, 'wt') as f:
        f.write(json.dumps(old_config))

def scp_put(local_path, remote_path, host, root, passwd):
    scp_put = '''
    set timeout -1
    spawn scp %s %s@%s:%s
    expect "(yes/no)?" {
    send "yes\r"
    expect "password:"
    send "%s\r"
    } "password:" {send "%s\r"}
    expect eof
    exit'''

    os.system("echo '%s' > scp_put.cmd" % (
        scp_put % (os.path.expanduser(local_path), root, host, remote_path, passwd, passwd)))
    os.system('expect scp_put.cmd')
    os.system('rm scp_put.cmd')

    shell_exe = '''
    set timeout -1
    spawn ssh %s@%s
    expect "(yes/no)?" {
    send "yes\r"
    expect "password:"
    send "%s\r"
    } "password:" {send "%s\r"}
    expect "#"
    send "mv /root/client-temp.py /root/client.py\r"
    expect "#"
    send "yum -y install epel-release\r"
    expect "#"
    send "yum -y install python-pip\r"
    expect "#"
    send "yum clean all\r"
    expect "#"
    send "yum -y install gcc\r"
    expect "#"
    send "yum -y install python-devel\r"
    expect "#"
    send "pip install psutil\r"
    expect "#"
    send "apt-get -y install python-setuptools python-dev build-essential\r"
    expect "#"
    send "apt-get -y install python-pip\r"
    expect "#"
    send "pip install psutil\r"
    expect "#"
    send "nohup python /root/client.py &> /dev/null &\r"
    expect "#"
    send "exit\r"
    expect eof
    exit'''

    os.system("echo '%s' > shell_exe.cmd" % (
        shell_exe % (root, host, passwd, passwd)))
    os.system('expect shell_exe.cmd')
    os.system('rm shell_exe.cmd')

if __name__ == '__main__':
    print '******* CloudMonitor ********'
    print '* 1, Install CloudMonitor   *'
    print '* 2, Add Client             *'
    print '*****************************'
    sel = raw_input("input number: ")
    if sel not in ['1', '2']:
        print 'error input!'
        exit(1)
    elif sel == '1':
        NewDeploy()
    elif sel == '2':
        AddClient()
