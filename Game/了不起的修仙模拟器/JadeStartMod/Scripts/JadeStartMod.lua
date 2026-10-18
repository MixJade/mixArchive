--=====================================================================
--  JadeStartMod（新手上路）
--
--  功能索引：
--    1. 可在画符桌制作「乾坤灵晶」
--       → Settings/ThingDef/Item/Item_Equipment_MiBao.xml
--    2. 可在画符桌制作「天柱石」
--       → Settings/ThingDef/Item/Item_Material_SkyStone.xml
--    3. 交流第一句话就满好感                        模块一
--    4. 每次进存档，各个门派都欠我 100 人情          模块二
--    5. 周天神算施展后，触发 3 次「古修踪迹」        模块三
--
--  说明：1、2 两项是纯数据改动（物品定义 + 制作配方），不涉及脚本；
--        脚本只负责 3、4、5 三项逻辑改动。
--=====================================================================
local JadeStart = GameMain:NewMod("JadeStartMod");


--=====================================================================
--  入口
--=====================================================================
function JadeStart:OnEnter()
	-- 模块一：交流满好感（挂「选中 NPC」+「交流新台词」两个触发点）
	self:InitFullFavour();
	-- 模块三：周天神算 → 古修踪迹
	self:ApplyProphesyOverride();
	-- 模块二：全门派 100 人情（进存档时发放一次）
	self.friendGiven = self:GiveSectFriendPoint();
end

-- 兜底：OnEnter 时 TradeMgr 有时还没就绪，读档完成后补发一次；
-- friendGiven 保证整个存档会话只发一次，切换地图不会重复发放。
function JadeStart:OnAfterLoad()
	if not self.friendGiven then
		self.friendGiven = self:GiveSectFriendPoint();
	end
end


--=====================================================================
--  模块一：交流第一句话就满好感
--
--  江湖 NPC（各门派弟子、散修、路人…）的好感度存在 JianghuMgr 的
--  KnowNpcData 里：
--    favour  好感度，0~100，100 即满好感
--    hlock   心防标记，1 = 心防未破
--
--  两个触发点，互相兜底，都是幂等的：
--    ① 选中 NPC  —— 玩家点开某个江湖 NPC（准备交流的那一刻）就把好感写满，
--                   交流界面一打开显示的就是满好感；
--    ② 交流新台词 —— 交流过程中真的冒出第一句话时再写一次，
--                   覆盖「不走选中流程直接交流」的情况。
--=====================================================================
JadeStart.MAX_FAVOUR = 100;    --好感度上限

--挂事件：一个 table 只能注册一个事件，这里各用独立 key
function JadeStart:InitFullFavour()
	local Event = GameMain:GetMod("_Event");
	if Event == nil then
		print("[JadeStartMod] _Event 未就绪，交流满好感跳过");
		return;
	end
	--① 选中 NPC
	Event:RegisterEvent(
		g_emEvent.SelectNpc,
		function(evt, npc, objs) JadeStart:OnSelectNpc(npc); end,
		"JadeStartMod_SelectNpc"
	);
	--② 交流过程中出现新台词
	Event:RegisterEvent(
		g_emEvent.JiangTalkNewLine,
		function(evt, obj, objs) JadeStart:OnTalkNewLine(obj); end,
		"JadeStartMod_TalkLine"
	);
end

--选中 NPC：同一对象连续触发只处理一次
function JadeStart:OnSelectNpc(npc)
	if npc == nil then
		return;
	end
	if npc == self.lastFavourNpc then
		return;
	end
	self.lastFavourNpc = npc;
	self:FullFavour(npc);
end

--交流新台词：先从事件参数取交流对象，取不到再从交流窗口里找
function JadeStart:OnTalkNewLine(obj)
	local npc = nil;
	--事件参数本身可能就是交流对象
	if type(obj) == "userdata" or type(obj) == "table" then
		npc = obj;
	end
	--否则从交流窗口上取（不同版本字段名不同，逐个试，失败就算了）
	if npc == nil then
		pcall(function()
			local W = CS.Wnd_JianghuTalk.Instance;
			if W ~= nil then
				npc = W.Thing or W.Obj or W.m_Npc;
			end
		end);
	end
	if npc ~= nil then
		self:FullFavour(npc);
	end
end

--把某个 NPC 的好感度拉满；非江湖 NPC 静默跳过
function JadeStart:FullFavour(npc)
	if npc == nil then
		return;
	end
	if type(npc) ~= "userdata" and type(npc) ~= "table" then
		return;
	end
	--先取 JiangHuSeed：不是 NPC 或不是江湖人物就直接返回，不报错
	local seed = nil;
	local okSeed = pcall(function() seed = npc.JiangHuSeed; end);
	if not okSeed or seed == nil or seed <= 0 then
		return;
	end

	local ok, err = pcall(function()
		--JianghuMgr 是 main.lua 里挂的全局，取不到时退回 CS 上的单例
		local JH = JianghuMgr or CS.XiaWorld.JianghuMgr.Instance;
		if JH == nil then
			return;
		end
		--没认识过就先建立认识记录
		local data = JH:GetKnowNpcData(seed);
		if data == nil then
			JH:AddKnowNpcData(seed);
			data = JH:GetKnowNpcData(seed);
		end
		if data == nil then
			return;
		end
		--好感度直接写满
		data.favour = JadeStart.MAX_FAVOUR;
		--顺手破除心防；已破的就不动，避免重复加记忆
		local locked = true;
		local okH, h = pcall(function() return data.hlock; end);
		if okH and h == 0 then
			locked = false;
		end
		if locked then
			local okU = pcall(function() data:UnlockHeart(); end);
			if not okU then
				pcall(function() data.hlock = 0; end);
			end
		end
	end);
	if not ok then
		print("[JadeStartMod] 满好感处理异常: " .. tostring(err));
	end
end


--=====================================================================
--  模块二：每次进存档，各个门派都欠我 100 人情
--
--  TradeMgr:AddGlobalFriendPoint(n) 给所有门派统一加 n 点人情，
--=====================================================================
JadeStart.SECT_FRIEND_POINT = 100;    --每个门派加多少人情

--返回 true 表示确实加上了，供 OnEnter / OnAfterLoad 判断是否需要补发
function JadeStart:GiveSectFriendPoint()
	local ok, ret = pcall(function()
		local Trade = CS.XiaWorld.TradeMgr.Instance;
		if Trade == nil then
			return false;
		end
		Trade:AddGlobalFriendPoint(JadeStart.SECT_FRIEND_POINT);
		return true;
	end);
	if not ok then
		print("[JadeStartMod] 门派人情发放异常: " .. tostring(ret));
		return false;
	end
	if ret then
		print("[JadeStartMod] 已给所有门派各加 " .. JadeStart.SECT_FRIEND_POINT .. " 点人情");
	end
	return ret;
end


--=====================================================================
--  模块三：周天神算·古修踪迹
--
--  原版周天神算（Magic_Prophesy）施展成功后，只是给角色挂一个
--  Modifier_Sys_Magic_Prophesy（持续一个月，事件发生前预先提示）。
--  这里在保留原效果的基础上，成功时立即再触发 3 次「古修踪迹」。
--
--  GameEventMgr:TriggerEvent 的参数是 Settings/World/Events/EventList.txt
--  里的事件 ID：97 =「上古修行者」，对应秘闻 56「古修传闻」。
--
--  做法：在 OnEnter 里覆盖 MagicHelper 中 Magic_Prophesy 的 MagicLeave，
--  晚于游戏本体 Scripts/Magic/class/Magic_Prophesy.lua 执行。
--=====================================================================
JadeStart.PROPHESY_SECRET_ID = 97;    --「古修踪迹」事件 ID

function JadeStart:ApplyProphesyOverride()
	local MagicHelper = GameMain:GetMod("MagicHelper");
	local tbMagic = nil;
	if MagicHelper ~= nil and MagicHelper.GetMagic ~= nil then
		tbMagic = MagicHelper:GetMagic("Magic_Prophesy");
	end
	if tbMagic == nil then
		print("[JadeStartMod] Magic_Prophesy 未就绪，周天神算修改跳过");
		return;
	end
	--防止重复包装（会把原版逻辑叠好几层）
	if tbMagic.JadeStartHooked then
		return;
	end
	tbMagic.JadeStartHooked = true;

	--保留原版 MagicLeave（成功提示 + 挂 Modifier），成功时再补 3 次古修踪迹
	local rawLeave = tbMagic.MagicLeave;
	function tbMagic:MagicLeave(success)
		if rawLeave ~= nil then
			rawLeave(self, success);
		end
		if success == true then
			JadeStart:FireProphesySecret();
		end
	end
end

--立即触发 3 次「古修踪迹」
function JadeStart:FireProphesySecret()
	local ok, err = pcall(function()
		for i = 1, 3 do
			GameEventMgr:TriggerEvent(JadeStart.PROPHESY_SECRET_ID);
		end
	end);
	if not ok then
		print("[JadeStartMod] 触发古修踪迹异常: " .. tostring(err));
	end
end
