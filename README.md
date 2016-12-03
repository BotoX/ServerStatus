# ServerStatus中文版：   

* 该项目直接克隆自：https://github.com/BotoX/ServerStatus，据说ServerStatus是一个更嗨、更炫、高逼格的探针！

# 在线演示：

* 暂无，英文版演示：https://status.botox.bz/

# 更新说明：

* 去掉无用的IPV6信息，增加服务器总流量监控        
* 汉化了status文件夹下的index.html和js/serverstatus.js所有英文提示      
* 汉化并简化安装教程              

# 安装教程：        

【服务端配置】:            
一、克隆代码          
```
git clone https://github.com/tenyue/ServerStatus.git
cd ServerStatus/server
make
./sergate
```
如果没错误提示，OK，ctrl+c关闭；如果有错误提示，检查35601端口是否被占用    

二、修改配置文件         
修改config.json文件，乱七八糟的字段都可以更改，嗨上天也可以。但是username, password的值需要和客户端对应一致                 
```
{"servers":
	[
		{
			"username": "s01",
			"name": "Mainserver 1",
			"type": "Dedicated Server",
			"host": "GenericServerHost123",
			"location": "Austria",
			"password": "some-hard-to-guess-copy-paste-password"
		},
	]
}       
```

三、拷贝ServerStatus/status到你的网站目录
例如：
```
sudo cp -r ServerStatus/status/* /home/wwwroot/default
```

四、运行服务端：       
web-dir参数为你放置ServerStatus/status的根目录，务必修改成自己网站的路径   
```
./sergate --config=config.json --web-dir=/home/wwwroot/default   
```

【客户端配置】：
客户端程序在ServerStatus/clients文件夹下 （服务器总流量监控暂支持client.py客户端）       
一、vim client.py, 修改username, password        

二、python client.py 运行即可。      

打开云探针页面，就可以正常的监控。接下来把服务器和客户端脚本自行加入开机启动，或者进程守护，或以后台方式运行即可！  

# 为什么会有ServerStatus中文版：

* 有些功能确实没用
* 原版本部署，英文说明复杂
* 不符合中文版的习惯
* 没有一次又一次的轮子，哪来如此优秀的插件

# 相关开源项目，感谢： 

* ServerStatus：https://github.com/BotoX/ServerStatus
* mojeda: https://github.com/mojeda 
* mojeda's ServerStatus: https://github.com/mojeda/ServerStatus
* BlueVM's project: http://www.lowendtalk.com/discussion/comment/169690#Comment_169690