# coding=utf-8
# @Time    : 2024/11/18 19:56
# @Software: PyCharm
import pandas as pd

# 输入的csv文件
inputFile = '丹方需求.csv'

# 读取CSV文件(如果读取失败，请手动将对应csv文件转为utf8格式)
df = pd.read_csv(inputFile, encoding='utf-8')

# 获取需要的列
df = df[['name', 'level', 'info', 'main', 'mainNeed', 'pu1', 'pu1Need', 'pu2', 'pu2Need', 'leadIn']]

# 逐行打印其json格式
for index, row in df.iterrows():
    print("{" + f"ind={index},", end='')
    print(
        f"name: \"{row['name']}\",level: {row['level']},info: \"{row['info']}\"," +
        f"main: \"{row['main']}\",mainNeed: {row['mainNeed']}",
        end='')
    if not pd.isna(row['pu1']):
        print(f",pu1: \"{row['pu1']}\",pu1Need: {row['pu1Need']}", end='')
    if not pd.isna(row['pu2']):
        print(f",pu2: \"{row['pu2']}\",pu2Need: {row['pu2Need']}", end='')
    print(f",leadIn: {row['leadIn']}", end='')
    print("},")
