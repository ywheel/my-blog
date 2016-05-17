---
categories:
- 技术文章
date: 2015-02-15T20:59:08+08:00
description: "leetcode"
keywords:
- leetcode
title: LeetCode 003 Longest Substring Without Repeating Characters
url: ""
---

```java
package ywheel.leetcode._003_longest_substring_without_repeating_characters;  
  
/** 
 * Given a string, find the length of the longest substring without repeating 
 * characters. For example, the longest substring without repeating letters for 
 * "abcabcbb" is "abc", which the length is 3. For "bbbbb" the longest substring 
 * is "b", with the length of 1. 
 *  
 * @author ywheel 
 *  
 */  
public class LongestSubString {  
    public int lengthOfLongestSubstring(String s) {  
        if (s == null || s.isEmpty()) {  
            return 0;  
        }  
        int maxLength = 0;  
        int[] index = new int[256];  
        for (int i = 0; i < 256; i++) {  
            index[i] = -1;  
        }  
        int strLen = s.length();  
        int length = 1;  
        index[s.charAt(0)] = 0;  
        for (int i = 1; i < strLen; i++) {  
            char ch = s.charAt(i);  
            if (i - index[ch] <= length) {  
                // repeat  
                maxLength = length > maxLength ? length : maxLength;  
                length = i - index[ch];  
            } else {  
                length++;  
            }  
            index[ch] = i; // set the last index of ch  
        }  
        maxLength = length > maxLength ? length : maxLength;  
        return maxLength;  
    }  
  
    public static void main(String[] args) {  
        LongestSubString solution = new LongestSubString();  
        String s = "abcabcbb";  
        System.out.println(solution.lengthOfLongestSubstring(s));  
        s = "bbbbbb";  
        System.out.println(solution.lengthOfLongestSubstring(s));  
    }  
} 
```
