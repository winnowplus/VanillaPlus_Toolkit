--------------------------------------------------  Imports  --------------------------------------------------

local GetInventoryItemLink  = GetInventoryItemLink;

-----------------------------------------------  Declarations  ------------------------------------------------

local ItemLinkPattern       = "|%a+|Hitem:(.+))|h[%a+]|h|r";

-------------------------------------------------  Functions  -------------------------------------------------

function GetGearEnchantID(itemLink)
    local _,_, value = string.find(itemLink, ItemLinkPattern);
    print(value);
end