# Mio修改存档

> 2026-01-21 22:20:52

* 存档位置
* 文件名`slot_0.save`

```txt
%userprofile%\AppData\Local\MIO\Saves\Steam\76561199039777494
```

## 修改金钱

* `slot_0.save`内部都是这种键值对，其中`贝母滴液`是下面这样
* 搜索`RESOURCE:PEARL_SHARDS`即可
* `pairs.48`这种数字会变化，疑似乱序存储

```txt
pairs.48.key = String("RESOURCE:PEARL_SHARDS")
pairs.48.value.flags = Flags("Acquired")
pairs.48.value.count = i32(24000)
```

