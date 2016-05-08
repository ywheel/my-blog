---
categories:
- 读书笔记
date: 2013-09-01T22:32:39+08:00
description: "计算广告学笔记"
keywords:
- 计算广告学
title: 计算广告学笔记2-常用广告系统开源工具
url: ""
---

```
注：内容来自师徒网， 计算广告学 刘鹏
```

## 使用开源工具搭建广告系统
Hadoop：大数据处理的平台
- HDFS
- MapReduce

### 离线处理工具
HBase， Hadoop上的列存储数据库。类似的有：BigTable； HypeTable（C语言写的，效率相对高一点）；Cassandra(Facebook, 不过好像他自己也不用了)； mahout（数据挖掘、机器学习算法的MR实现工具）；Elephant-bird: 配合Pig使用；
两个脚本语言： Pig/Hive， 使用MR实现类SQL的查询；

### 在线工具
ZooKeeper: 分布式环境下解决一致性问题； Chubby：Google。 Zookeeper可以认为是Chubby的简化版本；
Avro；Thrift（Facebook）：解决分布式环境里跨语言通信的工具包；
S4; Storm(twitter) 满足快速计算任务如快速计算粉丝数等；
Chuhwa；Scribe（facebook）： Data highway；

### Thrift
- 跨语言服务快速搭建（C++, Java, Python, ruby, c#）
- 用struct定于语言无关的通信数据结构；

```json
struct KV
{1:optional i32 key=10; 2:optional string value="x"}
```

- 用service定义RPC服务接口：

```
service KVCache{void set(1:i32 key, 2:string value)}; string get(1:i32 key); void delete(1:i32 key);}
```

- 将上述声明放在IDL文件（比如service.thrift）中，用thrift -r -gen cpp service.thrift 生成服务框架代码
- 能实现结构体和接口的Backward compatible   （程序的后相兼容，新版本必须兼容老版本的数据接口）
- 类似工具：Hadoop子项目Avro, Google开发的ProtoBuf