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

