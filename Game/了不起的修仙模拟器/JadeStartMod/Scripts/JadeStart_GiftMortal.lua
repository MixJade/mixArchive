--=====================================================================
--  JadeStartMod —— 招贤礼包：召来一批天资不凡的凡人叩山门
--
--  走本体「点化仙缘」同一条原生路径 me:AddJoiners，
--  姓名 / 年龄 / 相貌 / 技能全部由 NpcRandomMechine.RandomNpc 原生生成。
--  （自己用 ThingMgr.AddNpc 造人会让属性面板技能页全显示成「机能」。）
--
--  原生接口不返回 npc 句柄，只能调用前后扫 ThingMgr.NpcList 取差集，
--  再按「带拜山门标记 10005」或「有合法地图格 Key」筛出真正落地的人。
--=====================================================================
local JadeStart = GameMain:GetMod("JadeStartMod");


--要赋予的词条（Name 取自 Settings/Npc/Features/*.xml）
--  SonOfDestiny=命运之子  Reader=读书人  GoodMentality=心如止水
JadeStart.GIFT_FEATURES = {
	"SonOfDestiny",
	"Reader",
	"GoodMentality",
};

JadeStart.GIFT_JOINER_COUNT = 10;   --一次招几人（10 正好吃满本体候选池，不会留孤儿）
JadeStart.GIFT_JOINER_LEVEL = 1;    --来客等级，1 = 凡人
JadeStart.GIFT_JOINER_RACE  = "Human";

local JOINER_FLAG = 10005;          --Map._NormalJoinerAfter 给落地者打的拜山门标记


local function tryDo(tag, fn)
	local ok, err = pcall(fn);
	if not ok then
		print("[JadeStartMod] 失败(" .. tag .. "): " .. tostring(err));
	end
	return ok;
end


--遍历 ThingMgr.NpcList（XLua 的 List<T> 是 0 基）
local function eachNpc(fn)
	local list, n = nil, nil;
	pcall(function() list = ThingMgr.NpcList; end);
	if list == nil then
		return false;
	end
	pcall(function() n = list.Count; end);
	if n == nil or n <= 0 then
		return false;
	end
	for i = 0, n - 1 do
		local npc = nil;
		local ok = pcall(function() npc = list:get_Item(i); end);
		if not ok or npc == nil then
			pcall(function() npc = list[i]; end);
		end
		if npc ~= nil then
			fn(npc);
		end
	end
	return true;
end


--记录当前所有 npc 的 ID
local function snapshot(t)
	return eachNpc(function(npc)
		local id = nil;
		pcall(function() id = npc.ID; end);
		if id ~= nil then
			t[id] = true;
		end
	end);
end


--收集新增的、真正落地的拜山门者
local function collectJoiners(before)
	local out = {};
	eachNpc(function(npc)
		local id, key, flag = nil, nil, false;
		pcall(function() id = npc.ID; end);
		if id ~= nil and not before[id] then
			pcall(function() key = npc.Key; end);
			pcall(function() flag = npc:HasSpecialFlag(JOINER_FLAG); end);
			if flag or (key ~= nil and key > 0) then
				out[#out + 1] = npc;
			end
		end
	end);
	return out;
end


--调原生拜山门接口（点化仙缘同款）
local function addJoiners(me)
	local count = JadeStart.GIFT_JOINER_COUNT or 10;
	local level = JadeStart.GIFT_JOINER_LEVEL or 1;
	local race  = JadeStart.GIFT_JOINER_RACE or "Human";

	local ok, err = pcall(function()
		me:AddJoiners(count, level, 0, 0, 0, 0, 0, 0, race);
	end);
	if not ok then
		print("[JadeStartMod] AddJoiners 失败: " .. tostring(err));
	end
	return ok;
end


--对外入口：招一批带词条的凡人叩山门，返回落地 npc 数组（拿不到句柄时为空表）
function JadeStart:SpawnBlessedMortal(me)
	local before = {};
	local canScan = snapshot(before);

	if not addJoiners(me) then
		return {};
	end

	local joiners = canScan and collectJoiners(before) or {};
	local feats = self.GIFT_FEATURES or {};
	for i = 1, #joiners do
		local npc = joiners[i];
		for j = 1, #feats do
			tryDo("特性:" .. feats[j], function()
				npc.PropertyMgr:AddFeature(feats[j]);
			end);
		end
	end
	return joiners;
end
