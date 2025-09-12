using BepInEx;
using BepInEx.Logging;
using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
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

        // 多档位存档系统
        private static Dictionary<int, SaveSlot> saveSlots = new Dictionary<int, SaveSlot>();

        // Alt+6功能的入口点轮换索引
        private static int currentEntryPointIndex = 0;

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
        }

        // 可序列化的存档数据
        [System.Serializable]
        public class PersistentData
        {
            public Dictionary<int, SerializableSaveSlot> saveSlots = new Dictionary<int, SerializableSaveSlot>();
            public int currentEntryPointIndex = 0;
        }

        [System.Serializable]
        public class SerializableSaveSlot
        {
            public float x, y, z;
            public string scene = "";
            public bool hasData = false;

            public SerializableSaveSlot() { }

            public SerializableSaveSlot(SaveSlot slot)
            {
                x = slot.position.x;
                y = slot.position.y;
                z = slot.position.z;
                scene = slot.scene ?? "";
                hasData = slot.hasData;
            }

            public SaveSlot ToSaveSlot()
            {
                return new SaveSlot(new Vector3(x, y, z), scene);
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
                    string json = File.ReadAllText(filePath);
                    PersistentData data = JsonConvert.DeserializeObject<PersistentData>(json);

                    if (data != null && data.saveSlots != null)
                    {
                        // 恢复存档槽数据
                        saveSlots.Clear();
                        foreach (var kvp in data.saveSlots)
                        {
                            if (kvp.Value != null && kvp.Value.hasData)
                            {
                                saveSlots[kvp.Key] = kvp.Value.ToSaveSlot();
                            }
                        }

                        // 恢复入口点索引
                        currentEntryPointIndex = data.currentEntryPointIndex;

                        // 已加载持久化数据：data.saveSlots.Count 个存档槽
                    }
                }
            }
            catch (Exception ex)
            {
                Logger?.LogError($"加载持久化数据时发生错误: {ex.Message}");
            }
        }

        // 保存持久化数据
        private void SavePersistentData()
        {
            try
            {
                PersistentData data = new PersistentData();

                // 保存存档槽数据
                foreach (var kvp in saveSlots)
                {
                    if (kvp.Value.hasData)
                    {
                        data.saveSlots[kvp.Key] = new SerializableSaveSlot(kvp.Value);
                    }
                }

                // 保存入口点索引
                data.currentEntryPointIndex = currentEntryPointIndex;

                string json = JsonConvert.SerializeObject(data, Newtonsoft.Json.Formatting.Indented);
                string filePath = GetSaveFilePath();

                // 确保目录存在
                string directory = Path.GetDirectoryName(filePath);
                if (!Directory.Exists(directory))
                {
                    Directory.CreateDirectory(directory);
                }

                File.WriteAllText(filePath, json);
                // 已保存持久化数据：{data.saveSlots.Count} 个存档槽
            }
            catch (Exception ex)
            {
                Logger?.LogError($"保存持久化数据时发生错误: {ex.Message}");
            }
        }

        // 获取存档文件路径
        private string GetSaveFilePath()
        {
            try
            {
                // 使用Unity的persistentDataPath获取游戏数据目录
                // 通常是: C:\Users\[用户名]\AppData\LocalLow\Team Cherry\Hollow Knight Silksong
                string gameDataPath = "C:\\MyHide\\silkModData";

                // 在游戏数据目录下创建SureGodSwim子文件夹
                string modDataPath = Path.Combine(gameDataPath, "SureGodSwim");

                // 返回完整的JSON文件路径
                string saveFilePath = Path.Combine(modDataPath, "savedata.json");

                // 存档文件路径 {saveFilePath};
                return saveFilePath;
            }
            catch (Exception ex)
            {
                Logger?.LogError($"获取存档文件路径时发生错误 | Error getting save file path: {ex.Message}");
                // 出错时回退到相对路径
                return Path.Combine("SureGodSwim", "savedata.json");
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
                        SaveToSlot(i);
                        break;
                    }
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
                        LoadFromSlot(i);
                        break;
                    }
                }
            }
        }


        // 将字符串转换为KeyCode
        private KeyCode ParseKeyCode(string keyString)
        {
            try
            {
                return (KeyCode)System.Enum.Parse(typeof(KeyCode), keyString, true);
            }
            catch
            {
                Logger?.LogWarning($"无法解析按键设置: {keyString}，使用默认值: {keyString}, using default");
                return KeyCode.None;
            }
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
            string keyString = "Alpha1";
            if (slotNumber == 2)
            {
                keyString = "Alpha2";
            }
            else if (slotNumber == 3)
            {
                keyString = "Alpha3";
            }
            else if (slotNumber == 4)
            {
                keyString = "Alpha4";
            }
            else if (slotNumber == 5)
            {
                keyString = "Alpha5";
            }
            return ParseKeyCode(keyString);
        }

        // 检查并修复当前场景的位置安全性
        private Vector3 CheckAndFixPositionInCurrentScene(Vector3 targetPosition, int slotNumber)
        {
            try
            {
                if (HeroController.instance == null) return targetPosition;

                // 检查位置是否安全
                if (IsPositionSafe(targetPosition))
                {
                    // 档位 {slotNumber} 位置安全: {targetPosition}");
                    return targetPosition;
                }

                // 位置不安全，寻找附近的安全位置
                Logger?.LogWarning($"档位 {slotNumber} 位置不安全，正在查找安全位置: {targetPosition}");
                Vector3 safePosition = FindSafePositionNearby(targetPosition);

                if (safePosition != Vector3.zero)
                {
                    // 找到安全位置，更新存档槽
                    string currentScene = GameManager.instance.sceneName;
                    saveSlots[slotNumber] = new SaveSlot(safePosition, currentScene);
                    // 档位 {slotNumber} 已修正为安全位置: {targetPosition} -> {safePosition}
                    return safePosition;
                }
                else
                {
                    Logger?.LogWarning($"档位 {slotNumber} 无法找到安全位置，将在传送后尝试修复");
                    return targetPosition;
                }
            }
            catch (Exception ex)
            {
                Logger?.LogError($"检查位置安全性时发生错误: {ex.Message}");
                return targetPosition;
            }
        }

        // 检查位置是否安全（不会卡在地形中）
        private bool IsPositionSafe(Vector3 position)
        {
            try
            {
                var heroCollider = HeroController.instance?.GetComponent<Collider2D>();
                if (heroCollider == null) return true; // 如果获取不到碰撞器，假设安全

                var groundLayerMask = LayerMask.GetMask("Terrain");

                // 检查该位置是否与地形重叠
                var overlap = Physics2D.OverlapBox(
                    position,
                    heroCollider.bounds.size,
                    0f,
                    groundLayerMask
                );

                bool isSafe = overlap == null;
                //位置安全检查: {position} -> {(isSafe ? "安全" : "不安全")};
                return isSafe;
            }
            catch (Exception ex)
            {
                Logger?.LogError($"检查位置安全性时发生错误: {ex.Message}");
                return true; // 出错时假设安全
            }
        }

        private void SaveToSlot(int slotNumber)
        {
            try
            {
                if (HeroController.instance != null && GameManager.instance != null)
                {
                    Vector3 currentPosition = HeroController.instance.transform.position;
                    string currentScene = GameManager.instance.sceneName;

                    saveSlots[slotNumber] = new SaveSlot(currentPosition, currentScene);
                    // 档位 {slotNumber} 已保存: {currentPosition} 在场景: {currentScene}");

                    // 保存持久化数据
                    SavePersistentData();
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

                Vector3 targetPosition;
                string targetScene;

                // 检查指定档位是否有存档数据
                if (saveSlots.ContainsKey(slotNumber) && saveSlots[slotNumber].hasData)
                {
                    // 有存档数据，传送到存档位置
                    var slot = saveSlots[slotNumber];
                    targetPosition = slot.position;
                    targetScene = slot.scene;
                    // 准备传送到档位 {slotNumber}: {targetPosition} 在场景: {targetScene}");
                }
                else
                {
                    // 没有存档数据，回退到椅子传送逻辑
                    // 档位 {slotNumber} 没有存档数据，传送到椅子位置");
                    var (position, scene) = GetBenchPositionAndScene();
                    targetPosition = position;
                    targetScene = scene;

                    if (targetPosition == Vector3.zero || string.IsNullOrEmpty(targetScene))
                    {
                        Logger?.LogWarning("未找到有效的椅子位置或场景信息");
                        return;
                    }
                    // 准备传送到椅子位置: {targetPosition} 在场景: {targetScene}");
                }

                // 检查是否需要切换场景
                string currentScene = GameManager.instance.sceneName;
                if (!string.IsNullOrEmpty(targetScene) && currentScene != targetScene)
                {
                    // 需要切换场景: {currentScene} -> {targetScene}");
                    StartCoroutine(TeleportWithSceneChange(targetScene));
                }
                else
                {
                    // 在同一场景，先检查位置安全性
                    Vector3 safePosition = CheckAndFixPositionInCurrentScene(targetPosition, slotNumber);
                    // 已经预先检查过安全性，直接传送，无需重复检查
                    PerformTeleport(safePosition);
                }

            }
            catch (Exception ex)
            {
                Logger?.LogError($"从档位 {slotNumber} 传送时发生错误: {ex.Message}");
            }
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

                // 查找椅子: {respawnMarkerName} 在场景: {respawnScene}");

                // 检查椅子是否在当前场景
                string currentScene = GameManager.instance?.sceneName ?? "";
                if (currentScene == respawnScene)
                {
                    // 椅子在当前场景，直接查找位置
                    if (RespawnMarker.Markers != null)
                    {
                        var targetMarker = RespawnMarker.Markers
                            .FirstOrDefault(marker => marker != null && marker.gameObject.name == respawnMarkerName);

                        if (targetMarker != null)
                        {
                            // 在当前场景找到椅子: {targetMarker.gameObject.name} 位置: {targetMarker.transform.position}");
                            return (targetMarker.transform.position, respawnScene);
                        }
                    }
                    Logger?.LogWarning($"在当前场景中未找到椅子标记: {respawnMarkerName}");
                    return (Vector3.zero, "");
                }
                else
                {
                    // 椅子在其他场景，返回场景信息，坐标将在场景切换后获取
                    // 椅子在其他场景: {respawnScene}，需要切换场景后获取坐标");
                    return (Vector3.one, respawnScene); // 使用 Vector3.one 作为占位符，表示需要场景切换后获取真实坐标
                }
            }
            catch (Exception ex)
            {
                Logger?.LogError($"获取椅子位置时发生错误: {ex.Message}");
                return (Vector3.zero, "");
            }
        }

        // 场景切换传送
        private IEnumerator TeleportWithSceneChange(string targetScene)
        {
            // 开始场景切换到: {targetScene}");

            // 没有指定入口点，尝试智能选择
            string useEntryPoint = GetBestEntryPointForScene();

            // 使用入口点: {useEntryPoint}");

            // 使用 GameManager 的场景切换功能
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

            // 等待场景加载完成
            yield return new WaitWhile(() => GameManager.instance != null && GameManager.instance.IsInSceneTransition);

            // 等待额外一小段时间确保所有组件都初始化完成
            yield return new WaitForSeconds(0.5f);
        }

        // 智能选择最佳入口点
        private string GetBestEntryPointForScene()
        {
            try
            {
                // 常见的安全入口点名称列表（按优先级排序）
                string[] commonEntryPoints = { "door1", "door_entrance", "entrance", "left1", "right1", "top1", "bot1" };

                foreach (string entryPoint in commonEntryPoints)
                {
                    // 这里可以根据需要添加更复杂的逻辑
                    // 比如检查特定场景的已知入口点
                    // 尝试使用入口点: {entryPoint}");
                    return entryPoint;
                }

                // 如果都没有找到，返回默认值，GameManager会fallback到第一个可用的
                return "door1";
            }
            catch (Exception ex)
            {
                Logger?.LogError($"选择最佳入口点时发生错误: {ex.Message}");
                return "door1";
            }
        }

        // 在附近查找安全位置
        private Vector3 FindSafePositionNearby(Vector3 originalPosition)
        {
            try
            {
                var heroCollider = HeroController.instance?.GetComponent<Collider2D>();
                if (heroCollider == null) return Vector3.zero;

                var groundLayerMask = LayerMask.GetMask("Terrain");

                // 尝试向上、左、右偏移查找安全位置
                Vector3[] offsets = {
                new Vector3(0, 2f, 0),   // 向上
                new Vector3(0, 4f, 0),   // 向上更远
                new Vector3(-1f, 2f, 0), // 左上
                new Vector3(1f, 2f, 0),  // 右上
                new Vector3(-2f, 0, 0),  // 左侧
                new Vector3(2f, 0, 0),   // 右侧
            };

                foreach (var offset in offsets)
                {
                    Vector3 testPosition = originalPosition + offset;

                    var overlap = Physics2D.OverlapBox(
                        testPosition,
                        heroCollider.bounds.size,
                        0f,
                        groundLayerMask
                    );

                    if (overlap == null)
                    {
                        // 找到安全位置偏移: {offset}");
                        return testPosition;
                    }
                }

                return Vector3.zero;
            }
            catch (Exception ex)
            {
                Logger?.LogError($"查找安全位置时发生错误: {ex.Message}");
                return Vector3.zero;
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
    }

}
