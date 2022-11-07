---
dynamic: $device
title: Getting Started
order: 1
category: docs
domain: os
---

# Getting Started on the $device.name

In balenaOS all application logic and services are encapsulated in Docker containers. In this getting started guide we will walk you through setting up one of our pre-built development OS images and creating a simple application container. In the guide we will use the [balena CLI](https://www.npmjs.com/package/balena-cli) tool to make things super easy.

## Download an Image
To get a balenaOS device setup, we will first need to flash a system image on to the device, so head over to [balena.io/os](https://www.balena.io/os/#download) and grab the **development** OS for your board.

Once the download is finished, make sure to unzip the file and keep the resulting `balena.img` somewhere safe, we will need it very soon!

## Install the Balena CLI
The CLI is a collection of utilities which helps us to develop balenaOS based application containers.

Install the CLI with the following instructions, [available here](https://github.com/balena-io/balena-cli/blob/master/INSTALL.md).

## Configure the Image
To allow balenaOS images to be easily configurable before boot, some key config files are added to boot partition. In this step we will use the CLI to configure the network, set our hostname to `mydevice` and disable persistent logging, because we don’t want to kill our flash storage with excessive writes. If you are using ethernet you can skip this step, by default the device hostname will be `balena`.

**Note:**  Check our list of supported [WiFi adapters](https://github.com/balena-os/meta-balena#recommended-wifi-usb-dongle) and [modems](https://github.com/balena-os/meta-balena#modems).

``` bash
$ sudo balena local configure ~/Downloads/balena.img
? Network SSID I_Love_Unicorns
? Network Key superSecretPassword
? Do you want to set advanced settings? Yes
? Device Hostname mydevice
? Do you want to enable persistent logging? no
Done!
```

## Get the Device Up and Running
Okay, so now we have a fully configured image ready to go, so let’s flash and boot this baby. For this step we recommend [balenaEtcher](https://www.balena.io/etcher/) a handy flashing utility. You can, however, flash this image using `dd` or any other SD card flashing utility, if you wish.

### Flash $device.bootMedia

Open [balenaEtcher](https://www.balena.io/etcher/) and use the blue "Select Image" button to find the disk image you downloaded earlier. Once you have selected the image you want to flash, insert your SD card or connect your device (in the case of a balenaFin) to your laptop and flash the image.

### Boot the device

<!-- import "bootdevice" -->
Now power on and boot up your device, after about 10 seconds or so your device should be up and connected to your local network, you should see it broadcasting itself as `mydevice.local`. To check this, let’s try ping the device.

``` bash
$ ping mydevice.local
PING 192.168.1.111 (192.168.1.111): 56 data bytes
64 bytes from 192.168.1.111: icmp_seq=0 ttl=64 time=103.674 ms
64 bytes from 192.168.1.111: icmp_seq=1 ttl=64 time=9.723 ms
^C
--- 192.168.1.111 ping statistics ---
6 packets transmitted, 6 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 7.378/24.032/103.674/35.626 ms
```

Now if we want to poke around a bit inside balenaOS we can just ssh in with:
``` bash
$ balena ssh mydevice.local
Last login: Wed Sep 11 10:32:01 2019 from fe80::1420:6988:2a39:3d3d%wlan0
root@mydevice:~# uname -a
Linux mydevice 4.19.66 #1 SMP PREEMPT Wed Aug 28 16:57:11 UTC 2019 aarch64 aarch64 aarch64 GNU/Linux
root@mydevice:~# balena-engine version
Client:
 Version:           18.09.8-dev
 API version:       1.39
 Go version:        go1.10.8
 Git commit:        80d443d400dcc85e87322f72866593b46bafb157
 Built:             Mon Aug 26 09:22:28 2019
 OS/Arch:           linux/arm64
 Experimental:      false

Server:
 Engine:
  Version:          18.09.8-dev
  API version:      1.39 (minimum version 1.12)
  Go version:       go1.10.8
  Git commit:       80d443d400dcc85e87322f72866593b46bafb157
  Built:            Mon Aug 26 09:22:28 2019
  OS/Arch:          linux/arm64
  Experimental:     true
```

## Running your first Container
### Clone a demo Project

``` bash
$ git clone https://github.com/balenalabs/multicontainer-getting-started.git
```

### Get some Containers Running
To launch containers on our device, we will use the [`balena push`](https://www.balena.io/docs/reference/cli/#push-applicationordevice) command. First we need to change directory into the project we cloned down and then issue the following command.
``` bash
$ balena push mydevice.local
```
This command will use the image specified by the `docker-compose.yml` or `Dockerfile` in the root of your project directory. The build of this project will happen on your balenaOS device and once completed, the command will start up a container from that newly built image(s). **Note:** The first time you push a project it will need to pull the base images, so it can take a few minutes. Later pushes will be much faster.

Once it's finished building, you should see `[Logs] ...` streaming back and if you visit http://mydevice.local/ you will get a pretty little webpage showing CPU load and memory usage. You will also notice that anytime you change the code in the `multicontainer-getting-started` code base it will hot reload your containers, syncing the new code changes on the device.

## Poking Around balenaOS
To help explore balenaOS devices and application containers more easily, the balena CLI has an ssh command which will help you connect either to the HostOS or a running container on the device.

#### To ssh into the hostOS:
``` bash
$ balena ssh mydevice.local
```

#### To ssh into a particular container:
``` bash
$ balena ssh mydevice.local <service_name>
```
Where `<service_name>` can be replaced with any of the containers defined in your `docker-compose.yml`. If you have a single container app that doesn't have a compose file, your service will get the default name of `main`, so you can access the container using `balena ssh mydevice.local main`.

## Going Further
### Advanced Settings

Either mount the $device.bootMedia and run:
``` bash
$ sudo balena local configure /path/to/drive
```
And select `y` when asked if you want to add advanced settings.

Alternatively you can add `“persistentLogging”: true` to `config.json` in your boot partition of the $device.bootMedia.

To enable persistent logs in a running device, add `“persistentLogging”: true` to `/mnt/boot/config.json` and reboot.

The journal can be found at  `/var/log/journal/` which is bind mounted to `root-overlay/var/log/journal` in the `resin-conf` partition.
When logging is not persistent, the logs can be found at `/run/log/journal/` and this log is volatile so you will lose all logs when you power the device down.

### Creating a Project from Scratch
Alright! So we have an awesome container machine up and running on our network. So let’s start pushing some application containers onto it. In this section we will do a quick walk through of setting up a `Dockerfile` and make a simple little node.js webserver.

To get started, let’s create a new project directory called “myapp” and create a new file called `Dockerfile`.

``` bash
$ mkdir -p myapp && touch Dockerfile
```

Now we will create a minimal node.js container based on the slim [Alpine Linux distro](https://hub.docker.com/r/balenalib/raspberrypi3-alpine-node). We do this by adding the following lines to our Dockerfile.

``` Dockerfile
FROM balenalib/$device.id-alpine-node
CMD ["cat", "/etc/os-release"]
```

The `FROM` tells Docker what our container will be based on. In this case an Alpine Linux userspace with just the bare essentials needed for the node.js runtime. The `CMD` just defines what our container runs on startup. In this case, it’s not very exciting yet.

Now to get our application running on our device we can use the `balena push mydevice.local` functionality.
```bash
$ balena push mydevice.local
[Info]    Starting build on device mydevice.local
[Info]    Creating default composition with source: .
[Build]   [main] Step 1/4 : FROM balenalib/$device.id-alpine-node
[Build]   [main]  ---> 25d3c8c8d0af
[Build]   [main] Step 2/4 : CMD ["cat", "/etc/os-release"]
[Build]   [main]  ---> Running in 449e2d11b48f
[Build]   [main] Removing intermediate container 449e2d11b48f
[Build]   [main]  ---> fc19268cf077
[Build]   [main] Step 3/4 : LABEL io.resin.local.image=1
[Build]   [main]  ---> Running in efbf5e0d1027
[Build]   [main] Removing intermediate container efbf5e0d1027
[Build]   [main]  ---> da6d888c128f
[Build]   [main] Step 4/4 : LABEL io.resin.local.service=main
[Build]   [main]  ---> Running in 4befab0ab3f3
[Build]   [main] Removing intermediate container 4befab0ab3f3
[Build]   [main]  ---> 8351b83ebb73
[Build]   [main] Successfully built 8351b83ebb73
[Build]   [main] Successfully tagged local_image_main:latest

[Live]    Waiting for device state to settle...
[Info]    Streaming device logs...
[Live]    Watching for file changes...
[Logs]    [9/11/2019, 12:50:23 PM] Creating volume 'resin-data'
[Logs]    [9/11/2019, 12:50:26 PM] Installing service 'main sha256:8351b83ebb73f49ae044237191307c3bfed80c2ace2535bf33e8e4361c43461d'
[Logs]    [9/11/2019, 12:50:26 PM] Installed service 'main sha256:8351b83ebb73f49ae044237191307c3bfed80c2ace2535bf33e8e4361c43461d'
[Logs]    [9/11/2019, 12:50:26 PM] Starting service 'main sha256:8351b83ebb73f49ae044237191307c3bfed80c2ace2535bf33e8e4361c43461d'
[Logs]    [9/11/2019, 12:50:27 PM] Started service 'main sha256:8351b83ebb73f49ae044237191307c3bfed80c2ace2535bf33e8e4361c43461d'
[Logs]    [9/11/2019, 12:50:27 PM] [main] NAME="Alpine Linux"
[Logs]    [9/11/2019, 12:50:27 PM] [main] ID=alpine
[Logs]    [9/11/2019, 12:50:27 PM] [main] VERSION_ID=3.10.2
[Logs]    [9/11/2019, 12:50:27 PM] [main] PRETTY_NAME="Alpine Linux v3.10"
[Logs]    [9/11/2019, 12:50:27 PM] [main] HOME_URL="https://alpinelinux.org/"
[Logs]    [9/11/2019, 12:50:27 PM] [main] BUG_REPORT_URL="https://bugs.alpinelinux.org/"
```

This command will start the build on your local balenaOS device from whatever you have in the current working directory. It will then start up all the containers and stream back the logs from each container to the terminal. We can see that for our local balenaOS device we have an app called `[main]` which will be created from an image called `local_image_main` and is associated to a container on our device called `main_1_1`. You will notice that the container keeps restarting over and over. This is due to the fact that the our main process of printing out the `os-release` file exits after running and by default our containers restart policy is to always restart containers.

So now that we are building, let’s start adding some actual code! We will just add `main.js` file in the root of our `myapp` directory.

``` javascript
//main.js
console.log("Hey… I’m a node.js app running in a container!!");
```

We then make sure our Dockerfile copies this source file into our container context by replacing our current `CMD ["cat","/etc/os-release"]` in our Dockerfile with the following.

``` Dockerfile
FROM balenalib/$device.id-alpine-node
WORKDIR /usr/src/app
COPY . .
CMD ["node", "main.js"]
```

This puts all the contents of our `myapp` directory into `/usr/src/app` in our running container and says we should start main.js when the container starts.

Alright, so we have a simple javascript container, but that’s pretty boring, let’s add some dependencies and complexity.  To add dependencies in node.js we need a package.json, the easiest way to whip up one is to just run `npm init` in the root of our `myapp` directory. After a nice little interactive dialog we have the following `package.json` in directory.

``` json
{
  "name": "myapp",
  "version": "1.0.0",
  "description": "a simple hello world webserver",
  "main": "main.js",
  "scripts": {
    "test": "echo \"no tests yet\""
  },
  "repository": {
    "type": "git",
    "url": "none"
  },
  "author": "Shaun Mulligan <shaun@balena.io>",
  "license": "ISC"
}
```

Now it’s time to add some dependencies. For our little webserver, we will use the popular expressjs module. We can add it to the `package.json` after the `"license": "ISC"`, so it now looks like this:

``` json
{
  "name": "myapp",
  "version": "1.0.0",
  "description": "a simple hello world webserver",
  "main": "main.js",
  "scripts": {
    "test": "echo \"no tests yet\""
  },
  "repository": {
    "type": "git",
    "url": "none"
  },
  "author": "Shaun Mulligan <shaun@balena.io>",
  "license": "ISC",
  "dependencies": {
    "express": "^4.14.0"
  }
}
```

Now all we need to do is add a few more lines of javascript to our main.js and we are off to the races.

``` javascript
//main.js

var express = require('express');
var app = express();

// reply to request with "Hello World!"
app.get('/', function (req, res) {
  res.send("Hello World, I'm a container running on balenaOS!");
});

//start a server on port 80 and log its start to our console
var server = app.listen(80, function () {

  var port = server.address().port;
  console.log("Hey… I’m a node.js server running in a container and listening on port: ", port);
});
```

Great, so now we are almost ready to go, but we want to make sure our dependency gets installed when we build. We then need to run a `npm install` in our build, so we add a few lines to our Dockerfile.

``` Dockerfile
FROM balenalib/$device.id-alpine-node
WORKDIR /usr/src/app
COPY package.json package.json
RUN npm install
COPY . .
CMD ["node", "main.js"]
```

__NOTE:__ Add `node_modules` to your `.dockerignore` file, otherwise your local modules might be copied to the device with the above `Dockerfile`, and they are likely the wrong architecture for your application!

We can now deploy our new webserver container again with:

``` bash
$ balena push <DEVICE_IP>
```

You should now be able to point your web browser on your laptop to the IP address of your device and see the "Hello, World!" message.

### Configure balenaOS without the CLI

If you are not using the CLI, you will need to mount the boot partition of the image and edit the configuration manually.

Edit `/boot/config.json` so it looks like this:
``` json
{
  "persistentLogging": false,
  "hostname": "mydevice",
}
```

And create a file in `/boot/system-connections` called `my-wifi` with the following content and the `ssid` and `psk` values replaced as needed.

```bash
[connection]
id=my-wifi
type=wifi

[wifi]
mode=infrastructure
ssid=I_Love_Unicorns

[wifi-security]
auth-alg=open
key-mgmt=wpa-psk
psk=superSecretPassword

[ipv4]
method=auto

[ipv6]
addr-gen-mode=stable-privacy
method=auto
```
