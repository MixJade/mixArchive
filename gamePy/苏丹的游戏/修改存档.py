# coding=utf-8
# @Time    : 2025/4/16 21:34
# @Software: PyCharm
import json
import os


def check_one_key(data, target_key, new_value):
    """修改单层键的值

    :param data: json数据
    :param target_key: 目标键
    :param new_value: 新的值
    """
    if target_key in data:
        print(f"键 {target_key} 由 {data[target_key]} 改为 {new_value}")
        data[target_key] = new_value
    else:
        print(f"错误：键 {target_key} 不存在于 JSON 文件中。")


def check_two_key(data, outer_key, inner_key, new_value):
    """修改双层键的值

    :param data: json数据
    :param outer_key: 目标键
    :param inner_key: 目标键
    :param new_value: 新的值
    """
    if outer_key in data:
        if inner_key in data[outer_key]:
            print(f"键 {outer_key}.{inner_key} 由 {data[outer_key][inner_key]} 改为 {new_value}")
            data[outer_key][inner_key] = new_value
        else:
            print(f"错误：内层键 {inner_key} 不存在于 {outer_key} 中。")
    else:
        print(f"错误：外层键 {outer_key} 不存在于 JSON 文件中。")


def check_array_key(data, card_id, new_value, is_add=False):
    """修改json中卡片的标签

    :param data: json数据
    :param card_id: 卡片id
    :param new_value: 新的标签
    :param is_add: 是否追加形式写入
    """
    if "cards" in data:
        if isinstance(data["cards"], list):
            for item in data["cards"]:
                if isinstance(item, dict) and 'id' in item and item['id'] == card_id:
                    # 修改 tag 属性
                    if is_add:
                        item['tag'].update(new_value)
                        print(f"id为{card_id}的 card tag 已追加:{new_value}")
                    else:
                        item['tag'] = new_value
                        print(f"id为{card_id}的 card tag 已修改:{new_value}")
                    break
            else:
                print(f"错误：未找到 id 为 {card_id} 的元素。")
        else:
            print(f"错误：JSON 数据不是一个数组。")
    else:
        print("错误：键 cards 不存在于 JSON 文件中。")


def update_rites_array_key(data, rite_id, card_id, new_value):
    """修改事件json中卡片的标签

    :param data: json数据
    :param rite_id: 事件id
    :param card_id: 卡片id
    :param new_value: 新的标签
    """
    if "rites" in data:
        if isinstance(data["rites"], list):
            for item in data["rites"]:
                if isinstance(item, dict) and 'id' in item and item['id'] == rite_id:
                    check_array_key(item, card_id, new_value, True)
                    break
        else:
            print(f"错误：JSON 数据不是一个数组。")
    else:
        print("错误：键 rites 不存在于 JSON 文件中。")


def modify_json_key(file_path):
    try:
        # 读取 JSON 文件
        with open(file_path, 'r', encoding='utf-8') as file:
            data = json.load(file)

        # 全局变量
        check_one_key(data, "sudan_card_init_life", 99)  # 苏丹卡时间
        check_two_key(data, "counter", "7100006", 99)  # 金骰子

        # 主角属性
        main_tag = {"physique": 30, "charm": 30, "battle": 30, "wisdom": 30, "magic": 30, "social": 30,
                    "conceal": 30, "survival": 30}
        check_array_key(data, 2000001, main_tag)
        check_array_key(data, 2000861, main_tag)

        # 随从属性
        adherent_tag = {**main_tag, "adherent": 1, "support": 2}
        check_array_key(data, 2000006, adherent_tag)  # 普通老婆
        check_array_key(data, 2000457, adherent_tag)  # 强化老婆1
        check_array_key(data, 2000458, adherent_tag)  # 强化老婆2
        check_array_key(data, 2000372, adherent_tag)  # 法拉杰
        check_array_key(data, 2000522, adherent_tag)  # 法拉杰2
        check_array_key(data, 2000523, adherent_tag)  # 法拉杰3
        check_array_key(data, 2000461, adherent_tag)  # 贝姬夫人
        check_array_key(data, 2000460, adherent_tag)  # 哈桑
        check_array_key(data, 2000459, adherent_tag)  # 马尔基娜
        check_array_key(data, 2000129, adherent_tag)  # 阿图娜尔
        check_array_key(data, 2000019, adherent_tag)  # 热娜

        # 奴隶属性
        check_array_key(data, 2000369, {**adherent_tag, "lock_9": -1})  # 铁头
        check_array_key(data, 2000370, {**adherent_tag, "lock_10": -1})  # 快脚
        check_array_key(data, 2000371, {**adherent_tag, "lock_11": -1})  # 小圆

        # 物品属性
        own_tag = {**main_tag, "own": 1}
        check_array_key(data, 2000521, own_tag)  # 魅力护符
        check_array_key(data, 2000520, own_tag)  # 再生护符
        check_array_key(data, 2000519, own_tag)  # 幸运护符
        check_array_key(data, 2000368, own_tag)  # 家传宝甲
        check_array_key(data, 2000527, own_tag)  # 家传宝甲(金)

        # 其它人物
        sudan_tag = {"support": 9}
        update_rites_array_key(data, 5001001, 2000024, sudan_tag)  # 上朝事件中的苏丹

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
