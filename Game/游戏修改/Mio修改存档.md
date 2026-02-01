# Mio修改存档

> 2026-0‎1‎-21 ‏‎22:20:52

* 存档位置
* 文件名`slot_0.save`

```txt
%userprofile%\AppData\Local\MIO\Saves\Steam\76561199039777494
```

## 修改金钱

* `slot_0.save`内部都是这种键值对，其中`贝母滴液`是下面这样

```txt
pairs.48.key = String("RESOURCE:PEARL_SHARDS")
pairs.48.value.flags = Flags("Acquired")
pairs.48.value.count = i32(24000)
```

