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
