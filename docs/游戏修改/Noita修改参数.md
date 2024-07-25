# Noita修改参数

文件夹路径：

```text
%userprofile%\AppData\LocalLow\Nolla_Games_Noita\save00
```

## Play文件

### 变形免疫与速度加快

> 以及免疫冰冻与无敌

加在文件中的最后一个`</Entity>`之前。

```xml
<Entity>
    <GameEffectComponent 
      effect="PROTECTION_POLYMORPH"
      frames="-1"
  >
    </GameEffectComponent >
</Entity>

<Entity>
    <GameEffectComponent 
      effect="MOVEMENT_FASTER_2X"
      frames="-1"
  >
    </GameEffectComponent >
</Entity>

<Entity>
    <GameEffectComponent 
        effect="PROTECTION_FREEZE"
        frames="-1"
    >
    </GameEffectComponent >
</Entity>

<Entity tags="protection">
	<GameEffectComponent
		effect="PROTECTION_ALL"
        frames="-1"
		>
	</GameEffectComponent>
</Entity>
```

### 人物的初始位置

```xml
  <_Transform 
    position.x="227" 
    position.y="-79.0028" 
    rotation="0" 
    scale.x="1" 
    scale.y="1" >
```

### 法杖修改

搜索：`item,wand"`进行定位。

魔法配置：

```text
mana="9999"               // 当前剩余魔法值
mana_charge_speed="999"   // 魔杖充能速度
mana_max="9999"           // 魔力上限
```

法杖配置：

```xml
<gun_config 
          actions_per_round="25"  // 多重施法
          deck_capacity="25"      // 法杖容量
          reload_time="0"         // 装填延迟
          shuffle_deck_when_empty="0" >   // 是否乱序：0为非乱序
```

开火配置：

```text
fire_rate_wait="-20"   // 法杖发射延迟
```

## world_state文件

```text
TEMPLE_PERK_DESTROY_CHANCE   // 特性博彩【改为0】
TEMPLE_PERK_REROLL_COUNT     // 重新生成特性的次数
```

