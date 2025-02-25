# 监狱建筑师mod开发

> 2024年7月23日20:45:32

## 一、修改教程

* 先下载一个修改属性的mod，比如：【Strong Guard】
* 然后打开以下文件夹

```url
%localappdata%\Introversion\Prison Architect
```

* 找到mods文件夹，以及其下面的某个mod（数字文件夹名）
* 如果这个mod有`materials.txt`文件，就可以进行修改

文档包含的对象主要可分为以下几类

1.物品 2.人物 3.装备 4.紧急召唤选项 5.房间要求 6.车辆（不建议修改）

我们的目的便是对文档中的数据进行修改来改变游戏内容

### 1.1 物品类（以床为例）

```lua
BEGIN Object
    Name                Bed             --名称，不修改
    Height              2               --（体积，不修改）
    ConstructionTime    3.00000         --（修建时间）
    MoveSpeedFactor     0.500000        --（经过物品的速度）
    Toughness           30.0000         --（物品血量）
    Price               -200            --（购买价格，把负号去掉你懂会发生什么的，对吧）
    --（以下不建议修改）
    NumSlots            2               --（位点）
    AttachToWall        true            --（靠墙是否改变位置）
    Group               StaticObject    --（物品类别）
    BlockedBy           Wall            --（部分属性）
    BlockedBy           StaticObject    --（部分属性）
    BlockedBy           UtilityStation  --（部分属性）
    Sprite              Bed             --（对应贴图）
    MadeOf              Wood            --（材料）
    ToolbarSprite       BedToolbar
    Properties          StaticObject
END
```

### 1.2 人物类（以警卫为例）

* 注：加上属性`Properties  DoesNotTire`表示永不疲劳

```lua
BEGIN Object     
    Name                Guard           --（名称 不修改）
    MoveSpeedFactor     0.600000        --（移动速度）
    Toughness           50.0000         --（人物血量）
    Price               -750            --（雇用价格）
    Upkeep              -100            --（每日工资）
    RenderDepth         2               --（渲染距离？）
    ViewRange           17              --（视野）
    --（以下不建议修改）
    BlockedBy           Wall            --（部分属性）
    BlockedBy           StaticObject    --（部分属性）
    BlockedBy           UtilityStation  --（部分属性）
    Sprite              Guard           --（对应贴图） 
    SpriteVariants      4               --（皮肤变种）
    Properties          Entity          --（是否可被雇佣）
    Properties          Staff           --（人物阵营） 
    Properties          Guard           --（人物种类）
    Equipment           Gun             --（装备，这里我已经改为 Gun 即 手枪 了）
END
```

### 1.3 装备类（以手枪为例）

```lua
BEGIN Equipment  
    Name                 Gun            --（名称 不修改）
    Sprite               Gun            --（对应贴图 ）
    Scale                0.700000       --（相对大小 不建议改）
    AttackPower          13.0000        --（威力，别改过高，除非你想来场屠杀）
    RechargeTime         2.0000         --（重装填时间，这个有用？）
    Range                10.0           --（射程）
    Ammo                 6              --（弹药，犯人持有时弹药量）
    Properties           Weapons        --（部分属性）
    Properties           Metal          --（部分属性，金属探测仪有效）
    Properties           RangedWeapon   --（部分属性，远程武器）
    Properties           Smelly         --（部分属性，警犬识别有效）
    Properties           NoImport       --（是否从外界带入）
END
```

### 1.4 紧急召唤类（以消防员为例）

```lua
BEGIN Callout  
    Name                FireEngine         --（名称 不修改）
    Cost                -100               --（召唤费用）
    MaxNumber           3                  --（最大可召唤数）
    --（以下不建议修改）  
    Vehicle             FireEngine         --（车辆属性）  
    Entity              Fireman            --（人物种类）
    NumEntities         4                  --（一队中个数）（取决于车辆）
    Sprite              EmergencyFireEngine --（召唤种类）
END
```

### 1.5 房间属性（以森林为例）

```lua
BEGIN Room       
    Name                 Forestry                       --（名称 不修改） 
    Research             GroundsKeeping                 --（研发条件）
    BEGIN Requirement Type MinimumSize  x 5  y 5  END   --（最小尺寸）
    BEGIN Requirement Type Outdoor END                  --（成立条件）
    BEGIN Contraband  Id   Saw END                      --（含有的违禁品）
    BEGIN Contraband  Id   Axe END                      --（含有的违禁品）
    BEGIN Contraband  Id   Spade END                    --（含有的违禁品） 
    BEGIN Contraband  Id   ChainsawWeapon END

	Properties			PrisonersCanWork
	WorkResearch		ForestryLabour
	WorkExperience		WorkLabourer
	WorkExperienceRate	0.05
END
```

## 二、寻找参照物教程

* 游戏目录

```url
C:\Program Files (x86)\Steam\steamapps\common\Prison Architect
```

1. 打开游戏目录(可通过Steam打开)
2. 找到`main.dat`，选择“用RAR打开文件”。
3. 在里面慢慢找，找到`materials.txt`。
4. 找到你想要修改的东西的代码

### 2.1 武器代码

| 英文            | 中文  |
|:--------------|:----|
| Baton         |警棍  |
| DogLeash      |狗绳|
| GradeTowers   |狙击步枪|
| Gun           |手枪|
| Shotgun       |霰弹枪|
| Rifle         |来复枪|
| AssaultRifle  | 突击步枪|
| SubMachineGun | 冲锋枪|
| Tazer         |泰瑟电击枪|

### 2.2 人物代码

| 英文                | 中文      |
|:------------------|:--------|
| Workman           | 工人      |
| TruckDriver       | 卡车司机    |
| Guard             | 警卫      |
| ArmedGuard        | 武装警卫    |
| DogHandler        | 狗子训练员   |
| Sniper            | 狙击手     |
| Teacher           | 教师      |
| SpiritualLeader   | 牧师(?)   |
| ParoleOfficer     | 假释管     |
| ParoleLawyer      | 假释律师    |
| AppealsLawyer     | 上诉律师    |
| AppealsMagistrate | 上诉法官    |
| Dog               | 狗       |
| RiotGuard         | 防暴警察    |
| Soldier           | 士兵      |
| Prisoner          | 囚犯      |
| Doctor            | 医生      |
| Paramedic         | 急救人员    |
| Cook              | 厨师      |
| Gardener          | 园丁      |
| Janitor           | 清洁工     |
| Fireman           | 消防员     |
| Visitor           | 探视者     |
| ExecutionWitness  | 死刑执行见证人 |
| Warden            | 典狱长     |
| Chief             | 主管      |
| Foreman           | 工头      |
| Psychologist      | 心理学家    |
| Accountant        | 会计      |
| Lawyer            | 律师      |

## 三、推荐Mod

| 名称             | 描述                       |
| ---------------- | -------------------------- |
| Death Row Letter | 允许将囚犯变成死刑犯       |
| Kill Prisoner    | 可以杀死囚犯               |
| Strong Guare     | 强壮的警卫(建议改它的文件) |
| Super Radio      | 收音机满足一切需求         |
| Money Spawner    | 可以随时获得一千万         |

## 四、游戏小细节

1. 游戏中一天等于0.2年的刑期
2. 游戏的地图边缘会出现空投违禁品，空投的距离是13格左右，建立一道15格的外墙就可以隔绝空投(顺便弄一个员工区)。
3. 游戏的配餐桌虽然能分割区域，但它可以供人通行。

## 五、我的Mod

也可以自己开发一个Mod，放在上文所说的文件夹下就行：

```url
%localappdata%\Introversion\Prison Architect\mods
```

* 注意Mod文件夹需用数字命名

## 六、存档修改教程

打开存档文件夹，修改里面的`autosave.prison`文件

```
%localappdata%\Introversion\Prison Architect\saves
```

* 在游戏里，有些设置打开后不可关闭，比如员工需求
  如果打开了又想关闭怎么办呢？
  那只需要找到对应的英文，比如员工需求-`StaffNeeds`，只需删除这行，保存，然后**读档**即可。

* 修改殉职人数：搜索`StaffDeaths`，将它的value改成0
* 修改逃脱人数：`PrisonersEscaped`