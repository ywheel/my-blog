---
categories:
- 读书笔记
- 技术文章
date: 2013-09-01T22:43:12+08:00
description: "计算广告学笔记"
keywords:
- 计算广告学
title: 计算广告学笔记3-合约广告系统简介
url: ""
---

```
注： 内容来自师徒网：刘鹏--计算广告学
```

## 合约广告系统简介
Agreement based Advertising，能够解决什么问题?

### 传统媒体--直接媒体购买
- 供给方：广告排期系统
- 帮助媒体自动执行多个合同的排期
- 不提供受众定向，可以将广告素材直接插入页面。比如都是静态数据，可以直接放在CDN， latency就短。
- 需求方：代理商
- 帮助广告商策划和执行排期
- 用经验和人工满足广告商质和量的需求
- 代表: 4A公司

在中国，很多品牌广告还是这样的方式，比如在门户网站按天排期

### 在线广告系统主流做法--担保式投送与广告投放
- 担保式投送（Guaranteed Delivery，GD）
- 基于合约的广告机制，约定的量未完成需要向广告商补偿
- 量（Quantity）优于质（Quality）的销售方式
- 多采用千次展示付费（Cost per Mille, CPM）方式结算
- 广告投放机（Ad Server）  把广告由静态的页面转到由服务器计算决定
- CPM方式必然要求广告投送由服务器端完成决策
- 受众定向，CTR预测和流量预测是广告投放机的基础
- GD合约下，投放机满足合约的量，并尽可能优化各广告主流量的质
