# coding=utf-8
# @Time    : 2025/9/7 20:12
# @Software: PyCharm
import os
import shutil


def copy_file_to_folder(source_file, target_folder):
    """将源文件复制到目标文件夹，如果自动目标文件夹不存在则创建
    """
    try:
        # 检查源文件是否存在
        if not os.path.exists(source_file):
            raise FileNotFoundError(f"源文件不存在: {source_file}")

        # 创建目标文件夹（如果不存在），exist_ok=True表示如果文件夹已存在也不会报错
        os.makedirs(target_folder, exist_ok=True)

        # 获取源文件的文件名
        file_name = os.path.basename(source_file)

        # 构建目标文件的完整路径
        target_file = os.path.join(target_folder, file_name)

        # 复制文件
        shutil.copy2(source_file, target_file)
        print(f"文件已成功复制到: {target_file}")

    except Exception as e:
        print(f"复制文件时出错: {str(e)}")


# 使用示例
if __name__ == "__main__":
    game_dir = r"C:\Program Files (x86)\Steam\steamapps\common\Hollow Knight Silksong"
    # 源文件路径"Assembly-CSharp.dll",""
    source_dlls = [
        r"\BepInEx\core\0Harmony.dll",
        r"\BepInEx\core\BepInEx.dll",
        r"\BepInEx\core\BepInEx.Harmony.dll",
        r"\Hollow Knight Silksong_Data\Managed\Assembly-CSharp.dll",
        r"\Hollow Knight Silksong_Data\Managed\UnityEngine.dll",
        r"\Hollow Knight Silksong_Data\Managed\UnityEngine.CoreModule.dll",
        r"\Hollow Knight Silksong_Data\Managed\UnityEngine.UI.dll",
        # 以下mod为炼制定仙游所需
        r"\Hollow Knight Silksong_Data\Managed\UnityEngine.Physics2DModule.dll",
        r"\Hollow Knight Silksong_Data\Managed\UnityEngine.InputLegacyModule.dll",
    ]

    # 目标文件夹路径（可以是不存在的）
    destination = r"C:\MyHide\silkModLibs"
    # 调用函数进行复制
    for source in source_dlls:
        copy_file_to_folder(game_dir + source, destination)
