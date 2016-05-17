---
categories:
- 技术文章
date: 2015-03-17T00:16:08+08:00
description: "leetcode"
keywords:
- leetcode
title: LeetCode 119 Pascal's Triangle II
url: ""
---

题：

```
https://leetcode.com/problems/pascals-triangle-ii/
Given an index k, return the kth row of the Pascal's triangle.

For example, given k = 3,
Return [1,3,3,1].

Note:
Could you optimize your algorithm to use only O(k) extra space?
```


解法较容易，时间复杂度依然是0(n^2)，要实现空间复杂度得考虑在内层循环时从后往前看，这样的话上一行的结果不会被覆盖。

```java
public class Solution {  
    public List<Integer> getRow(int rowIndex) {  
        if (rowIndex < 0) return null;  
        List<Integer> results = new ArrayList<Integer>(rowIndex + 1);  
        for (int row=0; row < rowIndex; row++) {  
            results.add(1);  
            for (int i=row; i>0; i--) {  
                results.set(i, results.get(i - 1) + results.get(i));  
            }  
        }  
        results.add(1); // add last 1  
        return results;  
    }  
}  
```