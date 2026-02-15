# Mio撬门进坩埚

> 2026-02-15 13:50:11

【秘奥】修改存档，撬门过坩埚

# 简介

这几天想给Mio做一个全收集存档解析，于是在游戏里面一个一个收集数据。

但是坩埚真给我搞不会了，一周目已经左右坩埚都跳了一遍，我是真不想再体验第二回。

于是借着存档解析的脚本，顺手研究了如何翘坩埚的门。

# 操作

* 首先打开存档，存档路径如下

```txt
%userprofile%\AppData\Local\MIO\Saves\Steam\ {一串数字}\slot_0.save
```

* （记得备份存档，这样改坏了还能恢复）
* 然后搜索`pairs = Array`。(这里存着元素的数量)
* 我们搜到了`pairs = Array(980)`，给它加个2变成`pairs = Array(982)`

* 然后搜索最后一个元素：`pairs.979.key`
* 接着将坩埚开门的代码粘贴到后面

```txt
pairs.980.key = String("DOOR:ST_cuve_door1")
pairs.980.value.flags = Flags("Acquired")
pairs.980.value.count = i32(1)
pairs.981.key = String("DOOR:ST_cuve_door2")
pairs.981.value.flags = Flags("Acquired")
pairs.981.value.count = i32(1)
```

* 注意这里的数字要接着最后一个元素，比如之前最后一个元素是979，我们就把新粘贴的代码改成980、981
* 然后保存修改、重进游戏，就能看到左右坩埚的门都打开了