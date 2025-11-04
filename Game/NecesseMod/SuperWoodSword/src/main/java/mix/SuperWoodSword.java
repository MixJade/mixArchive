package mix;

import necesse.engine.modLoader.annotations.ModEntry;
import necesse.engine.network.gameNetworkData.GNDItemEnchantment;
import necesse.engine.network.gameNetworkData.GNDItemMap;
import necesse.engine.registries.ItemRegistry;
import necesse.engine.registries.ObjectRegistry;
import necesse.engine.registries.RecipeTechRegistry;
import necesse.inventory.item.Item;
import necesse.inventory.item.toolItem.ToolItem;
import necesse.inventory.item.toolItem.swordToolItem.WoodSwordToolItem;
import necesse.inventory.recipe.Ingredient;
import necesse.inventory.recipe.Recipe;
import necesse.inventory.recipe.Recipes;
import necesse.level.gameObject.GameObject;
import necesse.level.gameObject.TorchObject;

import java.lang.reflect.Field;
import java.lang.reflect.Method;

/**
 * 将木剑、木镐、木斧的伤害都改为520，将火把的亮度翻倍
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
                }
            }

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
        // 新增配方：1石头做5炸药
        registerNone("dynamitestick");
        // 新增配方：1石头做5回城卷轴
        registerNone("recallscroll");
        // 新增配方：1石头做5传送卷轴
        registerNone("teleportationscroll");
        // 新增配方：1石头做5铁皮药水
        registerWork("greaterresistancepotion");
        // 新增配方：1石头做5速度药水
        registerWork("greaterspeedpotion");
        // 新增配方：1石头做5钨锭
        registerWork("tungstenbar");
        // 新增配方：1石头做5石英
        registerWork("quartz");
        // 神圣卷轴-法师
        registerScroll("divine");
        // 狂暴卷轴-近战
        registerScroll("berserk");
        // 大师卷轴-工具
        registerScroll("master");
        // 高超卷轴-射手
        registerScroll("masterful");
        // 坚固卷轴-饰品
        registerScroll("sturdy");
        // 野蛮卷轴-召唤
        registerScroll("savage");
    }

    /**
     * 注册 普通配方
     */
    private void registerNone(String goods) {
        Recipes.registerModRecipe(new Recipe(
                goods,
                5,
                RecipeTechRegistry.NONE,
                new Ingredient[]{
                        new Ingredient("anystone", 1)
                }
        ));
    }

    /**
     * 注册 工作台配方
     */
    private void registerWork(String goods) {
        Recipes.registerModRecipe(new Recipe(
                goods,
                5,
                RecipeTechRegistry.WORKSTATION,
                new Ingredient[]{
                        new Ingredient("anystone", 1)
                }
        ));
    }

    /**
     * 注册 注魔卷轴配方
     */
    private void registerScroll(String buffName) {
        Recipes.registerModRecipe(new Recipe(
                "enchantingscroll",
                1,
                RecipeTechRegistry.WORKSTATION,
                new Ingredient[]{
                        new Ingredient("anystone", 1)
                },
                false,
                new GNDItemMap().setItem("enchantment", new GNDItemEnchantment(buffName))
        ));
    }
}
