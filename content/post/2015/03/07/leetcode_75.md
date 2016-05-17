---
categories:
- 技术文章
date: 2015-03-07T22:30:08+08:00
description: "leetcode"
keywords:
- leetcode
title: LeetCode 75 Sort Colors
url: ""
---

```java
public class Solution {  
      
    public void sortColors(int[] A) {  
        if (A == null || A.length == 0) return;  
        int zero = 0;  
        int two = A.length - 1;  
        int i = 0;  
        while (i <= two) {  
            if (A[i] == 0) {  
                swap(A, zero, i);  
                zero++;  
            }  
            if (A[i] == 2) {  
                swap(A, i, two);  
                two--;  
            } else {  
                i++;  
            }  
        }  
    }  
    private void swap(int[] A, int a, int b) {  
        int temp = A[a];  
        A[a] = A[b];  
        A[b] = temp;  
    }  
}  
```

