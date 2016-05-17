---
categories:
- 技术文章
date: 2015-03-08T22:20:08+08:00
description: "leetcode"
keywords:
- leetcode
title: LeetCode 32 Longest Valid Parentheses
url: ""
---

题目大意是给定一个只有左右括号组成的字符串，求最长的valid字串长度，比如“()”的最长valid字串长度为2，“)()())”的最长valid字串为"()()"，则长度为4.

拿到这个题目第一反应就是用Stack，但是Stack里面装什么呢？如何表示Valid最大长度？后来想到是否能够把还没匹配好的括号的index放到stack中，如果有匹配的就pop，没有就push。当pop的时候判断stack是否为空，如果空了，则该index之前的字串都是valid；如果不为空，则该index与stack中的peek之差就是当前valid子串的长度。
代码如下：

```java
public class Solution {  
    public int longestValidParentheses(String s) {  
        int max = 0;  
        if (s == null || s.isEmpty()) return max;  
        int len = s.length();  
        Stack<Integer> stack = new Stack<Integer>();  
        for (int i=0; i<len; i++) {  
            char c = s.charAt(i);  
            if (c == ')' && !stack.isEmpty() && s.charAt(stack.peek()) == '(') {  
                stack.pop();  
                if (stack.isEmpty()) {  
                    max  = i+1;  
                } else {  
                    int valid_len = i - stack.peek();  
                    max = max > valid_len ? max : valid_len;  
                }  
            } else {  
                stack.push(i);  
            }  
        }  
        return max;  
    }  
}  
```
 
看到一篇博文，也可以用一维DP去解，等有空时再细研究。附上链接：[点击打开链接](https://leetcodenotes.wordpress.com/2013/10/19/leetcode-longest-valid-parentheses-%E8%BF%99%E7%A7%8D%E6%8B%AC%E5%8F%B7%E7%BB%84%E5%90%88%EF%BC%8C%E6%9C%80%E9%95%BF%E7%9A%84valid%E6%8B%AC%E5%8F%B7%E7%BB%84%E5%90%88%E6%9C%89%E5%A4%9A/)
