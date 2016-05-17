---
categories:
- 技术文章
date: 2015-03-12T00:16:08+08:00
description: "leetcode"
keywords:
- leetcode
title: LeetCode 147 Insertion Sort List
url: ""
---

题：

```
https://leetcode.com/problems/insertion-sort-list/
Sort a linked list using insertion sort.
```

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
    public ListNode insertionSortList(ListNode head) {  
        if (head == null) return head;  
        // start from second node  
        ListNode node = head.next;  
        ListNode nodePrev = head;  
        while (node != null) {  
            // start from head node  
            ListNode prev = head;  
            ListNode curr = head;  
            while (curr != node) {  
                if (node.val < curr.val) {  
                    // insert node before curr  
                    nodePrev.next = node.next;  
                    node.next = curr;  
                    if (curr == head) {  
                        head = node;  
                    } else {  
                        prev.next = node;  
                    }  
                    node = nodePrev.next;  
                    break;  
                } else {  
                    // continue  
                    prev = curr == head ? head : prev.next;  
                    curr = curr.next;  
                }  
            }  
            if (curr == node) {  
                node = node.next;  
                nodePrev = nodePrev.next;  
            }  
        }  
        return head;  
    }  
}  

```