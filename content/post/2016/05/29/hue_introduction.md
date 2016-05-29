---
categories:
- 技术文章
date: 2016-05-29T21:31:44+08:00
description: "HUE Introduction and how to contribute"
keywords:
- hue,cloudera,hadoop
title: HUE Introduction and Contribution
url: ""
---

前段时间给同事们做了一次HUE入门使用的培训，就顺便整理出来。本篇文章先简单介绍HUE，再介绍如何给HUE贡献代码。

## HUE是什么
HUE=**Hadoop User Experience**

Hue是一个开源的Apache Hadoop UI系统，由Cloudera Desktop演化而来，最后Cloudera公司将其贡献给Apache基金会的Hadoop社区，它是基于Python Web框架Django实现的。

通过使用Hue我们可以在浏览器端的Web控制台上与Hadoop集群进行交互来分析处理数据，例如操作HDFS上的数据，运行MapReduce Job，执行Hive的SQL语句，浏览HBase数据库等等。

## HUE链接
- Site: http://gethue.com/
- Github: https://github.com/cloudera/hue
- Reviews: https://review.cloudera.org

## 核心功能
- SQL编辑器，支持Hive, Impala, MySQL, Oracle, PostgreSQL, SparkSQL, Solr SQL, Phoenix...
- 搜索引擎Solr的各种图表
- Spark和Hadoop的友好界面支持
- 支持调度系统Apache Oozie，可进行workflow的编辑、查看

HUE提供的这些功能相比Hadoop生态各组件提供的界面更加友好，但是一些需要debug的场景可能还是需要使用原生系统才能更加深入的找到错误的原因。

HUE中查看Oozie workflow时，也可以很方面的看到整个workflow的DAG图，不过在最新版本中已经将DAG图去掉了，只能看到workflow中的action列表和他们之间的跳转关系，想要看DAG图的仍然可以使用oozie原生的界面系统查看。

### HUE登录
如果自己搭建了HUE，则可以使用管理员账户创建一个新的用户，然后使用新的用户进行登录，见下图：

![HUE登录图](http://o75oehjrs.bkt.clouddn.com/image/blog/HUE%E7%99%BB%E5%BD%95.png?watermark/2/text/YmxvZy55d2hlZWwuY24=/font/5a6L5L2T/fontsize/500/fill/Izk3QjhGMw==/dissolve/100/gravity/SouthEast/dx/10/dy/10)

使用[HUE官网](http://gethue.com/)上的live demo可以尝鲜。如果大家自己没有搭建大数据平台，没有安装HUE的话，可以先在该demo上尝试。点击[Play with the live Demo now!](http://demo.gethue.com/),将会进入HUE的"我的文档"：

![HUE Demo图](http://o75oehjrs.bkt.clouddn.com/image/blog/HUE%20Demo.png?watermark/2/text/YmxvZy55d2hlZWwuY24=/font/5a6L5L2T/fontsize/500/fill/Izk3QjhGMw==/dissolve/100/gravity/SouthEast/dx/10/dy/10)

### HDFS文件浏览
HUE可以很方面的浏览HDFS中的目录和文件，并且进行文件和目录的创建、复制、删除、下载以及修改权限等操作。

HDFS实现了一个和POSIX系统类似的文件和目录的权限模型。每个文件和目录有一个所有者（owner）和一个组（group）。文件或目录对其所有者、同组的其他用户以及所有其他用户分别有着不同的权限。**但，用户身份机制对HDFS本身来说只是外部特性。HDFS并不提供创建用户身份、创建组或处理用户凭证等功能。** 使用HUE访问HDFS时，HDFS简单的将HUE上的用户名和组的名称进行权限的校验。

在Live Demo中,点击"文件浏览器", 进入HDFS的家目录：

![HUE HDFS图](http://o75oehjrs.bkt.clouddn.com/image/blog/HUE%20File%20Browser.png?watermark/2/text/YmxvZy55d2hlZWwuY24=/font/5a6L5L2T/fontsize/500/fill/Izk3QjhGMw==/dissolve/100/gravity/SouthEast/dx/10/dy/10)

**PS:** Live Demo中禁了文件上传功能。

### 作业浏览

点击Job Browser，可以查看作业列表，并且可以通过点击右上角的"成功","正在运行","失败","停止"来筛选不同状态的作业：

![HUE Job Browser](http://o75oehjrs.bkt.clouddn.com/image/blog/HUE%20Job%20Browser.png?watermark/2/text/YmxvZy55d2hlZWwuY24=/font/5a6L5L2T/fontsize/500/fill/Izk3QjhGMw==/dissolve/100/gravity/SouthEast/dx/10/dy/10)

我们在实际工作中发现，当集群(CDH5.2) 配置了HA后，当active的ResourceManager自动切换后(比如NN1上的ResourceManager是active，而NN2是standby，当NN1出现故障， NN2上的ResourceManager转变为active状态)，HUE的job browser将不能够正确显示。只有当修复故障后，将NN1上的ResourceManager重新变成active状态，HUE的job browser才能正常工作。不知道这个问题在后续版本是否已经得到修复。

### Hive查询
HUE的beeswax app提供友好方便的Hive查询功能，能够选择不同的Hive数据库，编写HQL语句，提交查询任务，并且能够在界面下方看到查询作业运行的日志。在得到结果后，还提供进行简单的图表分析能力。

![HUE Hive查询](http://o75oehjrs.bkt.clouddn.com/image/blog/HUE%20Hive.png?watermark/2/text/YmxvZy55d2hlZWwuY24=/font/5a6L5L2T/fontsize/500/fill/Izk3QjhGMw==/dissolve/100/gravity/SouthEast/dx/10/dy/10)

点击"Data Browsers"->"Metastore表"，还可以看到Hive中的数据库，数据库中的表以及各个表的元数据等信息。

![HUE Hive MetaStore](http://o75oehjrs.bkt.clouddn.com/image/blog/HUE%20Hive%20MetaStore.png?watermark/2/text/YmxvZy55d2hlZWwuY24=/font/5a6L5L2T/fontsize/500/fill/Izk3QjhGMw==/dissolve/100/gravity/SouthEast/dx/10/dy/10)

### Oozie Workflow编辑
HUE也提供了很好的Oozie的集成，能够在HUE上创建和编辑Bundles, Coordinator, Workflow. Oozie的介绍可以去[官网](https://oozie.apache.org/)查看。下图为在HUE上创建一个新的workflow，在该界面上，可以直接拖动不同的组件，变成DAG中的节点，并且设置各个action的流转逻辑。

![HUE WF Editor](http://o75oehjrs.bkt.clouddn.com/image/blog/HUE%20Workflow%20Editor.png?watermark/2/text/YmxvZy55d2hlZWwuY24=/font/5a6L5L2T/fontsize/500/fill/Izk3QjhGMw==/dissolve/100/gravity/SouthEast/dx/10/dy/10)

当然Oozie也可以通过命令行的方式提交B,C,W. 不过是使用HUE创建的workflow，或者是通过命令行提交的workflow，都可以在HUE上查看运行的状况：

![HUE WF Browser](http://o75oehjrs.bkt.clouddn.com/image/blog/HUE%20Workflow%20Browser.png?watermark/2/text/YmxvZy55d2hlZWwuY24=/font/5a6L5L2T/fontsize/500/fill/Izk3QjhGMw==/dissolve/100/gravity/SouthEast/dx/10/dy/10)

只是通过命令行提交的workflow就不可以在HUE上进行编辑了。使用配置文件、命令行提交的方式能够保证在生产环境上运行的和在测试环境上运行的版本一致，而使用HUE界面编辑的方式虽然方便，但也可能会带来人工操作在生产环境中失误的风险，有利也有弊吧。


## Contribution
我在给同事准备培训材料的时候，到HUE的github上去查找资料。在看到HUE的主要功能时，github上的原文是这样的：

![HUE Features old](http://o75oehjrs.bkt.clouddn.com/image/blog/HUE%20Features%20old.png?watermark/2/text/YmxvZy55d2hlZWwuY24=/font/5a6L5L2T/fontsize/500/fill/Izk3QjhGMw==/dissolve/100/gravity/SouthEast/dx/10/dy/10)

恰好我司主要使用的数据库是PostgreSQL，看到PostGresl感觉怪怪的，于是Google了一把，PostgreSQL有两个名字：PostgreSQL和Postgres，目前[官方网站](https://www.postgresql.org/)上的名字仍然是PostgreSQL. 不管PostGresl是否有什么典故，但是PostgreSQL一定是对的。因此，我去查了下如何给HUE提交代码修改。在Github上能找到wiki: [Contribute to HUE](https://github.com/cloudera/hue/wiki/Contribute-to-HUE), HUE有自己的JIRA和Review Board, 但也说了`The Hue project gladly welcomes any patches or pull requests!`

于是我在github上给HUE发了一个[Issue](https://github.com/cloudera/hue/issues/371)和一个[Pull Request](https://github.com/cloudera/hue/pull/372)。几天后Pull Request被接收，merge到了master分支上，可以看到这个[Commit](https://github.com/cloudera/hue/commit/61e80b3cd2820c68f2103e8cef34d50734f02c09)。

在这里记录一下更新的步骤：
1. Fork HUE的工程，比如 [ywheel/hue](https://github.com/ywheel/hue)
2. 创建一个新的分支，不要使用master分支提交修改。比如我创建了[fix-postgresql-spelling](https://github.com/ywheel/hue/tree/fix-postgresql-spelling)分支。
3. 将代码pull下来，修改后commit，提交到[fix-postgresql-spelling](https://github.com/ywheel/hue/tree/fix-postgresql-spelling)分支。
4. 创建issue。当HUE的工程上创建[issue](https://github.com/cloudera/hue/issues/371), 描述清楚问题，提交。
5. 点击'Pull Request', 选择目的工程和分支，比如cloudera/hue的master分支。填写comment, 说明已创建的issue, create pull request.

接下来就是等了，等该提交被review, 被merge到master分支, 等你自己的名字出现在[Contributors](https://github.com/cloudera/hue/graphs/contributors)里面, **then everything DONE!**

---

ps: 虽然改了个单词拼写就出来说简直是丢人，不过算是一个good start, 希望能在不久的将来真的能给开源项目（特别是流行的大数据生态中的开源项目）贡献代码，加油!