# ServerStatus

ServerStatus is a full rewrite of [mojeda's](https://github.com/mojeda) [ServerStatus](https://github.com/mojeda/ServerStatus) script, which in turn is a modified version of [BlueVM's](http://www.lowendtalk.com/discussion/comment/169690#Comment_169690) script.

### Live demo:
* https://status.botox.bz/
* https://status.xu.cx/
* https://status.lolis.in/

There are many things which I dislike about the original script, for example:
* requires webserver and PHP for every client
* querys clients for every user that visits the site
* hangs when said clients don't respond
* loading slow with many servers
* messy codebase
* progress bar animation skips
* setup process complicated

Therefore I made my own ServerStatus which is quite different than the others under the hood, but still looks as nice!

The way my ServerStatus works is as following:
* Master server listens on port 35061 TCP
* Clients connect to the master server
* Clients generate statistics and send it to the master server periodically (eg. every second)
* Master server writes summarized stats to web-dir/json/stats.json
* Users load HTML page with JavaScript, which fetches the stats.json every two seconds and updates the table

# Installation & Usage

## Master Server
Name "sergate" given by Dasiel :)

Switch to a non-privileged user or create one.
Port 35601 needs to be free and forwarded/open for running the server.
```
git clone https://github.com/BotoX/ServerStatus.git
cd ServerStatus/server
make
./sergate
```
If everything goes well you can move on to the next step!

### Configuration
Simply edit the config.json file, it's self explanatory.
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
If you want to temporarily disable a server you can add
```
"disabled": true
```

There are also some command line switches which you should be aware of.
Simply add the -h switch when running the binary to find out!
```
    -h, --help            Show this help message and exit
    -v, --verbose         Verbose output
    -c, --config=<str>    Config file to use
    -d, --web-dir=<str>   Location of the web directory
    -b, --bind=<str>      Bind to address
    -p, --port=<int>      Listen on port
```

Also, don't forget to copy/move the web directory (ServerStatus/status) to a place where your webserver can find it.

### Running
You could manually run the master server, but using a startup script is preferred.

#### Debian and other init.d based systems
Copy the init.d script to /etc/init.d
```
cp ServerStatus/other/sergate.initd /etc/init.d/sergate
```
Edit it with your favourite text editor and change the following lines according to your setup:
```
# Change this according to your setup!
DAEMON_PATH="/usr/local/share/ServerStatus/server"
WEB_PATH="/var/www/botox.bz/status"
DAEMON="sergate"
OPTS="-d $WEB_PATH"
RUNAS="www-data"
```
Start the service by running as root
```
service sergate start
```
Add it to the autostart by running as root
```
update-rc.d sergate defaults
```

#### Arch Linux and other systemd based systems
Copy the systemd service to /etc/systemd/system
```
cp ServerStatus/other/sergate.service /etc/systemd/system/sergate.service
```
Edit it with your favourite text editor and change the following lines according to your setup:
```
WorkingDirectory=/usr/local/share/ServerStatus/server
User=botox.bz
Group=http
ExecStart=/usr/local/share/ServerStatus/server/sergate -d /home/botox.bz/status
```

Start the service by running as root
```
systemctl start sergate
```
Add it to the autostart by running as root
```
systemctl enable sergate
```

###### Note:
Make sure that the user which runs the master server has access to the web path and can write to $WEB_PATH/json.

## Client
There are two client implementations at the moment:
* Python2 **[preferred]**
* Bash

They are both fully supported and are as easy to set up.
More implementations will follow, feel free to create one and make a pull request.

## Automatic installation
The bash script client-setup.sh in other/ is an easy way to set up a new client.
You need to have wget and ca-certificates installed for it to work.
You could run it like this:
```
curl https://raw.github.com/BotoX/ServerStatus/master/other/client-setup.sh | bash
```
The script will also detect wether you're using systemd or SysVinit and ask you wether it should create a service/autostart for the client.

## Manual installation
With your favourite text editor change the following lines according to your setup:
### Python Client
```
SERVER = "status.botox.bz"
PORT = 35601
USER = "s01"
PASSWORD = "some-hard-to-guess-copy-paste-password"
INTERVAL = 1 # Update interval
```
### Bash Client
```
SERVER="status.botox.bz"
PORT=35601
USER="s01"
PASSWORD="some-hard-to-guess-copy-paste-password"
INTERVAL=1 # Update interval
```

### Running
After you've verified that the client configuration is correct, by running it, you can either make it start automatically by a startup script or cronjob, or just start it manually:
```
nohup ./client.py &> /dev/null &
```
#### Debian and other init.d based systems
Simply add something like this to /etc/rc.local:
```
su -l $USERNAME -c "/path/to/client.py &> /dev/null &"
```

#### Arch Linux and other systemd based systems
Create a new systemd service by creating the file /etc/systemd/system/serverstatus.service with similar content:
```
[Unit]
Description=ServerStatus Client
After=network.target

[Service]
Type=simple
IgnoreSIGPIPE=no
User=$USERNAME
ExecStart=/path/to/client.py

[Install]
WantedBy=multi-user.target
```
###### Note:
IgnoreSIGPIPE=no is important for the bash client, when this line is missing it wont reconnect and flood the journal with broken pipe errors.

You don't have to worry about the clients in case the master server goes down, they will keep trying to reconnect until they can reach the master server again.

# Additional information
## License
```
            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                    Version 2, December 2004

 Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>

 Everyone is permitted to copy and distribute verbatim or modified
 copies of this license document, and changing it is allowed as long
 as the name is changed.

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. You just DO WHAT THE FUCK YOU WANT TO.
```
If you work on this I'd be happy if you let me know!

## Credits
Obviously the original script from [BlueVM](http://www.lowendtalk.com/discussion/comment/169690#Comment_169690) and [mojeda's](https://github.com/mojeda) [fork](https://github.com/mojeda/ServerStatus).

I'd also like to thank the [Teeworlds](https://github.com/teeworlds/teeworlds) project for some of the code which has been used in this project.