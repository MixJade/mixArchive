using BepInEx;
using HarmonyLib;
using System;

namespace MixSilkSongMod
{
    [BepInPlugin("MixJade.MixSilkSongMod", "MixSilkPlugin", "1.0.0.0")]
    [BepInProcess("Hollow Knight Silksong.exe")]
    public class MixSilkPlugin : BaseUnityPlugin
    {
        // 获取灵丝倍数
        private static float _silkMultiplier = 9;
        // 获取碎片倍数
        private static float _shardsMultiplier = 10;
        // 获取念珠倍数
        private static float _rosaryMultiplier = 2;
        // 造成伤害倍数
        private static float _damageMult = 2;


        private void Awake()
        {
            // 设置一堆配置文件参数
            Harmony.CreateAndPatchAll(typeof(MixSilkPlugin));
            _silkMultiplier = Config.Bind("Cheats", "MixSilkMult", 9.0f, "获取灵丝倍数").Value;
            _shardsMultiplier = Config.Bind("Cheats", "MixShardsMult", 10.0f, "获取碎片倍数").Value;
            _rosaryMultiplier = Config.Bind("Cheats", "MixRosaryMult", 2.0f, "获取念珠倍数").Value;
            _damageMult = Config.Bind("Cheats", "PlayerDamageMult", 2.0f, "造成伤害倍数").Value;
            Logger.LogInfo("Plugin MixJade.MixSilkSongMod is loaded!");
        }

        [HarmonyPatch(typeof(HeroController), "AddSilk", new[] { typeof(int), typeof(bool), typeof(SilkSpool.SilkAddSource), typeof(bool) })]
        [HarmonyPrefix]
        private static void AddSilkPrefix(ref int amount, ref bool heroEffect, ref SilkSpool.SilkAddSource source, ref bool forceCanBindEffect)
        {
            amount = (int)Math.Round(amount * _silkMultiplier);
        }

        [HarmonyPatch(typeof(PlayerData), "AddShards")]
        [HarmonyPrefix]
        private static void AddShardsPrefix(PlayerData __instance, ref int amount)
        {
            amount = (int)Math.Round(amount * _shardsMultiplier);
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
            // 所有获取念珠行为(包括拆红包)
            amount = (int)Math.Round(amount * _rosaryMultiplier);
        }
        [HarmonyPatch(typeof(HeroController), "CocoonBroken", new[] { typeof(bool), typeof(bool) })]
        [HarmonyPrefix]
        private static void CocoonBrokenPrefix(ref bool doAirPause, ref bool forceCanBind, HeroController __instance)
        {
            // 防止收魂的念珠加倍
            __instance.playerData.HeroCorpseMoneyPool = (int)Math.Round(__instance.playerData.HeroCorpseMoneyPool / _rosaryMultiplier);
        }
        [HarmonyPatch(typeof(HeroController), "AddToMaggotCharmTimer", new[] { typeof(float) })]
        [HarmonyPrefix]
        private static void AddToMaggotCharmTimerPrefix(ref float delta)
        {
            // 净界花环不消耗
            delta = 0;
        }
    }
}
