# coding=utf-8
# @Time    : 2025/4/3 0:51
# @Software: PyCharm
import csv
import json

# 使用 with 语句打开 JSON 文件
with open('SteamTime.json', 'r', encoding='utf-8') as file:
    # 读取 JSON 数据并解析为 Python 对象
    data = json.load(file)
    # 查看游戏数
    print(f'游戏数: {data["response"]["game_count"]}')

# 提取游戏数据（时长保留两位小数）
games = data["response"]["games"]
game_list = []
for game in games:
    name = game.get("name", "Unknown")
    playtime = game.get("playtime_forever", 0)  # 单位为分钟
    game_list.append({
        "name": name,
        "playtime_hours": round(playtime / 60, 2)  # 精确到两位小数
    })

print(len(game_list))
# 按游玩时长降序排序
game_list_sorted = sorted(game_list, key=lambda x: x["playtime_hours"], reverse=True)
# 添加序号列（从1开始）
for index, game in enumerate(game_list_sorted, start=1):
    game["rank"] = index

# 写入CSV文件（字段包含序号）
out_file_path = "../../outputFile/steam_games.csv"
with open(out_file_path, "w", newline="", encoding="utf-8-sig") as f:
    fieldnames = ["rank", "name", "playtime_hours"]
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(game_list_sorted)
    print(f"文件已生成：{out_file_path}")
