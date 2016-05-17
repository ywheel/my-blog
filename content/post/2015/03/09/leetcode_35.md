---
categories:
- 技术文章
date: 2015-03-09T23:41:08+08:00
description: "leetcode"
keywords:
- leetcode
title: LeetCode 35 Search Insert Position 二叉查找相关（一）
url: ""
---

题目：

```
https://leetcode.com/problems/search-insert-position/
Given a sorted array and a target value, return the index if the target is found. If not, return the index where it would be if it were inserted in order.

You may assume no duplicates in the array.

Here are few examples.
[1,3,5,6], 5 → 2
[1,3,5,6], 2 → 1
[1,3,5,6], 7 → 4
[1,3,5,6], 0 → 0
```

考查基本的二叉查找算法，直接上代码：

```java
public class Solution {  
    public int searchInsert(int[] A, int target) {  
        if (A == null || A.length == 0) {  
            return 0;  
        }  
        int l = 0;  
        int r = A.length - 1;  
        while (l <= r) {  
            int mid = (l + r) / 2;  
            if (A[mid] == target) {  
                return mid;  
            } else if (A[mid] < target) {  
                l = mid + 1;  
            } else {  
                r = mid -1;  
            }  
        }  
        return l;  
    }  
}  
```