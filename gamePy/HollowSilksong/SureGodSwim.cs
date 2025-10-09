using BepInEx;
using BepInEx.Logging;
using System;
using System.Collections;
using System.IO;
using System.Linq;
using UnityEngine;

namespace SureGodSwimMod
{
    [BepInPlugin("MixJade.SureGodSwimMod", "SureGodSwim", "1.0.0")]
    [BepInProcess("Hollow Knight Silksong.exe")]
    public class SureGodSwim : BaseUnityPlugin
    {
        private new static ManualLogSource Logger;

        // 多档位存档系统 - 键为存档槽位，值为场景(x,y)格式的字符串
        private static string[] saveSlots = {
             "Song_Enclave(36,8)", // 圣歌盟地
             "Belltown(71,8)", // 钟心镇
             "Bone_10(26,17)", // 幸存者营地
             "Aqueduct_05(122,10)", // 蚤托邦
             "Abyss_12(18,9)", // 深渊
        };

        // 存档数据结构
        public struct SaveSlot
        {
            public Vector3 position;
            public string scene;
            public bool hasData;

            public SaveSlot(Vector3 pos, string sceneName)
            {
                position = pos;
                scene = sceneName;
                hasData = true;
            }

            // 转换为scene(x,y)格式字符串
            public string ToSceneCoordinateString()
            {
                return $"{scene}({position.x:F2},{position.y:F2})";
            }
        }

        private void Awake()
        {
            Logger = base.Logger;
            Logger.LogInfo("《定仙游》已加载!");
            // 加载持久化数据
            LoadPersistentData();
        }

        // 加载持久化数据
        private void LoadPersistentData()
        {
            try
            {
                string filePath = GetSaveFilePath();
                if (File.Exists(filePath))
                {
                    // 读取所有行（自动按换行符分割）
                    string[] lines = File.ReadAllLines(filePath);
                    // 循环5次
                    for (int i = 0; i < 5; i++)
                    {
                        saveSlots[i] = lines[i].Trim();
                    }
                }
            }
            catch (Exception ex)
            {
                Logger?.LogError($"加载持久化数据时发生错误: {ex.Message}");
            }
        }

        // 获取存档文件路径
        private string GetSaveFilePath()
        {
            try
            {
                // 保存点位存档的位置
                string gameDataPath = "C:\\MyHide\\silkModData";
                // 返回完整的JSON文件路径
                string saveFilePath = Path.Combine(gameDataPath, "sureGodSwim.txt");
                // 存档文件路径
                return saveFilePath;
            }
            catch (Exception ex)
            {
                Logger?.LogError($"获取存档文件路径时发生错误: {ex.Message}");
                // 出错时回退到相对路径
                return Path.Combine("SureGodSwim", "sureGodSwim.txt");
            }
        }

        private void Update()
        {
            // 使用UnsafeInstance避免游戏启动时的错误日志
            if (GameManager.UnsafeInstance == null)
            {
                return;
            }
            // 键盘输入检测
            HandleKeyboardInput();
        }

        private void HandleKeyboardInput()
        {
            // 检查游戏是否暂停，如果暂停则忽略其他输入
            var gm = GameManager.UnsafeInstance;
            if (gm == null || gm.isPaused || gm.GameState != GlobalEnums.GameState.PLAYING)
            {
                return;
            }
            // 保存修饰键+存档槽按键 保存对应档位
            if (IsModifierKeyPressed("LeftControl"))
            {
                for (int i = 1; i <= 5; i++)
                {
                    KeyCode slotKey = GetSlotKey(i);
                    if (slotKey != KeyCode.None && Input.GetKeyDown(slotKey))
                    {
                        SaveToSlot(i-1);
                        break;
                    }
                }
                // ctrl+alt刷新存档
                KeyCode goSaveKeyCode = ParseKeyCode("LeftAlt");
                if (goSaveKeyCode != KeyCode.None && Input.GetKeyDown(goSaveKeyCode))
                {
                    LoadPersistentData();
                }
            }
            // 传送修饰键+存档槽按键 读取对应档位
            else if (IsModifierKeyPressed("LeftAlt"))
            {
                for (int i = 1; i <= 5; i++)
                {
                    KeyCode slotKey = GetSlotKey(i);
                    if (slotKey != KeyCode.None && Input.GetKeyDown(slotKey))
                    {
                        LoadFromSlot(i-1);
                        break;
                    }
                }
                KeyCode benchTeleportKeyCode = ParseKeyCode("Alpha6");
                if (benchTeleportKeyCode != KeyCode.None && Input.GetKeyDown(benchTeleportKeyCode))
                {
                    TeleportToBench();
                }
            }
        }

        // 将字符串转换为KeyCode
        private KeyCode ParseKeyCode(string keyString)
        {
            return (KeyCode)System.Enum.Parse(typeof(KeyCode), keyString, true);
        }

        // 检查修饰键是否被按下
        private bool IsModifierKeyPressed(string modifierKeyString)
        {
            KeyCode keyCode = ParseKeyCode(modifierKeyString);
            if (keyCode == KeyCode.None) return false;
            return Input.GetKey(keyCode);
        }

        // 获取配置的存档槽按键
        private KeyCode GetSlotKey(int slotNumber)
        {
            string keyString = "Alpha6";
            if (slotNumber == 1) keyString = "Alpha1";
            else if (slotNumber == 2) keyString = "Alpha2";
            else if (slotNumber == 3) keyString = "Alpha3";
            else if (slotNumber == 4) keyString = "Alpha4";
            else if (slotNumber == 5) keyString = "Alpha5";
            return ParseKeyCode(keyString);
        }

        private void SaveToSlot(int slotNumber)
        {
            try
            {
                if (HeroController.instance != null && GameManager.instance != null)
                {
                    Vector3 currentPosition = HeroController.instance.transform.position;
                    string currentScene = GameManager.instance.sceneName;

                    // 保存为scene(x,y)格式字符串
                    saveSlots[slotNumber] = new SaveSlot(currentPosition, currentScene).ToSceneCoordinateString();

                    string filePath = GetSaveFilePath();
                    // 确保目录存在
                    string directory = Path.GetDirectoryName(filePath);
                    if (!Directory.Exists(directory))
                    {
                        Directory.CreateDirectory(directory);
                    }
                    // 直接将数组写入文件，每个元素占一行
                    File.WriteAllLines(filePath, saveSlots);
                }
                else
                {
                    Logger?.LogWarning("HeroController 或 GameManager 未找到，无法保存位置");
                }
            }
            catch (Exception ex)
            {
                Logger?.LogError($"保存档位 {slotNumber} 时发生错误: {ex.Message}");
            }
        }

        private void LoadFromSlot(int slotNumber)
        {
            try
            {
                if (HeroController.instance == null || GameManager.instance == null)
                {
                    Logger?.LogWarning("HeroController 或 GameManager 未找到，无法传送");
                    return;
                }

                // 传送到存档位置
                var slot = TryParse(saveSlots[slotNumber]);
                Vector3 targetPosition = slot.position;
                string targetScene = slot.scene;
            

                string currentScene = GameManager.instance.sceneName;
                if (!string.IsNullOrEmpty(targetScene) && currentScene != targetScene)
                {
                    StartCoroutine(TeleportWithSceneChange(targetScene));
                }
                else
                {
                    PerformTeleport(targetPosition);
                }

            }
            catch (Exception ex)
            {
                Logger?.LogError($"从档位 {slotNumber} 传送时发生错误: {ex.Message}");
            }
        }

        // 从scene(x,y)格式字符串解析
        private SaveSlot TryParse(string str)
        {
            // 1. 分割场景名（左括号 '(' 之前的部分）
            int leftParenIndex = str.IndexOf('(');
            // 提取场景名（如 "Belltown"）
            string scene = str.Substring(0, leftParenIndex); 
            // 2. 提取括号内的坐标部分（如 "71.5,8.2"）
            int rightParenIndex = str.IndexOf(')');
            string coords = str.Substring(leftParenIndex + 1, rightParenIndex - leftParenIndex - 1);
            // 3. 分割x和y坐标（按逗号 ',' 分割）
            string[] xy = coords.Split(',');
            return new SaveSlot(new Vector3(float.Parse(xy[0]), float.Parse(xy[1]), 0.004f), scene);
        }

        private (Vector3 position, string scene) GetBenchPositionAndScene()
        {
            try
            {
                if (PlayerData.instance == null)
                {
                    Logger?.LogWarning("PlayerData 未找到");
                    return (Vector3.zero, "");
                }

                string respawnMarkerName = PlayerData.instance.respawnMarkerName;
                string respawnScene = PlayerData.instance.respawnScene;

                if (string.IsNullOrEmpty(respawnMarkerName) || string.IsNullOrEmpty(respawnScene))
                {
                    Logger?.LogWarning("未找到椅子标记名称或场景信息");
                    return (Vector3.zero, "");
                }

                string currentScene = GameManager.instance?.sceneName ?? "";
                if (currentScene == respawnScene)
                {
                    if (RespawnMarker.Markers != null)
                    {
                        var targetMarker = RespawnMarker.Markers
                            .FirstOrDefault(marker => marker != null && marker.gameObject.name == respawnMarkerName);

                        if (targetMarker != null)
                        {
                            return (targetMarker.transform.position, respawnScene);
                        }
                    }
                    Logger?.LogWarning($"在当前场景中未找到椅子标记: {respawnMarkerName}");
                    return (Vector3.zero, "");
                }
                else
                {
                    return (Vector3.one, respawnScene);
                }
            }
            catch (Exception ex)
            {
                Logger?.LogError($"获取椅子位置时发生错误: {ex.Message}");
                return (Vector3.zero, "");
            }
        }

        private IEnumerator TeleportWithSceneChange(string targetScene)
        {
            string useEntryPoint = GetBestEntryPointForScene();

            try
            {
                GameManager.instance.BeginSceneTransition(new GameManager.SceneLoadInfo
                {
                    SceneName = targetScene,
                    EntryGateName = useEntryPoint,
                    HeroLeaveDirection = GlobalEnums.GatePosition.unknown,
                    EntryDelay = 0f,
                    Visualization = GameManager.SceneLoadVisualizations.Default,
                    AlwaysUnloadUnusedAssets = true
                });
            }
            catch (Exception ex)
            {
                Logger?.LogError($"开始场景切换时发生错误: {ex.Message}");
                yield break;
            }

            yield return new WaitWhile(() => GameManager.instance != null && GameManager.instance.IsInSceneTransition);
            yield return new WaitForSeconds(0.5f);
        }

        private string GetBestEntryPointForScene()
        {
            try
            {
                string[] commonEntryPoints = { "door1", "door_entrance", "entrance", "left1", "right1", "top1", "bot1" };
                foreach (string entryPoint in commonEntryPoints)
                {
                    return entryPoint;
                }
                return "door1";
            }
            catch (Exception ex)
            {
                Logger?.LogError($"选择最佳入口点时发生错误: {ex.Message}");
                return "door1";
            }
        }

        // 原始传送方法，供内部使用
        private void PerformTeleport(Vector3 targetPosition)
        {
            try
            {
                if (HeroController.instance == null)
                {
                    Logger?.LogWarning("HeroController 未找到，无法执行传送");
                    return;
                }

                // 执行传送
                HeroController.instance.transform.position = targetPosition;

                // 重置物理速度，避免传送后继续移动
                var rb2d = HeroController.instance.GetComponent<Rigidbody2D>();
                if (rb2d != null)
                {
                    rb2d.linearVelocity = Vector2.zero;
                }

                // 重置一些可能导致问题的状态
                if (HeroController.instance.cState != null)
                {
                    HeroController.instance.cState.recoiling = false;
                    HeroController.instance.cState.transitioning = false;
                }

                // 传送完成: {targetPosition}");
            }
            catch (Exception ex)
            {
                Logger?.LogError($"执行传送时发生错误: {ex.Message}");
            }
        }

        // 直接传送到椅子功能
        private void TeleportToBench()
        {
            try
            {
                if (HeroController.instance == null || GameManager.instance == null)
                {
                    Logger?.LogWarning("HeroController 或 GameManager 未找到，无法传送到椅子");
                    return;
                }

                // 获取椅子位置信息
                var (position, scene) = GetBenchPositionAndScene();
                if (position == Vector3.zero || string.IsNullOrEmpty(scene))
                {
                    Logger?.LogWarning("未找到有效的椅子位置或场景信息");
                    return;
                }

                string currentScene = GameManager.instance.sceneName;
                // 检查是否需要切换场景
                if (!string.IsNullOrEmpty(scene) && currentScene != scene)
                {
                    StartCoroutine(TeleportWithSceneChange(scene));
                }
                else
                {
                    // 在同一场景，直接传送
                    PerformTeleport(position);
                }
            }
            catch (Exception ex)
            {
                Logger?.LogError($"传送到椅子时发生错误: {ex.Message}");
            }
        }
    }
}