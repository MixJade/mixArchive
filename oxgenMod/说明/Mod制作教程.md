# Mod制作教程

> 上一集我们完成了基本的配置，并改了c#文件的类名，获得了PLib.dll与mod.yaml、mod_info.yaml文件

现在说明mod文件的代码编写，与编写完成以后的引入。

## 一、初次编写代码

### 1.1 定位与修改发电功率

还是以`人力发电机（ManualGenerator)`为例，上一集找到了其发电功率为（记住这串代码，后面要复制）：

```text
buildingDef.GeneratorWattageRating = 400f;
```

该代码位于`ManualGeneratorConfig`类，其中的`CreateBuildingDef()`方法，也就是下面这样（无关代码已省略)

```c#
public class ManualGeneratorConfig : IBuildingConfig
{
	public override BuildingDef CreateBuildingDef()
	{
		BuildingDef buildingDef = BuildingTemplates.CreateBuildingDef(...);
		buildingDef.GeneratorWattageRating = 400f;
		return buildingDef;
	}
}
```

注意：该代码返回了`BuildingDef`对象，我们要编写代码对这个返回的对象进行修改。

我们所编写的代码，参数要求也是`BuildingDef`类型的，并在前面加一个`ref`，这种似乎被称为【后置补丁】。

【注意，要在namespace上面加一个`using HarmonyLib;`，以及确保项目已引用上一集要求的那七个文件】

```c#
namespace MixJadeFirstMod
{
    public class Patches // 固定代码
    {
        // ===============================【人力发电机】===================================
        [HarmonyPatch(typeof(ManualGeneratorConfig), "CreateBuildingDef")] // 定位代码
        public class Patches_a  // 自定义名称，我起这个名称是致敬我初学所看的教程
        {
             // 下面的函数名称固定，参数类型是定位函数的返回值，且这种修改返回值的要在前面加ref
            public static void Postfix(ref BuildingDef __result)
            {
                __result.GeneratorWattageRating = 40000f; // 发电功率
            }
        }
    }
}
```

###  1.2 使用Mod

#### 1.2.1 输出dll文件

如上的代码编写完成以后，我们在`visual studio`右边资源管理器，右键点击，选择【生成】

可以看到控制台输出以下信息：

```text
1>------ 已启动生成: 项目: MixJadeFirstMod, 配置: Debug Any CPU ------
1>  MixJadeFirstMod -> C:\Users\11141\source\repos\MixJadeFirstMod\MixJadeFirstMod\bin\Debug\MixJadeFirstMod.dll
```

我们从中复制`MixJadeFirstMod.dll`文件的地址，即：【`C:\Users\11141\source\repos\MixJadeFirstMod\MixJadeFirstMod\bin\Debug\`】，直接去文件夹的地址栏打开，然后找到`MixJadeFirstMod.dll`文件，拖出来。

#### 1.2.2 编写yaml文件

我们上一集从别人的Mod中，获得了`PLib.dll`与`mod.yaml`、`mod_info.yaml`文件

接下来我们要炼化那两个yaml文件，记事本打开，改成如下形状。

* mod.yaml

```yaml
title: MixJadeFirstMod
description: 测试Mod
staticID: MixJadeFirstMod
```

* mod_info.yaml

```yaml
supportedContent: ALL
minimumSupportedBuild: 525812
APIVersion: 2
version: "1.0.0"
```

### 1.3 引入Mod到缺氧

打开mod的文件夹，我们在上一集从“文档”里面找到了从steam下载的Mod，现在我们要在它的旁边另起炉灶。

文件夹位置：

```text
C:\Users\11141\Documents\Klei\OxygenNotIncluded\mods\
```

我们可以看到这个文件夹里面有一个`Steam`文件夹，在旁边新建一个`Dev`文件夹，并在里面建一个`MixJadeFirstMod`文件夹。

完整路径如下：

```text
C:\Users\11141\Documents\Klei\OxygenNotIncluded\mods\Dev\MixJadeFirstMod\
```

然后将我们的`MixJadeFirstMod.dll`、`PLib.dll`与`mod.yaml`、`mod_info.yaml`文件放进去。

也就是一个`MixJadeFirstMod`下面有四个文件，然后启动游戏，在主菜单的【模组】选项中开启即可。

【注：如果你开启以后，重进游戏，游戏依然提示你重启，且报错信息为：“继续可能引发崩溃”，就说明你Mod的代码编写有问题，回去改掉错误的代码，然后重新生成dll文件进行替换即可】

## 二、修改电池容量

如何寻找定位代码与上文一致，不再赘述，直接进入正题。

至于怎么确定哪些代码是我们要改的，可以去网上找一些【使用dnspy修改缺氧的教程】，里面大概率会告诉具体改哪些代码。

像这种有参数，但是返回值为`void`的方法，我们可以把我们编写的方法参数调成与之一致的，然后通过参数来改。

【小技巧：方法内的代码可以直接从游戏代码里面复制，然后删掉不用的，只留下要改的】

```c#
namespace MixJadeFirstMod
{
    public class Patches // 固定代码
    {
        // ===============================【人力发电机】===================================
        // ...刚才编写的，与普通电池同级的人力发电机的定位代码与功能代码

        // ================================【普通电池】====================================
        [HarmonyPatch(typeof(BatteryConfig), "DoPostConfigureComplete")]
        public class Patches_b
        {
            public static void Postfix(GameObject go) // 参数要与定位的函数一致
            {
                Battery battery = go.AddOrGet<Battery>();
                battery.capacity = 1000000f;
                battery.joulesLostPerSecond = 0f;
            }
        }
    }
}
```

## 三、食物压制器增加新配方

* 其实食物压制器中的配方是一个`私有（private）方法`，我们是改不了的。
* 并且配方其实不算在食物压制器中，而是先有了配方，然后配方中指定要用食物压制器，我们才能在压制器中使用配方。

所以我们可以直接加一个配方，前面的定位代码其实是不必要的。

这个配方的代码可以去食物压制器的代码里面复制，然后稍作修改即可。

```c#
// ===============================【食物压制器】===================================
[HarmonyPatch(typeof(MicrobeMusherConfig), "ConfigureRecipes")]
public class Patches_c
{
    public static void Postfix()
    {
        // 新配方：泥土和砂岩合成火椒面包
        ComplexRecipe.RecipeElement[] array = new ComplexRecipe.RecipeElement[]
        {
            new ComplexRecipe.RecipeElement("Dirt".ToTag(), 0.1f), // 输入100克泥土
            new ComplexRecipe.RecipeElement("Sandstone".ToTag(), 0.1f) // 输入100克砂岩
        };
        ComplexRecipe.RecipeElement[] array2 = new ComplexRecipe.RecipeElement[]
        {
            new ComplexRecipe.RecipeElement("SpiceBread".ToTag(), 1f, ComplexRecipe.RecipeElement.TemperatureOperation.Heated, false) // 设置输出为火椒面包
        };
        SpiceBreadConfig.recipe = new ComplexRecipe(ComplexRecipeManager.MakeRecipeID("MicrobeMusher", array, array2), array, array2) // 指定这个配方由食物压制器完成
        {
            time = 8f, // 设置亨饪时间为8秒
            description = ITEMS.FOOD.SPICEBREAD.RECIPEDESC,
            nameDisplay = ComplexRecipe.RecipeNameDisplay.Result,
            fabricators = new List<Tag>
            {
                "MicrobeMusher"
            }, // 再次指定由食物压制器完成
            sortOrder = 600
        };
    }
}
```

## 四、氧气扩散器修改输入输出

> 其实是可以更改输入输出物的，不过这里先只改输出输入的量

这里也是，方法没有返回值，只能将`Postfix()函数`的参数设置为与目标函数的参数一致。

然后通过参数来修改输入输出的物品量。

```c#
// ===============================【氧气扩散器】===================================
[HarmonyPatch(typeof(MineralDeoxidizerConfig), "ConfigureBuildingTemplate")]
public class Patches_d
{
    public static void Postfix(GameObject go, Tag prefab_tag) // 参数要与定位的函数一致
    {
        ElementConverter elementConverter = go.AddOrGet<ElementConverter>();
        // Consumed为消耗的元素
        elementConverter.consumedElements = new ElementConverter.ConsumedElement[]
        {
            // 每次消耗藻类10克
            new ElementConverter.ConsumedElement(new Tag("Algae"), 0.01f, true)
        };
        elementConverter.outputElements = new ElementConverter.OutputElement[]
        {
            // 每次输出氧气5千克
            new ElementConverter.OutputElement(5f, SimHashes.Oxygen, 303.15f, false, false, 0f, 1f, 1f, byte.MaxValue, 0, true)
        };
    }
}
```

## 五、自学的路径

1. 可以去看大佬的视频：【缺氧mod制作详细教程-完全面向新手】 https://www.bilibili.com/video/BV1hN4y1c7Fj/?share_source=copy_web&vd_source=f59197803093edc2a7923250e8ceed1f

2. 还可以去Steam的创意工坊上面下载一些你想开发那种类型的mod，然后去`“文档\Klei\OxygenNotIncluded\mods\Steam”`中，找到刚刚下载的mod，反编译它的dll文件即可看到源码，可以这样来看别人的思路。

