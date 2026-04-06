# 杀戮尖塔2mod开发

> 2026-04-06 15:55:27

## mod开发准备

1. 复制开发所需的dll，运行`gamePy/SlayTheSpire2/复制Mod所需dll库.py`即可
2. 打开`Visual Studio 2022`，新建项目-选择模板-【类库】(用于创建面向.NET或.NET Standard类库的项目)
3. 框架选择【.NET 9.0】
4. 在vs的资源管理器中，引用之前复制的3个dll文件。(资源管理器在【视图】-【解决方案资源管理器】)
5. 接着将源代码`gamePy/SlayTheSpire2/Slay2Plugin.cs`复制进去

## 《杀戮尖塔2》mod说明

玩家回合开始时，获得50金币、50能量

## 关于存档

由于尖塔2不安装模组和安装模组的存档是分开的，当你玩模组版时需要复制一份非模组版的存档。

* 存档路径

```text
%userprofile%\AppData\Roaming\SlayTheSpire2\steam\{一串数字}
```

把`profile1`等复制到`modded`里即可。

## 控制台

开启了模组，按下`~`（tab上方那个键）即可打开控制台。输入`help`即可查看命令。例如`card SURVIVOR`是把一张生存者加入手中。

你可以查询一个命令的帮助，使用`help card`等。
