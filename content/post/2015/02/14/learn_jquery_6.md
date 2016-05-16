---
categories:
- 技术文章
date: 2015-02-14T19:01:47+08:00
description: "从零开始学习jQuery (六) jQuery中的Ajax"
keywords:
- jQuery
title: 从零开始学习jQuery (六) jQuery中的Ajax
url: ""
---

```
节选转载自http://www.cnblogs.com/engine1984/archive/2012/02/28/2371782.html
```

### jQuery Ajax详解
jQuery提供了几个用于发送Ajax请求的函数. 其中最核心也是最复杂的是jQuery.ajax( options ),所有的其他Ajax函数都是它的一个简化调用. 当我们想要完全控制Ajax时可以使用此结果, 否则还是使用简化方法如get, post, load等更加方便. 所以jQuery.ajax( options ) 方法放到最后一个介绍. 先来介绍最简单的load方法:

1.load( url, [data], [callback] )
Returns: jQuery包装集

说明:

load方法能够载入远程 HTML 文件代码并插入至 DOM 中。

默认使用 GET 方式, 如果传递了data参数则使用Post方式.传递附加参数时自动转换为 POST 方式。jQuery 1.2 中，可以指定选择符，来筛选载入的 HTML 文档，DOM 中将仅插入筛选出的 HTML 代码。语法形如 "url #some > selector", 默认的选择器是"body>*".

讲解:

load是最简单的Ajax函数, 但是使用具有局限性:

它主要用于直接返回HTML的Ajax接口
load是一个jQuery包装集方法,需要在jQuery包装集上调用,并且会将返回的HTML加载到对象中, 即使设置了回调函数也还是会加载.
不过不可否认load接口设计巧妙并且使用简单.下面通过示例来演示Load接口的使用:

```html
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">  
<html xmlns="http://www.w3.org/1999/xhtml">  
<head>  
    <title>jQuery Ajax - Load</title>  
  
    <script type="text/javascript" src="../scripts/jquery-1.3.2-vsdoc2.js"></script>  
  
    <script type="text/javascript">  
        $(function()  
        {  
            $("#btnAjaxGet").click(function(event)  
            {  
                //发送Get请求  
                $("#divResult").load("../data/AjaxGetMethod.aspx?param=btnAjaxGet_click" + "×tamp=" + (new Date()).getTime());  
            });  
  
            $("#btnAjaxPost").click(function(event)  
            {  
                //发送Post请求  
                $("#divResult").load("../data/AjaxGetMethod.aspx", { "param": "btnAjaxPost_click" });  
            });  
  
            $("#btnAjaxCallBack").click(function(event)  
            {  
                //发送Post请求, 返回后执行回调函数.  
                $("#divResult").load("../data/AjaxGetMethod.aspx", { "param": "btnAjaxCallBack_click" }, function(responseText, textStatus, XMLHttpRequest)  
                {  
                    responseText = " Add in the CallBack Function! <br/>" + responseText  
                    $("#divResult").html(responseText); //或者: $(this).html(responseText);  
                });  
            });  
  
            $("#btnAjaxFiltHtml").click(function(event)  
            {  
                //发送Get请求, 从结果中过滤掉 "鞍山" 这一项  
                $("#divResult").load("../data/AjaxGetCityInfo.aspx?resultType=html" + "×tamp=" + (new Date()).getTime() + " ul>li:not(:contains('鞍山'))");  
            });  
  
        })  
    </script>  
  
</head>  
<body>      
    <button id="btnAjaxGet">使用Load执行Get请求</button><br />  
    <button id="btnAjaxPost">使用Load执行Post请求</button><br />  
    <button id="btnAjaxCallBack">使用带有回调函数的Load方法</button><br />  
    <button id="btnAjaxFiltHtml">使用selector过滤返回的HTML内容</button>  
    <br />  
    <div id="divResult"></div>  
</body>  
</html>
```

上面的示例演示了如何使用Load方法.

提示:我们要时刻注意浏览器缓存,  当使用GET方式时要添加时间戳参数 (net Date()).getTime() 来保证每次发送的URL不同, 可以避免浏览器缓存.

提示: 当在url参数后面添加了一个空格, 比如"  "的时候, 会出现"无法识别符号"的错误, 请求还是能正常发送. 但是无法加载HTML到DOM. 删除后问题解决.

2.jQuery.get( url, [data], [callback], [type] )
Returns: XMLHttpRequest

说明:

通过远程 HTTP GET 请求载入信息。

这是一个简单的 GET 请求功能以取代复杂 $.ajax 。请求成功时可调用回调函数。如果需要在出错时执行函数，请使用 $.ajax。

讲解:

此函数发送Get请求, 参数可以直接在url中拼接, 比如:

`$.get("../data/AjaxGetMethod.aspx?param=btnAjaxGet_click");`
或者通过data参数传递:

`$.get("../data/AjaxGetMethod.aspx", { "param": "btnAjaxGet2_click" });`
 
 

两种方式效果相同, data参数会自动添加到请求的url中

如果url中的某个参数, 又通过data参数传递, 不会自动合并相同名称的参数.

回调函数的签名如下:

```javascript
function (data, textStatus) {
  // data could be xmlDoc, jsonObj, html, text, etc...
  this; // the options for this ajax request
}
```

其中data是返回的数据, testStatus表示状态码, 可能是如下值:

"timeout","error","notmodified","success","parsererror"
在回调函数中的this是获取options对象的引用.有关options的各种说明, 请参见:
http://docs.jquery.com/Ajax/jQuery.ajax#options
 
type参数是指data数据的类型, 可能是下面的值:
"xml", "html", "script", "json", "jsonp", "text".
默认为"html".

jQuery.getJSON( url, [data], [callback] ) 方法就相当于 jQuery.get(url, [data],[callback], "json")

 

3.jQuery.getJSON( url,  [data], [callback] )
Returns: XMLHttpRequest

相当于:   jQuery.get(url, [data],[callback], "json")

说明:

通过 HTTP GET 请求载入 JSON 数据。

在 jQuery 1.2 中，您可以通过使用JSONP 形式的回调函数来加载其他网域的JSON数据，如 "myurl?callback=?"。jQuery 将自动替换 ? 为正确的函数名，以执行回调函数。

注意：此行以后的代码将在这个回调函数执行前执行。

讲解:

getJSON函数仅仅将get函数的type参数设置为"JSON"而已. 在回调函数中获取的数据已经是按照JSON格式解析后的对象了:

```javascript
$.getJSON("../data/AjaxGetCityInfo.aspx", { "resultType": "json" }, function(data, textStatus)
{
      alert(data.length);
      alert(data[0].CityName);
});
```

服务器端返回的字符串如下:

```json
[{""pkid"":""0997"",""ProvinceId"":""XJ"",""CityName"":""阿克苏"",""CityNameEn"":""Akesu"",""PostCode"":""843000"",""isHotCity"":false},
 {""pkid"":""0412"",""ProvinceId"":""LN"",""CityName"":""鞍山"",""CityNameEn"":""Anshan"",""PostCode"":""114000"",""isHotCity"":false}]
 ```

示例中我返回的饿是一个数组, 使用data.length可以获取数组的元素个数,  data[0]访问第一个元素, data[0].CityName访问第一个元素的CityName属性.

 

4.jQuery.getScript( url, [callback] )
Returns: XMLHttpRequest

相当于:   jQuery.get(url, null, [callback], "script")

说明:

通过 HTTP GET 请求载入并执行一个 JavaScript 文件。

jQuery 1.2 版本之前，getScript 只能调用同域 JS 文件。 1.2中，您可以跨域调用 JavaScript 文件。注意：Safari 2 或更早的版本不能在全局作用域中同步执行脚本。如果通过 getScript 加入脚本，请加入延时函数。

讲解:

以前我使用dojo类库时官方默认的文件不支持跨域最后导致我放弃使用dojo(虽然在网上找到了可以跨域的版本, 但是感觉不够完美).  所以我特别对这个函数的核心实现和使用做了研究.

首先了解此函数的jQuery内部实现, 仍然使用get函数, jQuery所有的Ajax函数包括get最后都是用的是jQuery.ajax(), getScript将传入值为"script"的type参数,  最后在Ajax函数中对type为script的请求做了如下处理:

```javascript
var head = document.getElementsByTagName("head")[0];            
var script = document.createElement("script");
script.src = s.url;
```

上面的代码动态建立了一个script语句块, 并且将其加入到head中:

`head.appendChild(script);`

当脚本加载完毕后, 再从head中删除:

```javascript
// Handle Script loading  
if ( !jsonp ) {  
    var done = false;  
  
    // Attach handlers for all browsers  
    script.onload = script.onreadystatechange = function(){  
        if ( !done && (!this.readyState ||  
                this.readyState == "loaded" || this.readyState == "complete") ) {  
            done = true;  
            success();  
            complete();  
  
            // Handle memory leak in IE  
            script.onload = script.onreadystatechange = null;  
            head.removeChild( script );  
        }  
    };  
}  
```

我主要测试了此函数的跨域访问和多浏览器支持.下面是结果:
 	IE6	FireFox	注意事项
非跨域引用js	通过	通过	回调函数中的data和textStatus均可用
跨域引用js	通过	通过	回调函数中的data和textStatus均为undifined
 

下面是我关键的测试语句, 也用来演示如何使用getScript函数:

```javascript
$("#btnAjaxGetScript").click(function(event)  
{  
    $.getScript("../scripts/getScript.js", function(data, textStatus)  
    {  
        alert(data);  
        alert(textStatus);  
        alert(this.url);  
    });  
});  
  
$("#btnAjaxGetScriptCross").click(function(event)  
{  
    $.getScript("http://resource.elong.com/getScript.js", function(data, textStatus)  
    {  
        alert(data);  
        alert(textStatus);  
        alert(this.url);  
    });  
});  
```

5.jQuery.post( url, [data], [callback], [type] )
Returns: XMLHttpRequest

说明:

通过远程 HTTP POST 请求载入信息。

这是一个简单的 POST 请求功能以取代复杂 $.ajax 。请求成功时可调用回调函数。如果需要在出错时执行函数，请使用 $.ajax。

讲解:

具体用法和get相同, 只是提交方式由"GET"改为"POST".

6.jQuery.ajax( options )
Returns: XMLHttpRequest

说明:

通过 HTTP 请求加载远程数据。

jQuery 底层 AJAX 实现。简单易用的高层实现见 $.get, $.post 等。

`$.ajax()` 返回其创建的 XMLHttpRequest 对象。大多数情况下你无需直接操作该对象，但特殊情况下可用于手动终止请求。

`$.ajax()` 只有一个参数：参数 key/value 对象，包含各配置及回调函数信息。详细参数选项见下。

注意： 如果你指定了 dataType 选项，请确保服务器返回正确的 MIME 信息，(如 xml 返回 "text/xml")。错误的 MIME 类型可能导致不可预知的错误。见 Specifying the Data Type for AJAX Requests 。

注意：如果dataType设置为"script"，那么所有的远程(不在同一域名下)的POST请求都将转化为GET请求。(因为将使用DOM的script标签来加载)

jQuery 1.2 中，您可以跨域加载 JSON 数据，使用时需将数据类型设置为 JSONP。使用 JSONP 形式调用函数时，如 "myurl?callback=?" jQuery 将自动替换 ? 为正确的函数名，以执行回调函数。数据类型设置为 "jsonp" 时，jQuery 将自动调用回调函数。

讲解:

这是jQuery中Ajax的核心函数, 上面所有的发送Ajax请求的函数内部最后都会调用此函数.options参数支持很多参数, 使用这些参数可以完全控制ajax请求. 在Ajax回调函数中的this对象也是options对象.

因为平时使用最多的还是简化了的get和post函数, 所以在此不对options参数做详细讲解了. options参数文档请见:

http://docs.jquery.com/Ajax/jQuery.ajax#options

 

### Ajax相关函数.
jQuery提供了一些相关函数能够辅助Ajax函数.

1.jQuery.ajaxSetup( options )
无返回值

说明:

设置全局 AJAX 默认options选项。

讲解:

有时我们的希望设置页面上所有Ajax属性的默认行为.那么就可以使用此函数设置options选项, 此后所有的Ajax请求的默认options将被更改.

options是一个对象, 可以设置的属性请此连接：http://docs.jquery.com/Ajax/jQuery.ajax#toptions

比如在页面加载时, 我使用下面的代码设置Ajax的默认option选项:

```javascript
$.ajaxSetup({  
    url: "../data/AjaxGetMethod.aspx",  
    data: { "param": "ziqiu.zhang" },  
    global: false,  
    type: "POST",  
    success: function(data, textStatus) { $("#divResult").html(data); }  
});  
```

上面的代码设置了一个Ajax请求需要的基本数据: 请求url, 参数, 请求类型, 成功后的回调函数.
此后我们可以使用无参数的get(), post()或者ajax()方法发送ajax请求.完整的示例代码如下:

```html
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">  
<html xmlns="http://www.w3.org/1999/xhtml">  
<head>  
    <title>jQuery Ajax - Load</title>  
  
    <script type="text/javascript" src="../scripts/jquery-1.3.2-vsdoc2.js"></script>  
  
    <script type="text/javascript">  
        $(document).ready(function()  
        {  
            $.ajaxSetup({  
                url: "../data/AjaxGetMethod.aspx",  
                data: { "param": "ziqiu.zhang" },  
                global: false,  
                type: "POST",  
                success: function(data, textStatus) { $("#divResult").html(data); }  
            });  
  
            $("#btnAjax").click(function(event) { $.ajax(); });  
            $("#btnGet").click(function(event) { $.get(); });  
            $("#btnPost").click(function(event) { $.post(); });  
            $("#btnGet2").click(function(event) { $.get("../data/AjaxGetMethod.aspx",{ "param": "other" }); });  
  
        });  
  
    </script>  
  
</head>    
<body>      
    <button id="btnAjax">不传递参数调用ajax()方法</button><br />  
    <button id="btnGet">不传递参数调用get()方法</button><br />  
    <button id="btnPost">不传递参数调用post()方法</button><br />  
    <button id="btnGet2">传递参数调用get()方法, 使用全局的默认回调函数</button><br />  
    <br />  
    <div id="divResult"></div>  
</body>  
</html>  
```

注意当使用get()或者post()方法时, 除了type参数将被重写为"GET"或者"POST"外, 其他参数只要不传递都是使用默认的全局option. 如果传递了某一个选项, 比如最后一个按钮传递了url和参数, 则本次调用会以传递的选项为准. 没有传递的选项比如回调函数还是会使用全局option设置值.
 

2.serialize( )
Returns: String

说明:

序列表表格内容为字符串，用于 Ajax 请求。

序列化最常用在将表单数据发送到服务器端时. 被序列化后的数据是标准格式, 可以被几乎所有的而服务器端支持.

为了尽可能正常工作, 要求被序列化的表单字段都有name属性, 只有一个eid是无法工作的.

像这样写name属性:

`<input id="email" name="email" type="text" /> `
讲解:

serialize()函数将要发送给服务器的form中的表单对象拼接成一个字符串. 便于我们使用Ajax发送时获取表单数据. 这和一个From按照Get方式提交时, 自动将表单对象的名/值放到url上提交差不多.

比如这样一个表单:

![图1](http://o75oehjrs.bkt.clouddn.com/image/blog/%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%E5%AD%A6%E4%B9%A0jQuery%20%28%E5%85%AD%29%20jQuery%E4%B8%AD%E7%9A%84Ajax1.png)

生成的字符串为:single=Single&param=Multiple&param=Multiple3&check=check2&radio=radio1

提示:代码见 chapter6\7-serialize.htm

3.serializeArray( )
Returns: Array<Object>

说明:

序列化表格元素 (类似 '.serialize()' 方法) 返回 JSON 数据结构数据。

注意，此方法返回的是JSON对象而非JSON字符串。需要使用插件或者第三方库进行字符串化操作。

讲解:

看说明文档让我有所失望, 使用此函数获取到的是JSON对象, 但是jQuery中没有提供将JSON对象转化为JSON字符串的方法.

在JSON官网上没有找到合适的JSON编译器, 最后选用了jquery.json这个jQuery插件:

http://code.google.com/p/jquery-json/

使用起来异常简单:

```javascript
var thing = {plugin: 'jquery-json', version: 1.3};
var encoded = $.toJSON(thing);              //'{"plugin": "jquery-json", "version": 1.3}'
var name = $.evalJSON(encoded).plugin;      //"jquery-json"
var version = $.evalJSON(encoded).version;  // 1.3
```

使用serializeArray( ) 再配合 $.toJSON 方法, 我们可以很方便的获取表单对象的JSON, 并且转换为JSON字符串:

```$("#results").html( $.toJSON( $("form").serializeArray() ));```

结果为:

```json
[{"name": "single", "value": "Single"}, {"name": "param", "value": "Multiple"}, {"name": "param", "value": "Multiple3"}, {"name": "check", "value": "check2"}, {"name": "radio", "value": "radio1"}]
```


### 全局Ajax事件
在jQuery.ajaxSetup( options ) 中的options参数属性中, 有一个global属性:

global

类型:布尔值

默认值: true

说明:是否触发全局的Ajax事件.

这个属性用来设置是否触发全局的Ajax事件. 全局Ajax事件是一系列伴随Ajax请求发生的事件.主要有如下事件:

|名称|说明|
|----|----|
|ajaxComplete( callback )|	AJAX 请求完成时执行函数
|ajaxError( callback )	|AJAX 请求发生错误时执行函数
|ajaxSend( callback )	|AJAX 请求发送前执行函数
|ajaxStart( callback )	|AJAX 请求开始时执行函数
|ajaxStop( callback )	|AJAX 请求结束时执行函数
|ajaxSuccess( callback )|	AJAX 请求成功时执行函数
 

用一个示例讲解各个事件的触发顺序:

```html
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">  
<html xmlns="http://www.w3.org/1999/xhtml">  
<head>  
    <title>jQuery Ajax - AjaxEvent</title>  
  
    <script type="text/javascript" src="../scripts/jquery-1.3.2.min.js"></script>  
  
    <script type="text/javascript">  
        $(document).ready(function()  
        {  
  
            $("#btnAjax").bind("click", function(event)  
            {  
                $.get("../data/AjaxGetMethod.aspx");  
            })  
  
            $("#divResult").ajaxComplete(function(evt, request, settings) { $(this).append('<div>ajaxComplete</div>'); })  
            $("#divResult").ajaxError(function(evt, request, settings) { $(this).append('<div>ajaxError</div>'); })  
            $("#divResult").ajaxSend(function(evt, request, settings) { $(this).append('<div>ajaxSend</div>'); })  
            $("#divResult").ajaxStart(function() { $(this).append('<div>ajaxStart</div>'); })  
            $("#divResult").ajaxStop(function() { $(this).append('<div>ajaxStop</div>'); })  
            $("#divResult").ajaxSuccess(function(evt, request, settings) { $(this).append('<div>ajaxSuccess</div>'); })  
  
        });  
  
    </script>  
  
</head>  
<body>      
  <br /><button id="btnAjax">发送Ajax请求</button><br/>  
  <div id="divResult"></div>  
</body>  
</html>  
```

结果如图:

![图2](http://o75oehjrs.bkt.clouddn.com/image/blog/%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%E5%AD%A6%E4%B9%A0jQuery%20%28%E5%85%AD%29%20jQuery%E4%B8%AD%E7%9A%84Ajax2.png)

我们可以通过将默认options的global属性设置为false来取消全局Ajax事件的触发.
