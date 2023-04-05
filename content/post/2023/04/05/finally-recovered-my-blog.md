---
categories:
- 技术文章
date: 2023-04-05T16:21:33+08:00
description: ""
keywords:
- hugo,docker,blog
title: "时隔五年终于恢复了这个博客"
url: "/post/2023/04/05/finally-recovered-my-blog"
---

## 引言

自从“卖身”给了本厂之后，就一直没有更新过这个blog。回头看看上一篇文章还是5年前，那个时候自己还在对着hadoop大数据体系不断的折腾。五年过去了，自己也从大数据，迈向了云计算和AI的大潮中。最最近ChatGPT掀起来的浪潮，也最终"迫使"重拾“技术学习”的热情.

所以赶紧重新折腾起这个博客，还好，`ywheel.com`这个域名还在，还不需要所有都重头开始。但没想到还没开头，就碰到了“难题”

## 重装环境

这个博客，整体方案是通过`hugo`生成静态页面，并交由github托管，定义CNAME并将域名绑定到github.io。方案不再赘述，但由于过了这么久的时间，本地环境也早已不存在。

因此先开始装环境，mac上的安装可以说“异常”顺利。

```
brew install hugo
```

一句话就安装好了。

那么新建工作目录，从github上拉代码

```
git clone https://github.com/ywheel/my-blog.git
```

完成后进入`my-blog`目录, 执行`hugo server`即可在本地启动服务并能够访问本地生成的静态页面了。但，出错了(精简)：

```
✗ hugo server
Start building sites … 
hugo v0.101.0+extended darwin/amd64 BuildDate=unknown
...
Error: Error building site: failed to render pages: render of "page" failed: "/Users/ywheel/Documents/GitHub/my-blog/themes/hugo-rapid-theme/layouts/_default/single.html:1:3": execute of template failed: template: _default/single.html:1:3: executing "_default/single.html" at <partial "head.html" .>: error calling partial: "/Users/ywheel/Documents/GitHub/my-blog/themes/hugo-rapid-theme/layouts/partials/head.html:15:5": execute of template failed: template: partials/head.html:15:5: executing "partials/head.html" at <partial "head.meta.html" .>: error calling partial: "/Users/ywheel/Documents/GitHub/my-blog/themes/hugo-rapid-theme/layouts/partials/head.meta.html:1:16": execute of template failed: template: partials/head.meta.html:1:16: executing "partials/head.meta.html" at <.URL>: can't evaluate field URL in type *hugolib.pageState
Built in 127 ms
```

虽然按照问题找了几个解决方法，但错误就像打地鼠，解决一个就会冒出来一个新的。这时候意识到是版本问题，毕竟五年时间过去，一切都变了。

于是我找到之前最后一篇文章发布的时间是18年的3月，通过hugo的github release页找到对应到大致时间的版本:0.40; 而最新的hugo版本已经是v0.111.3，而我刚装的版本是：

```
✗ hugo version
hugo v0.101.0+extended darwin/amd64 BuildDate=unknown
```

既然`brew`方案不好使，那么就源码安装吧。按照 https://gohugo.io/installation/macos/ 的指引，先安装了go，然后通过go来安装hugo:

```
go install -tags extended github.com/gohugoio/hugo@v0.40.1
```

而结果，毫无意外仍然是安装失败，要对齐所有相关依赖的版本确实是一件麻烦的事儿。

## 解决版本冲突

好在，官方文档中还提到了使用docker：

> Erlend Klakegg Bergheim graciously maintains Docker images based on images for Alpine Linux, Busybox, Debian, and Ubuntu.

> docker pull klakegg/hugo

在docker hub中寻找一番，找到了接近的版本：

```
docker pull klakegg/hugo:0.40
cd my-blog
docker run --rm -it -v $(pwd):/src klakegg/hugo:0.40
Building sites … ERROR 2023/04/05 04:20:27 Site config's rssURI is deprecated and will be removed in Hugo 0.41. Set baseName in outputFormats.RSS
ERROR 2023/04/05 04:20:29 Error while rendering "page" in "post/2018/03/21/": template: theme/_default/single.html:1:3: executing "theme/_default/single.html" at <partial "head.html" ...>: error calling partial: template: theme/partials/head.html:20:5: executing "theme/partials/head.html" at <partial "head.includ...>: error calling partial: template: theme/partials/head.includes.html:1:6: executing "theme/partials/head.includes.html" at <.RSSlink>: can't evaluate field RSSlink in type *hugolib.PageOutput
```

虽然有一点点报错，但简单解决一下就成功了。不得不说，docker还是保存“环境”的最佳实践。

## 5年后的第一篇文章

终于，可以开始写新文章了。计划中的《chatGPT钉钉机器人》已经搁置了好几天，那还不如，先记录下今天恢复blog踩过的坑。万一后来又一次断更5年，还能通过这篇记录恢复10年前的环境快速开工。

新建一篇新的文章：

```
docker run --rm -it -v $(pwd):/src -v $(pwd)/public:/target klakegg/hugo:0.40 "new post/2023/04/05/finally-recovered-my-blog.md"

Error: unknown flag: --destination

Usage:
  hugo new [path] [flags]
  hugo new [command]

Available Commands:
  site        Create a new site (skeleton)
  theme       Create a new theme

Flags:
      --editor string   edit new content with this editor, if provided
  -h, --help            help for new
  -k, --kind string     content type to create
  -s, --source string   filesystem path to read files relative from

Global Flags:
      --config string    config file (default is path/config.yaml|json|toml)
      --debug            debug output
      --log              enable Logging
      --logFile string   log File path (if set, logging enabled automatically)
      --quiet            build in quiet mode
  -v, --verbose          verbose output
      --verboseLog       verbose logging

Use "hugo new [command] --help" for more information about a command.
```

好吧，那就手工创建吧，`hugo new`命令的好处是创建文件后还会直接加上文件开头的定义内容，而手工创建文件后这部分要自己填一下，不麻烦。

稍作修改后，本地调起来看看：
```
docker run --rm -it -v $(pwd):/src -p 1313:1313 klakegg/hugo:0.40 server

                   | EN   
+------------------+-----+
  Pages            |  50  
  Paginator pages  |   0  
  Non-page files   |   0  
  Static files     | 105  
  Processed images |   0  
  Aliases          |   0  
  Sitemaps         |   1  
  Cleaned          |   0  

Total in 4655 ms
Watching for changes in /src/{content,data,layouts,static,themes}
Watching for config changes in /src/config.yaml
Serving pages from memory
Running in Fast Render Mode. For full rebuilds on change: hugo server --disableFastRender
Web Server is available at http://localhost:1313/ (bind address 0.0.0.0)
Press Ctrl+C to stop
```

打开浏览器访问`http://localhost:1313`

搞定，收工。
