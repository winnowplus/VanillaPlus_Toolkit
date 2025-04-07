--------------------------------------------------  Imports  --------------------------------------------------

local GetInventoryItemLink  = GetInventoryItemLink;

-----------------------------------------------  Declarations  ------------------------------------------------

local EnchantPattern        = "Hitem:%d-:(%d-):%d-:%d-";

-------------------------------------------------  Functions  -------------------------------------------------

function InspectInventoryEnchant(unit, slot, enchantId)
    local itemLink = GetInventoryItemLink(unit, slot);
    local _,_, value = string.find(itemLink, EnchantPattern); 

    if(value ~= enchantId) then
        DEFAULT_CHAT_FRAME:AddMessage("Unexpected EnchantId " .. tostring(value) .. " for " .. itemLink);
    end
end

function DumpInventoryEnchant(slot)
    local itemLink = GetInventoryItemLink("player", slot);
    local _,_, value = string.find(itemLink, EnchantPattern); 

    print(itemLink);
    print(value);
end