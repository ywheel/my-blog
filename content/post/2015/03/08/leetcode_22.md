---
categories:
- 技术文章
date: 2015-03-08T23:55:08+08:00
description: "leetcode"
keywords:
- leetcode
title: LeetCode 22 Generate Parentheses
url: ""
---

连续两次随机到关于括号的题了，跟括号真有缘。。。

```java
package ywheel.leetcode._22_generate_parentheses;  
  
import java.util.ArrayList;  
import java.util.List;  
  
/** 
 * Given n pairs of parentheses, write a function to generate all combinations 
 * of well-formed parentheses. 
 *  
 * For example, given n = 3, a solution set is: 
 * "((()))", "(()())", "(())()", "()(())", "()()()" 
 *  
 * @author ywheel 
 *  
 */  
public class GenerateParentheses {  
    public List<String> generateParenthesis(int n) {  
        List<String> results = new ArrayList<String>();  
        if (n > 0) {  
            // the first one must be '('  
            generateNext(n, n - 1, "(", results);  
        }  
        return results;  
    }  
    private void generateNext(int n, int rest_num_left, String solution, List<String> results) {  
        if (rest_num_left > 0) {  
            // can append '('  
            generateNext(n, rest_num_left - 1, solution + "(", results);  
            if (solution.length() < (n - rest_num_left)*2) {  
                // can append ')'  
                generateNext(n, rest_num_left, solution + ")", results);  
            }  
        } else {  
            // has already append n '(', so the only one solution here  
            // is to append all the rest ')'                  
            int rest_len = n*2 - solution.length();  
            while (rest_len > 0) {  
                solution += ")";  
                rest_len--;  
            }  
            results.add(solution);  
        }  
    }  
      
    public static void main(String[] args) {  
        GenerateParentheses solution = new GenerateParentheses();  
        List<String> result = solution.generateParenthesis(3);  
        if (result != null) {  
            for (String str : result) {  
                System.out.print(str + ",");  
            }  
        }  
    }  
}  

```