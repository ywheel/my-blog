---
categories:
- 技术文章
date: 2016-07-14T20:21:30+08:00
description: "ssh action in oozie workflow"
keywords:
- ssh, oozie
title: Oozie ssh action问题排查
url: ""
---

## 问题描述

最近在我们的其中一个现网环境中部署MR程序，MR程序的调度自然是用Oozie了。在Oozie的Workflow中，我们使用ssh action登录到一台节点上，并且在该节点上部署了脚本做数据库的建表操作。

该程序已经在现网多个生产环境部署运行过，经过了多次验证，但没想到在该环境中仍然出现了问题。问题出在ssh action中，并且抛出了一个`Cannot run program "scp": error=2, No such file or directory`的错误。

具体的错误栈信息如下：

```
2016-06-12 22:30:54,713 INFO org.apache.oozie.action.ssh.SshActionExecutor: SERVER[Master] USER[hdfs] GROUP[-] TOKEN[] APP[TestSsh] JOB[0000201-160113124428061-oozie-oozi-W] ACTION[0000201-160113124428061-oozie-oozi-W@ShellAction] Attempting to copy ssh base scripts to remote host [root@192.168.1.154]
2016-06-12 22:30:54,869 WARN org.apache.oozie.action.ssh.SshActionExecutor: SERVER[Master] USER[hdfs] GROUP[-] TOKEN[] APP[TestSsh] JOB[0000201-160113124428061-oozie-oozi-W] ACTION[0000201-160113124428061-oozie-oozi-W@ShellAction] Error while executing ssh EXECUTION
2016-06-12 22:30:54,870 WARN org.apache.oozie.command.wf.ActionStartXCommand: SERVER[Master] USER[hdfs] GROUP[-] TOKEN[] APP[TestSsh] JOB[0000201-160113124428061-oozie-oozi-W] ACTION[0000201-160113124428061-oozie-oozi-W@ShellAction] Error starting action [ShellAction]. ErrorType [ERROR], ErrorCode [UNKOWN_ERROR], Message [UNKOWN_ERROR: Cannot run program "scp": error=2, No such file or directory]
org.apache.oozie.action.ActionExecutorException: UNKOWN_ERROR: Cannot run program "scp": error=2, No such file or directory
    at org.apache.oozie.action.ssh.SshActionExecutor.execute(SshActionExecutor.java:599)
    at org.apache.oozie.action.ssh.SshActionExecutor.start(SshActionExecutor.java:204)
    at org.apache.oozie.command.wf.ActionStartXCommand.execute(ActionStartXCommand.java:228)
    at org.apache.oozie.command.wf.ActionStartXCommand.execute(ActionStartXCommand.java:63)
    at org.apache.oozie.command.XCommand.call(XCommand.java:281)
    at org.apache.oozie.service.CallableQueueService$CompositeCallable.call(CallableQueueService.java:323)
    at org.apache.oozie.service.CallableQueueService$CompositeCallable.call(CallableQueueService.java:252)
    at org.apache.oozie.service.CallableQueueService$CallableWrapper.run(CallableQueueService.java:174)
    at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
    at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:615)
    at java.lang.Thread.run(Thread.java:744)
Caused by: java.io.IOException: Cannot run program "scp": error=2, No such file or directory
    at java.lang.ProcessBuilder.start(ProcessBuilder.java:1041)
    at java.lang.Runtime.exec(Runtime.java:617)
    at java.lang.Runtime.exec(Runtime.java:485)
    at org.apache.oozie.action.ssh.SshActionExecutor.executeCommand(SshActionExecutor.java:332)
    at org.apache.oozie.action.ssh.SshActionExecutor.setupRemote(SshActionExecutor.java:376)
    at org.apache.oozie.action.ssh.SshActionExecutor$1.call(SshActionExecutor.java:206)
    at org.apache.oozie.action.ssh.SshActionExecutor$1.call(SshActionExecutor.java:204)
    at org.apache.oozie.action.ssh.SshActionExecutor.execute(SshActionExecutor.java:548)
    ... 10 more
Caused by: java.io.IOException: error=2, No such file or directory
    at java.lang.UNIXProcess.forkAndExec(Native Method)
    at java.lang.UNIXProcess.<init>(UNIXProcess.java:135)
    at java.lang.ProcessImpl.start(ProcessImpl.java:130)
    at java.lang.ProcessBuilder.start(ProcessBuilder.java:1022)
    ... 17 more
```

## 问题排查

### 排查Oozie Server是否有SCP命令

Oozie的ssh action是在oozie server所在服务器上，登录到目标机器，这样就需要做oozie server机器到目标机器的免密登录。

由于我们在安装集群时，使用的是自己开发的脚本安装，而在脚本安装过程中， `scp`是一定会使用的命令，所以Oozie Server节点应该安装有SCP的。在终端中试了一下，`scp`是能够正常使用的。

### 排查Oozie ssh免密登录

看到上述错误信息，其实应该不属于ssh免密登录问题，但这个`scp`的问题的确没有头绪（我们的脚本中并没有使用`scp`，而Oozie Server上又可以使用`scp`命令。）

于是，我们重做了oozie server到目标机器的免密登录，但无任何效果。更换目标机器、重新部署Oozie Server到另一个节点后再做免密登录均不能解决问题。

### 查看Oozie代码寻找scp过程

没辙了，只能看看Oozie的代码，看看在ssh action中，为什么需要scp, 在哪里使用到了scp.

从github上下载了Oozie的源代码，在`core`包中找到`org.apache.oozie.action.ssh.SshActionExecutor`, 其中有一个`start`方法，Oozie在执行ssh action时，会调用该方法：

```java
public void start(final Context context, final WorkflowAction action) throws ActionExecutorException {
        XLog log = XLog.getLog(getClass());
        log.info("start() begins");
        String confStr = action.getConf();
        Element conf;
        try {
            conf = XmlUtils.parseXml(confStr);
        }
        catch (Exception ex) {
            throw convertException(ex);
        }
        Namespace nameSpace = conf.getNamespace();
        Element hostElement = conf.getChild("host", nameSpace);
        String hostString = hostElement.getValue().trim();
        hostString = prepareUserHost(hostString, context);
        final String host = hostString;
        final String dirLocation = execute(new Callable<String>() {
            public String call() throws Exception {
                return setupRemote(host, context, action);
            }

        });

        String runningPid = execute(new Callable<String>() {
            public String call() throws Exception {
                return checkIfRunning(host, context, action);
            }
        });
        ...
    }
```

在`start`方法中执行到的第一个`callable`就是去调用`setupRemote`方法：

```java
protected String setupRemote(String host, Context context, WorkflowAction action) throws IOException, InterruptedException {
        XLog log = XLog.getLog(getClass());
        log.info("Attempting to copy ssh base scripts to remote host [{0}]", host);
        String localDirLocation = Services.get().getRuntimeDir() + "/ssh";
        if (localDirLocation.endsWith("/")) {
            localDirLocation = localDirLocation.substring(0, localDirLocation.length() - 1);
        }
        File file = new File(localDirLocation + "/ssh-base.sh");
        if (!file.exists()) {
            throw new IOException("Required Local file " + file.getAbsolutePath() + " not present.");
        }
        file = new File(localDirLocation + "/ssh-wrapper.sh");
        if (!file.exists()) {
            throw new IOException("Required Local file " + file.getAbsolutePath() + " not present.");
        }
        String remoteDirLocation = getRemoteFileName(context, action, null, true, true);
        String command = XLog.format("{0}{1}  mkdir -p {2} ", SSH_COMMAND_BASE, host, remoteDirLocation).toString();
        executeCommand(command);
        command = XLog.format("{0}{1}/ssh-base.sh {2}/ssh-wrapper.sh {3}:{4}", SCP_COMMAND_BASE, localDirLocation,
                              localDirLocation, host, remoteDirLocation);
        executeCommand(command);
        command = XLog.format("{0}{1}  chmod +x {2}ssh-base.sh {3}ssh-wrapper.sh ", SSH_COMMAND_BASE, host,
                              remoteDirLocation, remoteDirLocation);
        executeCommand(command);
        return remoteDirLocation;
    }
```

由此可以看到，在`setupRemote`方法中，Oozie会先寻找两个文件：`ssh-base.sh`,`ssh-wrapper.sh`, 这两个文件存在于Oozie Server运行时的目录里（Services.get().getRuntimeDir() + "/ssh"）. 在该环境的Oozie Server节点上，执行以下命令查找运行时目录：

```
[oozie@master oozie]$ ps aux | grep oozie
root      1068  0.0  0.0 145432  1592 pts/1    S    21:47   0:00 su oozie
oozie     1069  0.0  0.0 108300  1912 pts/1    S+   21:47   0:00 bash
root      3842  0.0  0.0 145432  1592 pts/9    S    22:18   0:00 su oozie
oozie     3843  0.0  0.0 108296  1880 pts/9    S    22:18   0:00 bash
oozie     4885  5.4  1.4 5295004 467072 ?      Sl   22:28   1:00 /usr/java/jdk1.7.0_45-cloudera/bin/java -Djava.util.logging.config.file=/var/lib/oozie/tomcat-deployment/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Xms1073741824 -Xmx1073741824 -XX:OnOutOfMemoryError=/usr/lib64/cmf/service/common/killparent.sh -Doozie.home.dir=/opt/cloudera/parcels/CDH-5.2.0-1.cdh5.2.0.p0.36/lib/oozie -Doozie.config.dir=/var/run/cloudera-scm-agent/process/3518-oozie-OOZIE_SERVER -Doozie.log.dir=/var/log/oozie -Doozie.log.file=oozie-cmf-oozie-OOZIE_SERVER-Master.log.out -Doozie.config.file=oozie-site.xml -Doozie.log4j.file=log4j.properties -Doozie.log4j.reload=10 -Doozie.http.hostname=Master -Doozie.http.port=11000 -Djava.net.preferIPv4Stack=true -Doozie.admin.port=11001 -Doozie.instance.id=Master -Dderby.stream.error.file=/var/log/oozie/derby.log -Doozie.https.keystore.file= -Doozie.https.keystore.pass= -Doozie.https.port= -Djava.endorsed.dirs=/opt/cloudera/parcels/CDH-5.2.0-1.cdh5.2.0.p0.36/lib/bigtop-tomcat/endorsed -classpath /opt/cloudera/parcels/CDH-5.2.0-1.cdh5.2.0.p0.36/lib/bigtop-tomcat/bin/bootstrap.jar -Dcatalina.base=/var/lib/oozie/tomcat-deployment -Dcatalina.home=/opt/cloudera/parcels/CDH-5.2.0-1.cdh5.2.0.p0.36/lib/bigtop-tomcat -Djava.io.tmpdir=/var/run/cloudera-scm-agent/process/3518-oozie-OOZIE_SERVER/temp org.apache.catalina.startup.Bootstrap start
oozie     6163  0.0  0.0 110228  1184 pts/9    R+   22:47   0:00 ps aux
oozie     6164  0.0  0.0 103252   900 pts/9    R+   22:47   0:00 grep oozie
root     61612  0.0  0.0 145432  1592 pts/3    S    20:54   0:00 su oozie
oozie    61613  0.0  0.0 108296  1908 pts/3    S+   20:54   0:00 bash
```

进入目录找到两个shell脚本文件：

```
[oozie@master temp]$ cd /var/run/cloudera-scm-agent/process/3518-oozie-OOZIE_SERVER/temp
[oozie@master temp]$ ll
总用量 0
drwxr-xr-x 3 oozie oozie 60 6月  12 22:28 oozie-oozi2411540976346867728.dir
[oozie@master temp]$ cd oozie-oozi2411540976346867728.dir/
[oozie@master oozie-oozi2411540976346867728.dir]$ ll
总用量 0
drwxr-xr-x 2 oozie oozie 80 6月  12 22:28 ssh
[oozie@master oozie-oozi2411540976346867728.dir]$ cd ssh/
[oozie@master ssh]$ ll
总用量 8
-rw-r--r-- 1 oozie oozie 1469 6月  12 22:28 ssh-base.sh
-rw-r--r-- 1 oozie oozie 2263 6月  12 22:28 ssh-wrapper.sh
```

说明这两个文件都存在。

在`setupRemote`方法中，首先运行`ssh`+`mkdir`命令，在目标机器上创建目录，路径为`oozie-oozi/${WORKFLOW-ID}/${ACTION}--${ACTION-TYPE}`。在ssh目标机器的/root目录下(由于是登录到root账号)，创建了`/root/oozie-oozi/0000201-160113124428061-oozie-oozi-W/ShellAction--ssh`目录。该目录的创建成功说明至少免密登录没有问题，Oozie Server能够免密登录到目标机器执行命令。

接下来执行`scp`操作，将Oozie Server中的`ssh-base.sh`和`ssh-wrapper.sh`文件scp到目标目录中，但是这一步失败。拼接该命令为：

```
scp -o PasswordAuthentication=no -o KbdInteractiveDevices=no -o StrictHostKeyChecking=no -o ConnectTimeout=20 /var/run/cloudera-scm-agent/process/3518-oozie-OOZIE_SERVER/temp/oozie-oozi2411540976346867728.dir/ssh/ssh-base.sh /var/run/cloudera-scm-agent/process/-oozie-OOZIE_SERVER/temp/oozie-oozi4864889223161337030.dir/ssh/ssh-wrapper.sh root@localhost:oozie-oozi/0000201-160113124428061-oozie-oozi-W/ShellAction--ssh/
```

但奇怪的是在Oozie Server所在服务器终端下切换到oozie用户，单独执行上述命令却能成功。

于是，这个问题就变成了: scp其实没问题，在终端下执行命令均可成功，但是Oozie Server执行scp缺不成功。

### 排查CDH版本问题

想来想去，没有头绪。在网上搜也没找到想要的结果。于是想到了土办法：升级。 有时候升级就像是重装系统一样"管用"。

当前的版本是CDH 5.2版本，Oozie的版本是4.0.0。而Oozie的新版本4.1.0是到了CDH 5.4才有的。由于我们在现网生产环境除了CDH 5.2之外，还使用了5.6，因此决定直接升到5.6.

跨版本升级的各种问题在此不表，反正是又升CDH，又升元数据啥的，并且由于集群并非每台机器都能连外网，升级agent需要各种依赖包，各种费劲。

总之一句话，升级到了5.6，仍然不能解决问题。

### 环境变量！！！

折腾了各种办法，只有再冷静下来仔细想想。为什么相同的集群版本，相同的软件版本，在其他地方都能执行成功个，而在该环境下就不行了呢？

答案就是： 环境变量。

Oozie执行scp命令是使用`Runtime.exec`，真正执行仍需要找到`scp`命令。

在Oozie Server节点上查找scp:

```
$ which scp
/usr/local/openssh/bin/scp
```

由此猜想是否oozie server的环境变量中没有这个目录到导致找不到scp？ 于是执行如下命令，创建软连接：

```
[root@master bin]# ln -s /usr/local/openssh/bin/scp scp
[root@master bin]# ll scp
lrwxrwxrwx 1 root root 26 6月  17 01:58 scp -> /usr/local/openssh/bin/scp
[root@master bin]# su oozie
sh-4.1$ which scp
/usr/bin/scp
```

然后再重试Oozie ssh action，居然成功了！！！

到目标机器的`/root/oozie-oozi/`目录下，也能找到那两个sh文件了(执行完成后会被删除)：

```
[root@master ssh-2ecf--ssh]# ll
总用量 16
-rw-r--r-- 1 root root    6 6月  17 02:13 0000001-160617010847759-oozie-oozi-W@ssh-2ecf@2.pid
-rw-r--r-- 1 root root    0 6月  17 02:13 17950.0000001-160617010847759-oozie-oozi-W@ssh-2ecf@2.stderr
-rw-r--r-- 1 root root    9 6月  17 02:13 17950.0000001-160617010847759-oozie-oozi-W@ssh-2ecf@2.stdout
-rwxr-xr-x 1 root root 1469 6月  17 02:13 ssh-base.sh
-rwxr-xr-x 1 root root 2263 6月  17 02:13 ssh-wrapper.sh
[root@master ssh-2ecf--ssh]# pwd
/root/oozie-oozi/0000001-160617010847759-oozie-oozi-W/ssh-2ecf--ssh
```

### 恢复Oozie

本以为解决了这个问题后大功告成。没想到，接下来又是一个深渊，运行oozie作业抛如下错误：

```
2016-06-17 10:06:16,950 WARN org.apache.oozie.action.hadoop.SqoopActionExecutor: SERVER[Master] USER[hdfs] GROUP[-] TOKEN[] APP[ReleaseV1_hour_20160609_01] JOB[0000004-160617010847759-oozie-oozi-W] ACTION[0000004-160617010847759-oozie-oozi-W@webByHour] Launcher exception: Could not find Yarn tags property (mapreduce.job.tags)
java.lang.RuntimeException: Could not find Yarn tags property (mapreduce.job.tags)
    at org.apache.oozie.action.hadoop.LauncherMainHadoopUtils.getChildYarnJobs(LauncherMainHadoopUtils.java:52)
    at org.apache.oozie.action.hadoop.LauncherMainHadoopUtils.killChildYarnJobs(LauncherMainHadoopUtils.java:87)
    at org.apache.oozie.action.hadoop.SqoopMain.run(SqoopMain.java:165)
    at org.apache.oozie.action.hadoop.LauncherMain.run(LauncherMain.java:39)
```

查找原因，说是需要升级Oozie共享库(现在集群版本已经升到CDH5.6了)，于是去CM中升级Oozie共享库，先停止Oozie, 然后安装Oozie共享库，则提示找不到yarn相关的包,需要升级CM。

于是又开始升级CM, 碰到如下问题：

1. `libssl.so.10: cannot open shared object file: No such file or directory`

2. 升级CM Server和agent的时候，依赖报错：

    ```
    ** Found 6 pre-existing rpmdb problem(s), 'yum check' output follows:
    git-1.7.1-3.el6_4.1.x86_64 has missing requires of openssh-clients
    6:kdelibs-devel-4.3.4-20.el6_4.1.x86_64 has missing requires of openssl-devel
    mysql-devel-5.1.71-1.el6.x86_64 has missing requires of openssl-devel
    1:net-snmp-devel-5.5-49.el6.x86_64 has missing requires of openssl-devel
    python-meh-0.12.1-3.el6.noarch has missing requires of openssh-clients
    systemtap-client-2.3-3.el6.x86_64 has missing requires of openssh-clients
    ```
    
3. 找不到正确的repo:

    ```
    Error: Cannot find a valid baseurl for repo: base 
    Could not retrieve mirrorlist http://mirrorlist.centos.org/?release=6&arch=x86_64&repo=os error was 
    14: PYCURL ERROR 6 - "Couldn't resolve host 'mirrorlist.centos.org'"
    ```

尝试使用以下方法解决：

1. `rpm -ivh openssl-1.0.1e-15.el6.x86_64.rpm`安装openssl

2. 配置`/etc/yum.repos.d/cdh.repo`,`/etc/yum.repos.d/cloudera-manager.repo`,添加阿里云centos源`wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo`

3. 执行`yum upgrade 'cloudera-*' --skip-broken`安装cloudera server. 可能仍然会碰到一些依赖库的问题，但不影响

4. 执行`yum -y install cloudera-manager-agent`. 这个要求一定要解决依赖库的问题。

使用上诉方法搞定了CM Server，CM界面能访问，并搞定了NameNode和SecondaryNameNode两个节点的agent，并能启动Cloudera Manager Service进行监控。

在执行`yum -y install cloudera-manager-agent`时，可能会报如下错误：

```
# yum -y install cloudera-manager-agent
Loaded plugins: fastestmirror, refresh-packagekit
Repository updates is listed more than once in the configuration
http://mirrors.aliyun.com/centos/6/os/x86_64/repodata/repomd.xml: [Errno 14] PYCURL ERROR 6 - "Couldn't resolve host 'mirrors.aliyun.com'"
Trying other mirror.
http://mirrors.aliyuncs.com/centos/6/os/x86_64/repodata/repomd.xml: [Errno 14] PYCURL ERROR 6 - "Couldn't resolve host 'mirrors.aliyuncs.com'"
Trying other mirror.
Error: Cannot retrieve repository metadata (repomd.xml) for repository: base. Please verify its path and try again
```

需要编辑/etc/resolv.conf文件成这样：

```
# Generated by NetworkManager
nameserver 123.125.81.6
nameserver 114.114.114.114
```

然后执行`yum -y install cloudera-manager-agent`, 各种进度条之后看到：

```
Dependency Installed:
  MySQL-python.x86_64 0:1.2.3-0.3.c1.1.el6          mod_ssl.x86_64 1:2.2.15-53.el6.centos          openssl-devel.x86_64 0:1.0.1e-48.el6_8.1          python-psycopg2.x86_64 0:2.0.14-2.el6         

Updated:
  cloudera-manager-agent.x86_64 0:5.6.1-1.cm561.p0.3.el6                                                                                                                                            

Dependency Updated:
  cloudera-manager-daemons.x86_64 0:5.6.1-1.cm561.p0.3.el6     httpd.x86_64 0:2.2.15-53.el6.centos     httpd-devel.x86_64 0:2.2.15-53.el6.centos     httpd-tools.x86_64 0:2.2.15-53.el6.centos    
  openssl.x86_64 0:1.0.1e-48.el6_8.1                          

Complete!
```

执行`service cloudera-scm-agent start`启动agent.

随后，重新安装Oozie共享库，集群可以正常使用。测试了MR作业，均可成功。总算大功告成！

---

小结：

一个"小"问题，牵扯出了如上的一大堆，前前后后排查了4天，虽不是4天都在排查这个问题，但终究得以解决。完全没想到的问题总会出现，时间预估总是太乐观，解决问题的过程总是坎坷，解决问题后的愉悦难以言表，还有，客户的要求总是那么无理，可是谁让他是"上帝"呢。

还记得那天，白天干完别的活，拖着疲惫的身体回家，看到issue列表，想起来这个拖了几天还没解决而且没有头绪的问题，一直尝试弄到凌晨4点，才发现环境变量的问题，"兴奋"的差点没直接睡在电脑上。。。多么简单的解决办法，发现他却也不简单。