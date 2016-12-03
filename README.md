# 汉化说明：      
汉化了status文件夹下的index.html和js/serverstatus.js文件      
汉化并简化了安装教程      
原版安装说明：https://github.com/BotoX/ServerStatus/blob/master/README.md      

# 简化安装教程：     

【服务端配置】:        
一、      
```
git clone https://github.com/BotoX/ServerStatus.git（汉化版：https://github.com/tenyue/ServerStatus.git）
cd ServerStatus/server
make
./sergate
```
如果没错误提示，OK，ctrl+c关闭；如果有错误提示，检查35601端口是否被占用    

二、     
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
如果你想临时禁用某个服务器状态，就在json中增加以下字段：       
```
"disabled": true
```

三、拷贝ServerStatus/status到你的网站目录       

四、运行服务端：       
web-dir参数为你放置ServerStatus/status的根目录   
```
./sergate --config=config.json --web-dir=/home/wwwroot/www.xxx.com/   
```

【客户端配置】：          
客户端提供三种方式（Python2、Python2-psutil、Bash）          

一、vim client.py, 修改username, password        

二、python client.py 运行即可。      

打开云探针页面，就可以正常的监控。接下来把服务器和客户端脚本自行加入开机启动，或者进程守护，或以后台方式运行即可！         

#####################################################################################################     
# 云监控：   

云监控基于mojeda的ServerStatus项目的全部重写，也是BlueVM项目的修改版！        

mojeda: https://github.com/mojeda       
mojeda's ServerStatus: https://github.com/mojeda/ServerStatus      
BlueVM's project: http://www.lowendtalk.com/discussion/comment/169690#Comment_169690      

在线演示:   
* https://status.botox.bz/     

原版脚本比较扯淡的:     
* 每个客户端都需要安装WebServer和PHP   
* 每次都需要查询客户端
* 客户端不响应，shit，云监控就挂机
* 服务器越多加载越缓慢
* 代码一坨屎
* 进度条动画跳过
* 设置复杂

所以我做了一个全新版本的ServerStatus， 看起来非常赞，主要工作流程如下:    
* 主服务器监听35061端口(TCP)
* 客户端连接到主服务器
* 客户端捕获信息并定时发送至服务器
* 主服务器把收到的信息写入web-dir / json / stats.json
* 每两秒钟获取一次stats.json并更新在页面上，通过js展示出来      

#####################################################################################################      
1、如果你还是不会配置，下方留言，会继续汉化更详细的说明。         
2、如果你是老手，直接看英文吧。      
