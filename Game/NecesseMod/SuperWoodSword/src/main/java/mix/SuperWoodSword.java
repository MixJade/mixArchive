package mix;

import necesse.engine.modLoader.annotations.ModEntry;
import necesse.engine.registries.ItemRegistry;
import necesse.inventory.item.Item;
import necesse.inventory.item.toolItem.ToolDamageItem;
import necesse.inventory.item.toolItem.ToolItem;
import necesse.inventory.item.toolItem.axeToolItem.CustomAxeToolItem;
import necesse.inventory.item.toolItem.pickaxeToolItem.CustomPickaxeToolItem;
import necesse.inventory.item.toolItem.swordToolItem.WoodSwordToolItem;

import java.lang.reflect.Field;
import java.lang.reflect.Method;

/**
 * 将木剑、木镐、木斧的伤害都改为520
 *
 * @since 2025-10-22 23:26:43
 */
@SuppressWarnings("unused")
@ModEntry
public class SuperWoodSword {
    public void init() {
        try {
            // 这里 ItemRegistry.getItems() 可以搜索所有物品的英文名称
            for (Item item : ItemRegistry.getItems()) {
                if ("woodsword".equals(item.getStringID()) && item instanceof WoodSwordToolItem) {
                    WoodSwordToolItem woodSword = (WoodSwordToolItem) item;
                    System.out.println("开始处理【木剑】" + woodSword.getStringID());
                    // 1. 直接从已知的 ToolItem 类获取 attackDamage 字段（无需循环查找父类）
                    Field attackDamageField = ToolItem.class.getDeclaredField("attackDamage");
                    attackDamageField.setAccessible(true); // 允许访问私有/受保护字段
                    // 2. 获取 attackDamage 字段的值
                    Object attackDamage = attackDamageField.get(woodSword);
                    // 3. 反射调用 setBaseValue 方法修改基础值
                    Method setBaseValueMethod = attackDamage.getClass().getDeclaredMethod("setBaseValue", float.class);
                    setBaseValueMethod.setAccessible(true);
                    setBaseValueMethod.invoke(attackDamage, 520.0F); // 传入新的基础值

                    System.out.println("成功修改【木剑】的 attackDamage 基础值");
                } else if ("woodpickaxe".equals(item.getStringID()) && item instanceof CustomPickaxeToolItem) {
                    CustomPickaxeToolItem customPickaxe = (CustomPickaxeToolItem) item;
                    System.out.println("开始处理【木镐】" + customPickaxe.getStringID());
                    // 1. 直接从已知的 ToolDamageItem类获取 toolDps 字段
                    Field toolDpsField = ToolDamageItem.class.getDeclaredField("toolDps");
                    toolDpsField.setAccessible(true); // 允许访问私有/受保护字段

                    // 2. 获取 toolDps 字段的值
                    Object toolDps = toolDpsField.get(customPickaxe);

                    // 3. 反射调用 setBaseValue 方法修改基础值（例如改为 50.0F）
                    Method setBaseValueMethod = toolDps.getClass().getDeclaredMethod("setBaseValue", int.class);
                    setBaseValueMethod.setAccessible(true);
                    setBaseValueMethod.invoke(toolDps, 520); // 传入新的基础值

                    System.out.println("成功修改【木镐】的 toolDps 基础值");
                } else if ("woodaxe".equals(item.getStringID()) && item instanceof CustomAxeToolItem) {
                    CustomAxeToolItem customAxe = (CustomAxeToolItem) item;
                    System.out.println("开始处理【木斧】" + customAxe.getStringID());
                    // 1. 直接从已知的 ToolDamageItem类获取 toolDps 字段
                    Field toolDpsField = ToolDamageItem.class.getDeclaredField("toolDps");
                    toolDpsField.setAccessible(true); // 允许访问私有/受保护字段

                    // 2. 获取 toolDps 字段的值
                    Object toolDps = toolDpsField.get(customAxe);

                    // 3. 反射调用 setBaseValue 方法修改基础值（例如改为 50.0F）
                    Method setBaseValueMethod = toolDps.getClass().getDeclaredMethod("setBaseValue", int.class);
                    setBaseValueMethod.setAccessible(true);
                    setBaseValueMethod.invoke(toolDps, 520); // 传入新的基础值

                    System.out.println("成功修改【木斧】的 toolDps 基础值");
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
