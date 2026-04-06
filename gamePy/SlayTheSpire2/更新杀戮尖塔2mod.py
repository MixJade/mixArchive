# coding=utf-8
# @Time    : 2026/4/6 15:40
# @Software: PyCharm
import os
import shutil

# 源dll文件
source_file_1 = os.path.join(os.path.expanduser("~"), r"source\repos\Slay2Plugin\bin\Debug\net9.0\Slay2Plugin.dll")
# 目标dll文件
target_file_1 = r"C:\MySoft\Slay the Spire 2\mods\Slay2Plugin.dll"
shutil.copy2(source_file_1, target_file_1)

# 源cs文件
source_file_2 = os.path.join(os.path.expanduser("~"), r"source\repos\Slay2Plugin\Slay2Plugin.cs")
# 目标cs文件
target_file_2 = r"mod_source\Slay2Plugin.cs"
shutil.copy2(source_file_2, target_file_2)

# 源json文件
source_file_3 = r"mod_source\mod_Slay2Plugin.json"
# 目标json文件
target_file_3 = r"C:\MySoft\Slay the Spire 2\mods\mod_Slay2Plugin.json"
shutil.copy2(source_file_3, target_file_3)
