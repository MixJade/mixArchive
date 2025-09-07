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

## 常用mod推荐

> 从下载mod的zip文件提取 DLL，将其放置在“Hollow Knight Silksong\BepInEx\plugins\”中

1. 始终拥有指南针(N网编号21)
2. 始终拥有磁铁(N网编号22)
3. 地图传送(N网编号33)

## 传送mod补充说明

***Keyboard / 键盘***

1. Ctrl + 1~5： Save position / 保存位置 （完全可自定义 / 完全可定制）有音效提示
2. Alt + 1~5： 加载位置 / 读取位置 （完全可自定义 / 完全可自定义）
3. Alt + 6： 安全重生（循环入口点） / 安全重生（轮换入口点） （完全可自定义 / 完全可定制）
4. Alt + 0： 重置所有坐标 / 重置所有坐标 （完全可自定义 / 完全可定制）
5. 无保存数据：自动传送到长凳 / 无存档时自动传送到椅子

***游戏手柄 / 手柄***

- 【不建议用手柄来运行此Mod，最好直接把配置文件里面的手柄关了】
- 配置项：`启用手柄支持 | Enable Gamepad Support = false`

***传送配置文件***

```text
C:\Program Files (x86)\Steam\steamapps\common\Hollow Knight Silksong\BepInEx\config\Mhz.TeleportMod.cfg
```

***传送坐标数据***

```text
%userprofile%\AppData\LocalLow\Team Cherry\Hollow Knight Silksong\TeleportMod\savedata.json
```
