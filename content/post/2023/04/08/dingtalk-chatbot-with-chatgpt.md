---
categories:
- 技术文章
date: 2023-04-08T17:30:00+08:00
description: ""
keywords:
- chatGPT,laf,sealos,dingTalk
title: "基于ChatGPT的钉钉聊天机器人"
url: "/post/2023/04/08/dingtalk-chatbot-with-chatgpt"
---

> ChatGPT的横空出世，给业界带来了巨大的震撼。作为一种新型的语言模型，它可以生成与人类交流极为接近的文本，被誉为“最接近人类思维的AI”。其强大的自然语言处理能力和广泛的应用场景，已经在各个领域引起了广泛的关注和应用。不使用ChatGPT，几乎就意味着在科技愈发发达的今天落伍了。

没错，上面这一段就是chatGPT自己写的。作为程序员群体的一员，肯定是尽快的尝鲜，在自己惊叹之余也想装个逼，那就得转换成其他人更容易接触的方式。毕竟，有梯子、注册账号等都是有门槛的。如何做到更容易使用？最简单的述求无非就是：随时能用(比如有手机)，随地能用(不用爬梯子)

基于wx/dingDing的机器人就是比较方便使用的一种方式。

## 注册OpenAI

首先，你得能使用google（`劝退第一步`）

打开ChatGPT的官方网站：https://openai.com/ ，找到API，点击SIGN UP:

![signup](/public/img/chat/signup.jpeg)

这里可以直接使用google或microsoft账户（我两者都有，所以也就注册了两个openai账户）会更方便。如果使用邮箱也可以，验证完邮箱之后进入到手机号码验证（`劝退第二步`）

这里会用到https://sms-activate.org/ 来注册一个国外的临时手机号码，用来接受验证码。详细的过程，可以参考《ChatGPT注册教程攻略》<sup>[1]</sup>. 这里说个有意思的事情：

![sms](/public/img/chat/sms.jpeg)

登录时提示：“我们怀疑你是人类。” 有点细思极恐的感觉了。。。

我选择的是“英国”的手机号码，收到验证码的速度还是可以的。注册了两个都能正常快速收到验证码。参考文章中使用支付宝付款时只需要0.2美元，而我使用的时候已经涨价到2美元了。当然，2美元可以买多个号码

回到openai的注册过程，输入刚刚购买的临时号码，获取验证码，验证后就完成openAI的注册啦~

访问https://chat.openai.com/chat 进入聊(tiao)天(xi)体验:

![chat](/public/img/chat/chatgpt.jpeg)

## 开发代理服务

毕竟想要随时随地使用官方的chatGPT会有诸多限制带来的不便，因此我们需要搞一个代理服务（`劝退第三步`）。整体的方案如下：

![sa](/public/img/chat/sa.jpeg)

选择一个合适的地方部署代理很重要，使得国内访问代理不被Q，代理访问OpenAI不被F, 太难了。。。

可选的方案有好多种，比如：

- 在aws上搞一台ec2部署代理（新手送一台小规格12个月）
- 类似的，在aliyun上买一台ecs，注意选择海外的region； 或者使用函数计算服务，serverless
- 既然是serverless，那就更彻底一些，可以使用[aircode](https://docs.aircode.io/getting-started/)创建cloud function
- 国内也有一家，使用laf创建应用函数，提供http接口调用

我选择使用laf创建函数。访问 https://laf.dev/login 通过手机号码登录/注册；

![laflogin](/public/img/chat/laflogin.jpeg)

新用户可以创建一个免费的资源受限的应用，对于自用chatGPT已经足够用了（更何况openai的账号本身也是有限制的呢）

![lafnew](/public/img/chat/lafnew.jpeg)

不过这里提示的`根据当前平台资源负载情况，不定期停止应用实例` 我已经碰到过实例被停止，这点体验确实不太好，不过谁让它是免费的呢。。。

可用区只有新加坡，就它了。创建好应用后，就进入了开发页面。

参考《三分钟 ChatGPT 接入钉钉机器人》<sup>[2]</sup>，我也搭建了一个可调用chatGPT api的函数。不过，正如作者所提到的, 这段代码还存在一些问题，比如：

- 不支持连续对话，需要传入`parentMessageId`让chatGPT理解上下文
- 不支持多用户、多群
  - 钉钉webhook地址是固定的，无法推送到多个聊天窗口
  - 没有做不同用户聊天会话的隔离

这里暂时打住，先不解决这些问题，我们先去创建钉钉机器人并进行调试。

![lafdev](/public/img/chat/lafdev.jpeg)

laf开发结束后可发布为公开接口，例如：https://*******.laf.dev/request-openai


## 创建钉钉机器人

从网上各种文章、以及我们内部使用的专有钉的群来说，都是可以在钉钉群聊中创建机器人，并配置outging。而我却看到了这个：

![outgoing](/public/img/chat/outgoing.jpeg)


好在还可以通过创建一个企业/组织，然后使用钉钉开放平台后台对企业内部应用创建机器人。在钉钉上创建一个公司也很方便，只是公司名字叫啥好呢？`找ChatGPT帮忙想一个名字吧`~~

随后进入钉钉开放平台，创建应用和配置机器人，具体步骤可参考《企业内部开发机器人》<sup>[3]</sup>

我给这个机器人取名叫"小G", 记得给机器人上传一个chatGPT的icon~~

最后填入上一章节发布的laf接口，点击“调试”，钉钉会自定创建一个包含自己和机器人的群，就可以发消息进行调试了。

![debug1](/public/img/chat/debug1.jpeg)


从文档中可以找到艾特机器人后钉钉发送出来的消息格式：

```json
{
    "conversationId": "xxx",
    "atUsers": [
        {
            "dingtalkId": "xxx",
            "staffId":"xxx"
        }
    ],
    "chatbotCorpId": "dinge8a565xxxx",
    "chatbotUserId": "$:LWCP_v1:$Cxxxxx",
    "msgId": "msg0xxxxx",
    "senderNick": "杨xx",
    "isAdmin": true,
    "senderStaffId": "user123",
    "sessionWebhookExpiredTime": 1613635652738,
    "createAt": 1613630252678,
    "senderCorpId": "dinge8a565xxxx",
    "conversationType": "2",
    "senderId": "$:LWCP_v1:$Ff09GIxxxxx",
    "conversationTitle": "机器人测试-TEST",
    "isInAtList": true,
    "sessionWebhook": "https://oapi.dingtalk.com/robot/sendBySession?session=xxxxx",
    "text": {
        "content": " 你好"
    },
    "msgtype": "text"
}
```

在调试阶段，也可以在laf中，通过打印request body来验证消息。修改laf代码中的dingtalk_robot_url为群中的小G机器人的webhook地址，这样就调通了！

![debug2](/public/img/chat/debug2.jpeg)


## 会话隔离&群聊

上上个章节留了几个laf中的node.js程序的问题。现在钉钉机器人已经调通了，改来解决遗留问题了。我对这一段node.js代码做了修改，主要有：

- 从chatGPT的response里获取`parentMessageId`，下一个request带上这个id，从而实现连续对话
- 通过dingding消息中的`sessionWebhook`来动态设置每一个response要推送到dingding的webhook地址，这样就不再局限于一个群聊中添加机器人的固定的webhook地址，实现了多个窗口同时和"小G"聊天，回复的消息可以准确的推送回到相应的那一个窗口
- 从钉钉消息中获取`conversationId`, 通过laf提供的`cloud.shared`来保存每个会话的`parentMessageId`; 因此在钉钉的不同窗口向chatGPT发送消息时将是不同的会话上下文。这样的效果是：

  - 可以对"小G"单聊，每个人和他的聊天窗口不一样，`conversationId`就不同，因此和chatGPT的连续对话就实现了会话隔离
  - 在群聊时，同一个群里的多个人，和"小G"聊天讲是同一个主题，正所谓群聊嘛。当然也可以再区分人，比如通过`conversationId+senderStaffId`来保存`parentMessageId`，那么同一个群里的人艾特"小G"时，就是各聊各的，那还不如和他单独一个窗口聊呢


最终的代码如下：

```javascript
import cloud from '@lafjs/cloud'
import axios from 'axios'

const dingtalk_robot_url = 'https://oapi.dingtalk.com/robot/send?access_token=xxxxxxx'
const sendDingDing = async (md, sessionWebhook) => {
  const sendMessage = {
    msgtype: "markdown",
    markdown: {
      title: "ChatGPT消息",
      text: md,
    }
  };
  if (sessionWebhook) {
    return await axios.post(sessionWebhook, sendMessage);
  } else {
    return await axios.post(dingtalk_robot_url, sendMessage);
  }
};

export async function main(ctx: FunctionContext) {
  // body, query 为请求参数, auth 是授权对象
  const { auth, body, query } = ctx;

  const { ChatGPTAPI } = await import('chatgpt')

  let api=cloud.shared.get('api')
  if(!api){
    api = new ChatGPTAPI({ apiKey: cloud.env.OPENAI_API_KEY })
    cloud.shared.set('api', api)
  }
  const prompt = body.text.content;
  console.log(body)
  const conversationId = body.conversationId;
  // const senderStaffId = body.senderStaffId;
  const sessionWebhook = body.sessionWebhook;
  const parentMessageId = cloud.shared.get(conversationId+'.parentMessageId')

  let res
  // 这里前端如果传过来 parentMessageId 则代表需要追踪上下文
  if (!parentMessageId) {
    console.log("parentId is null")
    res = await api.sendMessage(prompt)
  } else {
    console.log("Using parentId " + parentMessageId)
    res = await api.sendMessage(prompt, { parentMessageId })
  }

  console.log(res.text)
  sendDingDing(res.text, sessionWebhook)
  cloud.shared.set(conversationId+'.parentMessageId',res.id)
  return {"id": res.id, "resp": res.text}
}
```

改好后，重启laf应用。开始愉快的聊天啦。

先看看多轮对话：

![qun1](/public/img/chat/qun1.jpeg)

再看一下群聊(多人共享一个会话上下文)：

![qun2](/public/img/chat/qun2.jpeg)

同样的问题，在单聊的聊天窗口问，可以看到时没有上文理解的，与刚才的群聊是隔离的：

![single](/public/img/chat/single.jpeg)


## 其他方案

由于上面的钉钉机器人使用的是 企业内部应用的方案，因此需要加入到该企业组织内才能使用。并且上述方案仅仅使用了文本格式，对于包含表格、代码等回答无法提供好的显示体验。想要玩到功能齐备、体验良好的能力，还得有一些其他办法，如：

- 直接去访问官方chatGPT
- 国内大厂发布的对标产品（外部同学需要邀请码），也有好多“蹭热度”的直播博主
  - 百度“文心一言”
  - 阿里“通义千问”： https://tongyi.aliyun.com
- 找一些国内能访问到的客户端或者web，如：
  - https://chunpiao.xin/#/chat (网页版，国内直接能访问，不需要登录，偶有不稳定报5XX)<sup>[4]</sup>
- 写代码调用本文中使用的laf，也就不需要加入我的钉钉组织了


以前有时候瞎想，如果哪一天有个AI担任个人助理帮忙处理一些简单的事情，我就可以有更多时间去撸代码、写文章、画画了。而现实情况是，AI可以去撸代码、写文章、画画，`那我干什么去呢？`

> 现在是2050年4月9日8:00，我醒了，已植入在我眼角膜的moss就检测到我睁开了眼，随后我看到moss在我的眼睛里投射出一行字：我们怀疑你是一个人类，请先通过验证。。。

## 参考文章
- [1] ChatGPT注册教程攻略：解决手机无法接收验证码问题（亲测有效）: https://www.xnbeast.com/create-openai-chatgpt-account/
- [2] 三分钟 ChatGPT 接入钉钉机器人: https://juejin.cn/post/7211061398680305725
- [3] 钉钉官方文档-企业内部开发机器人: https://open.dingtalk.com/document/orgapp/enterprise-created-chatbot
- [4] 用 Express 和 Vue3 搭建的 ChatGPT 演示网页: https://github.com/Chanzhaoyu/chatgpt-web