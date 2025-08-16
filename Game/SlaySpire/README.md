# 杀戮尖塔jar包代码替换

> 2025-08-15 22:01:59

## 一、把游戏jar添加为库 

* 可以将杀戮尖塔的`desktop-1.0.jar` 复制到本项目的`lib`目录下
* 解压到文件夹`desktop-1.0`，删除到只剩一个com
* * 然后执行下面命令打包(必须使用java8)

```bash
C:\rubbish\jdk1.8.0_461\bin\jar.exe cf modified.jar -C desktop-1.0/ .
```

* 然后打开IDEA，将刚生成的`modified.jar`添加为库


## 二、替换class

* `com/megacrit/cardcrawl/cards/red`里面都是铁甲战士相关的卡片代码
* 改完后，可以运行`org/example/JarClassReplacer.java`来进行class文件的替换

## 卡片ID查看

* 可以去解压`desktop-1.0.jar`,找`localization\zhs\card.json`
* 里面有所有卡片的ID和名称、描述
* 比如“防御卡”是`Defend_R`
* 那么我们可以去`com/megacrit/cardcrawl/cards/red`下面找`Defend_Red`