# 丝之歌mod开发与使用

> 2025-09-07 20:25:04

* 参考链接1: [BepInEx开发Mod教程-3dm](https://mod.3dmgame.com/wiki/BepInEx)
* 参考链接2: [丝之歌mod-N网](https://www.nexusmods.com/games/hollowknightsilksong)

## mod开发准备

1. 下载BepInEx[v5.x，x64 版本](https://github.com/BepInEx/BepInEx/releases)
2. 解压到游戏根目录: `C:\Program Files (x86)\Steam\steamapps\common\Hollow Knight Silksong`
3. 复制开发所需的dll，运行`gamePy/HollowSilksong/复制Mod所需dll库.py`即可
4. 打开`Visual Studio 2022`，新建项目-选择模板【c#、Windows】-【类库(.NET Framework)】
5. 项目名叫`MixSilkSongMod`，路径默认，勾选`将解决方案和项目放同一目录中`
6. 在vs的资源管理器中，引用之前复制的七个dll文件。(资源管理器在【视图】-【解决方案资源管理器】)
7. 将默认的class名称`Class1`右键重命名为`MixSilkPlugin`，然后点击保存
8. 接着将源代码`gamePy/HollowSilksong/MixSilkPlugin.cs`复制进去
9. 至此准备完成

## 《蛊仙修为》mod说明

1. 蛊仙具有无限真元，九倍获取灵丝
2. 仙窍可以经营物资，八倍获取碎片
3. 仙窍可以经营产业，双倍获取念珠
4. 催动功率不同凡响，所有伤害双倍
5. 血道大宗师境界，杀敌回血回灵丝
6. 拥有无限净水蛊，所以净界花环泡粪水不消耗(受击还是原来的三次)
7. 拥有无限避火蛊，所以熔岩钟不消耗
8. 会智道推算，所以总是有指南针
9. 拥有元磁蛊，所以总是有磁铁
10. 力道宗师境界，蓄力时间从1.35s变为0.4s
11. 仙窍具有储存功能，所有工具数量+100(包括储备缚丝器的次数)

## 《定仙游》mod说明

***Keyboard / 键盘***

1. Ctrl + 1~5：保存位置
2. Alt + 1~5：加载位置
3. Alt + 6：传送到椅子所在场景
4. 无保存数据：无存档时自动传送到椅子所在场景
5. 在场景内再次传送到当前场景，自动回到椅子
6. Ctrl + Alt：重新从本地读取存档数据

***传送坐标数据***

```text
C:\MyHide\silkModData\savedata.json
```
