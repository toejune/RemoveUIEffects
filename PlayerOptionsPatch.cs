using HarmonyLib;

namespace RemoveUIEffects;

[HarmonyPatch(typeof(PlayerOptions))]
public class PlayerOptionsPatch
{
    [HarmonyPrefix]
    [HarmonyPatch("SetUIDistortion")]
    static void SetUIDistortion_Prefix(ref float value) => value = 0;
    [HarmonyPrefix]
    [HarmonyPatch("SetUIBloom")]
    static void SetUIBloom_Prefix(ref float value) => value = 0;
}