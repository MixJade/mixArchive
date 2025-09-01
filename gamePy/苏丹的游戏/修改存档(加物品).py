# coding=utf-8
# @Time    : 2025/4/16 21:34
# @Software: PyCharm
import json
import os


def add_a_card(data, card_ids: list):
    """给自己加一张卡片

    :param data: json数据
    :param card_ids: 卡片的id
    """
    begin_uid = data["card_uid_index"]

    if "cards" in data:
        if isinstance(data["cards"], list):
            for card_id in card_ids:
                data["cards"].append(
                    {"uid": begin_uid, "id": card_id, "count": 1, "life": 1, "rareup": 0,
                     "tag": {"own": 1},
                     "equip_slots": [],
                     "equips": [], "bag": 3, "bagpos": 2, "custom_name": "", "custom_text": ""})
                begin_uid += 1
                data["card_uid_index"] = begin_uid
                print(f"新的卡片追加成功:{card_id}")
        else:
            print(f"错误：JSON 数据不是一个数组。")
    else:
        print("错误：键 cards 不存在于 JSON 文件中。")


def modify_json_key(file_path):
    try:
        # 读取 JSON 文件
        with open(file_path, 'r', encoding='utf-8') as file:
            data = json.load(file)

        # 给自己加一张卡
        add_a_card(data, card_ids=[
            2000304,  # 小鳄鱼
            2000744,  # 激进的军队
            2000477,  # 天命所归
            2001034,  # 星光信标
            2000910,  # 革命的计划
            2000680,  # 苏丹的猜忌
        ])

        # 将修改后的数据写回文件
        with open(file_path, 'w', encoding='utf-8') as file:
            json.dump(data, file, ensure_ascii=False, indent=4)
        print(f"修改完成")

    except FileNotFoundError:
        print("错误：文件未找到。")
    except json.JSONDecodeError:
        print("错误：无法解析 JSON 文件。")
    except Exception as e:
        print(f"错误：发生未知错误：{e}")


# 获取 %userprofile% 的值
user_profile = os.getenv('USERPROFILE')
save_file_path = user_profile + r'\AppData\LocalLow\DoubleCross\SultansGame\SAVEDATA\76561197960287930\auto_save.json'
modify_json_key(save_file_path)
