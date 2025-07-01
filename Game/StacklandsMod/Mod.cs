using HarmonyLib;
using System;
using System.Collections;
using UnityEngine;

namespace mixJadeNS
{
    public class mixJade : Mod
    {
        public override void Ready()
        {
            WorldManager.instance.GameDataLoader.AddCardToSetCardBag(SetCardBagType.CookingIdea, "mixJade_blueprint_golden_berry", 1);
            Logger.Log("Ready!");
        }
    }
}