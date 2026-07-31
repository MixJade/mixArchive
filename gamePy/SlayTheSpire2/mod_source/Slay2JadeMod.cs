using HarmonyLib;
using MegaCrit.Sts2.Core.Combat;
using MegaCrit.Sts2.Core.Commands;
using MegaCrit.Sts2.Core.Entities.Players;
using MegaCrit.Sts2.Core.GameActions.Multiplayer;
using MegaCrit.Sts2.Core.Hooks;
using MegaCrit.Sts2.Core.Modding;

namespace Slay2JadeMod
{
    [ModInitializer("Init")]
    public static class Slay2JadeMod
    {
        public static void Init()
        {
            new Harmony("com.mixjade.slay2JadeMod").PatchAll();
        }
    }

    // 补丁目标：Hook.AfterPlayerTurnStart
    [HarmonyPatch(typeof(Hook), nameof(Hook.AfterPlayerTurnStart))]
    public static class Hook_AfterPlayerTurnStart_Patch
    {
        // 玩家回合开始
        static void Postfix(CombatState combatState, PlayerChoiceContext choiceContext, Player player)
        {
            PlayerCmd.GainGold(10, player, false); // 获取10金币
            PlayerCmd.GainEnergy(10, player); // 获取10能量
        }
    }
}
