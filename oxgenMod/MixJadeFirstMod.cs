using System.Collections.Generic;
using System.Linq;
using System.Reflection.Emit;
using HarmonyLib;
using STRINGS;
using UnityEngine;

namespace MixJadeFirstMod
{
    public class Patches // 固定代码
    {
        // ================================【人力发电机】====================================
        [HarmonyPatch(typeof(ManualGeneratorConfig), "CreateBuildingDef")] // 定位代码
        public class Patches_a  // 自定义名称
        {
            public static void Postfix(ref BuildingDef __result) // 函数名称固定，参数类型是定位函数的返回值
            {
                __result.GeneratorWattageRating = 40000f; // 发电功率
            }
        }
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
        // ================================【普通电池:发热功率】====================================
        [HarmonyPatch(typeof(BatteryConfig), "CreateBuildingDef")] // 定位代码
        public class Patches_b_heat1  // 自定义名称
        {
            public static void Postfix(ref BuildingDef __result) // 后置补丁
            {
                __result.SelfHeatKilowattsWhenActive = 0f; // 自发热功率
                __result.ExhaustKilowattsWhenActive = 0f; // 排出热量功率
            }
        }
        // ================================【电灯泡:发热功率】====================================
        [HarmonyPatch(typeof(CeilingLightConfig), "CreateBuildingDef")] // 定位代码
        public class Patches_b_heat2 // 自定义名称
        {
            public static void Postfix(ref BuildingDef __result) // 后置补丁
            {
                __result.SelfHeatKilowattsWhenActive = 0f; // 自发热功率
            }
        }
        // ================================【食物压制器】====================================
        [HarmonyPatch(typeof(MicrobeMusherConfig), "ConfigureRecipes")]
        public class Patches_c
        {
            public static void Postfix()
            {
                // 新配方：泥土和砂岩合成火椒面包
                ComplexRecipe.RecipeElement[] array = new ComplexRecipe.RecipeElement[]
                {
                    new ComplexRecipe.RecipeElement("Dirt".ToTag(), 0.1f),
                    new ComplexRecipe.RecipeElement("Sandstone".ToTag(), 0.1f)
                };
                ComplexRecipe.RecipeElement[] array2 = new ComplexRecipe.RecipeElement[]
                {
                    new ComplexRecipe.RecipeElement("SpiceBread".ToTag(), 1f, ComplexRecipe.RecipeElement.TemperatureOperation.AverageTemperature, false)
                };
                SpiceBreadConfig.recipe = new ComplexRecipe(ComplexRecipeManager.MakeRecipeID("MicrobeMusher", array, array2), array, array2)
                {
                    time = 8f,
                    description = ITEMS.FOOD.SPICEBREAD.RECIPEDESC,
                    nameDisplay = ComplexRecipe.RecipeNameDisplay.Result,
                    fabricators = new List<Tag>
                    {
                        "MicrobeMusher"
                    },
                    sortOrder = 300
                };
                // 新配方：沙子合成冰霜汉堡(烤炉制作)
                ComplexRecipe.RecipeElement[] array3 = new ComplexRecipe.RecipeElement[]
                {
                    new ComplexRecipe.RecipeElement("Sand".ToTag(), 0.01f)
                };
                ComplexRecipe.RecipeElement[] array4 = new ComplexRecipe.RecipeElement[]
                {
                    new ComplexRecipe.RecipeElement("Burger".ToTag(), 1f, ComplexRecipe.RecipeElement.TemperatureOperation.Heated, false)
                };
                SpiceBreadConfig.recipe = new ComplexRecipe(ComplexRecipeManager.MakeRecipeID("CookingStation", array3, array4), array3, array4)
                {
                    time = 8f,
                    description = ITEMS.FOOD.SPICEBREAD.RECIPEDESC,
                    nameDisplay = ComplexRecipe.RecipeNameDisplay.Result,
                    fabricators = new List<Tag>
                    {
                        "CookingStation"
                    },
                    sortOrder = 301
                };
                // 修改碎石机配方
                // 配方：沙子生成金子和钢、塑料
                ComplexRecipe.RecipeElement[] array21 = new ComplexRecipe.RecipeElement[]
                {
                    new ComplexRecipe.RecipeElement("Sand".ToTag(), 1f)
                };
                ComplexRecipe.RecipeElement[] array22 = new ComplexRecipe.RecipeElement[]
                {
                    new ComplexRecipe.RecipeElement("Steel".ToTag(), 600f),
                    new ComplexRecipe.RecipeElement("Gold".ToTag(), 600f),
                    new ComplexRecipe.RecipeElement("Polypropylene".ToTag(), 300f)
                };
                SpiceBreadConfig.recipe = new ComplexRecipe(ComplexRecipeManager.MakeRecipeID("RockCrusher", array21, array22), array21, array22)
                {
                    time = 8f,
                    nameDisplay = ComplexRecipe.RecipeNameDisplay.IngredientToResult,
                    description = "Steel",
                    fabricators = new List<Tag>
                    {
                        "RockCrusher"
                    },
                    sortOrder = 302
                };
            }
        }
        // ================================【氧气扩散器】====================================
        [HarmonyPatch(typeof(MineralDeoxidizerConfig), "ConfigureBuildingTemplate")]
        public class Patches_d
        {
            public static void Postfix(GameObject go) // 参数要与定位的函数一致
            {
                ElementConverter elementConverter = go.AddOrGet<ElementConverter>();
                elementConverter.consumedElements = new ElementConverter.ConsumedElement[]
                {
            new ElementConverter.ConsumedElement(new Tag("Algae"), 0.01f, true)
                };
                elementConverter.outputElements = new ElementConverter.OutputElement[]
                {
            new ElementConverter.OutputElement(5f, SimHashes.Oxygen, 303.15f, false, false, 0f, 1f, 1f, byte.MaxValue, 0, true)
                };
            }
        }
        // ================================【存储箱】====================================
        [HarmonyPatch(typeof(StorageLockerConfig), "DoPostConfigureComplete")]
        public class Patches_e
        {
            // 容量从两万到十万，这个修改原理还没搞懂，因为capacityKg是类中的常量
            public static void Postfix(ref GameObject go)
            {
                go.AddOrGet<Storage>().capacityKg = 100000f;
            }
        }
        // ================================【电线的负载功率】====================================
        [HarmonyPatch(typeof(Wire), "GetMaxWattageAsFloat")]
        public class Patches_f
        {
            // 将所有的电线负载改成5万
            public static bool Prefix(ref float __result)
            {
                __result = 50000f;
                return false;
            }
        }
        // ================================【储液库的容量100吨】====================================
        [HarmonyPatch(typeof(LiquidReservoirConfig), "ConfigureBuildingTemplate")]
        public class Patches_g
        {
            public static IEnumerable<CodeInstruction> Transpiler(IEnumerable<CodeInstruction> codeInstructions)
            {
                List<CodeInstruction> list = codeInstructions.ToList();
                list[17].operand = 100000f;
                return list.AsEnumerable();
            }
        }
        // ================================【储气库的容量100吨】====================================
        [HarmonyPatch(typeof(GasReservoirConfig), "ConfigureBuildingTemplate")]
        public class Patches_h
        {
            public static IEnumerable<CodeInstruction> Transpiler(IEnumerable<CodeInstruction> codeInstructions)
            {
                List<CodeInstruction> list = codeInstructions.ToList();
                list[14].operand = 100000f;
                return list.AsEnumerable();
            }
        }
        // ================================【液冷修改】====================================
        // 由于液冷是直接引用的气冷模板，因此修改气冷的配置即可。
        [HarmonyPatch(typeof(AirConditioner), "UpdateState")]
        public static class ConditionerHeatAdjust
        {
            public static IEnumerable<CodeInstruction> Transpiler(IEnumerable<CodeInstruction> instructions)
            {
                List<CodeInstruction> list = new List<CodeInstruction>(instructions);
                for (int i = 1; i < list.Count - 1; i++)
                {
                    bool flag1 = list[i].opcode == OpCodes.Stloc_S && list[i + 1].opcode == OpCodes.Ldloc_S && list[i].operand == list[i + 1].operand && list[i - 1].opcode == OpCodes.Add;
                    if (flag1)
                    {
                        list.InsertRange(i + 1, new CodeInstruction[]
                        {
                            new CodeInstruction(OpCodes.Ldarg_0, null),
                            new CodeInstruction(OpCodes.Callvirt, typeof(ConditionerHeatAdjust).GetMethod("SetTargetHeat")),
                            new CodeInstruction(list[i].opcode, list[i].operand)
                        });
                        break;
                    }
                }
                for (int j = 0; j < list.Count - 1; j++)
                {
                    bool flag2 = list[j].opcode == OpCodes.Mul && list[j + 1].opcode == OpCodes.Ldloc_S && list[j + 2].opcode == OpCodes.Mul && list[j + 3].opcode == OpCodes.Stloc_S;
                    if (flag2)
                    {
                        list.InsertRange(j + 3, new CodeInstruction[]
                        {
                            new CodeInstruction(OpCodes.Ldc_R4, 0f),
                            new CodeInstruction(OpCodes.Mul, null)
                        });
                        break;
                    }
                }
                return list.AsEnumerable();
            }

            // 设置输出温度：这个方法前面有引用
            public static float SetTargetHeat(AirConditioner conditioner)
            {
                return 291.15f; // 恒定输出18度
            }
        }
    }
}
