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

};

-------------------------------------------------  Functions  -------------------------------------------------

local function AddHeader(headers, stat)
    if(not headers[stat]) then
        headers[stat] = true;
        table.insert(headers, stat);
    end
end

local function SetStat(gear, stat, value, headers)
    AddHeader(headers, stat);
    gear[stat] = value;
end

local function IncreaseStat(gear, stat, value, headers)
    AddHeader(headers, stat);
    gear[stat] = (gear[stat] or 0) + tonumber(value);
end

local function GetGearStats(ids)
    local headers, gears, allLoaded = {}, {}, true;

    for _, id in ipairs(ids) do
        VanillaPlusTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");
        VanillaPlusTooltip:ClearLines();
        VanillaPlusTooltip:SetHyperlink("item:" .. id .. ":0:0:0");
        local itemName = GetItemInfo(id);

        if(itemName == nil) then
            allLoaded = false;
        else
            local gear = {};
            table.insert(gears, gear);
            SetStat(gear, "名称", itemName, headers);

            for line = 1, VanillaPlusTooltip:NumLines() do
                local widget = _G["VanillaPlusTooltipTextLeft" .. line];
                local text = widget and widget:GetText();

                if(text ~= nil) then
                    for pattern, stat in pairs(StatPatterns) do
                        local _,_, value = string.find(text, pattern);

                        if(value ~= nil) then
                            IncreaseStat(gear, stat, value, headers);
                            break;
                        end
                    end
                end
            end
        end
    end

    return headers, gears, allLoaded;
end

function ExportGearStats(ids)
    local headers, gears, allLoaded = GetGearStats(ids);
    local csvText = table.concat(headers, ",");

    for _, gear in ipairs(gears) do
        csvText =  csvText .. "\n";

        for index, header in ipairs(headers) do
            local cell = gear[header] and tostring(gear[header]) or "";

            if(index == 1) then
                csvText =  csvText .. cell;
            else
                csvText =  csvText .. "," .. cell;
            end
        end
    end

    if(not allLoaded) then
        DEFAULT_CHAT_FRAME:AddMessage("One or more gears are not loaded, please try again.");
    end

    return csvText;
end