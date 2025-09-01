# coding=utf-8
# @Time    : 2025/7/23 21:47
# @Software: PyCharm
from typing import NamedTuple

import requests

url = 'https://api-takumi.mihoyo.com/event/e20200928calculate/v1/sync/avatar/list'
cookie = '自行去网页版米游社取cookie'
uid = "152915436"  # 原神uid

ua = {
    'Accept': 'application/json, text/plain, */*',
    'User-Agent': 'Mozilla/5.0 (Linux; Android 9; Unspecified Device) AppleWebKit/537.36 '
                  '(KHTML, like Gecko) Version/4.0 Chrome/39.0.0.0 Mobile Safari/537.36 miHoYoBBS/2.2.0',
    'Cookie': cookie,
    'Origin': 'https://act.mihoyo.com/',
    'Referer': 'https://act.mihoyo.com/',
    'Content-type': 'application/json;charset=UTF-8',
    'Sec-Ch-Ua': '"Not)A;Brand";v="8", "Chromium";v="138", "Microsoft Edge";v="138"',
    'x-rpc-device_fp': '38d80df4b6305',
    'x-rpc-device_id': '5ef28e27-2a93-4c45-a646-a66bd3ab5764',
    'x-rpc-platform': '4',
}

body = {
    "uid": uid,
    "region": "cn_gf01",
    "element_attr_ids": [],
    "weapon_cat_ids": [],
    "page": 1,
    "size": 200,
    "lang": "zh-cn"
}

# 请求 content
response = requests.post(url=url, headers=ua, json=body)
print("==" * 30)
# 直接获取JSON数据（内部已处理了解析）
result = response.json()
retcode = result.get("retcode")
print(f"返回值：{retcode}")
if retcode != 0:
    print(result)
print("==" * 30)

data_pa = result.get("data", {})
print(f"一共 {data_pa.get('total')} 个角色")
# 获取data.list
print("==" * 30)
data_list = data_pa.get("list", [])


class GenshinCharacters(NamedTuple):
    role_id: id  # 角色id
    role_name: str  # 角色名称
    level_current: int  # 角色当前等级
    constellation_num: int  # 命座数量
    fetter_level: int  # 角色好感度等级
    weapon_name: str  # 武器名称
    weapon_rarity: int  # 武器星级
    weapon_level: int  # 武器等级
    skill_1_name: str  # 普通攻击名称
    skill_1_level: int  # 普通攻击等级
    skill_2_name: str  # 元素技能名称
    skill_2_level: int  # 元素技能等级
    skill_3_name: str  # 元素爆发名称
    skill_3_level: int  # 元素爆发等级
    flower_name: str  # 生之花名称
    flower_rarity: int  # 生之花品质
    flower_level: int  # 生之花等级
    # 死之羽
    plume_name: str  # 死之羽名称
    plume_rarity: int  # 死之羽品质
    plume_level: int  # 死之羽等级
    # 时之沙
    sands_name: str  # 时之沙名称
    sands_rarity: int  # 时之沙品质
    sands_level: int  # 时之沙等级
    # 空之杯
    goblet_name: str  # 空之杯名称
    goblet_rarity: int  # 空之杯品质
    goblet_level: int  # 空之杯等级
    # 理之冠
    circlet_name: str  # 理之冠名称
    circlet_rarity: int  # 理之冠品质
    circlet_level: int  # 理之冠等级


# noinspection SqlResolve,SqlNoDataSourceInspection,SqlDialectInspection
out_sql = """INSERT INTO genshin_characters (role_id, role_name, level_current, constellation_num, fetter_level, weapon_name,
                                weapon_rarity,
                                weapon_level, skill_1_name, skill_1_level, skill_2_name, skill_2_level,
                                skill_3_name, skill_3_level, flower_name,
                                flower_rarity, flower_level, plume_name, plume_rarity, plume_level, sands_name,
                                sands_rarity, sands_level, goblet_name, goblet_rarity, goblet_level, circlet_name,
                                circlet_rarity, circlet_level) VALUES"""
# 处理数据
for item in data_list:
    # 武器
    weapon = item.get('weapon', {})
    # 技能
    skill_list = item.get('skill_list', [])
    skill_list_2 = []
    for skill in skill_list:
        if skill.get('max_level') == 10:
            skill_list_2.append({"name": skill.get('name'), "level_current": skill.get('level_current')})
    sk_len = len(skill_list_2)
    if sk_len < 3:
        for i in range(3 - sk_len):
            skill_list_2.append({"name": "无", "level_current": 0})
    # 圣遗物
    reliquary_list = item.get('reliquary_list', [])
    gc = GenshinCharacters(
        role_id=item.get('id'),
        role_name=item.get('name'),
        level_current=item.get('level_current'),  # 当前等级
        constellation_num=item.get('constellation_num'),  # 命座
        fetter_level=item.get('fetter_level'),  # 好感度等级
        weapon_name=weapon.get('name'),  # 武器名称
        weapon_rarity=weapon.get('weapon_level'),  # 武器星级
        weapon_level=weapon.get('level_current'),  # 武器等级
        skill_1_name=skill_list_2[0].get('name'),  # 普攻名称
        skill_1_level=skill_list_2[0].get('level_current'),
        skill_2_name=skill_list_2[1].get('name'),  # e技能名称
        skill_2_level=skill_list_2[1].get('level_current'),
        skill_3_name=skill_list_2[2].get('name'),  # 大招名称
        skill_3_level=skill_list_2[2].get('level_current'),
        # 生之花
        flower_name=reliquary_list[0].get('name'),  # 生之花名称
        flower_rarity=reliquary_list[0].get('reliquary_level'),  # 生之花品质
        flower_level=reliquary_list[0].get('level_current'),  # 生之花等级
        # 死之羽
        plume_name=reliquary_list[1].get('name'),  # 死之羽
        plume_rarity=reliquary_list[1].get('reliquary_level'),  # 死之羽品质
        plume_level=reliquary_list[1].get('level_current'),  # 死之羽等级
        # 时之沙
        sands_name=reliquary_list[2].get('name'),
        sands_rarity=reliquary_list[2].get('reliquary_level'),
        sands_level=reliquary_list[2].get('level_current'),
        # 空之杯
        goblet_name=reliquary_list[3].get('name'),
        goblet_rarity=reliquary_list[3].get('reliquary_level'),
        goblet_level=reliquary_list[3].get('level_current'),
        # 理之冠
        circlet_name=reliquary_list[4].get('name'),
        circlet_rarity=reliquary_list[4].get('reliquary_level'),
        circlet_level=reliquary_list[4].get('level_current'),
    )
    out_sql += (
        f"\n({gc.role_id}, "
        f"'{gc.role_name}', "
        f"{gc.level_current}, "
        f"{gc.constellation_num}, "
        f"{gc.fetter_level}, "
        f"'{gc.weapon_name}', "
        f"{gc.weapon_rarity}, "
        f"{gc.weapon_level}, "
        f"'{gc.skill_1_name}', "
        f"{gc.skill_1_level}, "
        f"'{gc.skill_2_name}', "
        f"{gc.skill_2_level}, "
        f"'{gc.skill_3_name}', "
        f"{gc.skill_3_level}, "
        f"'{gc.flower_name}', "
        f"{gc.flower_rarity}, "
        f"{gc.flower_level}, "
        f"'{gc.plume_name}', "
        f"{gc.plume_rarity}, "
        f"{gc.plume_level}, "
        f"'{gc.sands_name}', "
        f"{gc.sands_rarity}, "
        f"{gc.sands_level}, "
        f"'{gc.goblet_name}', "
        f"{gc.goblet_rarity}, "
        f"{gc.goblet_level}, "
        f"'{gc.circlet_name}', "
        f"{gc.circlet_rarity}, "
        f"{gc.circlet_level}),"
    )

# 截取除最后一个字符外的所有内容，再拼接新字符
out_sql = out_sql[:-1] + ";"
# 写入文件
with open(f'../../outputFile/原神拥有的角色.sql', 'w', encoding='utf-8') as f:
    f.write(out_sql)
print("sql文件写入成功")
