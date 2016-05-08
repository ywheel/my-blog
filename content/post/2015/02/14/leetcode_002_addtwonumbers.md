---
categories:
- 技术文章
date: 2015-02-14T14:59:23+08:00
description: "leetcode"
keywords:
- leetcode
title: leetcode_002_addtwonumbers
url: ""
---

```java
package ywheel.leetcode._002_add_two_numbers;  
  
/** 
 * You are given two linked lists representing two non-negative numbers. The 
 * digits are stored in reverse order and each of their nodes contain a single 
 * digit. Add the two numbers and return it as a linked list. 
 *  
 * Input: (2 -> 4 -> 3) + (5 -> 6 -> 4) Output: 7 -> 0 -> 8 
 *  
 * @author ywheel 
 *  
 */  
public class AddTwoNumbers {  
    public ListNode addTwoNumbers(ListNode l1, ListNode l2) {  
        ListNode next = null;  
        ListNode head = null;  
        int decade = 0;  
        while (l1 != null || l2 != null || decade > 0) {  
            int l1_val = l1 == null ? 0 : l1.val;  
            int l2_val = l2 == null ? 0 : l2.val;  
            int sum = l1_val + l2_val + decade;  
            ListNode newNode = new ListNode(sum % 10);  
            decade = sum / 10;  
            if (next == null) {  
                next = newNode;  
                head = next;  
            } else {  
                next.next = newNode;  
                next = next.next;  
            }  
            l1 = l1 == null ? null : l1.next;  
            l2 = l2 == null ? null : l2.next;  
        }  
        return head;  
    }  
  
    public static void main(String[] args) {  
        AddTwoNumbers solution = new AddTwoNumbers();  
        // construct two inputs  
        ListNode l1 = new ListNode(2);  
        ListNode l11 = new ListNode(4);  
        ListNode l12 = new ListNode(3);  
        l1.next = l11;  
        l11.next = l12;  
        ListNode l2 = new ListNode(5);  
        ListNode l21 = new ListNode(6);  
        ListNode l22 = new ListNode(4);  
        l2.next = l21;  
        l21.next = l22;  
        ListNode resultNode = solution.addTwoNumbers(l1, l2);  
        if (resultNode != null) {  
            System.out.print(resultNode.val);  
        }  
        while (resultNode.next != null) {  
            resultNode = resultNode.next;  
            System.out.print("->" + resultNode.val);  
        }  
    }  
}  
  
/** 
 * Definition for singly-linked list. 
 */  
class ListNode {  
    int val;  
    ListNode next;  
  
    ListNode(int x) {  
        val = x;  
        next = null;  
    }  
}  
```