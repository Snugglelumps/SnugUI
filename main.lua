_G.SnugUI = _G.SnugUI or {}
local SnugUI = _G.SnugUI


---<============================================================================================>---<<============
---<===Name Space Initialization===>---

SnugUISettings = SnugUISettings or {}
SnugUI.settings = SnugUISettings

SnugUI.frames     = SnugUI.frames or {}
SnugUI.panels     = SnugUI.panels or {}
SnugUI.buttons    = SnugUI.buttons or {}
SnugUI.leftButton = SnugUI.leftButton or {}
SnugUI.leftButton.Highlights = SnugUI.leftButton.Highlights or {}

SnugUI.api       = SnugUI.api or {}
SnugUI.functions = SnugUI.functions or {}
SnugUI.commitRegistry = SnugUI.commitRegistry or {}

SnugUI.settingDefs       = SnugUI.settingDefs or {}
SnugUI.settings.defaults = SnugUI.settings.defaults or {}
-- Ensure SavedVariables table exists
-- SnugUISettings = SnugUISettings or {}
-- SnugUI.settings = SnugUISettings

-- SnugUI.frames         = SnugUI.frames or {} -- mostly background frames
-- SnugUI.panels         = SnugUI.panels or {} -- content panels for settings UI
-- SnugUI.buttons        = SnugUI.buttons or {}
-- SnugUI.leftButton     = SnugUI.leftButton or {}
-- SnugUI.leftButton.Highlights = SnugUI.leftButton.Highlights or {}
-- SnugUI.api            = SnugUI.api or {}
-- SnugUI.settings.anchorAssignments = SnugUI.settings.anchorAssignments or {}

-- SnugUI.settingDefs              = SnugUI.settingDefs or {}
-- SnugUI.settingsOrder            = SnugUI.settingsOrder or {}
-- SnugUI.settings.defaults        = SnugUI.settings.defaults or {}
-- SnugUI.settings.anchors         = SnugUI.settings.anchors or {}
-- SnugUI.settings.chat            = SnugUI.settings.chat or {}
-- SnugUI.settings.minimap         = SnugUI.settings.minimap or {}
-- SnugUI.settings.qol             = SnugUI.settings.qol or {}

-- SnugUI.functions                = SnugUI.functions or {}


---<============================================================================================>---<<============
---<===Critical Functions===>---
local loginTriggerQueue = {}

function SnugUI.loginTrigger(callback)
    table.insert(loginTriggerQueue, callback)
end

local loginFrame = CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_LOGIN")
loginFrame:SetScript("OnEvent", function(self)
    for _, fn in ipairs(loginTriggerQueue) do
        local ok, err = xpcall(fn, debugstack)
        if not ok then
            print("|cffff0000SnugUI loginTrigger error:|r", err)
        end
    end
    wipe(loginTriggerQueue)
    self:UnregisterAllEvents()
    self:SetScript("OnEvent", nil)
end)

local f = CreateFrame("Frame")  -- This ensures our saved variables are loaded before we try to access them
f:RegisterEvent("ADDON_LOADED") -- ADDON_LOADED is the earliest event from the client that guarentees our SavedVariables are available
f:SetScript("OnEvent", function(_, _, name)
    if name ~= "SnugUI-ascension" then return end

    SnugUISettings = SnugUISettings or {}
    SnugUI.settings = SnugUISettings
    
    f:UnregisterAllEvents()
    f:SetScript("OnEvent", nil)
end)
---<============================================================================================>---<<============
---<===Commands===>---
SLASH_SnugUI1 = "/sui"
SlashCmdList["SnugUI"] = function()
    if SnugUI.frames.BG:IsShown() then
        SnugUI.frames.BG:Hide()
    else
        SnugUI.frames.BG:Show()
    end
end

SLASH_SNUGWHO1 = "/swho"
SlashCmdList.SNUGWHO = function()
    local f = GetMouseFocus()
    if not f then
        print("no focus")
        return
    end

    print("focus:", f:GetName())

    -- Parent chain
    local p = f
    while p do
        print("  parent:", p:GetName())
        p = p:GetParent()
    end

    -- Anchor info
    if f.GetNumPoints then
        local n = f:GetNumPoints()
        for i = 1, n do
            local point, relTo, relPoint, x, y = f:GetPoint(i)
            print(
                "  point", i,
                "point=", point,
                "relTo=", relTo and relTo:GetName() or "nil",
                "relPoint=", relPoint,
                "x=", x,
                "y=", y
            )
        end
    end
    print("BuffFrame Stuff-------------------------")
    local p, rel, rp, x, y = BuffFrame:GetPoint(1)
    print("BuffFrame point:", p, "relName:", rel and rel:GetName(), "rel:", rel, "relPoint:", rp, x, y)
end