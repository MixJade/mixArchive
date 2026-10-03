local JadeXian = GameMain:NewMod("JadeXian");
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
