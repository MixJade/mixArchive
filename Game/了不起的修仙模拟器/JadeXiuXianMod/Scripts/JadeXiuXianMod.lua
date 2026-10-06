local JadeXian = GameMain:NewMod("JadeXian");

--=====================================================================
--  模块一：扒光访客
--=====================================================================
function JadeXian:OnEnter()
	self.mod_enable = true;
	local Event = GameMain:GetMod("_Event");
	Event:RegisterEvent(g_emEvent.SelectNpc,
	function(evt, item, objs)
		if item ~= self.last_item then
			self.last_item = item
			self:AddBtn2Npcs(evt, item, objs);
		end
	end, "JadeXian");
	if World.GameMode == CS.XiaWorld.g_emGameMode.Fight then
		self.mod_enable = false;
	end
	--进入世界后自动应用“超级符师”相关设置（无界面、无弹窗）
	self:ApplyPainterDefaults(true);
	--绑定画符窗口：突破画符界面上挂「快速画符+」按钮（模块三）
	self:InitQuickPaint();
	--藏经阁扩容（模块四）
	self:InitCangJingGe();
	--大衍神算修改（模块六）
	self:ApplyMapStoryOverride();
end

function JadeXian:AddBtn2Npcs(evt, thing, objs)
	if not self.mod_enable then
		return;
	end
	if thing ~= nil and thing.ThingType == g_emThingType.Npc and thing.IsVistor then
		thing:RemoveBtnData("扒光");
		thing:AddBtnData(
			"扒光",
			"res/Sprs/ui/icon_hand",
			"GameMain:GetMod('JadeXian'):JadeXianonekey(bind)",
			"尽取其财，逐之出山",
			nil
		);
	end
end

function JadeXian:JadeXianonekey(npc)
	npc:AddMood("Tool_PerfectWorld");
	npc:AddMood("Magic1");
	npc:AddMood("BaseExpect2");
	npc:AddMood("Dan_Happiness");
	npc:AddMood("Illusion1");
	npc.Equip:UnEquipAll();
	npc:RemoveModifier("SysVistorModifier");
end


--=====================================================================
--  模块二：超级符师（由 GreatPainter MOD 合并而来，纯自动版、零界面）
--=====================================================================
local GlobleDataMgr = CS.XiaWorld.GlobleDataMgr.Instance;

--存入存档的固定数值：100 / 100 / 0.95 ≈ 1.06
--（100 是显示品质，0.95 为 GreatPainter 原公式系数，这里直接把结果硬编码）
local FU_VALUE = 1.06;

--把单个符文的快速画符品质写死为 100，并写入存档
local function SetOneFu(name, verbose)
	if name == nil then
		return;
	end
	local s, cv = GlobleDataMgr.FuSaves:TryGetValue(name)
	if s and cv > FU_VALUE then
		GlobleDataMgr.FuSaves:Remove(name)
	end
	GlobleDataMgr:SaveFuValue(name, FU_VALUE);
	local spelldef = PracticeMgr:GetSpellDef(name)
end

--把所有符文的快速画符品质统一写死为 100（自动执行，无弹窗、无提示框）
function JadeXian:SetAllFu(verbose)
	--存档数据尚未就绪时先跳过，交给 OnAfterLoad 兜底
	if PracticeMgr == nil or PracticeMgr.m_mapSpellDefs == nil then
		return 0;
	end
	if GlobleDataMgr == nil or GlobleDataMgr.FuSaves == nil then
		return 0;
	end
	local count = 0;
	for k, v in pairs(PracticeMgr.m_mapSpellDefs) do
		SetOneFu(k, verbose);
		count = count + 1;
	end
	return count;
end

--一次性应用所有“超级符师”默认设置（幂等，可重复调用）
function JadeXian:ApplyPainterDefaults(verbose)
	--幽粹成功率直接 100%
	CS.XiaWorld.GameDefine.SOULCRYSTALYOU_BASE = 1;
	--灵粹成功率直接 100%
	CS.XiaWorld.GameDefine.SOULCRYSTALLING_BASE = 1;
	--全部符文快速画符品质写死 100
	self:SetAllFu(verbose);
end

--兜底：进入世界的那一刻，存档数据有可能还没完全就绪；
--OnAfterLoad 是“读档且所有系统准备完毕后”触发的（切换地图时也会触发），
--所以在这里再幂等地设置一遍，保证一定生效。
function JadeXian:OnAfterLoad()
	self:ApplyPainterDefaults(false);
	if not self.painter_loaded then
		self.painter_loaded = true;
		print("超级符师默认设置已自动应用：幽粹/灵粹 100%，全部符文快速画符品质 100");
	end
	--风水镇物免条件（模块七）：进入世界后处理一次，换地图不重复
	if not self.fs_inited then
		self.fs_inited = true;
		local ok, err = pcall(function() JadeXian:StripFengshuiCondition(); end);
		if not ok then
			print("[JadeXian] 镇物条件处理异常: " .. tostring(err));
		end
	end
end


--=====================================================================
--  模块三：突破时快速画符（由 GreatPainter 的「快速画符+」合并）
--
--  符修「本命符（突破画符）」界面上挂一颗「16倍画符」按钮，
--  点一下即按固定倍率16倍直接结算完成本命符，不再弹出倍率选择窗口；
--=====================================================================
JadeXian.PainterPower = 16;    --固定倍率

--绑定画符窗口 + 挂按钮：窗口实例在切图/重进世界时可能被游戏重建，所以每次进入世界都重挂一次
function JadeXian:InitQuickPaint()
	xlua.private_accessible(CS.Wnd_FuPatinter);
	self.PainterWindow = CS.Wnd_FuPatinter.Instance;
	if self.HookedWindow ~= self.PainterWindow then
		self.HookedWindow = self.PainterWindow;
		self.PainterWindow.onPositionChanged:Add(function() JadeXian:AddQuickPaintButton(); end);
	end
end

--按固定倍率直接结算当前本命符
function JadeXian:QuickPaintPlus(power)
	local Window = self.PainterWindow;
	if Window == nil then
		return;
	end
	local callBack = Window.BrokenCallBack;
	if callBack ~= nil then
		local selectName = Window.SelectName;
		--先置 willhide 再调回调，避免游戏在回调内同步检查时错过标志
		if Window.waithide then
			Window.willhide = true;
		end
		--直接调用游戏自己的画符结算回调：(符名, ?, 倍率, ?)
		callBack(selectName, 1, power, true);
		--置 nil 防止重复结算，下次开窗游戏会重新赋值
		Window.BrokenCallBack = nil;
	end
	if not Window.waithide then
		Window:Hide();
	else
		--willhide 已置好，禁用画笔，等游戏自己关窗
		CS.MapRender.Instance.MousePainter.enabled = false;
	end
end

--按钮显隐：只在「本命符（突破画符）」页显示（模式索引 2 = 第三项）
function JadeXian:UpdateQuickPaintButton(EventContext)
	local Button = self.QuickPaintButton;
	if Button == nil then
		return;
	end
	Button.visible = (EventContext.sender.selectedIndex == 2);
end

--往画符窗口上挂「快速画符+」按钮
function JadeXian:AddQuickPaintButton()
	local Window = self.PainterWindow;
	if Window == nil or Window.contentPane == nil then
		return;
	end
	local contentPane = Window.contentPane;
	--防重入：同一窗口实例 + 同一面板且按钮还在时只挂一次
	if self.BuildedWindow == Window and self.BuildedPane == contentPane then
		if self.QuickPaintButton ~= nil and self.QuickPaintButton.parent == contentPane then
			return;
		end
		self.BuildedWindow = nil;
		self.BuildedPane = nil;
	end
	--清掉上一个窗口实例上残留的旧按钮
	if self.QuickPaintButton ~= nil then
		pcall(function()
			local b = JadeXian.QuickPaintButton;
			if b.parent then
				b.parent:RemoveChild(b);
			end
		end);
		self.QuickPaintButton = nil;
	end
	--先登记防重入标志，即使后面构建出错也不会在同一面板上叠第二颗按钮
	self.BuildedWindow = Window;
	self.BuildedPane = contentPane;
	local ok, err = pcall(function()
		local obj = UIPackage.CreateObjectFromURL("ui://0xrxw6g7hdhl18");
		local Button = contentPane:AddChild(obj);
		Button:SetXY(contentPane.m_n51.x - 10, contentPane.m_n51.y - 35);
		Button.width = 75;
		Button.title = XT("16倍画符");
		Button.name = "QuickPaintPlus";
		Button.onClick:Add(function() JadeXian:QuickPaintPlus(JadeXian.PainterPower); end);
		Button.visible = false;
		JadeXian.QuickPaintButton = Button;
		contentPane.m_Mode.onChanged:Add(function(EventContext) JadeXian:UpdateQuickPaintButton(EventContext); end);
		--按当前模式先同步一次显隐（进界面时可能已经在突破页）
		pcall(function() JadeXian:UpdateQuickPaintButton({ sender = contentPane.m_Mode }); end);
	end);
	if not ok then
		print("[JadeXian] 16倍画符+ 按钮构建失败: " .. tostring(err));
	end
end


--=====================================================================
--  模块四：藏经阁扩容（由 CangJingGeKuoRong100 MOD 合并而来）
--
--  把藏经阁「书架记忆上限」从默认 100 提到 10000（即扩容 100 倍）
--=====================================================================
function JadeXian:InitCangJingGe()
	--BOOK_SHELF_MEMORY 是私有静态字段，先开放访问
	xlua.private_accessible(CS.CangJingGeMgr);
	local Mgr = CS.CangJingGeMgr.Instance;
	if Mgr == nil then
		return;
	end
	Mgr.BOOK_SHELF_MEMORY = 10000;
	Mgr:ResetBookSelf();
end


--=====================================================================
--  模块五：更高堆叠上限（由 MOREMAXSTACK MOD 合并而来）
--
--  把所有可堆叠物品的叠加上限改成 9999，仓库上限单独处理
--  必须放在 OnBeforeInit：物品定义要在世界初始化之前改好
--=====================================================================
function JadeXian:OnBeforeInit()
	local ThingMgr = CS.XiaWorld.ThingMgr.Instance;
	if ThingMgr == nil then
		return;
	end
	--2 = 物品/建筑那类定义表（MaxStack 本来就是 1 的不可堆叠物品不动）
	local b, data = ThingMgr.m_mapThingDefs:TryGetValue(2);
	if b and data ~= nil then
		for k, v in pairs(data) do
			if v ~= nil and v.MaxStack ~= nil and v.MaxStack ~= 1 then
				v.MaxStack = 9999;
			end
		end
	end
	--仓库（储物格）不在上面的表里，需要单独取定义来改
	local storeDef = ThingMgr:GetDef(g_emThingType.Space, "StorageSpace");
	if storeDef ~= nil then
		storeDef.MaxStack = 9999;
	end
end


--=====================================================================
--  模块六：大衍神算修改（由 SpellOfTriWorldByDao MOD 合并而来）
--
--  原版大衍神算随机出 53~76 号秘闻（并把 60 修正成 59），这里改成只出
--  「道统 / 奇书」两类：五成概率 70~76，五成概率 58~60
--  做法与原 mod 相同：覆盖 MagicHelper 里 Magic_MapStory 神通类的方法
--  放在 OnEnter 执行，确保晚于游戏本体的 Scripts\Magic\class\Magic_MapStory.lua
--=====================================================================
function JadeXian:ApplyMapStoryOverride()
	local MagicHelper = GameMain:GetMod("MagicHelper");
	local tbMagic = nil;
	if MagicHelper ~= nil and MagicHelper.GetMagic ~= nil then
		tbMagic = MagicHelper:GetMagic("Magic_MapStory");
	end
	if tbMagic == nil then
		print("[JadeXian] Magic_MapStory 未就绪，大衍神算修改跳过");
		return;
	end

	function tbMagic:Init()
	end

	function tbMagic:TargetCheck(k, t)
		return true;
	end

	function tbMagic:MagicEnter(IDs, IsThing)
	end

	function tbMagic:MagicStep(dt, duration)    --返回值 0继续 1成功并结束 -1失败并结束
		self:SetProgress(duration / self.magic.Param1);
		if duration >= self.magic.Param1 then
			return 1;
		end
		return 0;
	end

	function tbMagic:MagicLeave(success)
		if success == true then
			local LuaHelper = self.bind.LuaHelper;
			local daohang = LuaHelper:GetDaoHang();
			local rate = daohang / 4000 * (LuaHelper:GetIntelligence() + LuaHelper:GetLuck());
			local SECRET;
			if math.random(10) / 10 >= 0.5 then
				SECRET = {70, 76};    --道统
			else
				SECRET = {58, 60};    --奇书
			end
			if world:CheckRate(rate) then
				world:ShowStoryBox(XT("大衍神算成功，获得秘闻"), XT("大衍神算"));
				GameEventMgr:TriggerEvent(world:RandomInt(SECRET[1], SECRET[2]));
			else
				world:ShowStoryBox(XT("大衍神算失败"), XT("大衍神算"));
			end
		end
	end

	function tbMagic:OnGetSaveData()
		return nil;
	end

	function tbMagic:OnLoadData(tbData, IDs, IsThing)
	end
end


--=====================================================================
--  模块七：风水镇物免条件
--
--  随机生成的镇物默认带几类生效条件：
--    RoomKind      房间类型（卧室/丹房/库房…，位标志）
--    RoomLevel     房间大小等级
--    RoomFengshui  房间风水等级
--    Localtion     摆放位置（角落/靠墙/门旁…）
--    ElementKind   元素种类（要求放在对应五行浓度足够的位置）
--    ElementPower  该元素的最低浓度要求
--  FengshuiItemData.CheckActive 里这几项都是「字段 != 0 才检查」，
--  所以清零就等于取消对应限制，镇物放进任意房间都能生效。
--
--  做法：进入世界时遍历一次全部物品，挑出镇物（FSItemState > 0），读一次
--  FengshuiItem 触发它懒加载生成属性数据，再把上面几项写成 0。
--  （属性数据只在首次读取时生成一次，种子是物品 ID，所以必须在
--    生成之后再改，改了就是永久生效。）
--
--  时机：不做定时扫描，只在「进入世界」后处理一次，换地图不再重复。
--  入口挂在 OnAfterLoad（读档且所有系统就绪后才触发，新档/读档都会走，
--  比 OnEnter 可靠 —— OnEnter 时世界数据可能还没载入完），
--  一个 fs_inited 标志保证整个游戏会话只跑一遍。
--
--  边界说明：
--   * 元素浓度要求（ElementKind / ElementPower）也一并清零：
--     CheckActive 里 ElementKind == 0 会直接跳过整段元素判定，镇物不再挑
--     元素位置；物品自身的五行属性走 Thing.ElementKind，是另一个字段，不受影响；
--   * 只处理随机生成的镇物（def 里没自带 Fengshui 的），
--     道德印之类的固定镇物定义不动；
--   * 进入世界之后新生成/新开出的镇物不在处理范围内。
--=====================================================================

--清掉一件镇物的「房间 / 摆放 / 元素浓度」条件；返回 true 表示确实改到了数据
function JadeXian:ClearFengshuiCondition(item)
	local ok, err = pcall(function()
		--读这个属性会触发游戏懒加载生成属性数据（只生成一次，之后走缓存）
		local data = item.FengshuiItem;
		if data == nil then
			error("FengshuiItem 为空");
		end
		--0 即「无要求」
		data.RoomKind = 0;         --不限房间类型
		data.RoomLevel = 0;        --不限房间大小等级
		data.RoomFengshui = 0;     --不限房间风水等级
		data.Localtion = 0;        --不限摆放位置
		data.ElementKind = 0;      --不限元素种类（跳过五行浓度判定）
		data.ElementPower = 0;     --不限元素浓度
	end);
	if not ok then
		if not self.fs_warned then
			self.fs_warned = true;
			print("[JadeXian] 镇物条件写入失败，本功能未生效: " .. tostring(err));
		end
		return false;
	end
	return true;
end

--扫描一遍全部物品，把镇物的房间/摆放/元素浓度条件清掉（进入世界后调用一次）
function JadeXian:StripFengshuiCondition()
	local Mgr = CS.XiaWorld.ThingMgr.Instance;
	if Mgr == nil then
		return;
	end
	local things = Mgr.m_mapThingbyID;   --物品 ID -> Thing
	if things == nil then
		return;
	end
	local ItemType = g_emThingType.Item;
	local count = 0;
	for _, t in pairs(things) do
		if t ~= nil then
			local ok1, isItem = pcall(function() return t.ThingType == ItemType; end);
			if ok1 and isItem then
				local ok2, state = pcall(function() return t.FSItemState; end);
				if ok2 and state ~= nil and state > 0 then
					--def 自带 Fengshui 的是固定镇物，不动；其余是随机生成的
					local ok3, isRandom = pcall(function()
						local d = t.def;
						return d ~= nil and d.Item ~= nil and d.Item.Fengshui == nil;
					end);
					if ok3 and isRandom and self:ClearFengshuiCondition(t) then
						count = count + 1;
					end
				end
			end
		end
	end
	if count > 0 then
		print("[JadeXian] 已清除 " .. count .. " 件镇物的房间/摆放/元素浓度条件");
	end
end
