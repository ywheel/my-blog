---
categories:
- 技术文章
date: 2015-02-14T16:30:53+08:00
description: "使用awk合并两个文件的交叉项"
keywords:
- awk
title: "合并两个文件的交叉项"
url: ""
---

题：
合并两个文件的交叉项。比如：

1. file1.txt

```
111111
222222
333
4444
55555
```

2. file2.txt

```
7777,abc,abcd
222222,adfghjk,sdfsdfs
1111,qwertyu
55555,zxcvbn,asdfgh
```

希望能够得到如下结果：

```
222222,adfghjk,sdfsdfs
55555,zxcvbn,asdfgh
```

解：

```awk
awk 'BEGIN{FS=","}{if(NF==1){a[$1]++;}else if(a[$1]){printf"%s\n",$0}}' file1.txt file2.txt > file3.txt
```

awk一个好处就是多长的句子都能写在一行里。。。