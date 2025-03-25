--------------------------------------------------  Imports  --------------------------------------------------

local _G            = getfenv(0);
local GetItemInfo   = GetItemInfo;

-----------------------------------------------  Declarations  ------------------------------------------------

local StatPatterns  = {
    ["^(%d+)点护甲$"]   = "护甲",
    ["^%+(%d+) 力量$"]  = "力量",
    ["^%+(%d+) 敏捷$"]  = "敏捷",
    ["^%+(%d+) 耐力$"]  = "耐力",
    ["^%+(%d+) 智力$"]  = "智力",
    ["^%+(%d+) 精神$"]  = "精神",
    
    ["^装备： 使你的攻击速度和施法速度提高(%d)%%。"]    = "急速",
    ["^装备： 使你的攻击和施法速度提高(%d)%%。"]        = "急速",

    ["^装备： %+(%d+)攻击强度。"]                      = "攻击强度",
    ["^装备： 使你击中目标的几率提高(%d)%%。"]          = "命中",
    ["^装备： 使你造成致命一击的几率提高(%d)%%。"]      = "暴击",

    ["^装备： 提高所有法术和魔法效果所造成的伤害和治疗效果，最多(%d+)点。"]  = "法术伤害",
    ["^装备： 提高法术所造成的治疗效果，最多(%d+)点。"]                     = "治疗效果",
    ["^装备： 使法术的治疗效果提高最多(%d+)点。"]                          = "治疗效果", -- 扭曲虚空之锤
    ["^装备： 提高法术和魔法效果所造成的治疗效果，最多(%d+)点。"]           = "治疗效果", -- 虚妄预言者节杖
    ["^装备： 使治疗法术和效果所回复的生命值提高(%d+)点。"]                 = "治疗效果", -- 祈福
    ["^装备： 使你的法术击中敌人的几率提高(%d)%%。"]                       = "法术命中",
    ["^装备： 使你的法术造成致命一击的几率提高(%d)%%。"]                    = "法术暴击",
    ["^装备： 提高你的法术造成致命一击的几率(%d)%%。"]                      = "法术暴击", -- 衰落之眼
    ["^装备： 每5秒回复(%d+)点法力值。"]                                  = "法力回复",

    ["^装备： 提高奥术法术和效果所造成的伤害，最多(%d+)点。"]    = "奥术伤害",
    ["^装备： 奥术伤害提高(%d+)。"]                           = "奥术伤害", -- 灵风肩饰
    ["^装备： 提高火焰法术和效果所造成的伤害，最多(%d+)点。"]    = "火焰伤害",
    ["^装备： 提高冰霜法术和效果所造成的伤害，最多(%d+)点。"]    = "冰霜伤害",
    ["^装备： 提高神圣法术和效果所造成的伤害，最多(%d+)点。"]    = "神圣伤害",
    ["^装备： 提高自然法术和效果所造成的伤害，最多(%d+)点。"]    = "自然伤害",
    ["^装备： 提高暗影法术和效果所造成的伤害，最多(%d+)点。"]    = "暗影伤害",
    ["^装备： 使暗影法术所造成的伤害提高最多(%d+)点。"]          = "暗影伤害",
};

-------------------------------------------------  Functions  -------------------------------------------------

local function AddHeader(headers, header)
    if(not headers[header]) then
        headers[header] = true;
        table.insert(headers, header);
    end
end

function GetGearStats(...)
    local headers, gears = {}, {};

    for _, ids in ipairs(arg) do
        ids = type(ids) == "table" and ids or {ids};

        for _, id in ipairs(ids) do
            VanillaPlusTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");
            VanillaPlusTooltip:ClearLines();
            VanillaPlusTooltip:SetHyperlink("item:" .. id .. ":0:0:0");
            local gearName = GetItemInfo(id);

            if(gearName == nil) then
                DEFAULT_CHAT_FRAME:AddMessage("Gear " .. tostring(id) .. " is not loaded, please try again.");
            else
                local gear = {};
                table.insert(gears, gear);
            
                AddHeader(headers, "装备");
                gear["装备"] = gearName;

                for line = 1, VanillaPlusTooltip:NumLines() do
                    local widget = _G["VanillaPlusTooltipTextLeft" .. line];
                    local text = widget and widget:GetText();
    
                    if(text ~= nil) then
                        for pattern, stat in pairs(StatPatterns) do
                            local _,_, value = string.find(text, pattern);
    
                            if(value ~= nil) then
                                AddHeader(headers, stat);
                                gear[stat] = (gear[stat] or 0) + tonumber(value);
    
                                break;
                            end
                        end
                    end
                end
            end
        end
    end

    return headers, gears;
end

function ToCsv(headers, data)
    local csvText = table.concat(headers, ",");

    for _, item in ipairs(data) do
        csvText =  csvText .. "\n";

        for index, header in ipairs(headers) do
            local cell = item[header] and tostring(item[header]) or "";

            if(index == 1) then
                csvText =  csvText .. cell;
            else
                csvText =  csvText .. "," .. cell;
            end
        end
    end

    return csvText;
end

-------------------------------------------------  Gear List  -------------------------------------------------

