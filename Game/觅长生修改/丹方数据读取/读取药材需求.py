# coding=utf-8
# @Time    : 2024/11/18 20:53
# @Software: PyCharm
import pandas as pd

# 输入的csv文件
inputFile = '药材性质.csv'

# 读取CSV文件(如果读取失败，请手动将对应csv文件转为utf8格式)
df = pd.read_csv(inputFile, encoding='utf-8')

# 获取需要的列
df = df[['品级', '名字', '主药', '辅药', '药引', '药力']]

# 逐行打印其json格式
for index, row in df.iterrows():
    print("{", end='')
    print(
        f"ind: {index}, name: \"{row['名字']}({row['品级']})\"," +
        f"main: \"{row['主药']}\",pu: \"{row['辅药']}\",lead: \"{row['药引']}\",power: {row['药力']}",
        end='')
    print("},")
