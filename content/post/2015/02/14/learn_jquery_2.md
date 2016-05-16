---
categories:
- 技术文章
date: 2015-02-14T17:31:42+08:00
description: "从零开始学习jQuery (二) 万能的选择器"
keywords:
- jQuery
title: 从零开始学习jQuery (二) 万能的选择器
url: ""
---

```
节选转载自 http://www.cnblogs.com/engine1984/archive/2012/02/28/2371214.html
秋出品!博客园首发! 
```

### Dom对象和jQuery包装集
无论是在写程序还是看API文档,  我们要时刻注意区分Dom对象和jQuery包装集.

1. Dom对象

在传统的JavaScript开发中,我们都是首先获取Dom对象,比如:

```javascript
var div = document.getElementById("testDiv");  
var divs = document.getElementsByTagName("div");
```

我们经常使用 document.getElementById 方法根据id获取单个Dom对象, 或者使用 document.getElementsByTagName 方法根据HTML标签名称获取Dom对象集合.

另外在事件函数中, 可以通过在方法函数中使用this引用事件触发对象(但是在多播事件函数中IE6存在问题), 或者使用event对象的target(FF)或srcElement(iIE6)获取到引发事件的Dom对象.

注意我们这里获取到的都是Dom对象, Dom对象也有不同的类型比如input, div, span等.  Dom对象只有有限的属性和方法:

![图1](http://o75oehjrs.bkt.clouddn.com/image/blog/%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%E5%AD%A6%E4%B9%A0jQuery%20%28%E4%BA%8C%29%20%E4%B8%87%E8%83%BD%E7%9A%84%E9%80%89%E6%8B%A9%E5%99%A81.png)

 
2. jQuery包装集

jQuery包装集可以说是Dom对象的扩充.在jQuery的世界中将所有的对象, 无论是一个还是一组, 都封装成一个jQuery包装集,比如获取包含一个元素的jQuery包装集:

```javascript
var jQueryObject = $("#testDiv");  
```

jQuery包装集都是作为一个对象一起调用的. jQuery包装集拥有丰富的属性和方法, 这些都是jQuery特有的:

![图2](http://o75oehjrs.bkt.clouddn.com/image/blog/%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%E5%AD%A6%E4%B9%A0jQuery%20%28%E4%BA%8C%29%20%E4%B8%87%E8%83%BD%E7%9A%84%E9%80%89%E6%8B%A9%E5%99%A82.png)

3. Dom对象与jQuery对象的转换

(1) Dom转jQuery包装集

如果要使用jQuery提供的函数,  就要首先构造jQuery包装集.  我们可以使用本文即将介绍的jQuery选择器直接构造jQuery包装集,比如: `$("#testDiv");`

上面语句构造的包装集只含有一个id是testDiv的元素.

或者我们已经获取了一个Dom元素,比如:

```javascript 
var div = document.getElementById("testDiv");  
```

上面的代码中div是一个Dom元素, 我们可以将Dom元素转换成jQuery包装集:

```javascript
var domToJQueryObject = $(div);  
```

小窍门:因为有了智能感知, 所以我们可以通过智能感知的方法列表来判断一个对象啊是Dom对象还是jQuery包装集.

(2) jQuery包装集转Dom对象

jQuery包装集是一个集合, 所以我们可以通过索引器访问其中的某一个元素:

```javascript
var domObject = $("#testDiv")[0];  
```

注意, 通过索引器返回的不再是jQuery包装集, 而是一个Dom对象!

jQuery包装集的某些遍历方法,比如each()中, 可以传递遍历函数, 在遍历函数中的this也是Dom元素,比如:

```javascript
$("#testDiv").each(function() { alert(this) })  
```

如果我们要使用jQuery的方法操作Dom对象,怎么办? 用上面介绍过的转换方法即可:

```javascript
$("#testDiv").each(function() { $(this).html("修改内容") })  
```

小结: 先让大家明确Dom对象和jQuery包装集的概念, 将极大的加快我们的学习速度. 我在学习jQuery的过程中就花了很长时间没有领悟到两者的具体差异, 因为书上并没有专门讲解两者的区别, 所以经常被"this指针为何不能调用jQuery方法"等问题迷惑.  直到某一天豁然开朗, 发现只要能够区分这两者, 就能够在写程序时变得清清楚楚.

### 什么是jQuery选择器

在Dom编程中我们只能使用有限的函数根据id或者TagName获取Dom对象.

在jQuery中则完全不同,jQuery提供了异常强大的选择器用来帮助我们获取页面上的对象, 并且将对象以jQuery包装集的形式返回.

首先来看看什么是选择器:

```javascript
//根据ID获取jQuery包装集  
var jQueryObject = $("#testDiv");  
```

上例中使用了ID选择器, 选取id为testDiv的Dom对象并将它放入jQuery包装集, 最后以jQuery包装集的形式返回.

"$"符号在jQuery中代表对jQuery对象的引用, "jQuery"是核心对象, 其中包含下列方法:

`jQuery( expression, context )` Returns: jQuery

这个函数接收一个CSS选择器的字符串，然后用这个字符串去匹配一组元素。

This function accepts a string containing a CSS selector which is then used to match a set of elements.

`jQuery( html, ownerDocument )` Returns: jQuery

根据HTML原始字符串动态创建Dom元素.

Create DOM elements on-the-fly from the provided String of raw HTML.

`jQuery( elements )` Returns: jQuery

将一个或多个Dom对象封装jQuery函数功能(即封装为jQuery包装集)

Wrap jQuery functionality around a single or multiple DOM Element(s).

`jQuery( callback )` Returns: jQuery

$(document).ready()的简写方式

A shorthand for `$(document).ready()`.

上面摘选自jQuery官方手册.Returns的类型为jQuery即表示返回的是jQuery包装集.其中第一个方法有些问题, 官方接口写的是CSS选择器, 但是实际上这个方法不仅仅支持CSS选择器, 而是所有jQuery支持的选择器, 有些甚至是jQuery自定义的选择器(在CSS标准中不存在的选择器). 为了能让大家理解的更清楚,  我将方法修改如下:

`jQuery( selector, context )` Returns: jQuery 包装集

根据选择器选取匹配的对象, 以jQuery包装集的形式返回. context可以是Dom对象集合或jQuery包装集, 传入则表示要从context中选择匹配的对象, 不传入则表示范围为文档对象(即页面全部对象).

上面这个方法就是我们选择器使用的核心方法.可以用"$"代替jQuery让语法更简介, 比如下面两句话的效果相同:

```javascript
//根据ID获取jQuery包装集  
 var jQueryObject = $("#testDiv");  
  
//$是jQuery对象的引用:  
var jQueryObject = jQuery("#testDiv");  
```

接下来让我们系统的学习jQuery选择器.
 

### jQuery选择器全解
通俗的讲, Selector选择器就是"一个表示特殊语意的字符串". 只要把选择器字符串传入上面的方法中就能够选择不同的Dom对象并且以jQuery包装集的形式返回.

但是如何将jQuery选择器分类让我犯难. 因为书上的分类和jQuery官方的分类截然不同. 最后我决定以实用为主, 暂时不去了解CSS3选择器标准, 而按照jQuery官方的分类进行讲解.

jQuery的选择器支持CSS3选择器标准. 下面是W3C最新的CSS3选择器标准:

http://www.w3.org/TR/css3-selectors/

标准中的选择器都可以在jQuery中使用.

jQuery选择器按照功能主要分为"选择"和"过滤". 并且是配合使用的. 可以同时使用组合成一个选择器字符串. 主要的区别是"过滤"作用的选择器是指定条件从前面匹配的内容中筛选, "过滤"选择器也可以单独使用, 表示从全部"*"中筛选. 比如:

`$(":[title]")`

等同于:

`$("*:[title]")`

而"选择"功能的选择器则不会有默认的范围, 因为作用是"选择"而不是"过滤".

下面的选择器分类中,  带有"过滤器"的分类表示是"过滤"选择器,  否则就是"选择"功能的选择器.

jQuery选择器分为如下几类:

[说明] 

1. 点击"名称"会跳转到此方法的jQuery官方说明文档. 
2. 可以在下节中的jQuery选择器实验室测试各种选择器

#### 基础选择器 Basics
|名称|说明|举例|
|----|----|----|
|#id|根据元素Id选择|$("divId") 选择ID为divId的元素|
|element|根据元素的名称选择|$("a")选择所有`<a>`元素|
|.class|根据元素的css类选择|$(".bgRed") 选择所用CSS类为bgRed的元素|
|*|选择所有元素|$("*")选择页面所有元素|
|selector1,selector2,selectorN|可以将几个选择器用","分隔开然后再拼成一个选择器字符串.会同时选中这几个选择器匹配的内容.|$("#divId, a, .bgRed")|
 

[学习建议]: 
大家暂时记住基础选择器即可, 可以直接跳到下一节"jQuery选择器实验室"进行动手练习, 以后再回来慢慢学习全部的选择器, 或者用到的时候再回来查询.

#### 层次选择器 Hierarchy
|名称|说明|举例|
|----|----|----|
|ancestor descendant|使用"form input"的形式选中form中的所有input元素.即ancestor(祖先)为from, descendant(子孙)为input.|$(".bgRed div") 选择CSS类为bgRed的元素中的所有`<div>`元素.|
|parent > child|选择parent的直接子节点child.  child必须包含在parent中并且父类是parent元素.|$(".myList>li") 选择CSS类为myList元素中的直接子节点`<li>`对象.|
|prev + next|prev和next是两个同级别的元素. 选中在prev元素后面的next元素.|$("#hibiscus+img")选在id为hibiscus元素后面的img对象.|
|prev ~ siblings|选择prev后面的根据siblings过滤的元素<br>注:siblings是过滤器|$("#someDiv~[title]")选择id为someDiv的对象后面所有带有title属性的元素|
 

#### 基本过滤器 Basic Filters
|名称|说明|举例|
|----|----|----|
|:first|匹配找到的第一个元素|查找表格的第一行:$("tr:first")
|:last|匹配找到的最后一个元素|查找表格的最后一行:$("tr:last")
|:not(selector)|去除所有与给定选择器匹配的元素|查找所有未选中的 input 元素: $("input:not(:checked)")
|:even|匹配所有索引值为偶数的元素，从 0 开始计数|查找表格的1、3、5...行:$("tr:even")
|:odd|匹配所有索引值为奇数的元素，从 0 开始计数|查找表格的2、4、6行:$("tr:odd")
|:eq(index)|匹配一个给定索引值的元素         注:index从 0 开始计数|查找第二行:$("tr:eq(1)")
|:gt(index)|匹配所有大于给定索引值的元素         注:index从 0 开始计数|查找第二第三行，即索引值是1和2，也就是比0大:$("tr:gt(0)")
|:lt(index)|选择结果集中索引小于 N 的 elements         注:index从 0 开始计数|查找第一第二行，即索引值是0和1，也就是比2小:$("tr:lt(2)")
|:header|选择所有h1,h2,h3一类的header标签.|给页面内所有标题加上背景色: $(":header").css("background", |"#EEE");
|:animated|匹配所有正在执行动画效果的元素|只有对不在执行动画效果的元素执行一个动画特效:        $("#run").click(function(){$("div:not(:animated)").animate({ left: "+=20" }, 1000);});


#### 内容过滤器 Content Filters
|名称|说明|举例|
|----|----|----|
|:contains(text)|匹配包含给定文本的元素|查找所有包含 "John" 的 div 元素:$("div:contains('John')")
|:empty|匹配所有不包含子元素或者文本的空元素|查找所有不包含子元素或者文本的空元素:$("td:empty")
|:has(selector)|匹配含有选择器所匹配的元素的元素|给所有包含 p 元素的 div 元素添加一个 text 类: $("div:has(p)")|.addClass("test");
|:parent|匹配含有子元素或者文本的元素|查找所有含有子元素或者文本的 td 元素:$("td:parent")
 

#### 可见性过滤器  Visibility Filters
|名称|说明|举例|
|----|----|----|
|:hidden|匹配所有的不可见元素<br>注:在1.3.2版本中, hidden匹配自身或者父类在文档中不占用空间的元素.如果使用CSS visibility属性让其不显示但是占位,则不输入hidden.|查找所有不可见的 tr 元素:$("tr:hidden")
|:visible|匹配所有的可见元素|查找所有可见的 tr 元素:$("tr:visible")

#### 属性过滤器 Attribute Filters
|名称|说明|举例|
|----|----|----|
[attribute]|匹配包含给定属性的元素|查找所有含有 id 属性的 div 元素:         $("div[id]")
[attribute=value]|匹配给定的属性是某个特定值的元素|查找所有 name 属性是 newsletter 的 input 元素:         $("input[name='newsletter']").attr("checked", true);
[attribute!=value]|匹配给定的属性是不包含某个特定值的元素|查找所有 name 属性不是 newsletter 的 input 元素:         $("input[name!='newsletter']").attr("checked", true);
[attribute^=value]|匹配给定的属性是以某些值开始的元素|$("input[name^='news']")
[attribute$=value]|匹配给定的属性是以某些值结尾的元素|查找所有 name 以 'letter' 结尾的 input 元素:         $("input[name$='letter']")
[attribute*=value]|匹配给定的属性是以包含某些值的元素|查找所有 name 包含 'man' 的 input 元素:           $("input[name*='man']")
|[attributeFilter1][attributeFilter2][attributeFilterN]|复合属性选择器，需要同时满足多个条件时使用。|找到所有含有 id 属性，并且它的 name 属性是以 man 结尾的:         $("input[id][name$='man']")

#### 子元素过滤器 Child Filters
|名称|说明|举例|
|----|----|----|
:nth-child(index/even/odd/equation)|匹配其父元素下的第N个子或奇偶元素<br>':eq(index)' 只匹配一个元素，而这个将为每一个父元素匹配子元素。:nth-child从1开始的，而:eq()是从0算起的！<br>可以使用:           nth-child(even)           :nth-child(odd)           :nth-child(3n)           :nth-child(2)           :nth-child(3n+1)           :nth-child(3n+2)|在每个 ul 查找第 2 个li:         $("ul li:nth-child(2)")
|:first-child|匹配第一个子元素<br>':first' 只匹配一个元素，而此选择符将为每个父元素匹配一个子元素|在每个 ul 中查找第一个 li:         $("ul li:first-child")
|:last-child|匹配最后一个子元素<br>':last'只匹配一个元素，而此选择符将为每个父元素匹配一个子元素|在每个 ul 中查找最后一个 li:         $("ul li:last-child")
|:only-child|如果某个元素是父元素中唯一的子元素，那将会被匹配<br>如果父元素中含有其他元素，那将不会被匹配。|在 ul 中查找是唯一子元素的 li:         $("ul li:only-child")


#### 表单选择器 Forms  

|名称|说明|举例|
|----|----|----|
:input|匹配所有 input, textarea, select 和 button 元素|查找所有的input元素:         $(":input")
:text|匹配所有的文本框|查找所有文本框:         $(":text")
:password|匹配所有密码框|查找所有密码框:         $(":password")
:radio|匹配所有单选按钮|查找所有单选按钮
:checkbox|匹配所有复选框|查找所有复选框:         $(":checkbox")
:submit|匹配所有提交按钮|查找所有提交按钮:         $(":submit")
:image|匹配所有图像域|匹配所有图像域:         $(":image")
:reset|匹配所有重置按钮|查找所有重置按钮:         $(":reset")
:button|匹配所有按钮|查找所有按钮:         $(":button")
:file|匹配所有文件域|查找所有文件域:         $(":file")


#### 表单过滤器 Form Filters
|名称|说明|举例|
|----|----|----|
|:enabled|匹配所有可用元素|查找所有可用的input元素:         $("input:enabled")
|:disabled|匹配所有不可用元素|查找所有不可用的input元素:         $("input:disabled")
|:checked|匹配所有选中的被选中元素(复选框、单选框等，不包括select中的option)|查找所有选中的复选框元素:         $("input:checked")
|:selected|匹配所有选中的option元素|查找所有选中的选项元素:         $("select option:selected")
 

#### jQuery选择器实验室
jQuery选择器实验室使用的是"jQuery实战"一书中的代码, 感觉对于学习选择器很有帮助.

我们的实验对象是一个拥有很多元素的页面:

![图3](http://o75oehjrs.bkt.clouddn.com/image/blog/%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%E5%AD%A6%E4%B9%A0jQuery%20%28%E4%BA%8C%29%20%E4%B8%87%E8%83%BD%E7%9A%84%E9%80%89%E6%8B%A9%E5%99%A83.png)

在实验室页面的"Selector"输入框中输入jQuery选择器表达式,  所有匹配表达式的元素会显示红框:

![图4](http://o75oehjrs.bkt.clouddn.com/image/blog/%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%E5%AD%A6%E4%B9%A0jQuery%20%28%E4%BA%8C%29%20%E4%B8%87%E8%83%BD%E7%9A%84%E9%80%89%E6%8B%A9%E5%99%A84.png)

如上图所示,  在输入".myList"后点击"Apply", 下面的输出框会显示运行结果, 右侧会将选中的元素用红框显示.

代码在本章最后可以下载. 

#### API文档
jQuery官方API: http://docs.jquery.com/

#### 中文在线API
http://jquery.org.cn/visual/cn/index.xml

#### 中文jQuery手册下载
http://files.cnblogs.com/zhangziqiu/jquery_api.rar