---
categories:
- 技术文章
date: 2018-02-13T10:08:23+08:00
description: "多作业输出到同一组的多个目录"
keywords:
- Spark, MultipleOutput, OutputCommitter
title: "多作业输出到同一组的多个目录的问题"
url: "/post/2018/02/13/multipleoutput"
---


## 场景1：一个作业输出到多个目录

### RDDMultipleTextOutputFormat的实现
在一个典型的MR或者Spark作业中，作业输出到HDFS时会是一个目录，目录下将会根据分区写出成多个文件，比如`${outputDir}/part-r-00000`。但是在一些场景下，我们希望能够在一个作业中，输出到多个目录中，变成多个数据集，后续的数据处理即可区分处理。

这种场景的解决办法MultipleOutputFormat，很久之前就已经有了，在几年前写MapReduce程序的时候就已经实用过，网上一搜也一大堆。在这里，也只简单记录一下在Spark中如何使用。

在Spark中，可以使用`saveToHadoopFile`这个算子实现将RDD写入到HDFS，RDD的每个分区将会写出成HDFS上的一个文件，比如`part-00000`. 这里相比MapReduce来说，命名上没有了中间的Task类型，及不区分m还是r。先看代码：

```
  /**
   * Output the RDD to any Hadoop-supported file system, using a Hadoop `OutputFormat` class
   * supporting the key and value types K and V in this RDD.
   */
  def saveAsHadoopFile(
      path: String,
      keyClass: Class[_],
      valueClass: Class[_],
      outputFormatClass: Class[_ <: OutputFormat[_, _]],
      conf: JobConf = new JobConf(self.context.hadoopConfiguration),
      codec: Option[Class[_ <: CompressionCodec]] = None): Unit = self.withScope {
    // Rename this as hadoopConf internally to avoid shadowing (see SPARK-2038).
    val hadoopConf = conf
    hadoopConf.setOutputKeyClass(keyClass)
    hadoopConf.setOutputValueClass(valueClass)
    // Doesn't work in Scala 2.9 due to what may be a generics bug
    // TODO: Should we uncomment this for Scala 2.10?
    // conf.setOutputFormat(outputFormatClass)
    hadoopConf.set("mapred.output.format.class", outputFormatClass.getName)
    for (c <- codec) {
      hadoopConf.setCompressMapOutput(true)
      hadoopConf.set("mapred.output.compress", "true")
      hadoopConf.setMapOutputCompressorClass(c)
      hadoopConf.set("mapred.output.compression.codec", c.getCanonicalName)
      hadoopConf.set("mapred.output.compression.type", CompressionType.BLOCK.toString)
    }

    // Use configured output committer if already set
    if (conf.getOutputCommitter == null) {
      hadoopConf.setOutputCommitter(classOf[FileOutputCommitter])
    }

    FileOutputFormat.setOutputPath(hadoopConf,
      SparkHadoopWriter.createPathFromString(path, hadoopConf))
    saveAsHadoopDataset(hadoopConf)
  }
```

代码中，其中都是一些常规操作，在这里注意以下两点：
1. 参数中，可以指定OutputFormatClass， 这样我们就可以指定自定义的MultipleOutputFormat了，接下来会说明
2. 注意代码中，当没有显示指定OutputCommitter的时候，会默认使用FileOutputCommitter，一般场景下已经能满足。

因此，需要先实现一个自定义的MultipleOutputFormat。在这里，我们假定spark处理时，产生了K/V. 希望能够按照K的内容，区分目录输出。

```
class RDDMultipleTextOutputFormat[K, V]() extends MultipleTextOutputFormat[K, V]() {
  override def generateActualKey(key: K, value: V): K = {
    NullWritable.get().asInstanceOf[K]
  }

  override def generateFileNameForKeyValue(key: K, value: V, name: String): String = {
    key.toString
  }
}
```

在代码中，Key已经在之前的业务逻辑中，按照目录和文件名进行了赋值，因此，重写的generateFileNameForKeyValue只需要返回key的值即可。在generateFileNameForKeyValue的参数列表中,name可以认为是类似于`part-00000`这样的字符串，在这里，因为key值中是包含了（子）路径和文件名的，比如`/key1/20180212/task-00000.csv`,因此就不再需要name了，这个逻辑应该在前面的逻辑中保障。注意在这里也还需要重写generateActualKey返回NullWritable实例，在MultipleTextOutputFormat中，是使用TextOutputFormat输出，key为NullWritable实例时将不会写出key和K/V之间的分隔符，并且，从业务逻辑上来说，写出到HDFS的时候在当前的逻辑下是不需要写出Key到文件的，Key的内容已经在文件路径中了。


MultipleOutputFormat的其他逻辑，可以细看代码，大体上就是根据文件名创建了多个RecoredWriter，保存在一个TreeMap中，每行记录输出时，将会找到对应的RecoredWriter进行输出。由于在MultipleTextOutputFormat中使用的是TextOutputFormat,因此，RecoredWriter事实上是LineRecoredWriter. 具体的在这里就不展开了。

举一个简单的例子说明一下输出的结构。假设输出时，根目录为`/data`, 根据业务需求，使用每行记录中的字段A的取值进行分目录输出，A的值域是省份代码，比如BJ, GD等。由于作业是每天运行一次，因此，也需要在省份目录下，按照日期创建子目录，真正的数据文件写在日期目录下，例如一个可能的文件路径为：`/data/GD/20180212/task-00000.csv`, 这样，在上面的RDDMultipleTextOutputFormat.generateFileNameForKeyValue中，key的值为`/GD/20180212/task-00000.csv`

### MultipleOutput后的文件权限问题

在上面的场景中，在输出到多个目录后，还隐藏着一个坑。我们知道，HDFS使用POSIX和ACL进行访问权限控制。对于ACL来说，default权限可以被子目录继承。

我们当前的目录结构是`/data/${省份代码}/${日期}/${文件名}`，数据是由集群ETL作业处理后写出的，也就是说`/data`目录及子目录、文件的所有者是`etl`账号, 并且, 集群默认的umask设置为了`007`。在集群上分配业务账号使用时，需要对不同的账号授权，比如账号`guangdong`只能访问`/data/GD/`目录下的子目录和文件，具有只读权限，但对`/data/BJ/`目录下的子目录和文件，是不可读的，相反，`beijing`账号只能访问`/data/BJ/`目录下的子目录和文件。

因此，我们可以分别对两个目录进行ACL配置，使用如下命令进行授权：

```
hadoop fs -setfacl -m -R default:user:guangdong:r-x /data/GD
hadoop fs -setfacl -m -R user:guangdong:r-x /data/GD
hadoop fs -setfacl -m -R default:user:beijing:r-x /data/BJ
hadoop fs -setfacl -m -R user:beijing:r-x /data/BJ
```

这样，预期能实现区分账号访问数据的需求。但实际上却碰到了问题。

由于已经执行了`setfacl`操作，已有的目录、子目录和文件的权限正确，比如`/data/GD/20180210`的ACL如下：

```
$ hadoop fs -getfacl /data/GD/20180210
# file: /data/GD/20180210
# owner: etl
# group: etl
user::rwx
user:guangdong:r-x
group::rwx
mask::rwx
other::---
default:user::rwx
default:user:guangdong:r-x
default:group::rwx
default:mask::rwx
default:other::---
```

但是之后产生的子目录如`/data/GD/20180211`，却没有继承ACL，导致访问时抛出如下错误：

```
Error: java.io.IOException: org.apache.hadoop.security.AccessControlException: Permission denied
```

查看ACL，也的确发现没有`guangdong`这个用户在ACL里。

后来发现，原来在文件路径`/data/GD/20180211/task-00000.csv`生成的时候，`/data`才是输出目录，而`/GD/20180211/task-00000.csv`是MultipleOutputFormat输出的时候定义的文件名。因此，新产生的文件的ACL集成自`/data`，而在`/data`的ACL中，并没有配置`guangdong`用户的default可读权限(在这里, `/data`目录的POSIX设置为755)。


但问题又来了，我们需要区分`/data/GD`和`/data/BJ`的授权，却又不得不在`/data`目录配置`guangdong`,`beijing`用户的default可读权限，这两者相互矛盾。

因此，我们只好按如下方式进行：


1. 对`/data`目录添加业务账号（guangdong,beijing等）的default可读权限：

    ```
    $ hadoop fs -setfacl -m default:user:guangdong:r-x /data
    $ hadoop fs -setfacl -m default:user:guangdong:r-x /data
    $ hadoop fs -getfacl /data
    # file: /data
    # owner: etl
    # group: etl
    user::rwx
    group::r-x
    mask::rwx
    other::r-x
    default:user::rwx
    default:user:guangdong:r-x
    default:user:beijing:r-x
    default:group::r-x
    default:mask::rwx
    default:other::r-x
    ```

2. 默认创建`/data`目录下的所有可能子目录，在这里，就是把所有省份代码都创建一遍，比如`/data/GD`, `/data/BJ`. 由于在`/data`目录上配置了`guangdong`,`beijing`用户的default可读权限，因此ACL权限会被继承：

    ```
    $ hadoop fs -getfacl /data/GD
    # file: /data/GD
    # owner: etl
    # group: etl
    user::rwx
    user:guangdong:r-x
    user:beijing:r-x
    group::rwx
    mask::rwx
    other::---
    default:user::rwx
    default:user:guangdong:r-x
    default:user:beijing:r-x
    default:group::rwx
    default:mask::rwx
    default:other::---
    ```

3. 去除与各目录不相关的授权，比如`/data/GD`, 应该只保留对`guangdong`用户的可读权限，去掉`beijing`用户的读权限。在这里default权限去掉不去掉都无所谓了，因为子目录实际仍是从`/data`目录继承权限的。

    ```
    $ hadoop fs -setfacl -x user:beijing:r-x /data/GD
    $ hadoop fs -setfacl -x user:guangdong:r-x /data/BJ
    $ hadoop fs -getfacl /data/GD
    # file: /data/GD
    # owner: etl
    # group: etl
    user::rwx
    user:guangdong:r-x
    group::rwx
    mask::rwx
    other::---
    default:user::rwx
    default:user:guangdong:r-x
    default:user:beijing:r-x
    default:group::rwx
    default:mask::rwx
    default:other::---
    ```

这样，虽然ETL产生的新的文件仍然从`/data`目录继承ACL权限，`beijing`,`guangdong`账号的可读权限都会被继承，但，在`/data`目录下，省份代码这一层做了限制，也达到了区分账号控制文件访问权限的需求。

## 场景2：多个作业输出到同一组目录

在上一个场景中，一个ETL作业，可使用MultipleOutputFormat根据数据内容，区分目录和文件输出，应该已经能够满足大部分的需求了。但，我们偏偏还碰到了另一个变态的需求：多个ETL作业输出到相同的根目录下。

这个需求大概是这样产生的：所有的数据产生后都送到了Kafka中的同一个topic，并且由一个ETL作业来处理数据，并使用MultipleOutputFormat写出到HDFS。但由于数据量比较大，一个ETL作业难以处理（在这里原因有几个，不一一列举了），常出现处理时间超过预期，或者直接挂掉。那么，一个简单的做法，就是将数据送到不同的topic，再由多个不同的ETL作业进行处理。实际情况比这个更加复杂些，但我们在这里做一个简化描述，并假定按照中国北部、南部来区分，并由两个ETL作业来处理数据。这样，BJ的数据将由`ETL_North`处理并写出，GD的数据将由`ELT_Sourth`处理并写出.

这样一看，似乎并没有任何问题，两个作业写出的目录并不冲突。但在作业跑起来后，却发现了问题：`_SUCCESS`文件或`_temporary`目录被删除导致作业失败。

原来，我们使用的基于spark的ETL作业，写HDFS的时候使用了OutputCommitter的机制，其实与MapReduce一样，是为了保证作业各个task都成功才算是最终成功，因此，在作业运行过程中，会在输出目录下创建`_temporary`目录存在task attempt的信息和数据，最终成功后再移动到最终的目录，并产生`_SUCCESS`文件。但，由于我们使用了MultipleOutputFormat，其输出目录为`/data`，因此，两个ETL作业，都在`/data`目录下创建`_temporary`并放置临时数据，当一个作业成功，另一个作业还未结束时，成功的ETL作业将会在将数据移动到最终目录后删除`_temporary`目录，导致了另一个作业的失败。

那么，如果我们能定制OutputCommitter，将`_SUCCESS`文件和`_temporary`目录重命名为不会冲突的名称，各作业之间不相互影响，则可解决问题。

另外，由于我们使用的是`saveToHadoopFile`算子，使用的是老的API，那么得使用一个wrapper封装一下。

1. 创建CustomerFileOutputCommitter(部分代码，其余代码与FileOutputCommitter一样)，将`PENDING_DIR_NAME`和`SUCCEEDED_FILE_NAME`变量改为不是final。注意这里继承的OutputCommitter是在`org.apache.hadoop.mapreduce`包下:

    ```
    public class SelfFileOutputCommitter extends OutputCommitter {
        private static final Log LOG = LogFactory.getLog(SelfFileOutputCommitter.class);

        /**
         * Name of directory where pending data is placed.  Data that has not been
         * committed yet.
         */
        public static String PENDING_DIR_NAME = "_temporary";
        /**
         * Temporary directory name
         *
         * The static variable to be compatible with M/R 1.x
         */
        public static String SUCCEEDED_FILE_NAME = "_SUCCESS";
    
        /* 此处省略大部分一样的代码 */
    }
    ```

2. 创建FileOutputCommitterWrapper，继承`org.apache.hadoop.mapred.OutputCommitter`，封装CustomerFileOutputCommitter(部分)：

    ```    
    package com.ywheel.etl.lib.output;
    
    import java.io.IOException;
    
    import org.apache.commons.logging.Log;
    import org.apache.commons.logging.LogFactory;
    import org.apache.hadoop.classification.InterfaceAudience;
    import org.apache.hadoop.classification.InterfaceAudience.Private;
    import org.apache.hadoop.classification.InterfaceStability;
    import org.apache.hadoop.fs.Path;
    import org.apache.hadoop.mapred.*;
    
    @InterfaceAudience.Public
    @InterfaceStability.Stable
    public class FileOutputCommitterWrapper extends OutputCommitter {
    
        public static final Log LOG = LogFactory.getLog("com.ywheel.etl.lib.output.FileOutputCommitterWrapper");
    
        /**
         * Temporary directory name
         */
        public static String TEMP_DIR_NAME =
                CustomerFileOutputCommitter.PENDING_DIR_NAME;
        public static final String SUCCEEDED_FILE_NAME =
                CustomerFileOutputCommitter.SUCCEEDED_FILE_NAME;
        static final String SUCCESSFUL_JOB_OUTPUT_DIR_MARKER =
                CustomerFileOutputCommitter.SUCCESSFUL_JOB_OUTPUT_DIR_MARKER;
    
        private static Path getOutputPath(JobContext context) {
            JobConf conf = context.getJobConf();
            return FileOutputFormat.getOutputPath(conf);
        }
    
        private static Path getOutputPath(TaskAttemptContext context) {
            JobConf conf = context.getJobConf();
            return FileOutputFormat.getOutputPath(conf);
        }
    
        private CustomerFileOutputCommitter wrapped = null;
    
        private CustomerFileOutputCommitter
        getWrapped(JobContext context) throws IOException {
            if(wrapped == null) {
                wrapped = new CustomerFileOutputCommitter(
                        getOutputPath(context), context);
            }
            return wrapped;
        }
    
        private CustomerFileOutputCommitter
        getWrapped(TaskAttemptContext context) throws IOException {
            if(wrapped == null) {
                wrapped = new CustomerFileOutputCommitter(
                        getOutputPath(context), context);
            }
            return wrapped;
        }
    
        /* 此处省略大部分返回wrapped的方法 */
    }
    
    ```

3. 在`saveToHadoopFile`之前，指定OutputCommitter（还记得上一章节看saveToHadoopFile算子代码的时候，里面有一行是设置默认的FileOutputCommitter吗）为FileOutputCommitterWrapper，并定义`_SUCCESS`文件和`_temporary`目录的值。

    ```
    val conf: JobConf = new JobConf(rdd.context.hadoopConfiguration)
    CustomerFileOutputCommitter.PENDING_DIR_NAME = etlJobName + "_temporary"
    CustomerFileOutputCommitter.SUCCEEDED_FILE_NAME = etlJobName + "_SUCCESS"
    conf.setOutputCommitter(classOf[FileOutputCommitterWrapper])
    // next: rdd.saveToHadoopFile(outPutPath + File.separator, classOf[String], classOf[String], classOf[RDDMultipleTextOutputFormat[String, String]],conf)
    ```

这样改造后，各作业运行就相互不干扰了。在实际场景中，还可能出现多个作业往同一个叶子目录(本文讲的是中间路径而不是叶子目录)写文件的情况，那这个时候，除了考虑上面的Committer相关问题外，还需要考虑最后的文件名也不能冲突。比如每个作业输出在叶子目录中的文件名就不能是`task-00000.csv`了，而应该也要加上与作业相关的信息，比如`etl_north_task_00000.csv`,`etl_sourth_task_00000.csv`, 这样即便最后的文件在一个目录下也不再冲突。

---

想要对hadoop核心代码做一点contribution难，不过，在本文章内相关代码的时候，发现了一处拼写错误，遂改之: https://issues.apache.org/jira/browse/MAPREDUCE-7051