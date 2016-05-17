---
categories:
- 技术文章
date: 2015-03-11T01:32:08+08:00
description: "leetcode"
keywords:
- leetcode
title: LeetCode主题整理(4)链表及相关问题
url: ""
---

```
转载自：http://blog.csdn.net/feliciafay/article/details/18944093
```

### Topic 1 反转链表
#### Reverse Linked List II

在第m~n个节点中反转单链表，注意这道题可以把代码写得很长，如果分为区间一[0,m-1],区间二[m-n],区间三[n+1,end]这三个区间的话。也可以写得很短，如果仔细观察发现其实只需要考虑第一个区间是否为NULL就可以了。

#### Reverse Nodes in K Group

每K个节点为一个单位，反转第1个单位之后，反转第2个单位，反转第i个单位，反转最后一个单位，如果最后一个单位不足K个，就不进行反转。非常有意思的一道题目，依然可以写得很短，也可以写得很长。如果你用递归的办法去写，可以很快写完。如果你用迭代的办法去写，都会比较长。不管是否是调用了Reverse Linked List II中的函数，或者直接写一个大循环。

#### Reorder List
仔细观察后，发现本题的规律是，把链表后半段反转，然后依次插入到链表的前半段。

#### Rotate List
旋转链表。

### Topic 2 从数组排序迁移到链表排序
#### Insertion Sort List
用链表来模拟插入排序
#### Partition
用链表来模拟快排中的partition
#### Sort List
用链表来进行归并排序，完成时间复杂度为O(N lgN),空间复杂度为O(1)的排序
#### Merge Two Sorted Lists 
归并两个已经排好序的链表
#### Merge K Sorted Lists 
归并K个已经排好序的链表

### Topic 3 环形链表
#### Linked List Cycle
判断一个链表是否有环
#### Linked List Cycle II
如果一个链表有环，找到环的起始位置

### Topic 4 其它问题
#### Copy List with Random Pointer 
拷贝链表，链表的节点除了有next指针，还有random指针，指向任意一个点。
#### Remove Nth Node From End of List
删除从后向前数的第N个节点
#### Remove Duplicates from Sorted List 
去掉链表中的重复元素，使得原来链表中的所有元素都出现并且只出现一次。
#### Remove Duplicates from Sorted List II
去掉链表中的重复元素，使得原来链表中的非重复元素都出现并且只出现一次，重复元素不出现。