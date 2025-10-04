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

1. 九倍获取灵丝
2. 八倍获取碎片
3. 双倍获取念珠
4. 双倍伤害
5. 净界花环不消耗
6. 熔岩钟不消耗
7. 总是有指南针
8. 总是有磁铁
9. 猎人专注不消失
10. 蓄力时间从1.35s变为0.4s
11. 所有工具数量+100(包括储备缚丝器的次数)

## 《定仙游》mod说明

## 传送mod补充说明

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
