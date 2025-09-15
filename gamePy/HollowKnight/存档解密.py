# coding=utf-8
# @Time    : 2025/8/25 20:58
# @Software: PyCharm
import os

import hollowAES

if __name__ == '__main__':
    # 空洞骑士存档位置：
    hollow_dat = "Hollow Knight/user1.dat"
    # 丝之歌存档位置
    silk_song_dat = "Hollow Knight Silksong/1079511766/user1.dat"
    input_file = os.path.join(os.path.expanduser("~"), "AppData/LocalLow/Team Cherry/" + silk_song_dat)

    # 读取文件内容
    with open(input_file, 'rb') as f:
        encrypted_data = f.read()

    un_padded = hollowAES.decode(encrypted_data)

    # 输出解密结果
    with open("存档解密_结果.json", 'w', encoding='utf-8') as file:
        file.write(un_padded)
    print("文件解密成功")
