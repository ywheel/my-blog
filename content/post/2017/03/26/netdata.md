---
categories:
- 技术文章
date: 2017-03-26T23:15:46+08:00
description: "Netdata，单服务器监控的神器"
keywords:
- 监控, 可视化
title: "Linux服务器监控的神器：Netdata"
url: "/post/2017/03/26/netdata"
---

由于工作的关系，最近在思考如何做集群、服务器的监控。在网上东转转西转转，偶然发现了一个单机监控的2016新秀Netdata，眼前着实为之一亮。 令人印象非常之深刻的个主要特性：

1. 界面酷炫，实时监控
2. 零配置，即装即用

官网地址在这里： https://my-netdata.io/ ， 在[The state of the Octoverse 2016](https://octoverse.github.com/) 也能看到他的身影：

![github octoverse 2016](http://o75oehjrs.bkt.clouddn.com/image/blog/GitHub%20octoverse%202016.png?watermark/2/text/YmxvZy55d2hlZWwuY24=/font/5b6u6L2v6ZuF6buR/fontsize/500/fill/I0Y1RUZFRg==/dissolve/100/gravity/SouthEast/dx/10/dy/10)

## Netdata feature

从[Github](https://github.com/firehol/netdata#features)上能够看到netdata的主要功能，主要有几点（详细的可查看github上的说明）：

1. interactive bootstrap dashboards, 酷炫（主要是dark主题，light主题就没这感觉了）
2. 匪夷所思的快。。。所有请求每个metreic都在0.5ms内响应，即便是一台烂机器
3. 非常高效，每秒采集数千个指标，但仅占cpu单核1%，少量MB的内存以及完全没有磁盘IO
4. 提供复杂的、各种类型的告警，支持动态阈值、告警模板、多种通知方式等
5. 可扩展，使用自带的插件API（比如bash, python, perl, node.js, java, go, ruby等）来收集任何可以衡量的数据
6. 零配置：安装后netdata会自动的监测一切
7. 零依赖：netdata有自己的web server， 提供静态web文件和web API
8. 零维护：只管跑上！
9. 支撑多种时间序列后端服务，比如graphite, opentsdb, prometheus, json document DBs

Netdata监控项也很多，比如CPU, 内存，磁盘，网络这些基础的之外，还可以有IPC, netfilter/iptables Linux firewall, fping, Processes, NFS, `Network QoS`, Applications, Apache web server, Nginx, Tomcat, mysql, postgres, redis, mongodb, elasticsearch, SNMP devices等等。

## Netdata install

Netdata的安装非常简单，支持几乎所有的Linux版本。刚好我还有一个用于来科学上网的EC2机器是Unbutu系统，果断登上去尝试。

### 安装准备

Netdata提供了一个非常简便的安装方法，我的Unbutu系统只需要执行下面的命令即可完成安装netdata所依赖的各种东西：

```
curl -Ss 'https://raw.githubusercontent.com/firehol/netdata-demo-site/master/install-required-packages.sh' >/tmp/kickstart.sh && bash /tmp/kickstart.sh -i netdata
```

注意，上面的命令是安装基本的部分，不包括`mysql / mariadb, postgres, named, hardware sensors and SNMP`. 如果要完整安装，则需要执行下面的命令：

```
curl -Ss 'https://raw.githubusercontent.com/firehol/netdata-demo-site/master/install-required-packages.sh' >/tmp/kickstart.sh && bash /tmp/kickstart.sh -i netdata-all
```

### 安装Netdata

安装Netdata也很简单，按照wiki的说明即可：

```
# download it - the directory 'netdata' will be created
git clone https://github.com/firehol/netdata.git --depth=1
cd netdata

# run script with root privileges to build, install, start netdata
./netdata-installer.sh
``` 

注意上面要使用root权限，执行命令后的提示信息也很丰富有趣，比如刚开头是这样的：

```
$ sudo ./netdata-installer.sh 

  ^
  |.-.   .-.   .-.   .-.   .  netdata                                        
  |   '-'   '-'   '-'   '-'   real-time performance monitoring, done right!  
  +----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+--->


  You are about to build and install netdata to your system.

  It will be installed at these locations:

   - the daemon     at /usr/sbin/netdata
   - config files   in /etc/netdata
   - web files      in /usr/share/netdata
   - plugins        in /usr/libexec/netdata
   - cache files    in /var/cache/netdata
   - db files       in /var/lib/netdata
   - log files      in /var/log/netdata
   - pid file       at /var/run/netdata.pid
   - logrotate file at /etc/logrotate.d/netdata

  This installer allows you to change the installation path.
  Press Control-C and run the same command with --help for help.
```

安装结束的最后几行是这样的：

```
Uninstall script generated: ./netdata-uninstaller.sh
Update script generated   : ./netdata-updater.sh

netdata-updater.sh can work from cron. It will trigger an email from cron
only if it fails (it does not print anything if it can update netdata).
Run this to automatically check and install netdata updates once per day:

ln -s /home/ubuntu/netdata/netdata-updater.sh /etc/cron.daily/netdata-updater.sh

 --- We are done! --- 

  ^
  |.-.   .-.   .-.   .-.   .-.   .  netdata                          .-.   .-
  |   '-'   '-'   '-'   '-'   '-'   is installed and running now!  -'   '-'  
  +----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+--->

  enjoy real-time performance and health monitoring...

```

安装完后，还可以根据wiki所说的配置开机启动，照做之后执行`service netdata start`启动服务，可以访问http://localhost:19999/ 看到监控界面。随后去AWS控制台放通19999端口，我的EC2机器的监控系统就大功告成啦！

由此看出，Netdata的安装非常之简单，只有几行命令，而且根本无需配置。

### 监控页面

再来看看监控页面，除了配色酷炫，监控项种类繁多之外，页面元素的实时响应、告警设置等都极具亮点。为了更好的展示页面，在这里会盗用github上netdata官方的几个动态图来show一下.

#### System overview

![System overview](https://cloud.githubusercontent.com/assets/2662304/14092712/93b039ea-f551-11e5-822c-beadbf2b2a2e.gif)

#### Disks

![Disks](https://cloud.githubusercontent.com/assets/2662304/14093195/c882bbf4-f554-11e5-8863-1788d643d2c0.gif)

#### Network interfaces

![Network](https://cloud.githubusercontent.com/assets/2662304/14093128/4d566494-f554-11e5-8ee4-5392e0ac51f0.gif)

#### Alarms

![Alarms](http://o75oehjrs.bkt.clouddn.com/image/blog/netdata%20alarm.png?watermark/2/text/YmxvZy55d2hlZWwuY24=/font/5b6u6L2v6ZuF6buR/fontsize/500/fill/I0Y1RUZFRg==/dissolve/100/gravity/SouthEast/dx/10/dy/10)

## Netdata backend

Netdata也可以后台服务收集监控指标，多服务器的监控指标汇总到前台展示，或者归档汇总后提供给其他工具如grafana， 如下图：

![netdata backend](https://cloud.githubusercontent.com/assets/2662304/20649711/29f182ba-b4ce-11e6-97c8-ab2c0ab59833.png)

Netdata支持如下几个backends: 

- 1) graphite; 
- 2) opentsdb; 
- 3) json document DBs. 

并能够提供3种计算模式： 

- 1) as collected； 
- 2）average; 
- 3) sum or volume。 

具体的可以到[netdata wiki](https://github.com/firehol/netdata/wiki/netdata-backends)查看。利用这种方式，应该也较容易能够折腾出来一个集群监控的解决方案，并且netdata和grafana的界面看起来都非常的酷炫（又一次印证了一个观点：大屏监控系统就得是暗色系！）

看到[roadmap](https://github.com/firehol/netdata/wiki#is-there-a-roadmap)里面提到：monitor more applications (hadoop and friends, postgres, etc). 也希望hadoop这方面的监控能早日实现，又可以多一个可选方案啦~

