# coding=utf-8
# @Time    : 2025/10/7 11:01
# @Software: PyCharm
import re

# 读取文件内容
with open(r'开发相关文档/跳蚤位置（直接复制）.txt', 'r', encoding='utf-8') as f:
    content = f.read()

# 正则模式：匹配包含x、y、z、scene的组合（允许中间有换行和空格）
pattern = r'''
    "x":\s*(\d+\.\d+),\s*      # 匹配x的值（带小数）
    "y":\s*(\d+\.\d+),\s*      # 匹配y的值（带小数）
    "z":\s*(\d+\.\d+),\s*      # 匹配z的值（带小数）
    "scene":\s*"([^"]+)",       # 匹配scene的场景名
'''


# 替换函数：处理x和y（取整数部分+1），并重组格式
def replace_func(match):
    x_val = float(match.group(1))
    y_val = float(match.group(2))
    scene = match.group(4)

    # 处理x和y：去小数部分后+1
    x_processed = int(x_val) + 1
    y_processed = int(y_val) + 1

    # 返回目标格式（单引号包裹）
    return f"'{scene}({x_processed},{y_processed})'"


# 使用VERBOSE模式忽略正则中的空格和注释，更易读
new_content = re.sub(pattern, replace_func, content, flags=re.VERBOSE)

# 写入结果
out_filename = "开发相关文档/跳蚤位置_结果.txt"
with open(out_filename, 'w', encoding='utf-8') as f:
    f.write(new_content)

print("处理完成，结果已保存到 " + out_filename)
