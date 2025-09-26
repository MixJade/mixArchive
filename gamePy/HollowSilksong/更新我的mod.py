# coding=utf-8
# @Time    : 2025/9/7 20:12
# @Software: PyCharm
import os
import shutil


def copy_file_to_file(source_file, target_file):
    """将源文件复制到目标文件，如果目标文件不存在则警告
    """
    try:
        # 检查源文件是否存在
        if not os.path.exists(source_file):
            raise FileNotFoundError(f"源文件不存在: {source_file}")
        # 检查目标文件是否存在
        if not os.path.exists(target_file):
            print(f"目标文件不存在: {target_file}")
        # 复制文件
        shutil.copy2(source_file, target_file)
        print(f"文件已成功复制: {target_file}")
    except Exception as e:
        print(f"复制文件时出错: {str(e)}")


# 使用示例
if __name__ == "__main__":
    # 源dll文件
    source_file_1 = os.path.join(os.path.expanduser("~"), r"source\repos\MixSilkSongMod\bin\Debug\MixSilkSongMod.dll")
    # 目标dll文件
    target_file_1 = r"C:\Program Files (x86)\Steam\steamapps\common\Hollow Knight Silksong" \
                    r"\BepInEx\plugins\MixSilkSongMod.dll"
    copy_file_to_file(source_file_1, target_file_1)

    # 源cs文件
    source_file_2 = os.path.join(os.path.expanduser("~"), r"source\repos\MixSilkSongMod\MixSilkPlugin.cs")
    # 目标cs文件
    target_file_2 = r"MixSilkPlugin.cs"
    copy_file_to_file(source_file_2, target_file_2)

    # 源dll文件
    source_file_3 = os.path.join(os.path.expanduser("~"), r"source\repos\SureGodSwimMod\bin\Debug\SureGodSwimMod.dll")
    # 目标dll文件
    target_file_3 = r"C:\Program Files (x86)\Steam\steamapps\common\Hollow Knight Silksong" \
                    r"\BepInEx\plugins\SureGodSwimMod.dll"
    copy_file_to_file(source_file_3, target_file_3)
    # 源cs文件2
    source_file_4 = os.path.join(os.path.expanduser("~"), r"source\repos\SureGodSwimMod\SureGodSwim.cs")
    # 目标cs文件2
    target_file_4 = r"SureGodSwim.cs"
    copy_file_to_file(source_file_4, target_file_4)
