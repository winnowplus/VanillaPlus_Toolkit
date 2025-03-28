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
    
    ["^装备： 使你的攻击速度和施法速度提高(%d)%%。"]                          = "急速",
    ["^装备： 使你的攻击和施法速度提高(%d)%%。"]                             = "急速",
    ["^装备： 使周围半径30码范围内的所有小队成员的攻击和施法速度提高(%d)%%。"]  = "急速",

    ["^装备： 所造成伤害的(%d+)%%作为治疗返还。"]        = "吸血",

    ["^装备： %+(%d+)攻击强度。"]                      = "攻击强度",
    ["^装备： 使你击中目标的几率提高(%d)%%。"]          = "命中",
    ["^装备： 使你造成致命一击的几率提高(%d)%%。"]      = "暴击",
    ["^装备： 你的攻击无视目标(%d+)点护甲。"]             = "破甲",

    ["^装备： 提高所有法术和魔法效果所造成的伤害和治疗效果，最多(%d+)点。"]                               = "法术伤害",
    ["^装备： 使你的法术伤害提高最多(%d+)点，治疗效果提高最多%d+点。"]                                   = "法术伤害", --埃提耶什，守护者的传说之杖
    ["^装备： 法术伤害提高最多(%d+)，治疗效果提高最多%d+。"]                                            = "法术伤害", --埃提耶什，守护者的传说之杖
    ["^装备： 使周围半径30码范围内的所有小队成员的法术和魔法效果所造成的伤害和治疗效果提高最多(%d+)点。"]   = "法术伤害", --埃提耶什，守护者的传说之杖
    ["^装备： 提高法术所造成的治疗效果，最多(%d+)点。"]                                                 = "治疗效果",
    ["^装备： 使你的法术伤害提高最多%d+点，治疗效果提高最多(%d+)点。"]                                   = "治疗效果", --埃提耶什，守护者的传说之杖
    ["^装备： 法术伤害提高最多%d+，治疗效果提高最多(%d+)。"]                                            = "治疗效果", --埃提耶什，守护者的传说之杖
    ["^装备： 使周围半径30码范围内的所有小队成员的法术和魔法效果所造成的治疗效果提高最多(%d+)点。"]         = "治疗效果", --埃提耶什，守护者的传说之杖
    ["^装备： 使法术的治疗效果提高最多(%d+)点。"]                                                       = "治疗效果", -- 扭曲虚空之锤
    ["^装备： 提高法术和魔法效果所造成的治疗效果，最多(%d+)点。"]                                        = "治疗效果", -- 虚妄预言者节杖
    ["^装备： 使治疗法术和效果所回复的生命值提高(%d+)点。"]                                              = "治疗效果", -- 祈福
    ["^装备： 使你的法术击中敌人的几率提高(%d)%%。"]                                                    = "法术命中",
    ["^装备： 使你的法术造成致命一击的几率提高(%d)%%。"]                                                = "法术暴击",
    ["^装备： 提高你的法术造成致命一击的几率(%d)%%。"]                                                  = "法术暴击", -- 衰落之眼
    ["^装备： 每5秒回复(%d+)点法力值。"]                                                               = "法力回复",

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

local function ToCsv(headers, data)
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

function ExportGearStats(...)
    local headers, gears = GetGearStats(unpack(arg));
    return ToCsv(headers, gears);
end

-------------------------------------------------  Gear List  -------------------------------------------------

VP_Gear_Coll = {
    PVPPaladin              = {16474, 16476, 16473, 16471, 16475, 16472},
    PVPWarrior_Alliance     = {16478, 16480, 16477, 16484, 16479, 16483},
    PVPWarrior_Horde        = {16542, 16544, 16541, 16548, 16543, 16545},

    PVPHunter_Alliance      = {16465, 16468, 16466, 16463, 16467, 16462},
    PVPHunter_Horde         = {16566, 16568, 16565, 16571, 16567, 16569},
    PVPShaman               = {16578, 16580, 16577, 16574, 16579, 16573},

    PVPRogue_Alliance       = {16455, 16457, 16453, 16454, 16456, 16446},
    PVPRogue_Horde          = {16561, 16562, 16563, 16560, 16564, 16558},
    PVPDruid_Alliance       = {16451, 16449, 16452, 16448, 16450, 16459},
    PVPDruid_Horde          = {16550, 16551, 16549, 16555, 16552, 16554},

    PVPPriest_Alliance      = {17602, 17604, 17605, 17608, 17603, 17607},
    PVPPriest_Horde         = {17623, 17622, 17624, 17620, 17625, 17618},
    PVPMage_Alliance        = {16441, 16444, 16443, 16440, 16442, 16437},
    PVPMage_Horde           = {16533, 16536, 16535, 16540, 16534, 16539},
    PVPWarlock_Alliance     = {17578, 17580, 17581, 17584, 17579, 17583},
    PVPWarlock_Horde        = {17591, 17590, 17592, 17588, 17593, 17586},
    
    T05Paladin              = {22091, 22093, 22089, 22088, 22090, 22086, 22092, 22087},
    T1Paladin_Holy          = {16854, 16856, 16853, 16857, 16860, 16858, 16855, 16859},
    T1Paladin_Protection    = {47000, 47001, 47002, 47003, 47004, 47005, 47006, 47007},
    T1Paladin_Retribution   = {47008, 47009, 47010, 47011, 47012, 47013, 47014, 47015},
    ZGPaladin               = {19952, 19588, 19825, 19826, 19827},
    AQ20Paladin             = {21395, 21397, 21396},
    T2Paladin_Holy          = {16955, 16953, 16958, 16951, 16956, 16952, 16954, 16957},
    T2Paladin_Protection    = {47016, 47017, 47018, 47019, 47020, 47021, 47022, 47023},
    T2Paladin_Retribution   = {47024, 47025, 47026, 47027, 47028, 47029, 47030, 47031},
    AQ40Paladin_Retribution = {21389, 21387, 21390, 21391, 21388},
    AQ40Paladin_Protection  = {47032, 47033, 47034, 47035, 47036},
    AQ40Paladin_Holy        = {47037, 47038, 47039, 47040, 47041},
    T3Paladin_Holy          = {22428, 22429, 22425, 22424, 22426, 22431, 22427, 22430, 23066},
    T3Paladin_Protection    = {47042, 47043, 47044, 47045, 47046, 47047, 47048, 47049, 47050},
    T3Paladin_Retribution   = {47051, 47052, 47053, 47054, 47055, 47056, 47057, 47058, 47059},
    T35Paladin_Holy         = {47060, 47061, 47062, 47063, 47064, 47065},
    T35Paladin_Protection   = {47066, 47067, 47068, 47069, 47070, 47071},
    T35Paladin_Retribution  = {47072, 47073, 47074, 47075, 47076, 47077},
    

    AQ20Priest = {21410, 21412, 21411},
    ZGRings = {19898, 19925, 19873, 19912, 19863, 19920, 19905, 19893},
    WorldEpics1 = {1981, 867, 1980, 868, 869, 870, 1982, 2825, 1204, 873},
    WAILING = {6473, 10413, 10412, 10410, 10411, 81006},
    ScholoPlate = {14624, 14622, 14620, 14623, 14621},
    T3Rogue = {22478, 22479, 22476, 22483, 22481, 22482, 22477, 22480, 23060},
    STRAT = {13390, 13388, 13389, 13391, 13392},
    T1Priest = {16813, 16816, 16815, 16819, 16812, 16817, 16814, 16811, 47198, 47199, 47200, 47201, 47202, 47203, 47204, 47205},
    T35Shaman = {47180, 47181, 47182, 47183, 47184, 47185, 47186, 47187, 47188, 47189, 47190, 47191, 47192, 47193, 47194, 47195, 47196, 47197},
    ZGDruid = {19955, 19613, 19838, 19839, 19840},
    T35Rogue = {47324, 47325, 47326, 47327, 47328, 47329},
    T1Druid = {16834, 16836, 16833, 16830, 16831, 16828, 16835, 16829, 47330, 47331, 47332, 47333, 47338, 47339, 47340, 47341, 47342, 47343, 47344, 47345, 47334, 47335, 47336, 47337},
    T1Warlock = {16808, 16807, 16809, 16804, 16805, 16806, 16810, 16803, 47276, 47277, 47278, 47279, 47280, 47281, 47282, 47283},
    HakkariBlades = {19865, 19866},
    WorldEpics2 = {14550, 3075, 1315, 940, 14551, 17007, 14549, 942, 1447, 810, 809, 871, 2164, 2163, 2291, 2915, 812, 943, 2824, 2100, 1169, 1979},
    EmptyInstance = {},
    AQ40Shaman = {21374, 21372, 21375, 21376, 21373, 47152, 47153, 47154, 47155, 47156, 47157, 47158, 47159, 47160, 47161},
    T35Hunter = {47318, 47319, 47320, 47321, 47322, 47323},
    T2Mage = {16914, 16917, 16916, 16918, 16913, 16818, 16915, 16912, 47086, 47087, 47088, 47089, 70613, 70614, 70615, 70616, 70617, 70618, 70619, 70620, 47090, 47091, 47092, 47093},
    PrimalBlessing = {19896, 19910},
    ZGHunter = {19953, 19621, 19831, 19832, 19833},
    AQ20Shaman = {21398, 21400, 21399},
    T2Priest = {16921, 16924, 16923, 16926, 16920, 16925, 16922, 16919, 47206, 47207, 47208, 47209, 47210, 47211, 47212, 47213},
    T35Warlock = {47306, 47307, 47308, 47309, 47310, 47311, 47312, 47313, 47314, 47315, 47316, 47317},
    RarePets1 = {23713, 23712, 13584, 13583, 13582, 20371, 22114, 23007, 23015, 23002, 21301, 21308, 21305, 21309, 22235, 23083, 19450, 8491, 8489, 11110, 10822, 20769, 15996, 11826, 10398, 8494},
    RarePets2 = {11825, 12529, 11474, 8499, 8498, 21277, 12264},
    WorldEpics3 = {2245, 1443, 14558, 14552, 3475, 14553, 14554, 2246, 833, 14557, 2243, 20698, 1728, 811, 14555, 2244, 1263, 2801, 647, 2099, 1168, 944},
    T2Warlock = {16929, 16932, 16931, 16934, 16928, 16933, 16930, 16927, 47284, 47285, 47286, 47287, 47288, 47289, 47290, 47291},
    ZGRogue = {19954, 19617, 19834, 19835, 19836},
    SCARLET = {10328, 10333, 10331, 10329, 10330, 10332},
    T2Druid = {16900, 16902, 16897, 16904, 16899, 16903, 16901, 16898, 47346, 47347, 47348, 47349, 47354, 47355, 47356, 47357, 47358, 47359, 47360, 47361, 47350, 47351, 47352, 47353},
    SpiderKiss = {13218, 13183},
    T2Shaman = {16947, 16945, 16950, 16943, 16948, 16944, 16946, 16949, 47136, 47137, 47138, 47139, 47144, 47145, 47146, 47147, 47148, 47149, 47150, 47151, 47140, 47141, 47142, 47143},
    DEADMINES = {81007, 10399, 10401, 10403, 10400, 10402},
    Tabards = {15196, 15198, 19506, 20132, 19032, 19160, 22999, 23192, 23705, 23709, 15197, 15199, 19505, 20131, 19031},
    UnobMounts = {18768, 12327, 12325, 12326, 13318, 8628},
    PvPMountsSets = {19030, 18244, 18243, 18241, 18242, 19029, 18245, 18247, 18246, 18248},
    AQ40Rogue = {21364, 21360, 21362, 21361, 21359},
    ScholoLeather = {14637, 14640, 14636, 14638, 14641},
    ZGWarrior = {19951, 19577, 19822, 19823, 19824},
    AQ20Hunter = {21401, 21403, 21402},
    AQ20Warlock = {21416, 21418, 21417},
    Artifacts = {12947, 18582, 18583, 18584},
    BLACKROCKD = {11729, 11726, 11730, 11728, 11731},
    T1Mage = {16795, 16797, 16798, 16799, 16801, 16802, 16796, 16800, 47078, 47079, 47080, 47081, 47082, 47083, 47084, 47085},
    Legendaries = {19019, 22736, 17182, 21176, 17204, 18564, 18563, 17782, 22631, 22589, 22630, 22632, 22726, 61184, 55505, 23051, 13262},
    AQ40Warrior = {21331, 21329, 21332, 21330, 21333, 47256, 47257, 47258, 47259, 47260},
    AQ40Hunter = {21370, 21366, 21368, 21367, 21365},
    AQ20Mage = {21413, 21415, 21414},
    AQ40Druid = {21357, 21353, 21356, 21354, 21355, 47362, 47363, 47364, 47365, 47366, 47367, 47368, 47369, 47370, 47371},
    OldMounts = {12302, 12303, 13327, 13326, 13328, 13329, 12354, 12353, 13317, 8586, 12351, 12330, 15292, 15293},
    T3Priest = {22514, 22515, 22512, 22519, 22517, 22518, 22513, 22516, 23061, 47219, 47220, 47221, 47222, 47223, 47224, 47225, 47226, 47227},
    ZGPriest = {19958, 19594, 19841, 19842, 19843},
    T1Rogue = {16821, 16823, 16820, 16825, 16826, 16827, 16822, 16824},
    AQ20Druid = {21407, 21409, 21408},
    AQ40Warlock = {21334, 21337, 21336, 21335, 21338, 47292, 47293, 47294, 47295, 47296},
    AQ40Priest = {21351, 21348, 21352, 21350, 21349, 47214, 47215, 47216, 47217, 47218, 70732, 70733, 70734, 70735, 70736},
    AQ40Mage = {21347, 21345, 21343, 21346, 21344, 47094, 47095, 47096, 47097, 47098},
    AQ20Warrior = {21392, 21394, 21393},
    T3Druid = {22490, 22491, 22488, 22495, 22493, 22494, 22489, 22492, 23064, 47372, 47373, 47374, 47375, 47381, 47382, 47383, 47384, 47385, 47386, 47387, 47388, 47389, 47376, 47377, 47378, 47379, 47380},
    T3Warlock = {22506, 22507, 22504, 22511, 22509, 22510, 22505, 22508, 23063, 47297, 47298, 47299, 47300, 47301, 47302, 47303, 47304, 47305},
    RareMounts = {21176, 13335, 19872, 19902, 13086, 23720, 21218, 21323, 21321, 21324},
    T3Warrior = {22418, 22419, 22416, 22423, 22421, 22422, 22417, 22420, 23059, 47261, 47262, 47263, 47264, 47265, 47266, 47267, 47268, 47269},
    T1Shaman = {16842, 16844, 16841, 16840, 16839, 16838, 16843, 16837, 47120, 47121, 47122, 47123, 47128, 47129, 47130, 47131, 47132, 47133, 47134, 47135, 47124, 47125, 47126, 47127},
    AQ20Rogue = {21404, 21406, 21405},
    ZGShaman = {19956, 19609, 19828, 19829, 19830},
    IRONWEAVE = {22302, 22305, 22301, 22313, 22304, 22306, 22303, 22311},
    ZGWarlock = {19957, 19605, 20033, 19849, 19848},
    T3Shaman = {22466, 22467, 22464, 22471, 22469, 22470, 22465, 22468, 23065, 47162, 47163, 47164, 47165, 47171, 47172, 47173, 47174, 47175, 47176, 47177, 47178, 47179, 47166, 47167, 47168, 47169, 47170},
    SpiritofEskhandar = {18204, 18205, 18203, 18202},
    T0Mage = {16686, 16689, 16688, 16683, 16684, 16685, 16687, 16682, 22065, 22068, 22069, 22063, 22066, 22062, 22067, 22064},
    T0Warrior = {16731, 16733, 16730, 16735, 16737, 16736, 16732, 16734, 21999, 22001, 21997, 21996, 21998, 21994, 22000, 21995},
    ScourgeInvasion = {23085, 23091, 23084, 23089, 23093, 23081, 23088, 23092, 23082, 23087, 23090, 23078},
    ScholoCloth = {14633, 14626, 14629, 14632, 14631},
    T0Hunter = {16677, 16679, 16674, 16681, 16676, 16680, 16678, 16675, 22013, 22016, 22060, 22011, 22015, 22010, 22017, 22061},
    T0Druid = {16720, 16718, 16706, 16714, 16717, 16716, 16719, 16715, 22109, 22112, 22113, 22108, 22110, 22106, 22111, 22107},
    T0Rogue = {16707, 16708, 16721, 16710, 16712, 16713, 16709, 16711, 22005, 22008, 22009, 22004, 22006, 22002, 22007, 22003},
    ZGMage = {19959, 19601, 20034, 19845, 19846},
    T0Priest = {16693, 16695, 16690, 16697, 16692, 16696, 16694, 16691, 22080, 22082, 22083, 22079, 22081, 22078, 22085, 22084},
    ScholoMail = {14611, 14615, 14614, 14612, 14616},
    ShardOfGods = {17082, 17064},
    T1Hunter = {16846, 16848, 16845, 16850, 16852, 16851, 16847, 16849},
    T35Druid = {47390, 47391, 47392, 47393, 47394, 47395, 47396, 47397, 47398, 47399, 47400, 47401, 47402, 47403, 47404, 47405, 47406, 47407},
    DalRend = {12940, 12939},
    T1Warrior = {16866, 16868, 16865, 16861, 16863, 16864, 16867, 16862, 47240, 47241, 47242, 47243, 47244, 47245, 47246, 47247},
    T3Mage = {22498, 22499, 22496, 22503, 22501, 22502, 22497, 22500, 23062, 47099, 47100, 47101, 47102, 47103, 47104, 47105, 47106, 47107},
    T35Mage = {47108, 47109, 47110, 47111, 47112, 47113, 47114, 47115, 47116, 47117, 47118, 47119},
    T2Hunter = {16939, 16937, 16942, 16935, 16940, 16936, 16938, 16941},
    T2Rogue = {16908, 16832, 16905, 16911, 16907, 16910, 16909, 16906},
    T0Warlock = {16698, 16701, 16700, 16703, 16705, 16702, 16699, 16704, 22074, 22073, 22075, 22071, 22077, 22070, 22072, 22076},
    T3Hunter = {22438, 22439, 22436, 22443, 22441, 22442, 22437, 22440, 23067},
    T2Warrior = {16963, 16961, 16966, 16959, 16964, 16960, 16962, 16965, 47248, 47249, 47250, 47251, 47252, 47253, 47254, 47255},
    T35Warrior = {47270, 47271, 47272, 47273, 47274, 47275},
    T35Priest = {47228, 47229, 47230, 47231, 47232, 47233, 47234, 47235, 47236, 47237, 47238, 47239},
    T0Shaman = {16667, 16669, 16666, 16671, 16672, 16673, 16668, 16670, 22097, 22101, 22102, 22095, 22099, 22098, 22100, 22096},

};