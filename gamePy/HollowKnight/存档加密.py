# coding=utf-8
# @Time    : 2025/8/25 20:58
# @Software: PyCharm
import os

import hollowAES

if __name__ == '__main__':
    # 配置参数
    input_file = "存档解密_结果.json"  # 输入的明文JSON文件
    # 空洞骑士存档位置：
    hollow_dat = "Hollow Knight/user1.dat"
    # 丝之歌存档位置
    silk_song_dat = "Hollow Knight Silksong/1079511766/user1.dat"
    output_file = os.path.join(os.path.expanduser("~"), "AppData/LocalLow/Team Cherry/" + silk_song_dat)

    # 读取明文内容
    with open(input_file, 'r', encoding='utf-8') as f:
        plaintext = f.read()

    # 组装最终数据（头部 + 长度前缀 + 数据 + 结尾字节）
    final_data = hollowAES.encode(plaintext)

    # 写入加密文件
    with open(output_file, 'wb') as f:
        f.write(final_data)
    print("加密写回成功")
