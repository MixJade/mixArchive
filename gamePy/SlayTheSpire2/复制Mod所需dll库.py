# coding=utf-8
# @Time    : 2026/4/6 15:40
# @Software: PyCharm
import os
import shutil


def copy_file_to_folder(source_file, target_folder):
    """将源文件复制到目标文件夹
    """
    # 获取源文件的文件名
    file_name = os.path.basename(source_file)
    # 构建目标文件的完整路径
    target_file = os.path.join(target_folder, file_name)
    # 复制文件
    shutil.copy2(source_file, target_file)
    print(f"文件已成功复制到: {target_file}")


# 使用示例
if __name__ == "__main__":
    game_dir = r"C:\MySoft\Slay the Spire 2"
    # 源文件路径"Assembly-CSharp.dll",""
    source_dlls = [
        r"\data_sts2_windows_x86_64\0Harmony.dll",
        r"\data_sts2_windows_x86_64\GodotSharp.dll",
        r"\data_sts2_windows_x86_64\sts2.dll",
    ]

    # 目标文件夹路径（可以是不存在的）
    destination = r"C:\MyHide\SlayTheSpire2ModLib"
    # 调用函数进行复制
    for source in source_dlls:
        copy_file_to_folder(game_dir + source, destination)
