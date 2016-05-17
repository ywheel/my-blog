---
categories:
- 技术文章
date: 2015-03-11T01:26:08+08:00
description: "leetcode"
keywords:
- leetcode
title: LeetCode 066 Plus one
url: ""
---

题目：

```
https://leetcode.com/problems/plus-one/
Given a non-negative number represented as an array of digits, plus one to the number.

The digits are stored such that the most significant digit is at the head of the list.
```

题目虽简单，但是要注意的是当最高位是9的时候， 需要重新new一个长一位的新数组来存储结果。

```java
public class Solution {  
    public int[] plusOne(int[] digits) {  
        if (digits == null || digits.length == 0) return digits;  
        int carry = 1;  
        for (int i=digits.length - 1; i >= 0; i--) {  
            digits[i] = digits[i] + carry;  
            if (digits[i] < 10) {  
                return digits;  
            } else {  
                digits[i] = 0;  
                carry = 1;  
            }  
        }  
        int[] newDigits = new int[digits.length + 1];  
        newDigits[0] = 1;  
        System.arraycopy(digits, 0, newDigits, 1, digits.length);  
        return newDigits;  
    }  
}  
```