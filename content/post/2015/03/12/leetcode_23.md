---
categories:
- 技术文章
date: 2015-03-12T02:52:08+08:00
description: "leetcode"
keywords:
- leetcode
title: LeetCode 023 Merge K Sorted Lists
url: ""
---

题：

```
https://leetcode.com/problems/merge-k-sorted-lists/
Merge k sorted linked lists and return it as one sorted list. Analyze and describe its complexity.
```

### 解法一
将K个链表做K-1次归并，每次归并是对两个链表的归并，最终得到一个排序的链表。即：
1，2合并，遍历2n个节点；(1,2)与3合并，遍历3n个节点。。。(1...k-1)与k合并，遍历kn个节点。所以总共遍历n*(2+3+...+k)=n*(k^2+k-2)/2，那么时间复杂度为O(n*k^2)。

### 解法二
对解法一改进一下，改用分治法，所以时间复杂度变为O(nklogk)。

### 解法三
将K个链表的首元素都取出来，选择出最小的那个作为新链表的head。然后将该元素的next取出来，与其他链表的元素比较再选一个小的，放到新链表中。选择出最小元素的时间复杂度为O(k), 总共要选nk次，所以时间复杂度为O(n*k^2)。

### 解法四
对解法三改进一下，用最小堆来实现选择最小元素的要求，则时间复杂度降为O(logk)，则总的时间复杂度为O(nklogk)，与解法二的时间复杂度一样。在Java中，可以使用基于
最小堆算法的PriorityQueue来作为最小堆的集合类。代码如下：

```java
/** 
 * Definition for singly-linked list. 
 * public class ListNode { 
 *     int val; 
 *     ListNode next; 
 *     ListNode(int x) { 
 *         val = x; 
 *         next = null; 
 *     } 
 * } 
 */  
public class Solution {  
    public ListNode mergeKLists(List<ListNode> lists) {  
        if (lists == null || lists.isEmpty()) {  
            return null;  
        }  
        PriorityQueue<ListNode> minHeap = new PriorityQueue<ListNode>(new Comparator<ListNode>(){  
            public int compare(ListNode l1, ListNode l2) {  
                return Integer.compare(l1.val, l2.val);  
            }  
        });  
        for (ListNode node : lists) {  
            if (node != null) {  
                minHeap.add(node);  
            }  
        }  
        ListNode helper = new ListNode(0);  
        ListNode next = helper;  
        while (!minHeap.isEmpty()) {  
            ListNode min = minHeap.poll(); // must not be null  
            next.next = min;  
            min = min.next;  
            if (min != null) {  
                minHeap.add(min);  
            }  
            next = next.next;  
        }  
        return helper.next;  
    }  
}  
```