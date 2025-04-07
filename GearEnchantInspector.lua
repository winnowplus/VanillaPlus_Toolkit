--------------------------------------------------  Imports  --------------------------------------------------

local GetInventoryItemLink  = GetInventoryItemLink;

-----------------------------------------------  Declarations  ------------------------------------------------

local ItemLinkPattern       = "|%a+|Hitem:([%d:]+))|h[%a+]|h|r";

-------------------------------------------------  Functions  -------------------------------------------------

function GetGearEnchantID(itemLink)
    local _,_, value = string.find(itemLink, ItemLinkPattern);
    print(value);
end