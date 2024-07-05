using HarmonyLib;
using UnityEngine;

namespace SimplePlant
{
    public class Patches // 固定代码
    {
        // ================================【芳香百合】====================================
        [HarmonyPatch(typeof(SwampLilyConfig), "CreatePrefab")] // 定位代码
        public class 芳香百合修改  // 自定义名称
        {
            public static void Postfix(ref GameObject __result) // 函数名称固定，参数类型是定位函数的返回值
            {
                EntityTemplates.ExtendEntityToBasicPlant(__result, 258.15f, 289.15f, 358.15f, 448.15f, new SimHashes[]
                {
                    SimHashes.ChlorineGas,
                    SimHashes.Oxygen,  // 【改】这里是生长环境
			        SimHashes.ContaminatedOxygen,
                    SimHashes.CarbonDioxide,
                }, true, 0f, 0.15f, SwampLilyFlowerConfig.ID, true, true, true, true, 2400f, 0f, 4600f, SwampLilyConfig.ID + "Original", STRINGS.CREATURES.SPECIES.SWAMPLILY.NAME);
            }
        }
        // ================================【冰霜小麦】====================================
        [HarmonyPatch(typeof(ColdWheatConfig), "CreatePrefab")] // 定位代码
        public class 冰霜小麦修改  // 自定义名称
        {
            public static void Postfix(ref GameObject __result)
            {
                // 修改温度与环境
                EntityTemplates.ExtendEntityToBasicPlant(__result, 118.149994f, 218.15f, 323.15f, 358.15f, new SimHashes[]
                {
                    SimHashes.Oxygen,  // 【改】这里是生长环境
                    SimHashes.ContaminatedOxygen,
                    SimHashes.CarbonDioxide
                }, true, 0f, 0.15f, "ColdWheatSeed", true, true, true, true, 2400f, 0f, 12200f, "ColdWheatOriginal", STRINGS.CREATURES.SPECIES.COLDWHEAT.NAME);
                // 修改灌溉物
                EntityTemplates.ExtendPlantToIrrigated(__result, new PlantElementAbsorber.ConsumeInfo[]
                {
                    new PlantElementAbsorber.ConsumeInfo
                        {
                            tag = GameTags.DirtyWater, // 灌溉物为污水
                            massConsumptionRate = 0.01f // 每周期6千克
                        }
                });
            }
        }

        // ================================【夜幕菇】====================================
        [HarmonyPatch(typeof(MushroomPlantConfig), "CreatePrefab")] // 定位代码
        public class 夜幕菇修改  // 自定义名称
        {
            public static void Postfix(ref GameObject __result)
            {
                // 修改环境
                EntityTemplates.ExtendEntityToBasicPlant(__result, 228.15f, 278.15f, 308.15f, 398.15f, new SimHashes[]
                {
                    SimHashes.Oxygen,  // 【改】这里是生长环境
			        SimHashes.ContaminatedOxygen,
                    SimHashes.CarbonDioxide
                }, true, 0f, 0.15f, MushroomConfig.ID, true, true, true, true, 2400f, 0f, 4600f, "MushroomPlantOriginal", STRINGS.CREATURES.SPECIES.MUSHROOMPLANT.NAME);
                // 修改肥料为泥土，每周期6千克
                EntityTemplates.ExtendPlantToFertilizable(__result, new PlantElementAbsorber.ConsumeInfo[]
                {
                    new PlantElementAbsorber.ConsumeInfo
                    {
                        tag = GameTags.Dirt,
                        massConsumptionRate = 0.01f
                    }
                });
            }
        }

        // ================================【火藤椒】====================================
        [HarmonyPatch(typeof(SpiceVineConfig), "CreatePrefab")] // 定位代码
        public class 火藤椒修改  // 自定义名称
        {
            public static void Postfix(ref GameObject __result)
            {
                // 修改最低温度为16度
                EntityTemplates.ExtendEntityToBasicPlant(__result, 258.15f, 289.15f, 358.15f, 448.15f, null, true, 0f, 0.15f, SpiceNutConfig.ID, true, true, true, true, 2400f, 0f, 9800f, "SpiceVineOriginal", STRINGS.CREATURES.SPECIES.SPICE_VINE.NAME);
            }
        }

        // ================================【小吃芽】====================================
        [HarmonyPatch(typeof(BeanPlantConfig), "CreatePrefab")] // 定位代码
        public class 小吃芽修改  // 自定义名称
        {
            public static void Postfix(ref GameObject __result)
            {
                // 修改最高温度与气体环境
                float temperature_lethal_low = 198.15f;
                float temperature_warning_low = 248.15f;
                float temperature_warning_high = 323.15f; // 最高温度改为50度
                float temperature_lethal_high = 323.15f;
                string baseTraitName = STRINGS.CREATURES.SPECIES.BEAN_PLANT.NAME;
                EntityTemplates.ExtendEntityToBasicPlant(__result, temperature_lethal_low, temperature_warning_low, temperature_warning_high, temperature_lethal_high,new SimHashes[]
                {
                    SimHashes.Oxygen,  // 【改】这里是生长环境
			        SimHashes.ContaminatedOxygen,
                    SimHashes.CarbonDioxide 
                },
                true, 0f, 0.025f, "BeanPlantSeed", true, true, true, true, 2400f, 0f, 9800f, "BeanPlantOriginal", baseTraitName);
                // 修改灌溉物
                EntityTemplates.ExtendPlantToIrrigated(__result, new PlantElementAbsorber.ConsumeInfo[]
                {
                    new PlantElementAbsorber.ConsumeInfo
                    {
                        tag = GameTags.DirtyWater, // 灌溉物为污水
                        massConsumptionRate = 0.01f // 每周期6千克
                    }
                });
            }
        }

        // ================================【释气草】====================================
        [HarmonyPatch(typeof(GasGrassConfig), "CreatePrefab")] // 定位代码
        public class 释气草修改  // 自定义名称
        {
            public static void Postfix(ref GameObject __result)
            {
                EntityTemplates.ExtendPlantToIrrigated(__result, new PlantElementAbsorber.ConsumeInfo[]
                {
                    new PlantElementAbsorber.ConsumeInfo
                    {
                        tag = GameTags.DirtyWater, // 灌溉物为污水
                        massConsumptionRate = 0.01f // 每周期6千克
                    }
                });
            }
        }

        // ================================【水草】====================================
        [HarmonyPatch(typeof(SeaLettuceConfig), "CreatePrefab")] // 定位代码
        public class 水草修改  // 自定义名称
        {
            public static void Postfix(ref GameObject __result)
            {
                // 水草的最低温度改为5度，生长环境添加气体
                EntityTemplates.ExtendEntityToBasicPlant(__result, 248.15f, 278.15f, 338.15f, 398.15f, new SimHashes[]
                {
                    SimHashes.Water,
                    SimHashes.SaltWater,
                    SimHashes.Brine,
                    SimHashes.Oxygen,  // 【改】这里是生长环境
			        SimHashes.ContaminatedOxygen,
                    SimHashes.CarbonDioxide
                }, false, 0f, 0.15f, "Lettuce", true, true, true, true, 2400f, 0f, 7400f, SeaLettuceConfig.ID + "Original", STRINGS.CREATURES.SPECIES.SEALETTUCE.NAME);
                EntityTemplates.ExtendPlantToIrrigated(__result, new PlantElementAbsorber.ConsumeInfo[]
                {
                    new PlantElementAbsorber.ConsumeInfo
                    {
                        tag = GameTags.DirtyWater, // 灌溉物为污水
                        massConsumptionRate = 0.01f // 每周期6千克
                    }
                });
            }
        }

    }
}
