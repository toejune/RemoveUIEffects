using BepInEx;
using BepInEx.Logging;
using HarmonyLib;

namespace RemoveUIEffects;

[MycoMod(null, ModFlags.IsClientSide)]
[BepInPlugin(MyPluginInfo.PLUGIN_GUID, MyPluginInfo.PLUGIN_NAME, MyPluginInfo.PLUGIN_VERSION)]
public class Plugin : BaseUnityPlugin
{
    internal static new ManualLogSource Logger;
    private Harmony _harmony = new Harmony(MyPluginInfo.PLUGIN_GUID);
        
    private void Awake()
    {
        Logger = base.Logger;

        _harmony.PatchAll(typeof(PlayerOptionsPatch));

        Logger.LogInfo($"{MyPluginInfo.PLUGIN_GUID} loaded!");
    }
}
