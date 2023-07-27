var str1 = "67860";
var str2 = "67860,68023";

// 将两个字符串分割为数组
var arr1 = str1.split(',');
var arr2 = str2.split(',');

// 查找两个数组中的重复项
var duplicates = arr1.filter(item => arr2.includes(item));

if (duplicates.length > 0) {
  console.log("重复的数字是: " + duplicates.join(','));
} else {
  console.log("没有重复的数字");
}
