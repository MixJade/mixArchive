--=====================================================================
--  代理事件恒为最优解
-- 1. 代理事件无视所选手段，恒按最优手段结算
-- 2. 结算后追加保底收益（信仰人口 / 影响力 / 吸引力）
-- 3. 我方弟子救灾固定收益1600
--=====================================================================

--防止同一个文件被执行两次
if JadeXianAgencyBest ~= nil then
	return;
end

local M = GameMain:NewMod("JadeXianAgencyBest");
JadeXianAgencyBest = M;


--============================== 参 数 ==============================

--每个代理事件对应的「最优手段」（= 该事件里唯一有实际收益的那条分支）
M.BEST_WAY = {
	--布施事件（Settings/MapStories/MapStory_Policy.xml）
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
	--神树采集事件（Settings/MapStories/MapStory_Policy2.xml）
	OutSpread_TreeEXP = "Member",
	--赈灾事件（Settings/MapStories/MapStory_Disasters.xml）
	Place_Drought = "Food",
	Place_Flood = "Rock",
	Place_Siberia = "Charm",
	Place_EarthQuake = "Charm",
};

--内部常量
local MARK_EXTRA = "[JadeXian:EXTRA]";  --(3) 追加收益的幂等标记，删了会每次读档叠收益
local PATTERN    = "local%s+solve%s*=%s*cRegion%.RegionPolicy%.Way%s*;";
local ENUM       = "CS.XiaWorld.OutspreadMgr.Region.SolveWay.";
local WAY_FLAG   = "RegionPolicy.Way";  --"这是要选手段的代理事件"的判据

--(3) 追加到每个代理事件末尾的保底收益：信仰人口 / 影响力 / 吸引力
--    要改成轻微效果，把下面两个 Increase* 换成 SlightlyIncrease*
local EXTRA_CODE = "\n--" .. MARK_EXTRA .. " 结算追加：信仰人口 / 影响力 / 吸引力\n"
	.. "tbTable:IncreasePop(WorldLua, cRegion);\n"
	.. "tbTable:AddInfluence(WorldLua, cRegion);\n"
	.. "tbTable:IncreaseAttra(WorldLua, cRegion);\n";


--============================= 小工具 ==============================

function M:Log(s)
	print("[JadeXian][代理] " .. tostring(s));
end

local function isNull(v)
	return v == nil or tostring(v) == "null";
end


--======================== 游戏生命周期回调 ========================

--读档、进入世界、切换地图后都会调用
function M:OnAfterLoad()
	local ok, err = pcall(function()
		M:ApplyAgencyAttrFree();   --(2) 解除属性门槛
		M:PatchStories();          --(1)(3) 换最优手段 + 追加保底收益
		M:ApplyDisasterTimes();    --(4) 救灾固定收益
	end);
	if not ok then
		M:Log("!! 应用异常: " .. tostring(err));
	end
end


--==================== 核心：取故事表 + 逐条改写 ====================

function M:PatchStories()
	local Mgr = CS.XiaWorld.MapStoryMgr.Instance;
	if isNull(Mgr) then
		return;                      --还没进世界（主菜单阶段），此时没有故事表
	end

	--m_mapStories 是 private static 字段：必须先开放私有访问，
	--且只能用「类.字段」取，用实例取是拿不到的（实测，见文件头）
	xlua.private_accessible(CS.XiaWorld.MapStoryMgr);
	local map = CS.XiaWorld.MapStoryMgr.m_mapStories;
	if isNull(map) or map.Count < 1 then
		return;                      --启动阶段表是空的，读档 / 换地图后会重新填充
	end

	--单遍扫完整张表：BEST_WAY 里有的换手段 + 追加收益，没有的只追加收益。
	--字典 key 就是 Story Name（同 TryGetValue 用的那个字符串），pairs 能直接拿
	local fresh, extra, fail = 0, 0, 0;
	for k, def in pairs(map) do
		local name = tostring(k);
		if not isNull(def) then
			local r, add, why = M:PatchStory(name, def, M.BEST_WAY[name]);
			if r < 0 then
				fail = fail + 1;
				M:Log("!! 改写 " .. name .. " 出错：" .. tostring(why));
			elseif r > 0 then
				fresh = fresh + 1;
				extra = extra + (add or 0);
			end
		end
	end

	if fresh > 0 or extra > 0 or fail > 0 then
		M:Log("代理事件改写：" .. fresh .. " 条 / 追加收益 " .. extra .. " 段 / 出错 " .. fail);
	end
end


--改写单条故事。返回：r, added, why
--    r > 0   本次有改动（数值 = 改动了几个选项）
--    r = 0   无需改动：已经改过，或不是"要选手段"的代理事件
--    r < 0   处理中抛异常（why 说明原因，本条保持原样）
--    added   本次新追加收益的选项数
--
--  幂等性来源（重要，别乱改）：
--    * 手段替换后原文里的 RegionPolicy.Way 消失，下一轮 WAY_FLAG 判断直接跳过
--    * 收益追加没有这个特征，所以必须靠 MARK_EXTRA 标记拦住，否则每次
--      OnAfterLoad（读档 / 切地图）都会再追加一段，收益无限叠
function M:PatchStory(name, def, best)
	local sels = def.Selections;
	if isNull(sels) then
		return 0, 0;
	end

	--替换文本：行尾 "--" 注释符 + 换行缺一不可
	--（没有 "--" 就是语法错误；没有换行会把同一行后面的代码注释掉）
	--best 为 nil（不在 BEST_WAY 里）时 repl 也是 nil，只加收益不换手段
	local repl = best and ("local solve = " .. ENUM .. tostring(best) .. ";  --[JadeXian:BEST]恒按最优\n");

	local changed, added, hit, pat = 0, 0, 0, 0;

	local ok, err = pcall(function()
		for i = 0, sels.Count - 1 do
			local sel = sels[i];
			local code = sel and sel.OKResult;
			--只碰"要选手段"的代理事件（结算代码里引用了 RegionPolicy.Way）
			if type(code) == "string" and string.find(code, WAY_FLAG, 1, true) ~= nil then
				hit = hit + 1;
				local new = code;

				--(1) 把"读取玩家所选手段"换成固定最优手段；不匹配时 gsub 原样返回
				if repl ~= nil then
					local nm, n = string.gsub(new, PATTERN, repl);
					new = nm;
					pat = pat + n;
				end

				--(3) 末尾追加保底收益
				if string.find(new, MARK_EXTRA, 1, true) == nil then
					new = new .. EXTRA_CODE;
					added = added + 1;
				end

				if new ~= code then
					sel.OKResult = new;
					changed = changed + 1;
				end
			end
		end
	end);

	if not ok then
		return -1, 0, err;
	end
	return changed, added;
end


--==================== (4) 我方弟子救灾固定收益 ====================
function M:ApplyDisasterTimes()
	if self.disasterHooked then
		return;                          --只包一次，避免反复套娃
	end
	local H = GameMain:GetMod("MapStoryHelper");
	if H == nil or H.InnerDisaster == nil then
		M:Log("MapStoryHelper 未就绪，救灾增益跳过");
		return;
	end
	self.disasterHooked = true;

	H.InnerDisaster = function() return 1600; end;
	M:Log("我方弟子救灾收益固定 = 1600");
end


--=================== (2) 取消事件里的属性门槛 ====================
function M:ApplyAgencyAttrFree()
	if self.attrFreeHooked then
		return;
	end
	local H = GameMain:GetMod("MapStoryHelper");
	if H == nil or H.MPL == nil or H.SPL == nil then
		M:Log("MapStoryHelper 未就绪，属性门槛跳过");
		return;
	end
	self.attrFreeHooked = true;

	--xml 里是 tbTable:MPL(1) / tbTable:SPL(1) 冒号调用，原值返回等级门槛，
	--改成恒 -1 后 unionData.Charm > -1 恒成立，门槛即失效
	H.MPL = function() return -1; end;    --MainPropertyLevel
	H.SPL = function() return -1; end;    --SidePropertyLevel
	M:Log("代理事件属性门槛已解除");
end
