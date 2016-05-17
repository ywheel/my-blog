---
categories:
- 技术文章
date: 2015-03-10T00:07:08+08:00
description: "leetcode"
keywords:
- leetcode
title: LeetCode 34 Search For A Range 二叉查找相关（二）
url: ""
---

题目：

```
https://leetcode.com/problems/search-for-a-range/
Given a sorted array of integers, find the starting and ending position of a given target value.

Your algorithm's runtime complexity must be in the order of O(log n).

If the target is not found in the array, return [-1, -1].

For example,
Given [5, 7, 7, 8, 8, 10] and target value 8,
return [3, 4].
```

最直接的想法就是先二叉查找到target的一个index，然后再往左往右分别查找边界，这样实际上有三遍二叉查找，代码如下：

```java
public class Solution {  
    public int[] searchRange(int[] A, int target) {  
        int[] result = {-1, -1};  
        if (A == null || A.length == 0) {  
            return result;  
        }  
        int l = 0;  
        int r = A.length - 1;  
        boolean hasTarget = false;  
        int mid = (l + r) / 2;  
        while (l <= r) {  
            mid = (l + r) / 2;  
            if (A[mid] == target) {  
                hasTarget = true;  
                break;  
            } else if (A[mid] < target) {  
                l = mid + 1;  
            } else {  
                r = mid -1;  
            }  
        }  
        if (!hasTarget) {  
            return result;  
        }  
        // at this point, A[mid] = target, then need to find the range  
        // 1. find left range  
        l = 0;  
        r = mid;  
        result[1] = mid;  
        while (l <= r) {  
            mid = (l + r) / 2;  
            if (A[mid] == target) {  
                r = mid - 1;  
            } else {  
                // must be less than target  
                l = mid + 1;  
            }  
        }  
        result[0] = l;  
        // 2. find right range  
        l = result[1];  
        r = A.length - 1;  
        while (l <= r) {  
            mid = (l + r) / 2;  
            if (A[mid] == target) {  
                l = mid + 1;  
            } else {  
                // must be great than target  
                r = mid - 1;  
            }  
        }  
        result[1] = r;  
          
        return result;  
    }  
}  
```

提交之后发现运行时间排在JAVA类的靠后，有没有优化的空间呢？
发现其实并不需要先找到一个Index之后再找左右的边界，可以一遍二叉查找左边界，再来一次查找右边界，代码如下：

```java
public class Solution {  
    public int[] searchRange(int[] A, int target) {  
        int[] result = {-1, -1};  
        if (A == null || A.length == 0) {  
            return result;  
        }  
        int l = 0;  
        int r = A.length - 1;  
        // 1. find left range  
        while (l <= r) {  
            int mid = (l + r) / 2;  
            if (A[mid] >= target) {  
                r = mid - 1;  
            } else {  
                l = mid + 1;  
            }  
        }  
        if (l >= A.length || A[l] != target) {  
            // not found  
            return result;  
        }  
        result[0] = l;  
        // 2. find right range  
        r = A.length - 1;  
        while (l <= r) {  
            int mid = (l + r) / 2;  
            if (A[mid] == target) {  
                l = mid + 1;  
            } else {  
                // must be great than target  
                r = mid - 1;  
            }  
        }  
        result[1] = r;  
          
        return result;  
    }  
}  
```