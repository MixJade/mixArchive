--=====================================================================
--  代理事件恒为最优解（独立 mod 脚本）
--  丢进 mod 的 Scripts 目录即可 —— 游戏会自动加载 Scripts 下的所有 lua。
--  本文件自己用 GameMain:NewMod 注册成独立 mod，不依赖 JadeXiuXianMod.lua。
--
--  原理：代理事件的结算代码写在 Settings/MapStories/*.xml 的
--        <OKResult><![CDATA[ ... ]]></OKResult> 里，形如
--            local solve = cRegion.RegionPolicy.Way;
--            if solve == enumSolve.Social then A elseif solve == enumSolve.Fight then B ...
--        这些代码被读成 MapStoryDef.Selections[i].OKResult（public string），
--        玩家点「查看结果」时由 C# 现场编译执行、不缓存。因此在运行期把这段
--        字符串里的「读取手段」替换成固定值，就能让任何选择都按最优分支结算，
--        磁盘上的配置文件一个字节都不用改。
--=====================================================================

--防止同一个文件被执行两次
if JadeXianAgencyBest ~= nil then
	return;
end

local M = GameMain:NewMod("JadeXianAgencyBest");
JadeXianAgencyBest = M;


--============================== 配 置 ==============================

M.FORCE_BEST      = true;     --(1) 无视所选手段，恒按最优手段结算
M.IGNORE_ATTR     = true;     --(2) 取消代理事件内的属性门槛
M.EXTRA_REWARD    = true;     --(3) 结算后追加保底收益（信仰人口 / 影响力 / 吸引力）
M.EXTRA_FORCE     = "normal"; --(3) 强度："slight" = 轻微，"normal" = 标准

--每个代理事件对应的「最优手段」（= 该事件里唯一有实际收益的那条分支）
M.BEST_WAY = {
	--布施事件（MapStory_Policy.xml）
	OutSpread_Give1 = "Charm",
	OutSpread_Give2 = "Food",
	OutSpread_Give3 = "Rock",
	OutSpread_Give4 = "Social",
	OutSpread_Give5 = "Social",
	OutSpread_Give6 = "Social",
	OutSpread_Give7 = "Intelligence",
	OutSpread_Give8 = "LingStone",
	--特殊事件（遇到别的门派）
	OutSpread_Give9 = "Fight",
	OutSpread_Give10 = "Intelligence",
	OutSpread_Give11 = "Charm",
	OutSpread_Give12 = "Food",
	--布施事件
	OutSpread_Give13 = "Wood",
	OutSpread_Give14 = "Fight",
	OutSpread_Give15 = "Social",
	OutSpread_Give16 = "Social",
	OutSpread_Give17 = "LingStone",
	OutSpread_Give18 = "Social",
	--传道事件
	OutSpread_Sermon1 = "Charm",
	OutSpread_Sermon2 = "Charm",
	OutSpread_Sermon3 = "Fight",
	OutSpread_Sermon4 = "Intelligence",
	--密谋事件
	OutSpread_Secret1 = "Charm",
	OutSpread_Secret2 = "Intelligence",
	OutSpread_Secret3 = "Charm",
	OutSpread_Secret4 = "Food",
	--受戒事件（每篇对应的"正解"戒律不同）
	OutSpread_Disp1 = "Fight",
	OutSpread_Disp2 = "Charm",
	OutSpread_Disp3 = "Food",
	OutSpread_Disp4 = "Fight",
	OutSpread_Disp5 = "Intelligence",
	--神迹事件
	OutSpread_God1 = "Member",
	--神树采集事件（MapStory_Policy2.xml）
	OutSpread_TreeEXP = "Member",
	--赈灾事件（MapStory_Disasters.xml）
	Place_Drought = "Food",
	Place_Flood = "Rock",
	Place_Siberia = "Charm",
	Place_EarthQuake = "Charm",
};

--内部常量
M.MARK_BEST  = "[JadeXian:BEST]";     --(1) 换手段的幂等标记
M.MARK_EXTRA = "[JadeXian:EXTRA]";    --(3) 追加收益的幂等标记
M.PATTERN    = "local%s+solve%s*=%s*cRegion%.RegionPolicy%.Way%s*;";
M.ENUM       = "CS.XiaWorld.OutspreadMgr.Region.SolveWay.";
M.WAY_FLAG   = "RegionPolicy.Way";    --"这是要选手段的代理事件"的判据


--============================= 小工具 ==============================

function M:Log(s)
	print("[JadeXian][代理] " .. tostring(s));
end

function M:IsNull(v)
	return v == nil or tostring(v) == "null";
end


--======================== 游戏生命周期回调 ========================

--进世界时调用（故事表若还没就绪，Apply 内部会自行跳过）
function M:OnEnter()
	self:Apply();
end

--读档、进入世界、切换地图后都会调用
function M:OnAfterLoad()
	self:Apply();
end


--============================== 主逻辑 ==============================

function M:Apply()
	local ok, err = pcall(function()
		if M.IGNORE_ATTR then
			M.ApplyAgencyAttrFree(M);
		end
		if M.FORCE_BEST or M.EXTRA_REWARD then
			M:PatchStories();
		end
	end);
	if not ok then
		M:Log("!! 应用异常: " .. tostring(err));
	end
end


--==================== 核心：取故事表 + 逐条改写 ====================

function M:PatchStories()
	local Mgr = CS.XiaWorld.MapStoryMgr.Instance;
	if M:IsNull(Mgr) then
		return;                      --还没进世界（主菜单阶段），此时没有故事表
	end
	--m_mapStories 是 private static 字段，先开放私有成员访问
	pcall(function() xlua.private_accessible(CS.XiaWorld.MapStoryMgr) end);

	local map = nil;
	local okS, vS = pcall(function() return CS.XiaWorld.MapStoryMgr.m_mapStories end);
	if okS and not M:IsNull(vS) then
		map = vS;
	end
	if map == nil then
		local okI, vI = pcall(function() return Mgr.m_mapStories end);
		if okI and not M:IsNull(vI) then
			map = vI;
		end
	end
	if map == nil then
		return;
	end

	--故事表还没就绪（启动阶段是空的，读档 / 换地图时会重新填充）
	local okC, cnt = pcall(function() return map.Count end);
	if (not okC) or type(cnt) ~= "number" or cnt < 1 then
		return;
	end

	local fresh, extra, fail, missing = 0, 0, 0, 0;
	local seen = {};
	local function handle(name, def, best)
		if def == nil or seen[name] then
			return;
		end
		seen[name] = true;
		local r, ex, why = M:PatchAgencyStory(name, def, best);
		extra = extra + (ex or 0);
		if r == 1 then
			fresh = fresh + 1;
		elseif r == -1 then
			fail = fail + 1;
			M:Log("!! 改写 " .. tostring(name) .. " 出错： " .. tostring(why));
		end
	end

	--① 按「最优手段表」逐条改写（名字可靠，优先走 public 的 GetStoryDef）
	for name, best in pairs(M.BEST_WAY) do
		local def = nil;
		local okG, d1 = pcall(function() return Mgr:GetStoryDef(name) end);
		if okG and not M:IsNull(d1) then
			def = d1;
		end
		if def == nil then
			local ok2, d2 = pcall(function() return map[name] end);
			if ok2 and not M:IsNull(d2) then
				def = d2;
			end
		end
		if def == nil then
			missing = missing + 1;
		else
			handle(name, def, best);
		end
	end

	--② 整表扫一遍，给「最优手段表」之外的代理事件也追加保底收益
	if M.EXTRA_REWARD then
		local okEach = pcall(function()
			for k, def in pairs(map) do
				if def ~= nil then
					handle(tostring(k), def, nil);
				end
			end
		end);
		if not okEach then              --pairs 不可用时退化为 Keys 枚举
			pcall(function()
				local e = map.Keys:GetEnumerator();
				while e:MoveNext() do
					local nm = tostring(e.Current);
					local okG, d = pcall(function() return Mgr:GetStoryDef(nm) end);
					if okG and not M:IsNull(d) then
						handle(nm, d, nil);
					end
				end
			end);
		end
	end

	self.count = (self.count or 0) + fresh;
	if fresh > 0 or extra > 0 or fail > 0 or missing > 0 then
		self:Log("代理事件改写：" .. fresh .. " 条 / 追加收益 " .. extra .. " 段 / 出错 " .. fail
			.. " / 未找到 " .. missing .. "（累计 " .. self.count .. " 条）");
	end
end


--(3) 结算后追加的保底收益代码：信仰人口 / 影响力 / 吸引力
function M:ExtraCode()
	local pop = "IncreasePop";       --信仰人口（把当地不信者转成本门信众）
	local att = "IncreaseAttra";     --吸引力
	if M.EXTRA_FORCE == "slight" then
		pop = "SlightlyIncreasePop";
		att = "SlightlyIncreaseAttra";
	end
	return "\n--" .. M.MARK_EXTRA .. " 结算追加：信仰人口 / 影响力 / 吸引力\n"
		.. "tbTable:" .. pop .. "(WorldLua, cRegion);\n"
		.. "tbTable:AddInfluence(WorldLua, cRegion);\n"
		.. "tbTable:" .. att .. "(WorldLua, cRegion);\n";
end

--改写单条故事。返回：r, extra, why
--    r =  1  本次改了手段（或追加了收益）
--         0  无需改动（已经改过）
--        -1  处理中抛异常（why 说明原因，本条保持原样）
--         3  不是"要选手段"的代理事件，直接跳过（不计数）
--    extra = 本次新追加收益的段数
function M:PatchAgencyStory(name, def, best)
	if def == nil then
		return 3, 0;
	end
	local sels = def.Selections;
	if sels == nil then
		return 3, 0;
	end

	--替换文本：注意 "--" 注释符 + 结尾换行，缺一不可
	--（没有 "--" 就是语法错误；没有 "\n" 会把同一行后面的代码注释掉）
	local repl = "local solve = " .. M.ENUM .. tostring(best) .. ";  --" .. M.MARK_BEST
		.. "代理事件恒按最优手段结算\n";
	local extra = M:ExtraCode();

	local changed, extraAdd, eligible = 0, 0, 0;
	local ok, err = pcall(function()
		local n = sels.Count;
		for i = 0, n - 1 do
			local sel = sels[i];
			if sel ~= nil then
				local code = sel.OKResult;
				--只碰"要选手段"的代理事件（结算代码里引用了 RegionPolicy.Way）
				if type(code) == "string" and string.find(code, M.WAY_FLAG, 1, true) ~= nil then
					eligible = eligible + 1;
					local newCode = code;

					--(1) 把"读取玩家所选手段"换成固定最优手段
					if M.FORCE_BEST and best ~= nil
						and string.find(newCode, M.PATTERN) ~= nil
						and string.find(newCode, M.MARK_BEST, 1, true) == nil then
						newCode = string.gsub(newCode, M.PATTERN, repl);
					end

					--(3) 末尾追加保底收益
					if M.EXTRA_REWARD and string.find(newCode, M.MARK_EXTRA, 1, true) == nil then
						newCode = newCode .. extra;
					end

					if newCode ~= code then
						sel.OKResult = newCode;
						changed = changed + 1;
						if string.find(newCode, M.MARK_EXTRA, 1, true) ~= nil then
							extraAdd = extraAdd + 1;
						end
					end
				end
			end
		end
	end);

	if not ok then
		return -1, 0, "异常:" .. tostring(err);
	end
	if eligible == 0 then
		return 3, 0;                 --不是这类事件，不参与统计
	end
	if changed > 0 then
		return 1, extraAdd;
	end
	return 0, 0;
end


--=================== (2) 取消事件里的属性门槛 ====================

function M:ApplyAgencyAttrFree()
	local H = GameMain:GetMod("MapStoryHelper");
	if H == nil or H.MPL == nil or H.SPL == nil then
		self:Log("MapStoryHelper 未就绪，属性门槛解除跳过");
		return;
	end
	if self.attr_free_hooked then
		return;
	end
	self.attr_free_hooked = true;
	H.MPL = function(self, k) return -1; end;    --MainPropertyLevel
	H.SPL = function(self, k) return -1; end;    --SidePropertyLevel
	self:Log("代理事件属性门槛已解除");
end
