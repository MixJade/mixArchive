# coding=utf-8
# @Time    : 2026/2/2 21:17
# @Software: PyCharm
import json
import os
import re
import shutil
import time


def turn_mio_save_to_json_str(input_file_path: str) -> str:
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
    with open(input_file_path, 'r', encoding='utf-8') as f:
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
    return json.dumps(result_dict, ensure_ascii=False, indent=4)


input_file = os.path.join(os.path.expanduser("~"), "AppData/Local/MIO/Saves/Steam/76561199039777494/slot_0.save")
# 时间序列
# 6. 若指定输出路径，将 JSON 写入文件
formatted_time = time.strftime("%m%d%H%M%S", time.localtime(time.time()))
# 元件类型
cell_tp_map = {"0": "老旧核心", "1": "镀层部件", "2": "先祖遗产", "3": "蜡烛", "4": "序列号", "5": "其它"}
cell_tp = input("你发现了什么？（0老旧核心 1镀层部件 2先祖遗产 3蜡烛 4序列号 5其它）")
cell_tp_name = cell_tp_map[cell_tp]
# 自定义名称
file_name = input("请为它命名：")
for item in ["_前", "_后"]:
    if item == "_后":
        while True:
            check_type = input("你得到它了吗？（输入1确认）")
            if check_type == "1":
                break
    output_file_name = f"{formatted_time}{cell_tp_name}_{file_name}{item}"
    json_str = turn_mio_save_to_json_str(input_file)
    with open(f"{output_file_name}_结果.json", 'w', encoding='utf-8') as json_file:
        json_file.write(json_str)

    # 备份存档
    os.makedirs("save_bak", exist_ok=True)
    target_file_path = os.path.join("save_bak", f"{output_file_name}_结果.save")
    shutil.copy2(input_file, target_file_path)
    print(f"{output_file_name} JSON已生成，存档已复制")
