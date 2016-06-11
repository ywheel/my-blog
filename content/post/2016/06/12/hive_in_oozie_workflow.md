---
categories:
- 技术文章
date: 2016-06-12T00:16:44+08:00
description: "hive aciton in oozie workflow"
keywords:
- hive, oozie
title: Hive In Oozie Workflow
url: ""
---

在公司搭建和维护大数据平台，并提供给其他数据分析人员使用，hive就是那些非程序员使用的最多（几乎是唯一）的一个服务。当然，在每天的数据处理中，我们为了简化编码工作量，以及使用到数据分析人员积累的成果，可以直接使用或简单修改他们提供的hql脚本进行数据处理，并且使用Oozie调度hive作业。

在此介绍一下Hive action的编写，也记录一下曾经在这方面踩到的坑。

## Hive Action
在Oozie的workflow配置中添加一个hive action非常简单。

Hive action运行一个Hive作业, Oozie workflow将等待Hive作业运行完成后再进入下一个action。 在hive action中，需要配置诸如job-tracker, name-node, hive scripts等参数，当然在Hive action中也能配置在启动hive作业之前创建或删除HDFS目录。

在Oozie workflow的hive action中，也可以支持hive脚本的参数变量，使用`${VARIABLES}`来表示。

以下是官网中对hive action的语法例子：

```xml
<workflow-app name="[WF-DEF-NAME]" xmlns="uri:oozie:workflow:0.1">
    ...
    <action name="[NODE-NAME]">
        <hive xmlns="uri:oozie:hive-action:0.2">
            <job-tracker>[JOB-TRACKER]</job-tracker>
            <name-node>[NAME-NODE]</name-node>
            <prepare>
               <delete path="[PATH]"/>
               ...
               <mkdir path="[PATH]"/>
               ...
            </prepare>
            <job-xml>[HIVE SETTINGS FILE]</job-xml>
            <configuration>
                <property>
                    <name>[PROPERTY-NAME]</name>
                    <value>[PROPERTY-VALUE]</value>
                </property>
                ...
            </configuration>
            <script>[HIVE-SCRIPT]</script>
            <param>[PARAM-VALUE]</param>
                ...
            <param>[PARAM-VALUE]</param>
            <file>[FILE-PATH]</file>
            ...
            <archive>[FILE-PATH]</archive>
            ...
        </hive>
        <ok to="[NODE-NAME]"/>
        <error to="[NODE-NAME]"/>
    </action>
    ...
</workflow-app>
```

介绍一下这个语法中有几个参数：

1. `prepare` 如果需要在hive作业之前创建或删除HDFS目录，则可以增加`prepare`参数，指定需要创建或删除的HDFS路径。
2. `job-xml` 指定hive-site.xml所在HDFS上的路径；如果是CDH搭建的集群，则可以在任何一台hive gateway机器上的`/etc/hive/conf`目录下找到该配置文件。如果不指定该文件路径，hive action就不work。
3. `configuration` 包含传递给hive作业的参数，可以没有这个配置项，这样就全部使用默认配置
4. `script` 指定hql脚本所在HDFS上的路径；这个参数是hive action必须的。这个hql脚本中，可以使用`${VARIABLES}`来表示参数，获取在hive action中定义的`param`参数配置
5. `param` 定义在hql脚本中所需要的变量值


如下是我在生产环境中使用hive action的一个样例：

```xml
    <action name="HiveAction">
        <hive xmlns="uri:oozie:hive-action:0.2">
            <job-tracker>${jobTracker}</job-tracker>
            <name-node>${nameNode}</name-node>
            <!-- Need to upload hive-site.xml file to HDFS from local disk (/etc/hive/conf) first
            -->
            <job-xml>${HDFS_PREFIX}/file/xml/hive-site.xml</job-xml>
            <!--
            TODO: Maybe we need to delete the old path here
            <prepare>
                <delete path="${jobOutput}"/>
            </prepare>
            -->
            <!--
            <configuration>
                <property>
                    <name>mapred.compress.map.output</name>
                    <value>true</value>
                </property>
            </configuration>
            -->
            <script>${HDFS_PREFIX}/file/hql/hive_query.hql</script>
            <param>inputLogDay=${inputLogDay}</param>
            <param>inputPath=${OUTPUT_DIR}</param>
            <param>hiveDBname=${hiveDBname}</param>
        </hive>
        <ok to="end"/>
        <error to="kill"/>
    </action>
```

## Output data exceeds its limit
在上面的样例中可以看到，oozie workflow中的hive action不关心hql文件中定义的hive查询逻辑，在oozie workflow中做到了尽量简单，而hive的逻辑正确性保障和作业执行成功的保障都需要hql本身来完成。

我就在生产环境就碰到了个诡异的问题： `org.apache.oozie.action.hadoop.LauncherException: Output data exceeds its limit [2048]`

查找了一下原因，Oozie默认最大输出的数据大小为2K，即2048B；而在hive action中，执行hql脚本时提交的MR作业的ID（比如job_1464936467641_1657）均会被记录下来并且返回给Oozie，如果在一个hql脚本中，hive查询语句过多将会导致Oozie收到的结果数据超过2k大小，于是就抛这个错误。解决办法, 添加如下配置到Oozie-site.xml中，重启Oozie服务生效：

```xml
<property>
    <name>oozie.action.max.output.data</name>
    <value>204800</value>
</property>
```

PS：如果是CDH搭建的集群，那么可以在 `集群->Oozie->配置->Oozie Server Default Group->高级->oozie-site.xml 的 Oozie Server 高级配置代码段（安全阀）`中添加上述配置。

PS: 尝试过在Hive action中的`configuration`参数中添加这样的配置，但经过测试发现并不work.

## OutOfMemoryError

当执行一个hql脚本时，脚本中包含多个查询语句（好吧，又是好几百个），其中每个语句都经过测试能够正常运行并成功结束，但是放在一起被Oozie调用后缺抛如下错误：

```
Launching Job 613 out of 857
Number of reduce tasks is set to 0 since there's no reduce operator
java.lang.OutOfMemoryError: Java heap space
    at org.apache.hadoop.hdfs.util.ByteArrayManager$NewByteArrayWithoutLimit.newByteArray(ByteArrayManager.java:308)
    at org.apache.hadoop.hdfs.DFSOutputStream.createPacket(DFSOutputStream.java:192)
    at org.apache.hadoop.hdfs.DFSOutputStream.writeChunk(DFSOutputStream.java:1883)
    at org.apache.hadoop.fs.FSOutputSummer.writeChecksumChunks(FSOutputSummer.java:206)
    at org.apache.hadoop.fs.FSOutputSummer.write1(FSOutputSummer.java:124)
    at org.apache.hadoop.fs.FSOutputSummer.write(FSOutputSummer.java:110)
    at org.apache.hadoop.fs.FSDataOutputStream$PositionCache.write(FSDataOutputStream.java:58)
    at java.io.DataOutputStream.write(DataOutputStream.java:107)
    at org.apache.hadoop.io.IOUtils.copyBytes(IOUtils.java:87)
    at org.apache.hadoop.io.IOUtils.copyBytes(IOUtils.java:59)
    at org.apache.hadoop.io.IOUtils.copyBytes(IOUtils.java:119)
    at org.apache.hadoop.fs.FileUtil.copy(FileUtil.java:366)
    at org.apache.hadoop.fs.FileUtil.copy(FileUtil.java:338)
    at org.apache.hadoop.fs.FileSystem.copyFromLocalFile(FileSystem.java:1905)
    at org.apache.hadoop.fs.FileSystem.copyFromLocalFile(FileSystem.java:1873)
    at org.apache.hadoop.fs.FileSystem.copyFromLocalFile(FileSystem.java:1838)
    at org.apache.hadoop.mapreduce.JobSubmitter.copyJar(JobSubmitter.java:375)
    at org.apache.hadoop.mapreduce.JobSubmitter.copyAndConfigureFiles(JobSubmitter.java:256)
    at org.apache.hadoop.mapreduce.JobSubmitter.copyAndConfigureFiles(JobSubmitter.java:390)
    at org.apache.hadoop.mapreduce.JobSubmitter.submitJobInternal(JobSubmitter.java:483)
    at org.apache.hadoop.mapreduce.Job$10.run(Job.java:1306)
    at org.apache.hadoop.mapreduce.Job$10.run(Job.java:1303)
    at java.security.AccessController.doPrivileged(Native Method)
    at javax.security.auth.Subject.doAs(Subject.java:415)
    at org.apache.hadoop.security.UserGroupInformation.doAs(UserGroupInformation.java:1671)
    at org.apache.hadoop.mapreduce.Job.submit(Job.java:1303)
    at org.apache.hadoop.mapred.JobClient$1.run(JobClient.java:564)
    at org.apache.hadoop.mapred.JobClient$1.run(JobClient.java:559)
    at java.security.AccessController.doPrivileged(Native Method)
    at javax.security.auth.Subject.doAs(Subject.java:415)
    at org.apache.hadoop.security.UserGroupInformation.doAs(UserGroupInformation.java:1671)
    at org.apache.hadoop.mapred.JobClient.submitJobInternal(JobClient.java:559)
FAILED: Execution Error, return code -101 from org.apache.hadoop.hive.ql.exec.mr.MapRedTask. Java heap space
MapReduce Jobs Launched: 
```

从上述日志分析，这个hql包含很多个job，在执行过程中失败（`Launching Job 613 out of 857`）. 直接解决这个问题的方式就是：加大内存。我们知道，Oozie实现hive action的方式为先启动一个launcher（一个只有Map的Job），即client，用于提交hive任务；实际上进行数据处理的job是hive提交的MR作业。在这个错误中，是launcher发生了`OutOfMemoryError`。

解决办法也很简单，在hive action的`configuration`中添加如下配置，增大launcher的内存：

```xml
<configuration>
    <property>
        <name>oozie.launcher.mapreduce.map.memory.mb</name>
        <value>4096</value>
    </property>
    <property>
        <name>oozie.launcher.mapreduce.map.java.opts</name>
        <value>-Xmx3400m</value>
    </property>
</configuration>
```

其实把这些参数的`oozie.launcher`前缀去掉就是Hadoop的参数配置，Oozie在提交Launcher作业时，会将这些参数传递给YARN。

当然，root cause还是hql脚本没有经过优化，一个脚本包含的查询太多。深入理解业务后，精简hive查询，优化hql脚本，合理设计Oozie workflow才是正确的解决方案。