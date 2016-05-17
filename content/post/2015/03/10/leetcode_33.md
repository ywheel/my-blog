---
categories:
- 技术文章
date: 2015-03-10T01:45:08+08:00
description: "leetcode"
keywords:
- leetcode
title: LeetCode 33 Search in Rotated Sorted Array 二叉查找（三）
url: ""
---

题目：

```
https://leetcode.com/problems/search-in-rotated-sorted-array/
Suppose a sorted array is rotated at some pivot unknown to you beforehand.

(i.e., 0 1 2 4 5 6 7 might become 4 5 6 7 0 1 2).

You are given a target value to search. If found in the array return its index, otherwise return -1.

You may assume no duplicate exists in the array.
```

想当年校招的时候做过这一题，而且不是写在纸上的。故事是这样的。。。。（以上省略1万字，大意就是面试官拿着他的Thinkpad扔给了我问会写JAVA吗？会用eclipse吗？好，打开eclipse写吧，于是乎我就开始写，自己造了几个case都pass了，面试官一看总感觉哪里不对，狂试好几个，终于试出来个bug）
两年过去了，现在我正拿着该公司的macbook pro重新练习着这道题。。。依然写了几遍才过。。。哎

又说多了，大概解法就是需要找到有序的一半是在哪里，找到了之后就看target是否在有序的那一半的范围内：

```java
public class Solution {  
    public int search(int[] A, int target) {  
        if (A == null || A.length == 0) {  
            return -1;  
        }  
        int l = 0;  
        int r = A.length - 1;  
        while (l <= r) {  
            int mid = (l + r) / 2;  
            if (A[mid] == target) {  
                return mid;  
            } else if (A[mid] < A[r]) {  
                // right side is sorted  
                if (target >= A[mid] && target <= A[r]) {  
                    l = mid + 1;  
                } else {  
                    r = mid - 1;  
                }  
            } else {  
                // left side is sorted  
                if (target >= A[l] && target <= A[mid]) {  
                    r = mid - 1;  
                } else {  
                    l = mid + 1;  
                }  
            }  
        }  
        return -1;  
    }  
}  
```