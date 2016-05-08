---
categories:
- 技术文章
date: 2015-02-14T13:59:08+08:00
description: "leetcode"
keywords:
- leetcode
title: leetcode_001_twosum
url: ""
---

```java
package ywheel.leetcode._001_two_sum;  
  
import java.util.Arrays;  
import java.util.Comparator;  
  
/** 
 * Given an array of integers, find two numbers such that they add up to a 
 * specific target number. 
 *  
 * The function twoSum should return indices of the two numbers such that they 
 * add up to the target, where index1 must be less than index2. Please note that 
 * your returned answers (both index1 and index2) are not zero-based. You may 
 * assume that each input would have exactly one solution. 
 *  
 * Input: numbers={2, 7, 11, 15}, target=9 Output: index1=1, index2=2 
 *  
 * @author ywheel 
 *  
 */  
public class TwoSum {  
    public int[] twoSum(final int[] numbers, int target) {  
        Integer[] index = new Integer[numbers.length];  
        for (int i = 0; i < numbers.length; i++) {  
            index[i] = i;  
        }  
        Arrays.sort(index, new Comparator<Integer>() {  
            public int compare(Integer o1, Integer o2) {  
                return Integer.compare(numbers[o1], numbers[o2]);  
            }  
        });  
        int[] result = new int[2];  
        for (int i = 0; i < numbers.length - 1; i++) {  
            for (int j = i + 1; j < numbers.length; j++) {  
                int sum = numbers[index[i]] + numbers[index[j]];  
                if (sum == target) {  
                    result[0] = (index[i] < index[j] ? index[i] : index[j]) + 1;  
                    result[1] = (index[i] > index[j] ? index[i] : index[j]) + 1;  
                    return result;  
                } else if (sum > target) {  
                    break;  
                }  
            }  
        }  
        return null;  
    }  
  
    public static void main(String[] args) {  
        TwoSum solution = new TwoSum();  
        int[] numbers = { 2, 7, 11, 15 };  
        int target = 9;  
        int[] results = solution.twoSum(numbers, target);  
        for (int index = 0; index < results.length; index++) {  
            System.out  
                    .print("index" + (index + 1) + "=" + results[index] + " ");  
        }  
  
    }  
}  
```