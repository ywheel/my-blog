---
categories:
- 技术文章
date: 2015-03-07T21:59:08+08:00
description: "leetcode"
keywords:
- leetcode
title: LeetCode 129 Sum Root to Leaf Numbers
url: ""
---

```java
/** 
 * Definition for binary tree 
 * public class TreeNode { 
 *     int val; 
 *     TreeNode left; 
 *     TreeNode right; 
 *     TreeNode(int x) { val = x; } 
 * } 
 */  
public class Solution {  
    public int sumNumbers(TreeNode root) {  
        return sumSubTree(0, root);  
    }  
      
    private int sumSubTree(int decade, TreeNode subTreeRoot) {  
        int sum = 0;  
        if (subTreeRoot == null) {  
            return 0;  
        } else {  
            if (subTreeRoot.left == null && subTreeRoot.right == null) {  
                // leaf node  
                sum = decade * 10 + subTreeRoot.val;  
            } else {  
                // has child node  
                if (subTreeRoot.left != null) {  
                    sum += sumSubTree(decade*10+subTreeRoot.val, subTreeRoot.left);  
                }  
                if (subTreeRoot.right != null) {  
                    sum += sumSubTree(decade*10+subTreeRoot.val, subTreeRoot.right);  
                }  
            }  
        }  
        return sum;  
    }  
}  
```