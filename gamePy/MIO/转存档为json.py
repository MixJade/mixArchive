# coding=utf-8
# @Time    : 2026/2/2 21:17
# @Software: PyCharm
import json
import os
import re

"""将MIO存档的save文本转换为JSON格式
"""
# 1. 定义正则表达式（匹配三种核心行，提取关键数据）
# 匹配 key 行：例如 pairs.617.key = String("DIALOG:VO_EN_KHLIA_ENDING_FAREWELL_H")
key_pattern = re.compile(r'pairs\.(\d+)\.key\s*=\s*String\("([^"]+)"\)')
# 匹配 flags 行：例如 pairs.617.value.flags = Flags("Acquired")
flags_pattern = re.compile(r'pairs\.(\d+)\.value\.flags\s*=\s*Flags\("([^"]+)"\)')
# 匹配 count 行：例如 pairs.617.value.count = i32(1)
count_pattern = re.compile(r'pairs\.(\d+)\.value\.count\s*=\s*i32\((\d+)\)')

# 2. 初始化用于存储数据的字典（最终转为 JSON）
result_dict = {"pairs": []}
# 临时字典，用于缓存同一索引的所有数据（避免重复创建）
temp_pairs = {}

# 3. 逐行读取并解析文件
input_file = os.path.join(os.path.expanduser("~"), "AppData/Local/MIO/Saves/Steam/76561199039777494/slot_0.save")
with open(input_file, 'r', encoding='utf-8') as f:
    for line_num, line in enumerate(f, 1):
        # 去除首尾空白字符（空格、换行、制表符等）
        line_stripped = line.strip()
        # 跳过空行和无效行
        if not line_stripped or not line_stripped.startswith("pairs"):
            continue

        # 匹配 key 行
        key_match = key_pattern.match(line_stripped)
        if key_match:
            idx = key_match.group(1)
            key_value = key_match.group(2)
            # 初始化该索引的字典（若不存在）
            if idx not in temp_pairs:
                temp_pairs[idx] = {"key": "", "value": {"flags": "", "count": 0}}
            temp_pairs[idx]["key"] = key_value
            continue

        # 匹配 flags 行
        flags_match = flags_pattern.match(line_stripped)
        if flags_match:
            idx = flags_match.group(1)
            flags_value = flags_match.group(2)
            if idx not in temp_pairs:
                temp_pairs[idx] = {"key": "", "value": {"flags": "", "count": 0}}
            temp_pairs[idx]["value"]["flags"] = flags_value
            continue

        # 匹配 count 行
        count_match = count_pattern.match(line_stripped)
        if count_match:
            idx = count_match.group(1)
            count_value = int(count_match.group(2))  # 转换为整数（符合 JSON 数据类型）
            if idx not in temp_pairs:
                temp_pairs[idx] = {"key": "", "value": {"flags": "", "count": 0}}
            temp_pairs[idx]["value"]["count"] = count_value
            continue

# 4. 整理临时数据，转换为最终的列表格式（按索引排序，更规范）
for idx in sorted(temp_pairs.keys(), key=lambda x: int(x)):
    result_dict["pairs"].append(temp_pairs[idx])

# 5. 转换为格式化的 JSON 字符串
json_str = json.dumps(result_dict, ensure_ascii=False, indent=4)

# 6. 若指定输出路径，将 JSON
file_name = input("请输入名称：")
output_file = f"{file_name}_结果.json"
with open(output_file, 'w', encoding='utf-8') as json_file:
    json_file.write(json_str)
print(f"JSON 文件已成功生成：{output_file}")
