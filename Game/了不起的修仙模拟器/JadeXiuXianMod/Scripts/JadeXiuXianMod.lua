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
	--进入世界后自动应用“超级符师”相关设置（无界面、无弹窗、无按钮）
	self:ApplyPainterDefaults(true);
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
			"尽取其财，逐之出山。其人竟欣然色喜，犹感君之厚德，稽首而别。",
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
