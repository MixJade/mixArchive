# 脑叶公司mod安装

> 2024-8-8 20:16:59

## 一、N网下载

* 网址：[N网脑叶公司Mod](https://www.nexusmods.com/lobotomycorporation/mods/popularalltime/)

* 先安装排名第一的[Basemod](https://www.nexusmods.com/lobotomycorporation/mods/2)
* 然后是显示成功率的[More detailed info](https://www.nexusmods.com/lobotomycorporation/mods/47)
* 以及无限属性点的[Infinity LOB Points](https://www.nexusmods.com/lobotomycorporation/mods/80)
* 还有加强武器防具的[Super Agents](https://www.nexusmods.com/lobotomycorporation/mods/19)(这个要下载以后自己把数值调小一点，不然会有bug)

## 二、mod安装

1. 下载完`BaseMod`以后，直接将其解压，然后将其内容拖到下面文件夹中(需要覆盖文件)：

```url
C:\Program Files (x86)\Steam\steamapps\common\LobotomyCorp\LobotomyCorp_Data
```

2. 在`BaseMod`的内容放入上述文件夹后，会有一个`BaseMods`文件夹，将其他Mod直接解压到`BaseMods`文件夹下即可。
3. 但有些改属性的，比如`Super Agents`，这个一般要按照其说明去覆盖对应文件。

## 三、Super Agents的安装

* `Super Agents`有点特殊，它里面只有一个`BaseEquipment.txt`
* 不要将其放在 `\LobotomyCorp_Data\BaseMod`
  中，而是放在 `\LobotomyCorp_Data\Managed\BaseMod`中。
* 这个会覆盖一个原有的同名文件，注意备份。