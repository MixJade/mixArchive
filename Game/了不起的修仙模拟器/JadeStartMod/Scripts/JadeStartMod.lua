--=====================================================================
--  JadeStartMod（新手上路）
--
--  功能索引：
--    1. 可在画符桌制作「乾坤灵晶」
--       → Settings/ThingDef/Item/Item_Equipment_MiBao.xml
--    2. 可在画符桌制作「天柱石」
--       → Settings/ThingDef/Item/Item_Material_SkyStone.xml
--    3. 交流第一句话就满好感（含破心防）              模块一
--    4. 每次进存档，各个门派都欠我 10 人情             模块二
--    5. 周天神算施展后，触发 3 次「古修踪迹」          模块三
--    6. 主动观察产生的思绪不再带「眼睛」标记           模块四
--
--  说明：1、2 两项是纯数据改动（物品定义 + 制作配方），不涉及脚本；
--        脚本只负责 3、4、5、6 四项逻辑改动。
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
	-- 模块四：主动观察的思绪去掉标记（挂「作业结束」触发点）
	self:InitStudyMarkRemover();
	-- 模块二：全门派 10 人情（进存档时发放一次）
	self.friendGiven = self:GiveSectFriendPoint();
end

-- 兜底：OnEnter 时 TradeMgr 有时还没就绪，读档完成后补发一次；
-- friendGiven 保证整个存档会话只发一次，切换地图不会重复发放。
function JadeStart:OnAfterLoad()
	if not self.friendGiven then
		self.friendGiven = self:GiveSectFriendPoint();
	end
	-- 模块四：把存档里已经带上「眼睛」标记的旧思绪统一洗一遍
	self:ClearAllStudyConflict();
end


--=====================================================================
--  模块一：交流第一句话就满好感
--
--  江湖 NPC（各门派弟子、散修、路人…）的好感度存在 JianghuMgr 的
--  JHNpcData 里：
--    favour  好感度，0~100，100 即满好感
--    hlock   心防标记，注意是「反」的：hlock == 0 才是心防未破
--            （JHNpcData.HeartIsLock => hlock == 0）
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

--把某个 NPC 的好感度拉满并破心防；非江湖 NPC 静默跳过
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

		--破心防：hlock == 0 表示「心防未破」，UnlockHeart() 就是 hlock = 1。
		--（旧版本写成了「hlock == 0 即已破」，所以每次都被跳过，心防一直没破）
		local locked = true;
		local okH, h = pcall(function() return data.hlock; end);
		if okH and h ~= nil and h ~= 0 then
			locked = false;    --已经破过，不重复处理
		end
		if locked then
			local okU, errU = pcall(function() data:UnlockHeart(); end);
			if not okU then
				--兜底：直接写字段，语义同 UnlockHeart
				print("[JadeStartMod] 破心防失败，改用写字段: " .. tostring(errU));
				pcall(function() data.hlock = 1; end);
			end
		end
	end);
	if not ok then
		print("[JadeStartMod] 满好感处理异常: " .. tostring(err));
	end
end


--=====================================================================
--  模块二：每次进存档，各个门派都欠我 10 人情
--
--  TradeMgr:AddGlobalFriendPoint(n) 给所有门派统一加 n 点人情，
--=====================================================================
JadeStart.SECT_FRIEND_POINT = 10;    --每个门派加多少人情

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
--  Modifier_Sys_Magic_Prophesy（持续一个月，作用是事件发生前预先提示）。
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


--=====================================================================
--  模块四：主动观察产生的思绪不再带「眼睛」标记
--
--  开智期动物获得思绪有两条路：
--    被动：Step_NpcThink 随机生成，思绪片段 Conflict = 0；
--    主动：玩家指挥「观察」某个东西，JobStudyThing.OnToilFinish 会调用
--          HumanoidEvolutionMgr.AddThink(worker, frag, conflict: true)，
--          把这条片段的 Conflict 置成 1。
--
--  Conflict = 1 有两个副作用：
--    ① 开智界面里这条思绪会显示一个「眼睛」图标
--       （UI 代码：m_eye.visible = think.Conflict > 0）；
--    ② _CheckThinkConflict 会拦掉同名的片段，
--       导致同一种思绪靠观察只能拿到一条。
--
--  所以只要把主动观察产生的片段 Conflict 改回 0，
--  表现就和被动获得的完全一致：没有标记，也不再限制重复获取。
--  被动片段本来就是 0，统一清一遍没有副作用。
--
--  清理时机：
--    ① 挂 JobEvent —— 发现某只动物「正在做观察作业」就记一笔，
--      等这个作业结束（CurJob 置空）时把它身上刚拿到的片段洗掉。
--       这样只影响观察得来的片段，吃丹药 / 剧情给的思绪标记不受影响；
--    ② 读档完成后全量洗一遍，兼容存档里已经带标记的旧片段。
--=====================================================================
JadeStart.STUDY_JOB_NAME = "JobStudyThing";    --观察作业的 JobDef 名

function JadeStart:InitStudyMarkRemover()
	--记录「刚做过观察作业」的 NPC id
	self.studyNpc = {};

	local Event = GameMain:GetMod("_Event");
	if Event == nil then
		print("[JadeStartMod] _Event 未就绪，观察标记清理跳过");
		return;
	end
	Event:RegisterEvent(
		g_emEvent.JobEvent,
		function(evt, npc, objs) JadeStart:OnJobEvent(npc); end,
		"JadeStartMod_JobEvent"
	);
end

--作业事件：识别观察作业的开始 / 结束
function JadeStart:OnJobEvent(npc)
	if npc == nil then
		return;
	end
	local id = nil;
	local job = nil;
	local ok = pcall(function()
		id = npc.ID;
		job = npc.JobEngine.CurJob;    --作业刚开始时是当前作业，结束时已被置空
	end);
	if not ok or id == nil then
		return;
	end

	--正在做观察作业：先记一笔，等作业结束时再清
	if job ~= nil and job.jobdef ~= nil and job.jobdef.Name == JadeStart.STUDY_JOB_NAME then
		self.studyNpc[id] = true;
		return;
	end

	--不是观察作业（包括观察作业刚结束）：这只动物刚观察过就洗一次
	if self.studyNpc[id] then
		self.studyNpc[id] = nil;
		self:ClearStudyConflict(npc);
	end
end

--清理某只动物身上所有带 Conflict 标记的思绪片段
--（JobEvent 触发很频繁，这里不再套闭包/pcall，保持最轻）
function JadeStart:ClearStudyConflict(npc)
	if npc == nil then
		return;
	end
	local a2h = npc.A2H;    --只有开智期动物才有这个字段，其它单位是 nil
	if a2h == nil then
		return;
	end
	JadeStart:ClearConflictList(a2h.thinkFrags);
	JadeStart:ClearConflictList(a2h.thinkFragCaches);
end

--把一个 List<ThinkFrag> 里所有 Conflict > 0 的片段清零
function JadeStart:ClearConflictList(list)
	if list == nil then
		return;
	end
	for i = 0, list.Count - 1 do
		local frag = list[i];
		if frag ~= nil and frag.Conflict ~= nil and frag.Conflict > 0 then
			frag.Conflict = 0;
		end
	end
end

--全量清理（读档后调用一次）
function JadeStart:ClearAllStudyConflict()
	local ok, err = pcall(function()
		local npcList = CS.XiaWorld.ThingMgr.Instance.NpcList;
		if npcList == nil then
			return;
		end
		for i = 0, npcList.Count - 1 do
			local npc = npcList[i];
			if npc ~= nil then
				local a2h = npc.A2H;
				if a2h ~= nil then
					JadeStart:ClearConflictList(a2h.thinkFrags);
					JadeStart:ClearConflictList(a2h.thinkFragCaches);
				end
			end
		end
	end);
	if not ok then
		print("[JadeStartMod] 清理观察标记异常: " .. tostring(err));
	end
end
