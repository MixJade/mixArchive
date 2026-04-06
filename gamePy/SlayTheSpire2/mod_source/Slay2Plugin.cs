using HarmonyLib;
using MegaCrit.Sts2.Core.Combat;
using MegaCrit.Sts2.Core.Commands;
using MegaCrit.Sts2.Core.Entities.Players;
using MegaCrit.Sts2.Core.GameActions.Multiplayer;
using MegaCrit.Sts2.Core.Hooks;
using MegaCrit.Sts2.Core.Modding;
using MegaCrit.Sts2.Core.Models;

namespace Slay2Plugin
{
    [ModInitializer("Init")]
    public static class Slay2Plugin
    {
        public static void Init()
        {
            new Harmony("com.mixjade.slay2plugin").PatchAll();
        }
    }

    // 补丁目标：Hook.AfterPlayerTurnStart
    [HarmonyPatch(typeof(Hook), nameof(Hook.AfterPlayerTurnStart))]
    public static class Hook_AfterPlayerTurnStart_Patch
    {
        // 玩家回合开始
        static void Postfix(CombatState combatState, PlayerChoiceContext choiceContext, Player player)
        {
            PlayerCmd.GainGold(50, player, false); // 获取50金币
            PlayerCmd.GainEnergy(50, player); // 获取50能量
        }
    }
}
