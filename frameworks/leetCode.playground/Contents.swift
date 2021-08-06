import UIKit

// MARK: Given a string s, determine if it is a palindrome, considering only alphanumeric characters and ignoring cases.

func isPalindrome(_ s: String) -> Bool {
    var lowCasedString = s.lowercased()
    lowCasedString.removeAll(where: { !$0.isNumber && !$0.isLetter })
    let lowCasedStringArray = lowCasedString.map({$0})

    var l = 0, r = lowCasedString.count - 1

    while r >= 0 && l != r {
        if lowCasedStringArray[l] != lowCasedStringArray[r] {
            return false
        }
        l += 1
        r -= 1
    }

    return true
}

// MARK: Given a string s, reverse only all the vowels (гласные) in the string and return it.

func reverseVowels(_ s: String) -> String {

    guard !s.isEmpty else { return "" }

    let dict: [Character] = ["a", "e", "u", "o", "i", "A", "E", "U", "O", "I"]
    var l = 0, r = s.count - 1
    var data: [Character] = s.map({$0})

    while l < r {
        if (dict.contains(data[l]) && dict.contains(data[r])) {
            data.swapAt(l, r)
            l += 1
            r -= 1
        } else if dict.contains(data[l]) && !dict.contains(data[r]) {
            r -= 1
        } else if dict.contains(data[r]) && !dict.contains(data[l]) {
            l += 1
        } else if !dict.contains(data[l]) && !dict.contains(data[r]) {
            l += 1
            r -= 1
        }
    }

    return String(data)
}

// MARK: Given an array of integers numbers that is already sorted in non-decreasing order, find two numbers such that they add up to a specific target number.

func twoSum(_ numbers: [Int], _ target: Int) -> [Int] {

    var l = 0, r = numbers.count - 1

    while l < r {
        let currSum = numbers[l] + numbers[r]
        if currSum == target {
            break
        } else if currSum > target {
            r -= 1
        } else if currSum < target {
            l += 1
        }
    }

    return [l + 1, r + 1]
}

// MARK: Given an integer array nums, move all 0's to the end of it while maintaining the relative order of the non-zero elements. Note that you must do this in-place without making a copy of the array.

func moveZeroes(_ nums: inout [Int]) {
    guard nums.count > 1 else { return }
    var l = 0, r = 0

    while r < nums.count {
        if nums[l] != 0 && nums[r] != 0 {
            l += 1
            r += 1
        }
        if nums[l] == 0 && nums[r] == 0 {
            r += 1
        }
        if nums[l] == 0 && nums[r] != 0 {
            nums.swapAt(l, r)
            l += 1
            r += 1
        }
    }
}

// MARK: Given two integer arrays nums1 and nums2, return an array of their intersection. Each element in the result must appear as many times as it shows in both arrays and you may return the result in any order.

func intersect(_ nums1: [Int], _ nums2: [Int]) -> [Int] {


    return []
}
