# 脑叶公司mod安装

> 2024-8-8 20:16:59

在前面先推荐Wiki[脑叶公司 Wiki | Fandom](https://lobotomycorp.fandom.com/zh/wiki/脑叶公司_Wiki)

这个Wiki一般是在玩的时候查的，建议放在手机上查看

## 一、N网下载

* 网址：[N网脑叶公司Mod](https://www.nexusmods.com/lobotomycorporation/mods/popularalltime/)
* 先安装排名第一的[Basemod](https://www.nexusmods.com/lobotomycorporation/mods/2)
* 然后是显示成功率的[More detailed info](https://www.nexusmods.com/lobotomycorporation/mods/47)
* 以及无限属性点的[Infinity LOB Points](https://www.nexusmods.com/lobotomycorporation/mods/80)
* 还有加强武器防具的[Super Agents](https://www.nexusmods.com/lobotomycorporation/mods/19)(这个要下载以后自己把数值调小一点，不然会有bug)
* 重回第一天保留员工：[Permanent Agents](https://www.nexusmods.com/lobotomycorporation/mods/79)
* 自动连续工作：[Automatic Work Macro](https://www.nexusmods.com/lobotomycorporation/mods/107)

## 二、mod安装

1. 下载完`BaseMod`以后，直接将其解压，然后将其内容拖到下面文件夹中(需要覆盖文件)：

```url
C:\Program Files (x86)\Steam\steamapps\common\LobotomyCorp\LobotomyCorp_Data
```

2. 在`BaseMod`的内容放入上述文件夹后，会有一个`BaseMods`文件夹，将其他Mod直接解压到`BaseMods`文件夹下即可。
3. 但有些改属性的，比如`Super Agents`，这个一般要按照其说明去覆盖对应文件。

## 三、修改类mod安装

* `Super Agents`有点特殊，它里面只有一个`BaseEquipment.txt`
* 不要将其放在 `\LobotomyCorp_Data\BaseMod`
  中，而是放在 `\LobotomyCorp_Data\Managed\BaseMod`中。
* 这个会覆盖一个原有的同名文件，注意备份。

## 四、自动工作宏的使用

Shift + Click”：按住 shift 键并单击异常的工作类型，然后单击员工;您将设置它们以自动处理该异常。这将把他们正在处理的异常情况的肖像放在他们的头顶上，只有当被告知做其他事情或无法工作时，他们才会停下来。
“Shift”：选择任何员工并按 shift 键以阻止他们自动工作。这不会取消他们目前的工作，只会取消任何未来的工作。
“V”：按 V 停止任何和所有宏。
“B”：选择任何员工并按 B 键，让他们完成他们所做的最后一项工作。或者，打开异常的工作窗口，然后按 B 发送处理异常的最后一名人员。此键绑定还与按住 shift 一起使用，以自动为他们所做的上一个工作创建巨集。