using BepInEx;
using HarmonyLib;

namespace MixSilkSongMod
{
    [BepInPlugin("MixJade.MixSilkSongMod", "MixSilkPlugin", "1.0.0")]
    [BepInProcess("Hollow Knight Silksong.exe")]
    public class MixSilkPlugin : BaseUnityPlugin
    {
        // 造成伤害倍数
        private static float _damageMult = 2;


        private void Awake()
        {
            // 设置一堆配置文件参数
            Harmony.CreateAndPatchAll(typeof(MixSilkPlugin));
            _damageMult = Config.Bind("Cheats", "PlayerDamageMult", 2.0f, "造成伤害倍数").Value;
            Logger.LogInfo("《蛊仙修为》已加载");
        }

        [HarmonyPatch(typeof(HeroController), "AddSilk", new[] { typeof(int), typeof(bool), typeof(SilkSpool.SilkAddSource), typeof(bool) })]
        [HarmonyPrefix]
        private static void AddSilkPrefix(ref int amount, ref bool heroEffect, ref SilkSpool.SilkAddSource source, ref bool forceCanBindEffect)
        {
            // 获取灵丝x9
            amount *= 9;
        }

        [HarmonyPatch(typeof(PlayerData), "AddShards")]
        [HarmonyPrefix]
        private static void AddShardsPrefix(ref int amount)
        {
            // 获取碎片x8
            amount *= 8;
        }

        [HarmonyPatch(typeof(HealthManager), "TakeDamage")]
        [HarmonyPrefix]
        private static void TakeDamagePrefix(ref HitInstance hitInstance)
        {
            if (!hitInstance.IsHeroDamage)
                return;
            // 玩家造成伤害x2
            hitInstance.Multiplier *= _damageMult;
        }

        [HarmonyPatch(typeof(PlayerData), "AddGeo")]
        [HarmonyPrefix]
        private static void AddGeoPrefix(PlayerData __instance, ref int amount)
        {
            // 所有获取念珠行为(包括拆红包)x2
            amount *= 2;
        }
        [HarmonyPatch(typeof(HeroController), "CocoonBroken", new[] { typeof(bool), typeof(bool) })]
        [HarmonyPrefix]
        private static void CocoonBrokenPrefix(ref bool doAirPause, ref bool forceCanBind, HeroController __instance)
        {
            // 防止收魂的念珠加倍
            __instance.playerData.HeroCorpseMoneyPool = __instance.playerData.HeroCorpseMoneyPool / 2;
        }
        [HarmonyPatch(typeof(HeroController), "AddToMaggotCharmTimer", new[] { typeof(float) })]
        [HarmonyPrefix]
        private static void AddToMaggotCharmTimerPrefix(ref float delta)
        {
            // 净界花环不消耗
            delta = 0;
        }
        [HarmonyPatch(typeof(HeroController), "UseLavaBell")]
        [HarmonyPrefix]
        private static bool UseLavaBellPrefix()
        {
            // 熔岩钟不消耗
            return false;
        }
        [HarmonyPatch(typeof(GameMap), "PositionCompassAndCorpse")]
        [HarmonyPostfix]
        public static void GameMapPrefix(ref GameMap __instance)
        {
            // 总是有指南针
            // 这个语法专门用来设置类的私有属性(前提不是那种有且只有get的，哪怕没有get/set都行)
            Traverse.Create(__instance).Field("displayingCompass").SetValue(true);
        }
        [HarmonyPatch(typeof(CurrencyObjectBase), "MagnetToolIsEquipped")]
        [HarmonyPrefix]
        public static bool MagnetToolIsEquippedPrefix(ref CurrencyObjectBase __instance, ref bool __result)
        {
            // 总是有磁铁
            // __result是固定关键字，表示原方法的返回值
            __result = true;
            return false;
        }
        [HarmonyPatch(typeof(HeroController), "ResetHunterUpgCrestState")]
        [HarmonyPrefix]
        private static bool ResetHunterUpgCrestStatePrefix()
        {
            // 猎人专注不消失
            return false;
        }
        [HarmonyPostfix]
        [HarmonyPatch(typeof(HeroController), "get_CurrentNailChargeTime")]
        private static void IncreaseNailChargeTime(ref float __result)
        {
            // 蓄力时间变为0.4s（原1.35s）
            __result = 0.4f;
        }
    }
}
