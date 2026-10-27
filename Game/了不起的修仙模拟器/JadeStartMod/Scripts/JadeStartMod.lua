local JadeStart = GameMain:GetMod("JadeStartMod");


--=====================================================================
--  入口
--=====================================================================
function JadeStart:OnEnter()
	-- 模块一：交流满好感（挂「选中 NPC」+「交流新台词」两个触发点）
	self:InitFullFavour();
	-- 模块四 + 模块五：动物开智（观察 / 思考），见 JadeStartMod_A2H.lua
	self:InitA2H();
	-- 模块二：全门派 10 人情（进存档时发放一次）
	self.friendGiven = self:GiveSectFriendPoint();
	-- 模块二B：全门派 +200 好感
	self.relationGiven = self:GiveSectRelation();
end

-- 兜底：OnEnter 时 TradeMgr / SchoolMgr 有时还没就绪，读档完成后补发一次；
-- 两个 given 标记保证整个存档会话只发一次，切换地图不会重复发放。
function JadeStart:OnAfterLoad()
	if not self.friendGiven then
		self.friendGiven = self:GiveSectFriendPoint();
	end
	if not self.relationGiven then
		self.relationGiven = self:GiveSectRelation();
	end
	-- 模块四 / 五：洗掉旧思绪标记 + 把正在思考的作业直接跳完
	self:AfterLoadA2H();
end

function JadeStart:OnStep(dt)
	-- 模块五：上一帧没跳完的思考作业，下一帧再试一次（只是重试，不计时）
	if self.thinkJobs ~= nil and next(self.thinkJobs) ~= nil then
		self:RetryThinkJobs();
	end
end


--=====================================================================
--  公共工具：作业事件参数解析
--
--  JobEvent 的参数固定是 { 作业, 状态 }：
--    状态 0 = 作业开始，1 = 成功结束，2 = 失败 / 中断
--  （XLua 数组下标有 0 起和 1 起两种习惯，这里都兼容）
--=====================================================================

--从事件参数里取「作业 + 状态」；取不到返回 nil
function JadeStart:ParseJobEvent(objs)
	if objs == nil then
		return nil, nil;
	end
	local job = nil;
	local state = nil;
	local ok = pcall(function()
		if objs[0] ~= nil then
			job, state = objs[0], objs[1];
		else
			job, state = objs[1], objs[2];
		end
	end);
	if not ok or job == nil then
		return nil, nil;
	end
	if type(state) ~= "number" then
		state = nil;
	end
	return job, state;
end

--取作业的 JobDef 名（取不到返回 nil）
function JadeStart:GetJobName(job)
	if job == nil then
		return nil;
	end
	local ok, name = pcall(function() return job.jobdef.Name; end);
	if not ok then
		return nil;
	end
	return name;
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
--  模块二B：每次读档，全门派好感 +200
--
--  数值存在 SchoolMgr.SchoolRelation 里，范围 -1200 ~ 1200，等级换算：
--    >= 1000 敬重 / >= 400 友好 / >= 0 中立 / >= -400 冷淡 / >= -1000 敌视 / 更低仇恨
--
--  注意：正面加值会被难度系数缩放，实际入账可能少于200，这里不修正，跟随游戏原生难度设定走。
--=====================================================================
JadeStart.SECT_RELATION_ADD = 200;    --每个门派加多少好感（名义值，可能被难度缩放）

--门派ID：1~12 就是 Settings/World/Schools/Schools.txt 里的常规门派，不含武当DLC（ID=13）
JadeStart.SCHOOL_IDS = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 };

--返回 true 表示确实加上了
function JadeStart:GiveSectRelation()
	local ok, cnt = pcall(function()
		local SM = SchoolMgr or CS.XiaWorld.SchoolMgr.Instance;
		if SM == nil then
			return 0;
		end
		--注意：AddSchoolRelation 内部会对正数乘 RuntimeVar.Var.RealSchoolAddRelationScale
		--（难度系数，[DefV(1f)] 默认 1），所以这里传入的 200 只是「名义值」，
		--高难度下实际入账会按比例缩水。这是游戏原生的缩放，保持不动。
		local per = JadeStart.SECT_RELATION_ADD;
		local ids = JadeStart.SCHOOL_IDS;
		for i = 1, #ids do
			local id = ids[i];
			--单个门派出错不影响其他门派
			pcall(function() SM:AddSchoolRelation(id, per); end);
		end
		return #ids;
	end);
	if not ok then
		print("[JadeStartMod] 门派好感发放异常: " .. tostring(cnt));
		return false;
	end
	if cnt > 0 then
		print("[JadeStartMod] 已给 " .. cnt .. " 个门派各加 " .. JadeStart.SECT_RELATION_ADD .. " 点好感");
		return true;
	end
	return false;
end
