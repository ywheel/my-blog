---
categories:
- 技术文章
date: 2015-03-12T01:43:08+08:00
description: "leetcode"
keywords:
- leetcode
title: LeetCode 021 Merge Two Sorted Lists
url: ""
---

题：

````
https://leetcode.com/problems/merge-two-sorted-lists/
Merge two sorted linked lists and return it as a new list. The new list should be made by splicing together the nodes of the first two lists.
```

解法一：创建一个新的链表：

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
    public ListNode mergeTwoLists(ListNode l1, ListNode l2) {  
        if (l1 == null && l2 == null) {  
            return null;  
        } else if (l1 == null) {  
            return l2;  
        } else if (l2 == null) {  
            return l1;  
        } else {  
            ListNode head = null;  
            ListNode next = new ListNode(0); // before head  
            while (l1 != null || l2 != null) {  
                if (l1 != null && l2 != null) {  
                    if (l1.val < l2.val) {  
                        next.next = l1;  
                        l1 = l1.next;  
                    } else {  
                        next.next = l2;  
                        l2 = l2.next;  
                    }  
                } else if (l1 == null) {  
                    next.next = l2;  
                    l2 = l2.next;  
                } else {  
                    next.next = l1;  
                    l1 = l1.next;  
                }  
                head = head == null ? next.next : head;  
                next = next.next;  
            }  
            return head;  
        }  
    }  
}  
```

解法二：将l2加入到l1中

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
    public ListNode mergeTwoLists(ListNode l1, ListNode l2) {  
        if (l1 == null && l2 == null) {  
            return null;  
        } else if (l1 == null) {  
            return l2;  
        } else if (l2 == null) {  
            return l1;  
        } else {  
            // merge l2 to l1  
            ListNode head = null;  
            ListNode prev = null;  
            while (l2 != null) {  
                if (l1 == null) {  
                    prev.next = l2;  
                    break;  
                }  
                if (l1.val > l2.val) {  
                    if (prev == null) {  
                        prev = l2;  
                    } else {  
                        prev.next = l2;  
                    }  
                    ListNode node = l2.next;  
                    l2.next = l1;  
                    prev = l2;  
                    l2 = node;  
                } else {  
                    prev = l1;  
                    l1 = l1.next;  
                }  
                head = head == null ? prev : head;  
                  
            }  
            return head;  
        }  
    }  
}  
```