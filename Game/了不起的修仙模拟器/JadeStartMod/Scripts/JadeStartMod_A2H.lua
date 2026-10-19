--=====================================================================
--  JadeStartMod（新手上路）—— 动物开智相关优化
--
--  模块四：主动观察优化（去「眼睛」标记 + 一次结算三次）
--  模块五：思考不用等（原版 600 秒）
--
--  两件事都发生在动物开智期（npc.A2H 不为 nil），触发点也都挂在
--  g_emEvent.JobEvent 上，所以合在一个文件里，共用一个事件回调：
--     · JobStudyThing —— 观察作业（模块四）
--     · JobYsThink    —— 思考作业（模块五）
--
--  JobEvent 的参数固定是 { 作业, 状态 }：
--    状态 0 = 作业开始，1 = 成功结束，2 = 失败 / 中断
--  （解析用主文件里的 ParseJobEvent / GetJobName）
--=====================================================================
local JadeStart = GameMain:GetMod("JadeStartMod");

JadeStart.STUDY_JOB_NAME = "JobStudyThing";    --观察作业的 JobDef 名
JadeStart.THINK_JOB_NAME = "JobYsThink";       --思考作业的 JobDef 名
JadeStart.STUDY_SETTLE_TIMES = 3;              --一次观察结算几次（原版是 1）


--=====================================================================
--  初始化
--=====================================================================
function JadeStart:InitA2H()
	--模块四：观察
	self.studyNpc = {};       --兜底记录（事件里拿不到作业对象时用）
	self.studyTarget = {};    --观察目标缓存：作业开始时记下，结束时万一东西没了也能补结算
	--模块五：思考
	self.thinkJobs = {};      --[npcId] = 还没跳完的思考作业

	local Event = GameMain:GetMod("_Event");
	if Event == nil then
		print("[JadeStartMod] _Event 未就绪，开智相关修改跳过");
		return;
	end
	Event:RegisterEvent(
		g_emEvent.JobEvent,
		function(evt, npc, objs) JadeStart:OnA2HJobEvent(npc, objs); end,
		"JadeStartMod_A2HJob"
	);
end

--读档后统一收尾：洗掉旧标记 + 把正在思考的作业跳完
function JadeStart:AfterLoadA2H()
	JadeStart:ClearAllStudyConflict();
	JadeStart:FinishAllThinkJobs();
end

--作业事件总入口：按作业名分发到模块四 / 模块五
function JadeStart:OnA2HJobEvent(npc, objs)
	if npc == nil then
		return;
	end
	local job, state = JadeStart:ParseJobEvent(objs);
	if job == nil then
		JadeStart:OnStudyJobEventFallback(npc);
		return;
	end

	local name = JadeStart:GetJobName(job);

	--模块五：思考作业
	if name == JadeStart.THINK_JOB_NAME then
		if state == 0 then
			JadeStart:AddThinkJob(npc, job);    --刚开始就当场跳完
		else
			pcall(function() JadeStart.thinkJobs[npc.ID] = nil; end);
		end
		return;
	end

	--模块四：观察作业
	if name ~= JadeStart.STUDY_JOB_NAME then
		return;
	end
	--state == 0 是作业刚开始，记下观察目标备用
	if state == 0 then
		JadeStart:RememberStudyTarget(npc, job);
		return;
	end
	--作业结束：先把「眼睛」标记洗掉（成功失败都洗，代价可以忽略）
	JadeStart:ClearStudyConflict(npc);
	--成功结束（或状态未知）才补结算；失败 / 中断就不给思绪了
	if state == nil or state == 1 then
		JadeStart:ExtraStudySettle(npc, job);
	end
end


--=====================================================================
--  模块四之一：观察产生的思绪不再带「眼睛」标记
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
--=====================================================================

function JadeStart:IsStudyJob(job)
	return JadeStart:GetJobName(job) == JadeStart.STUDY_JOB_NAME;
end

--作业开始时记下观察目标（观察作业的指令里存着它：CommandStudyThing.thing）
function JadeStart:RememberStudyTarget(npc, job)
	local id = nil;
	local thing = nil;
	local ok = pcall(function()
		id = npc.ID;
		thing = job.CMD.thing;
	end);
	if ok and id ~= nil and thing ~= nil then
		self.studyTarget[id] = thing;
	end
end

--兜底：事件里没带作业对象时，沿用「记录 -> 下一个事件」的老办法
function JadeStart:OnStudyJobEventFallback(npc)
	local id = nil;
	local curJob = nil;
	local ok = pcall(function()
		id = npc.ID;
		curJob = npc.JobEngine.CurJob;    --作业刚开始时是当前作业，结束时已被置空
	end);
	if not ok or id == nil then
		return;
	end
	if curJob ~= nil and JadeStart:IsStudyJob(curJob) then
		self.studyNpc[id] = true;
		return;
	end
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


--=====================================================================
--  模块四之二：一次观察结算三次
--
--  原版只在作业的 Watch 环节结算一次，这里在观察作业成功结束时，
--  用同样的规则（按观察目标 def.Frags 的权重随机）再补 2 次，
--  效果等同于结算了三次。
--=====================================================================

--额外结算：按观察目标的思绪池，再随机产出 (STUDY_SETTLE_TIMES - 1) 条
function JadeStart:ExtraStudySettle(npc, job)
	local times = JadeStart.STUDY_SETTLE_TIMES - 1;
	if times <= 0 then
		return;
	end
	--观察目标：优先从作业的指令里取，取不到就用作业开始时缓存的那份
	local thing = nil;
	local id = nil;
	pcall(function()
		id = npc.ID;
		thing = job.CMD.thing;
	end);
	if thing == nil and id ~= nil then
		thing = self.studyTarget[id];
	end
	if id ~= nil then
		self.studyTarget[id] = nil;    --用完就清，避免一直挂着对象
	end
	if thing == nil then
		print("[JadeStartMod] 取不到观察目标，额外结算跳过");
		return;
	end
	local mgr = CS.XiaWorld.HumanoidEvolutionMgr.Instance;
	if mgr == nil then
		return;
	end

	for i = 1, times do
		local frag = JadeStart:PickFrag(thing);
		if frag == nil then
			return;
		end
		--用 conflict = true 添加：这样不会弹「获得思绪」的提示框；
		--加完立刻把标记洗成 0，既不留眼睛，也允许下一条取到同一种思绪
		local okAdd, errAdd = pcall(function()
			mgr:AddThink(npc, frag, true);
		end);
		if not okAdd then
			print("[JadeStartMod] 额外思绪添加失败: " .. tostring(errAdd));
			return;
		end
		JadeStart:ClearStudyConflict(npc);
	end
end

--按权重从观察目标的 def.Frags 里抽一条思绪（等价于原版的 WeightRander.Random）
function JadeStart:PickFrag(thing)
	local frags = nil;
	local ok = pcall(function() frags = thing.def.Frags; end);
	if not ok or frags == nil or frags.Count == nil or frags.Count <= 0 then
		return nil;
	end

	local total = 0;
	for i = 0, frags.Count - 1 do
		local w = frags[i].Weight;
		if w == nil or w < 1 then
			w = 1;
		end
		total = total + w;
	end
	if total <= 0 then
		return frags[0].Frag;
	end

	local r = math.random() * total;
	local acc = 0;
	for i = 0, frags.Count - 1 do
		local w = frags[i].Weight;
		if w == nil or w < 1 then
			w = 1;
		end
		acc = acc + w;
		if r < acc then
			return frags[i].Frag;
		end
	end
	return frags[frags.Count - 1].Frag;
end


--=====================================================================
--  模块五：开智期动物「思考」不用等
--
--  原版点「开始思考」后，默认要挂机 600 秒（每多一个终极思绪减 50 秒，最低 10 秒）。
--
--  JobYsThink 把时长存进公开字段 keep，并用它建一个 ToilIdle(keep)。
--  keeptime 是私有字段改不了，但 ToilBase 有公开的
--  ForceSetRuning() / FinishToil()，可以直接把这一步跳完：
--  跳完后走 OnToilFinish -> OnLeaveJob -> A2H.FinishThink()，
--  和自然等满 600 秒得到的结算完全一样。
--
--  所以这里不做任何计时：作业一开始就把这个 toil 直接跳完。
--  极少数情况下 toil 还没进状态机、当场跳不动，
--  就先记进 thinkJobs，下一帧再试一次（只是重试，不是等待）。
--=====================================================================

--思考作业开始：当场跳完
function JadeStart:AddThinkJob(npc, job)
	local id = nil;
	local ok = pcall(function() id = npc.ID; end);
	if not ok or id == nil then
		return;
	end
	JadeStart:FinishThinkJob(job);
	--跳完（作业随之结束）就不用留着了；跳不动才留到下一帧重试
	local finished = true;
	pcall(function() finished = job.IsFinished; end);
	if not finished then
		self.thinkJobs[id] = job;
	end
end

--直接把思考这一步跳完，走正常的结算流程
function JadeStart:FinishThinkJob(job)
	if job == nil then
		return;
	end
	local ok, err = pcall(function()
		--作业已经结束（被打断、读档前就完成了）就不要再动它
		if job.IsFinished then
			return;
		end
		local toil = job:GetCurToil();
		if toil == nil or toil.IsFinished then
			return;
		end
		--toil 可能还没进入运行态，先强制置成运行态，
		--这样 FinishToil 里的 LeaveToil 才能把状态判成「成功」
		toil:ForceSetRuning();
		toil:FinishToil();
	end);
	if not ok then
		print("[JadeStartMod] 思考加速异常: " .. tostring(err));
	end
end

--上一帧没跳完的思考作业，再试一次（由主文件 OnStep 每帧调用）
function JadeStart:RetryThinkJobs()
	local jobs = self.thinkJobs;
	if jobs == nil then
		return;
	end
	local keep = {};
	for id, job in pairs(jobs) do
		JadeStart:FinishThinkJob(job);
		local finished = true;
		pcall(function() finished = job.IsFinished; end);
		if not finished then
			keep[id] = job;
		end
	end
	self.thinkJobs = keep;
end

--读档后：把正在思考的动物也直接跳完（存档里不会保存本 mod 的中间状态）
function JadeStart:FinishAllThinkJobs()
	local ok, err = pcall(function()
		local npcList = CS.XiaWorld.ThingMgr.Instance.NpcList;
		if npcList == nil then
			return;
		end
		for i = 0, npcList.Count - 1 do
			local npc = npcList[i];
			if npc ~= nil then
				local job = nil;
				pcall(function() job = npc.JobEngine.CurJob; end);
				if JadeStart:GetJobName(job) == JadeStart.THINK_JOB_NAME then
					JadeStart:AddThinkJob(npc, job);
				end
			end
		end
	end);
	if not ok then
		print("[JadeStartMod] 清理思考作业异常: " .. tostring(err));
	end
end
