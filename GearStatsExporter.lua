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

local function AddHeader(headers, header)
    if(not headers[header]) then
        headers[header] = true;
        table.insert(headers, header);
    end
end

function ExportGearStats(...)
    local headers, gears = {}, {};

    for _, ids in ipairs(arg) do
        ids = type(data) == "table" and ids or {ids};

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