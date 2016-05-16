---
categories:
- 技术文章
date: 2015-02-14T18:01:45+08:00
description: "从零开始学习jQuery (四) 使用jQuery操作元素的属性与样式"
keywords:
- jQuery
title: 从零开始学习jQuery (四) 使用jQuery操作元素的属性与样式
url: ""
---

```
节选转载自http://www.cnblogs.com/engine1984/archive/2012/02/28/2371488.html
```

### 区分DOM属性和元素属性
一个img标签:

```html
<img src="images/image.1.jpg" id="hibiscus" alt="Hibiscus" class="classA" />
```

通常开发人员习惯将id, src, alt等叫做这个元素的"属性". 我将其称为"元素属性". 但是在解析成DOM对象时, 实际浏览器最后会将标签元素解析成"DOM对象", 并且将元素的"元素属性"存储为"DOM属性". 两者是有区别的.   虽然我们设置了元素的src是相对路径:images/image.1.jpg   但是在"DOM属性"中都会转换成绝对路径:http://localhost/images/image.1.jpg.

甚至有些"元素属性"和"DOM属性"的名称都不一样,比如上面的元素属性class, 转换为DOM属性后对应className.

牢记, 在JavaScript中我们可以直接获取或设置"DOM属性":

```javascript
<script type="text/javascript">  
    $(function() {  
        var img1 = document.getElementById("hibiscus");  
        alert(img1.alt);  
        img1.alt = "Change the alt element attribute";  
        alert(img1.alt);  
    })  
</script>  
```

所以如果要设置元素的CSS样式类, 要使用的是"DOM属性"className"而不是"元素属性"class:

`img1.className = "classB";`
 

### 操作"DOM属性"
在jQuery中没有包装操作"DOM属性"的函数, 因为使用javascript获取和设置"DOM属性"都很简单. 在jQuery提供了each()函数用于遍历jQuery包装集, 其中的this指针是一个DOM对象, 所以我们可以应用这一点配合原生javascript来操作元素的DOM属性:

```javascript
$("img").each(function(index) {  
    alert("index:" + index + ", id:" + this.id + ", alt:" + this.alt);  
    this.alt = "changed";  
    alert("index:" + index + ", id:" + this.id + ", alt:" + this.alt);  
}); 
```

下面是each函数的说明:
`each( callback )`  Returns: jQuery包装集

对包装集中的每一个元素执行callback方法. 其中callback方法接受一个参数, 表示当前遍历的索引值,从0开始.

### 操作"元素属性"
我们可以使用javascript中的getAttribute和setAttribute来操作元素的"元素属性".

在jQuery中给你提供了attr()包装集函数, 能够同时操作包装集中所有元素的属性:

|名称|说明|举例|
|----|----|----|
|attr( name )|取得第一个匹配元素的属性值。通过这个方法可以方便地从第一个匹配元素中获取一个属性的值。如果元素没有相应属性，则返回 undefined 。|返回文档中第一个图像的src属性值:         $("img").attr("src");
|attr( properties )	|将一个“名/值”形式的对象设置为所有匹配元素的属性。<br>这是一种在所有匹配元素中批量设置很多属性的最佳方式。 注意，如果你要设置对象的class属性，你必须使用'className' 作为属性名。或者你可以直接使用.addClass( class ) 和 .removeClass( class ).|为所有图像设置src和alt属性:         `$("img").attr({ src: "test.jpg", alt: "Test Image" });`|
|attr( key, value )|为所有匹配的元素设置一个属性值。|为所有图像设置src属性:         `$("img").attr("src","test.jpg");`
|attr( key, fn )	|为所有匹配的元素设置一个计算的属性值。<br>不提供值，而是提供一个函数，由这个函数计算的值作为属性值。|把src属性的值设置为title属性的值:         `$("img").attr("title", function() { return this.src });`
|removeAttr( name )|从每一个匹配的元素中删除一个属性|将文档中图像的src属性删除:         `$("img").removeAttr("src");`        
 

当使用id选择器时常常返回只有一个对象的jQuery包装集, 这个时侯常使用attr(name)函数获得它的元素属性:

```javascript
function testAttr1(event) {
   alert($("#hibiscus").attr("class"));
}
```
注意`attr(name)`函数只返回第一个匹配元素的特定元素属性值. 而`attr(key, name)`会设置所有包装集中的元素属性:

```javascript
//修改所有img元素的alt属性
$("img").attr("alt", "修改后的alt属性");
```

而 `attr( properties )` 可以一次修改多个元素属性:

`$("img").attr({title:"修改后的title", alt: "同时修改alt属性"});`
另外虽然我们可以使用 `removeAttr( name )` 删除元素属性, 但是对应的DOM属性是不会被删除的, 只会影响DOM属性的值.

比如将一个input元素的readonly元素属性去掉,会导致对应的DOM属性变成false(即input变成可编辑状态):

`$("#inputTest").removeAttr("readonly");`
 

### 修改CSS样式
修改元素的样式, 我们可以修改元素CSS类或者直接修改元素的样式.

一个元素可以应用多个css类, 但是不幸的是在DOM属性中是用一个以空格分割的字符串存储的, 而不是数组. 所以如果在原始javascript时代我们想对元素添加或者删除多个属性时, 都要自己操作字符串.

jQuery让这一切变得异常简单. 我们再也不用做那些无聊的工作了.

#### 修改CSS类
下表是修改CSS类相关的jQuery方法:

|名称|说明|举例|
|----|----|----|
|addClass( classes )|为每个匹配的元素添加指定的类名。|为匹配的元素加上 'selected' 类:  $("p").addClass("selected");
|hasClass( class )|判断包装集中是否至少有一个元素应用了指定的CSS类|$("p").hasClass("selected");
|removeClass( [classes] )|从所有匹配的元素中删除全部或者指定的类。	从匹配的元素中删除 'selected' 类:         $("p").|removeClass("selected");
|toggleClass( class )|如果存在（不存在）就删除（添加）一个类。	为匹配的元素切换 'selected' 类:         $("p").|toggleClass("selected");
|toggleClass( class, switch )|当switch是true时添加类,         当switch是false时删除类	|每三次点击切换高亮样式:           var count = 0;           $("p").click(function(){             $(this).toggleClass("highlight", count++ % 3 == 0);           });

 

使用上面的方法, 我们可以将元素的CSS类像集合一样修改, 再也不必手工解析字符串.

注意 ` addClass( class )` 和`removeClass( [classes] ) `的参数可以一次传入多个css类, 用空格分割,比如:

`$("#btnAdd").bind("click", function(event) { $("p").addClass("colorRed borderBlue"); });`

removeClass方法的参数可选, 如果不传入参数则移除全部CSS类:

 `$("p").removeClass()`
 

#### 修改CSS样式
同样当我们想要修改元素的具体某一个CSS样式,即修改元素属性"style"时,  jQuery也提供了相应的方法:

|名称|说明|举例|
|----|----|----|
|css( name )|访问第一个匹配元素的样式属性。	取得第一个段落的color样式属性的值:        |$("p").css("color");
|css( properties )	|把一个“名/值对”对象设置为所有匹配元素的样式属性。这是一种在所有匹配的元素上设置大量样式属性的最佳方式。|将所有段落的字体颜色设为红色并且背景为蓝色:         $("p").css({ color: "#ff0011", background: "blue" });        
|css( name, value )	|在所有匹配的元素中，设置一个样式属性的值。<br>数字将自动转化为像素值|将所有段落字体设为红色: $("p").css("color","red");

 

### 获取常用属性
虽然我们可以通过获取属性,特性以及CSS样式来取得元素的几乎所有信息,  但是注意下面的实验:

```html
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">  
<html xmlns="http://www.w3.org/1999/xhtml">  
<head>  
    <title>获取对象宽度</title>  
    <script type="text/javascript" src="scripts/jquery-1.3.2-vsdoc2.js"></script>  
    <script type="text/javascript">  
        $(function()  
        {  
            alert("attr(\"width\"):" + $("#testDiv").attr("width")); //undifined  
            alert("css(\"width\"):" + $("#testDiv").css("width")); //auto(ie6) 或 1264px(ff)  
            alert("width():" + $("#testDiv").width()); //正确的数值1264  
            alert("style.width:" +  $("#testDiv")[0].style.width ); //空值  
        })  
    </script>  
</head>  
<body>  
    <div id="testDiv">  
        测试文本</div>  
</body>  
</html>  
```

我们希望获取测试图层的宽度,  使用attr方法获取"元素特性"为undifined, 因为并没有为div添加width. 而使用css()方法虽然可以获取到style属性的值, 但是在不同浏览器里返回的结果不同, IE6下返回auto, 而FF下虽然返回了正确的数值但是后面带有"px". 所以jQuery提供了width()方法, 此方法返回的是正确的不带px的数值.

针对上面的问题, jQuery为常用的属性提供了获取和设置的方法, 比如width()用户获取元素的宽度, 而 width(val)用来设置元素宽度.

下面这些方法可以用来获取元素的常用属性值:

#### 宽和高相关 Height and Width
|名称|说明|举例|
|----|----|----|
|height( )|取得第一个匹配元素当前计算的高度值（px）。|获取第一段的高:         $("p").height();
height( val )|为每个匹配的元素设置CSS高度(hidth)属性的值。如果没有明确指定单位（如：em或%），使用px。|把所有段落的高设为 20:     $("p").height(20);
|width( )|取得第一个匹配元素当前计算的宽度值（px）。|获取第一段的宽:         $("p").width();
|width( val )|为每个匹配的元素设置CSS宽度(width)属性的值。如果没有明确指定单位（如：em或%），使用px。|将所有段落的宽设为 20:       $("p").width(20);
|innerHeight( )|获取第一个匹配元素内部区域高度（包括补白、不包括边框）。           此方法对可见和隐藏元素均有效。|见最后示例
|innerWidth( )|获取第一个匹配元素内部区域宽度（包括补白、不包括边框）。           此方法对可见和隐藏元素均有效。|见最后示例
|outerHeight( [margin] )|获取第一个匹配元素外部高度（默认包括补白和边框）。           此方法对可见和隐藏元素均有效。|见最后示例
|outerWidth( [margin] )|获取第一个匹配元素外部宽度（默认包括补白和边框）。           此方法对可见和隐藏元素均有效。|见最后示例
 

关于在获取长宽的函数中, 要区别"inner", "outer"和height/width这三种函数的区别:

![图1](http://o75oehjrs.bkt.clouddn.com/image/blog/%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%E5%AD%A6%E4%B9%A0jQuery%20%28%E5%9B%9B%29%20%E4%BD%BF%E7%94%A8jQuery%E6%93%8D%E4%BD%9C%E5%85%83%E7%B4%A0%E7%9A%84%E5%B1%9E%E6%80%A7%E4%B8%8E%E6%A0%B7%E5%BC%8F.png)

outerWith可以接受一个bool值参数表示是否计算margin值.

相信此图一目了然各个函数所索取的范围. 图片以width为例说明的, height的各个函数同理. 

#### 位置相关 Positioning
另外在一些设计套弹出对象的脚本中,常常需要动态获取弹出坐标并且设置元素的位置.

但是很多的计算位置的方法存在着浏览器兼容性问题,  jQuery中为我们提供了位置相关的各个函数:

|名称|说明|举例|
|----|----|----|
|offset( )|获取匹配元素在当前窗口的相对偏移。返回的对象包含两个整形属性：top 和 left。此方法只对可见元素有效。|获取第二段的偏移:         var p = $("p:last");           var offset = p.offset();           p.html( "left: " + offset.left + ", top: " + offset.top );
|position( )|获取匹配元素相对父元素的偏移。|返回的对象包含两个整形属性：top 和 left。为精确计算结果，请在补白、边框和填充属性上使用像素单位。此方法只对可见元素有效。|获取第一段的偏移:         var p = $("p:first");           var position = p.position();           $("p:last").html( "left: " + position.left + ", top: " + position.top );
|scrollTop( )|获取匹配元素相对滚动条顶部的偏移。此方法对可见和隐藏元素均有效。|获取第一段相对滚动条顶部的偏移:         var p = $("p:first");           $("p:last").text( "scrollTop:" + p.scrollTop() );
|scrollTop( val )|传递参数值时，设置垂直滚动条顶部偏移为该值。此方法对可见和隐藏元素均有效。|设定垂直滚动条值:        $("div.demo").scrollTop(300);
|scrollLeft( )|获取匹配元素相对滚动条左侧的偏移。此方法对可见和隐藏元素均有效。|获取第一段相对滚动条左侧的偏移:         var p = $("p:first");           $("p:last").text( "scrollLeft:" + p.scrollLeft() );
|scrollLeft( val )|传递参数值时，设置水平滚动条左侧偏移为该值。此方法对可见和隐藏元素均有效。|设置相对滚动条左侧的偏移:        $("div.demo").scrollLeft(300);
 