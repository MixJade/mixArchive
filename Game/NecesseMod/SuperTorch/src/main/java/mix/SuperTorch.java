package mix;

import necesse.engine.modLoader.annotations.ModEntry;
import necesse.engine.registries.ObjectRegistry;
import necesse.level.gameObject.GameObject;
import necesse.level.gameObject.TorchObject;

import java.lang.reflect.Field;

/**
 * 火把的亮度翻倍
 *
 * @since 2025-11-08 17:04:13
 */
@SuppressWarnings("unused")
@ModEntry
public class SuperTorch {
    public void init() {
        try {
            for (GameObject go : ObjectRegistry.getObjects()) {
                if ("torch".equals(go.getStringID()) && (go instanceof TorchObject)) {
                    TorchObject torch = (TorchObject) go;
                    System.out.println("开始处理【火把】" + torch.getStringID());
                    // 1. 直接获取 lightLevel 字段
                    Field lightLevelField = GameObject.class.getField("lightLevel");
                    // 2. 修改字段值为300（参数1：目标实例；参数2：要设置的值）
                    lightLevelField.setInt(torch, 300);
                    System.out.println("成功修改【火把】的 lightLevel 基础值");
                    break;
                }
            }
        } catch (Exception var6) {
            System.out.println("出现未知异常" + var6.getMessage());
            var6.printStackTrace();
        }
    }

    public void initResources() {
    }

    public void postInit() {
    }
}
