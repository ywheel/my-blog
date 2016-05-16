---
categories:
- 技术文章
date: 2015-02-14T17:01:30+08:00
description: "从零开始学习jQuery (一) 开天辟地入门篇"
keywords:
- jQuery
title: 从零开始学习jQuery (一) 开天辟地入门篇
url: ""
---

```
节选转载自http://www.cnblogs.com/engine1984/archive/2012/02/28/2371105.html
子秋出品!博客园首发!
```

## 什么是jQuery
jQuery是一套JavaScript脚本库.  在我的博客中可以找到"Javascript轻量级脚本库"系列文章. Javascript脚本库类似于.NET的类库, 我们将一些工具方法或对象方法封装在类库中, 方便用户使用.

注意jQuery是脚本库, 而不是脚本框架. "库"不等于"框架", 比如"System程序集"是类库,而"ASP.NET MVC"是框架. jQuery并不能帮助我们解决脚本的引用管理和功能管理,这些都是脚本框架要做的事.

脚本库能够帮助我们完成编码逻辑,实现业务功能. 使用jQuery将极大的提高编写javascript代码的效率, 让写出来的代码更加优雅, 更加健壮. 同时网络上丰富的jQuery插件也让我们的工作变成了"有了jQuery,天天喝茶水"--因为我们已经站在巨人的肩膀上了.

创建一个ASP.NET MVC项目时, 会发现已经自动引入了jQuery类库. jQuery几乎是微软的御用脚本库了!完美的集成度和智能感知的支持,让.NET和jQuery天衣无缝结合在一起!所以用.NET就要选用jQuery而非Dojo,ExtJS等.

## jQuery有如下特点:

### 提供了强大的功能函数
使用这些功能函数, 能够帮助我们快速完成各种功能, 而且会让我们的代码异常简洁.

### 解决浏览器兼容性问题
javascript脚本在不同浏览器的兼容性一直是Web开发人员的噩梦,  常常一个页面在IE7,Firefox下运行正常, 在IE6下就出现莫名其妙的问题. 针对不同的浏览器编写不同的脚本是一件痛苦的事情. 有了jQuery我们将从这个噩梦中醒来, 比如在jQuery中的Event事件对象已经被格式化成所有浏览器通用的, 从前要根据event获取事件触发者, 在ie下是event.srcElements 而ff等标准浏览器下下是event.target. jQuery则通过统一event对象,让我们可以在所有浏览器中使用event.target获取事件对象.

### 实现丰富的UI
jQuery可以实现比如渐变弹出, 图层移动等动画效果, 让我们获得更好的用户体验. 单以渐变效果为例, 从前我自己写了一个可以兼容ie和ff的渐变动画, 使用大量javascript代码实现, 费心费力不说, 写完后没有太多帮助过一段时间就忘记了. 再开发类似的功能还要再次费心费力. 如今使用jQuery就可以帮助我们快速完成此类应用.

### 纠正错误的脚本知识
这一条是我提出的, 原因就是大部分开发人员对于javascript存在错误的认识. 比如在页面中编写加载时即执行的操作DOM的语句, 在HTML元素或者document对象上直接添加"onclick"属性,  不知道onclick其实是一个匿名函数等等.  拥有这些错误脚本知识的技术人员也能完成所有的开发工作, 但是这样的程序是不健壮的. 比如"在页面中编写加载时即执行的操作DOM的语句", 当页面代码很小用户加载很快时没有问题, 当页面加载稍慢时就会出现浏览器"终止操作"的错误.jQuery提供了很多简便的方法帮助我们解决这些问题, 一旦使用jQuery你就将纠正这些错误的知识--因为我们都是用标准的正确的jQuery脚本编写方法!

### 太多了! 等待我们一一去发现.

## Hello World jQuery
按照惯例, 我们来编写jQuery的Hello World程序, 来迈出使用jQuery的第一步.

在本文最后可以下本章的完整源代码.

### 下载jQuery类库

jQuery的项目下载放在了Google Code上, 下载地址:

http://code.google.com/p/jqueryjs/downloads/list

上面的地址是总下载列表, 里面有很多版本和类型的jQuery库, 主要分为如下几类:

min: 压缩后的jQuery类库,  在正式环境上使用.如:jquery-1.3.2.min.js

vsdoc: 在Visual Studio中需要引入此版本的jquery类库才能启用智能感知.如：jquery-1.3.2-vsdoc2.js

release包: 里面有没有压缩的jquery代码, 以及文档和示例程序. 如:jquery-1.3.2-release.zip

### 编写程序

创建一个HTML页面, 引入jQuery类库并且编写如下代码:

```html
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">  
  
<html xmlns="http://www.w3.org/1999/xhtml">  
<head>  
    <title>Hello World jQuery!</title>  
    <script type="text/javascript" src="scripts/jquery-1.3.2-vsdoc2.js"></script>  
</head>  
<body>  
    <div id="divMsg">Hello World!</div>  
    <input id="btnShow" type="button" value="显示" />  
    <input id="btnHide" type="button" value="隐藏" /><br />  
    <input id="btnChange" type="button" value="修改内容为 Hello World, too!" />  
    <script type="text/javascript" >  
        $("#btnShow").bind("click", function(event) { $("#divMsg").show(); });  
        $("#btnHide").bind("click", function(event) { $("#divMsg").hide(); });  
        $("#btnChange").bind("click", function(event) { $("#divMsg").html("Hello World, too!"); });        
    </script>  
</body>  
</html>  
```

效果如下:

![图1](http://o75oehjrs.bkt.clouddn.com/image/blog/%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%E5%AD%A6%E4%B9%A0jQuery%20%28%E4%B8%80%29%20%E5%BC%80%E5%A4%A9%E8%BE%9F%E5%9C%B0%E5%85%A5%E9%97%A8%E7%AF%87.png)

页面上有三个按钮, 分别用来控制Hello World的显示,隐藏和修改其内容.

此示例使用了:

(1) jQuery的Id选择器: $("#btnShow")

(2) 事件绑定函数 bind()

(3) 显示和隐藏函数. show()和hide()

(4) 修改元素内部html的函数html()