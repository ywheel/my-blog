---
categories:
- 技术文章
date: 2015-03-12T00:36:08+08:00
description: "leetcode"
keywords:
- leetcode
title: LeetCode 088 Merge Sorted Array
url: ""
---

题：

```
https://leetcode.com/problems/merge-sorted-array/
Given two sorted integer arrays A and B, merge B into A as one sorted array.

Note:
You may assume that A has enough space (size that is greater or equal to m + n) to hold additional elements from B. The number of elements initialized in A and B are m and n respectively.
```

```java
public class Solution {  
    public void merge(int A[], int m, int B[], int n) {  
        if (A == null || B == null || A.length == 0 || B.length == 0 || A.length <  m+n) {  
            return;  
        }  
        int a = m - 1;  
        int b = n - 1;  
        for (int i=m+n-1; i>=0; i--) {  
            if (a >=0 && b >= 0) {  
                if (A[a] > B[b]) {  
                    A[i] = A[a--];  
                } else {  
                    A[i] = B[b--];  
                }  
            } else if (a < 0) {  
                // only left B  
                System.arraycopy(B, 0, A, 0, i+1);  
            } // else {  
                // only left A, do nothing  
            //}  
        }  
    }  
}  
```

往事不堪回首，当初某游戏公司的面试尽然倒在这题上，哎。。。说多了都是泪