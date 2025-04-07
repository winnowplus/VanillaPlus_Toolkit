--------------------------------------------------  Imports  --------------------------------------------------

local GetInventoryItemLink  = GetInventoryItemLink;

-----------------------------------------------  Declarations  ------------------------------------------------

local EnchantPattern        = "Hitem:%d-:(%d-):%d-:%d-";

-------------------------------------------------  Functions  -------------------------------------------------

function InspectInventoryEnchant(unit, slot, expect)
    local itemLink = GetInventoryItemLink(unit, slot);

    if(itemLink ~= nil) then
        local _, _, actual = string.find(itemLink, EnchantPattern);

        if(actual ~= expect) then
            DEFAULT_CHAT_FRAME:AddMessage("Wrong Enchant for " .. itemLink .. " (" .. expect .. " expected, got " .. actual .. ")");
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("Slot " .. slot .. " of " .. unit .. " is empty.");
    end
end

function DumpInventoryEnchant(slot)
    local itemLink = GetInventoryItemLink(unit, slot);

    if(itemLink ~= nil) then
        local _, _, actual = string.find(itemLink, EnchantPattern);
        DEFAULT_CHAT_FRAME:AddMessage(itemLink);
        DEFAULT_CHAT_FRAME:AddMessage(actual);
    end
end