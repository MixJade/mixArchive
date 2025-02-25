using System.Collections.Generic;
using HarmonyLib;
using STRINGS;

namespace SampleModel
{
    public class Patches // 固定代码
    {
        // ================================【食物压制器打印工艺品】====================================
        [HarmonyPatch(typeof(MicrobeMusherConfig), "ConfigureRecipes")]
        public class Patches_c
        {
            public static void Postfix()
            {
                // 新配方：沙子合成砂岩、水槽、魔方、办公室杯子
                ComplexRecipe.RecipeElement[] array = new ComplexRecipe.RecipeElement[]
                {
                    new ComplexRecipe.RecipeElement("Sand".ToTag(), 0.01f)
                };
                ComplexRecipe.RecipeElement[] array2 = new ComplexRecipe.RecipeElement[]
                {
                    new ComplexRecipe.RecipeElement("artifact_sandstone".ToTag(), 1f), // 砂岩
                    new ComplexRecipe.RecipeElement("artifact_sink".ToTag(), 1f), // 水槽 
                    new ComplexRecipe.RecipeElement("artifact_rubikscube".ToTag(), 1f), // 魔方
                    new ComplexRecipe.RecipeElement("artifact_officemug".ToTag(), 1f), // 办公室杯子
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
                    sortOrder = 404
                };
                // 新配方：沙子合成小型方尖碑、旧X光片、搅拌机、捷克陨石
                ComplexRecipe.RecipeElement[] array3 = new ComplexRecipe.RecipeElement[]
                {
                    new ComplexRecipe.RecipeElement("Sand".ToTag(), 0.01f)
                };
                ComplexRecipe.RecipeElement[] array4 = new ComplexRecipe.RecipeElement[]
                {
                    new ComplexRecipe.RecipeElement("artifact_obelisk".ToTag(), 1f), // 小型方尖碑
                    new ComplexRecipe.RecipeElement("artifact_okayxray".ToTag(), 1f), // 旧X光片 
                    new ComplexRecipe.RecipeElement("artifact_blender".ToTag(), 1f), // 搅拌机
                    new ComplexRecipe.RecipeElement("artifact_moldavite".ToTag(), 1f), // 捷克陨石
                };
                SpiceBreadConfig.recipe = new ComplexRecipe(ComplexRecipeManager.MakeRecipeID("MicrobeMusher", array3, array4), array3, array4)
                {
                    time = 8f,
                    description = ITEMS.FOOD.SPICEBREAD.RECIPEDESC,
                    nameDisplay = ComplexRecipe.RecipeNameDisplay.Result,
                    fabricators = new List<Tag>
                    {
                        "MicrobeMusher"
                    },
                    sortOrder = 405
                };
                // 新配方：沙子合成古代技术、损坏的萨克斯、现代艺术
                ComplexRecipe.RecipeElement[] array5 = new ComplexRecipe.RecipeElement[]
                {
                    new ComplexRecipe.RecipeElement("Sand".ToTag(), 0.01f)
                };
                ComplexRecipe.RecipeElement[] array6 = new ComplexRecipe.RecipeElement[]
                {
                    new ComplexRecipe.RecipeElement("artifact_vhs".ToTag(), 1f), // 古代技术
                    new ComplexRecipe.RecipeElement("artifact_saxophone".ToTag(), 1f), // 损坏的萨克斯
                    new ComplexRecipe.RecipeElement("artifact_modernart".ToTag(), 1f), // 现代艺术
                };
                SpiceBreadConfig.recipe = new ComplexRecipe(ComplexRecipeManager.MakeRecipeID("MicrobeMusher", array5, array6), array5, array6)
                {
                    time = 8f,
                    description = ITEMS.FOOD.SPICEBREAD.RECIPEDESC,
                    nameDisplay = ComplexRecipe.RecipeNameDisplay.Result,
                    fabricators = new List<Tag>
                    {
                        "MicrobeMusher"
                    },
                    sortOrder = 406
                };
                // 新配方：沙子合成腕表、带壳茶壶、奇怪的砖块、机械臂
                ComplexRecipe.RecipeElement[] array7 = new ComplexRecipe.RecipeElement[]
                {
                    new ComplexRecipe.RecipeElement("Sand".ToTag(), 0.01f)
                };
                ComplexRecipe.RecipeElement[] array8 = new ComplexRecipe.RecipeElement[]
                {
                    new ComplexRecipe.RecipeElement("artifact_ameliaswatch".ToTag(), 1f), // 腕表
                    new ComplexRecipe.RecipeElement("artifact_teapot".ToTag(), 1f), // 带壳茶壶
                    new ComplexRecipe.RecipeElement("artifact_brickphone".ToTag(), 1f), // 奇怪的砖块
                    new ComplexRecipe.RecipeElement("artifact_robotarm".ToTag(), 1f), // 机械臂
                };
                SpiceBreadConfig.recipe = new ComplexRecipe(ComplexRecipeManager.MakeRecipeID("MicrobeMusher", array7, array8), array7, array8)
                {
                    time = 8f,
                    description = ITEMS.FOOD.SPICEBREAD.RECIPEDESC,
                    nameDisplay = ComplexRecipe.RecipeNameDisplay.Result,
                    fabricators = new List<Tag>
                    {
                        "MicrobeMusher"
                    },
                    sortOrder = 407
                };
                // 新配方：沙子合成护盾生成器、荧光石、听诊器
                ComplexRecipe.RecipeElement[] array9 = new ComplexRecipe.RecipeElement[]
                {
                    new ComplexRecipe.RecipeElement("Sand".ToTag(), 0.01f)
                };
                ComplexRecipe.RecipeElement[] array10 = new ComplexRecipe.RecipeElement[]
                {
                    new ComplexRecipe.RecipeElement("artifact_shieldgenerator".ToTag(), 1f), // 护盾生成器
                    new ComplexRecipe.RecipeElement("artifact_bioluminescentrock".ToTag(), 1f), // 荧光石
                    new ComplexRecipe.RecipeElement("artifact_stethoscope".ToTag(), 1f), // 听诊器
                };
                SpiceBreadConfig.recipe = new ComplexRecipe(ComplexRecipeManager.MakeRecipeID("MicrobeMusher", array9, array10), array9, array10)
                {
                    time = 8f,
                    description = ITEMS.FOOD.SPICEBREAD.RECIPEDESC,
                    nameDisplay = ComplexRecipe.RecipeNameDisplay.Result,
                    fabricators = new List<Tag>
                    {
                        "MicrobeMusher"
                    },
                    sortOrder = 408
                };

                // 新配方：沙子合成蛋形石、原始化石、龙卷风石
                ComplexRecipe.RecipeElement[] array11 = new ComplexRecipe.RecipeElement[]
                {
                    new ComplexRecipe.RecipeElement("Sand".ToTag(), 0.01f)
                };
                ComplexRecipe.RecipeElement[] array12 = new ComplexRecipe.RecipeElement[]
                {
                    new ComplexRecipe.RecipeElement("artifact_eggrock".ToTag(), 1f), // 蛋形石
                    new ComplexRecipe.RecipeElement("artifact_hatchfossil".ToTag(), 1f), // 原始化石
                    new ComplexRecipe.RecipeElement("artifact_rocktornado".ToTag(), 1f), // 龙卷风石
                };
                SpiceBreadConfig.recipe = new ComplexRecipe(ComplexRecipeManager.MakeRecipeID("MicrobeMusher", array11, array12), array11, array12)
                {
                    time = 8f,
                    description = ITEMS.FOOD.SPICEBREAD.RECIPEDESC,
                    nameDisplay = ComplexRecipe.RecipeNameDisplay.Result,
                    fabricators = new List<Tag>
                    {
                        "MicrobeMusher"
                    },
                    sortOrder = 409
                };

                // 新配方：沙子合成咖啡壶、岩浆灯、双螺旋模型
                ComplexRecipe.RecipeElement[] array13 = new ComplexRecipe.RecipeElement[]
                {
                    new ComplexRecipe.RecipeElement("Sand".ToTag(), 0.01f)
                };
                ComplexRecipe.RecipeElement[] array14 = new ComplexRecipe.RecipeElement[]
                {
                    new ComplexRecipe.RecipeElement("artifact_pacupercolator".ToTag(), 1f), // 咖啡壶
                    new ComplexRecipe.RecipeElement("artifact_magmalamp".ToTag(), 1f), // 岩浆灯
                    new ComplexRecipe.RecipeElement("artifact_dnamodel".ToTag(), 1f), // 双螺旋模型
                };
                SpiceBreadConfig.recipe = new ComplexRecipe(ComplexRecipeManager.MakeRecipeID("MicrobeMusher", array13, array14), array13, array14)
                {
                    time = 8f,
                    description = ITEMS.FOOD.SPICEBREAD.RECIPEDESC,
                    nameDisplay = ComplexRecipe.RecipeNameDisplay.Result,
                    fabricators = new List<Tag>
                    {
                        "MicrobeMusher"
                    },
                    sortOrder = 410
                };

                // 新配方：沙子合成彩虹蛋形石、等离子灯、独立系统、月月月
                ComplexRecipe.RecipeElement[] array15 = new ComplexRecipe.RecipeElement[]
                {
                    new ComplexRecipe.RecipeElement("Sand".ToTag(), 0.01f)
                };
                ComplexRecipe.RecipeElement[] array16 = new ComplexRecipe.RecipeElement[]
                {
                    new ComplexRecipe.RecipeElement("artifact_rainboweggrock".ToTag(), 1f), // 彩虹蛋形石
                    new ComplexRecipe.RecipeElement("artifact_plasmalamp".ToTag(), 1f), // 等离子灯
                    new ComplexRecipe.RecipeElement("artifact_solarsystem".ToTag(), 1f), // 独立系统
                    new ComplexRecipe.RecipeElement("artifact_moonmoonmoon".ToTag(), 1f), // 月月月
                };
                SpiceBreadConfig.recipe = new ComplexRecipe(ComplexRecipeManager.MakeRecipeID("MicrobeMusher", array15, array16), array15, array16)
                {
                    time = 8f,
                    description = ITEMS.FOOD.SPICEBREAD.RECIPEDESC,
                    nameDisplay = ComplexRecipe.RecipeNameDisplay.Result,
                    fabricators = new List<Tag>
                    {
                        "MicrobeMusher"
                    },
                    sortOrder = 411
                };

                // DLC新配方：沙子合成果虫雕像、蜂蜜罐、核电厂模型、放射性情绪戒指、无用的机器
                // 但仍然算是太空工艺品
                ComplexRecipe.RecipeElement[] array17 = new ComplexRecipe.RecipeElement[]
                {
                    new ComplexRecipe.RecipeElement("Sand".ToTag(), 0.01f)
                };
                ComplexRecipe.RecipeElement[] array18 = new ComplexRecipe.RecipeElement[]
                {
                    new ComplexRecipe.RecipeElement("artifact_grubstatue".ToTag(), 1f), // 果虫雕像
                    new ComplexRecipe.RecipeElement("artifact_honeyjar".ToTag(), 1f), // 蜂蜜罐
                    new ComplexRecipe.RecipeElement("artifact_reactormodel".ToTag(), 1f), // 核电厂模型
                    new ComplexRecipe.RecipeElement("artifact_moodring".ToTag(), 1f), // 放射性情绪戒指
                    new ComplexRecipe.RecipeElement("artifact_oracle".ToTag(), 1f), // 无用的机器
                };
                SpiceBreadConfig.recipe = new ComplexRecipe(ComplexRecipeManager.MakeRecipeID("MicrobeMusher", array17, array18), array17, array18)
                {
                    time = 8f,
                    description = ITEMS.FOOD.SPICEBREAD.RECIPEDESC,
                    nameDisplay = ComplexRecipe.RecipeNameDisplay.Result,
                    fabricators = new List<Tag>
                    {
                        "MicrobeMusher"
                    },
                    sortOrder = 412
                };


            }
        }
    }
}
