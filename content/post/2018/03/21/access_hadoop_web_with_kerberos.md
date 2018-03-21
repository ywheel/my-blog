---
categories:
- 技术文章
date: 2018-03-21T23:22:33+08:00
description: ""
keywords:
- kerberos,hadoop web
title: "Win下访问安全集群的Web界面"
url: "/post/2018/03/21/access_hadoop_web_with_kerberos"
---

本文将简单记录在windows环境下，安装kerberos、进行环境配置、认证后，成功访问安全的hadoop集群的web页面并验证访问权限。

---

### 1. Install and Setup MIT Kerberos

下载一个MIT的，64位的程序下载地址： http://web.mit.edu/kerberos/dist/kfw/4.1/kfw-4.1-amd64.msi

安装完成之后，需要配置环境变量，将`C:\Program Files\MIT\Kerberos\bin;`添加在Path的最前面（有些windows机器中Oracle JDK可能带了kinit，需要将刚安装的MIT的放在Path的前面，执行kinit时才是用到正确的）

添加新的环境变量：

- KRB5_CONFIG ： C:\ProgramData\MIT\Kerberos5\krb5.ini

PS: 有的资料说还需要添加 KRB5CCNAME 环境变量用于缓存票据，但在windows下会报无权限访问该目录的问题，实际验证时不需添加这个环境变量，使用默认的就好

修改`C:\ProgramData\MIT\Kerberos5\krb5.ini`内容如下：

```ini
[libdefaults]
  default_realm = YWHEEL.COM
  dns_lookup_realm = false
  dns_lookup_kdc = false
  rdns = false
  ticket_lifetime = 24h
  forwardable = yes
  udp_preference_limit = 0


[realms]
  YWHEEL.COM = {
    kdc = ipa.ywheel.com:88
    master_kdc = ipa.ywheel.com:88
    admin_server = ipa.ywheel.com:749
    default_domain = YWHEEL.COM
  }


[domain_realm]
  .YWHEEL.COM = YWHEEL.COM
  YWHEEL.COM = YWHEEL.COM
  .ywheel.com = YWHEEL.COM
  ywheel.com = YWHEEL.COM
```

修改hosts文件，添加如下内容(以实际情况为准)

```
192.168.1.11 nn1.ywheel.com
192.168.1.12 nn2.ywheel.com
192.168.1.13 cm.ywheel.com
192.168.1.14 services.ywheel.com
192.168.1.200 ipa.ywheel.com
```

更改完环境变量后重启系统。

### 2. Install Firefox

这里没啥，找到firefox最新版安装即可。

### 3. Enable MIT Kerberos on Firefox

打开firefox，输入`about:config`，进行如下设置：

- network.negotiate-auth.trusted-uris = .ywheel.com
- network.negotiate-auth.using-native-gsslib = false
- network.auth.use-sspi = false
- network.negotiate-auth.allow-non-fqdn = true

设置后关闭firefox，重启。

### 4. Get Kerberos Ticket using MIT Kerberos Utility

打开`cmd`， 执行`kinit`命令，如下：

```
C:\Users\User>kinit ywheel
Password for ywheel@YWHEEL.COM:

C:\Users\User>klist
Ticket cache: API:krb5cc
Default principal: ywheel@YWHEEL.COM

Valid starting     Expires            Service principal
12/14/17 21:14:57  12/15/17 21:14:54  krbtgt/YWHEEL.COM@YWHEEL.COM
```


### 5. Open NN, RM UIs using Firefox

如果使用chrome，或者没有执行kinit，直接访问http://nn2.ywheel.com:50070/ , 会返回401（Authentication required）或者403（ GSSException: Defective token detected (Mechanism level: GSSHeader did not find the right tag)）错误

使用Firefox， 打开http://nn2.ywheel.com:50070/explorer.html#/ 访问WebHDFS， 比如认证的是 `ywheel`， 那么尝试访问有权限的目录，比如`/user/ywheel/`，验证可以访问。

再访问`/hbase`目录，提示`Permission denied: user=ywheel, access=READ_EXECUTE, inode="/hbase":hbase:hbase:drwx------`

同样，访问YARN的8088端口，http://nn1.ywheel.com:8088/cluster/apps/RUNNING , 也可以看到右上角显示用户为`ywheel`.


---

【主要参考】：

1. https://www.cnblogs.com/kischn/p/7443343.html
2. https://community.hortonworks.com/articles/28537/user-authentication-from-windows-workstation-to-hd.html