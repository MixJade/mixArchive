using HarmonyLib;
using UnityEngine;

namespace GreatSteamEngine
{
    public class Patches
    {
        // ================================【DLC的蒸汽引擎】====================================
        [HarmonyPatch(typeof(SteamEngineClusterConfig), "DoPostConfigureComplete")]
        public class Patches_b
        {
            public static void Postfix(GameObject go) // 参数要与定位的函数一致
            {
                RocketEngineCluster rocketEngineCluster = go.AddOrGet<RocketEngineCluster>();
                rocketEngineCluster.fuelTag = ElementLoader.FindElementByHash(SimHashes.Oxygen).tag;
                rocketEngineCluster.efficiency = 20000f;
                rocketEngineCluster.exhaustElement = SimHashes.Oxygen;
                rocketEngineCluster.exhaustTemperature = 289.15f;
                FuelTank fuelTank = go.AddOrGet<FuelTank>();
                fuelTank.FuelType = ElementLoader.FindElementByHash(SimHashes.Oxygen).tag;
                ConduitConsumer conduitConsumer = go.AddOrGet<ConduitConsumer>();
                conduitConsumer.capacityTag = fuelTank.FuelType;
                BuildingTemplates.ExtendBuildingToRocketModuleCluster(go, null, 15, (float)540, 0.001f);
            }
        }
    }
}
