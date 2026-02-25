_G.SnugUI = _G.SnugUI or {}
local SnugUI = _G.SnugUI



---<=======================================================================================>---<<1.1 Tables and Settings
---<===================================================================================[Initializes tables and settings]
-- Ensure SavedVariables table exists
SnugUISettings = SnugUISettings or {}
SnugUI.settings = SnugUISettings

SnugUI.frames         = SnugUI.frames or {} -- mostly background frames
SnugUI.panels         = SnugUI.panels or {} -- content panels for settings UI
SnugUI.buttons        = SnugUI.buttons or {}
SnugUI.leftButton     = SnugUI.leftButton or {}
SnugUI.leftButton.Highlights = SnugUI.leftButton.Highlights or {}
SnugUI.commitRegistry = SnugUI.commitRegistry or {}
SnugUI.api            = SnugUI.api or {}
--SnugUI.settings.anchorAssignments = SnugUI.settings.anchorAssignments or {}

SnugUI.settingDefs              = SnugUI.settingDefs or {}
SnugUI.settingsOrder            = SnugUI.settingsOrder or {}
SnugUI.settings.defaults        = SnugUI.settings.defaults or {}
SnugUI.settings.anchors         = SnugUI.settings.anchors or {}
SnugUI.settings.chat            = SnugUI.settings.chat or {}
SnugUI.settings.minimap         = SnugUI.settings.minimap or {}
SnugUI.settings.qol             = SnugUI.settings.qol or {}
SnugUI.settings.leftOffset      = -6

SnugUI.leftOffset = SnugUI.leftOffset or -7

SnugUI.functions                = SnugUI.functions or {}

-- Define settings assertion and apply via the ADDON_LOADED handler
SnugUI.settings.defaults = SnugUI.settings.defaults or {
    chat = {
        tabstyle = "SnugUI",
    },
    minimapStyle = "SnugUI",
    anchors = {
        width = 420,
        height = 200,
        leftAssignment = "Chat",
        rightAssignment = "Details!",
    },
    minimap = {
        style = "SnugUI",
        scale = 1,
        lockTracker = true,
        hideWorldMapButton = true,
    },
    qol = {
        questButton = true,
        questHotkey = "G",
    },
}

local function applyDefaults(target, source)
    for key, value in pairs(source) do
        if type(value) == "table" then
            if type(target[key]) ~= "table" then target[key] = {} end
            applyDefaults(target[key], value)
        elseif target[key] == nil then
            target[key] = value
        end
    end
end

local function initializeSettings()
    applyDefaults(SnugUI.settings, SnugUI.settings.defaults)
end

--solitary use of ADDON_LOADED for settings initialization, if used elsewhere consider C_Timer.After in conjunction
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, _, name)
    if name ~= "SnugUI" then return end
    SnugUISettings = SnugUISettings or {}
    SnugUI.settings = SnugUISettings
    initializeSettings()
    if SnugUI.settings.reloadUI then SnugUI.settings.reloadUI = false end
    -- Preserve any saved debug preference instead of clobbering it every load.
    if SnugUI.settings.debug == nil then
        SnugUI.settings.debug = false
    end
end)

local loginTriggerQueue = {}

function SnugUI.loginTrigger(callback)
    table.insert(loginTriggerQueue, callback)
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

-- function SnugUI.functions.debugNamespace()
--     if not SnugUI.settings or not SnugUI.settings.debug then return end

--     print("=========== SnugUI Namespace ===========")

--     for key, value in pairs(SnugUI) do
--         local valueType = type(value)
--         if valueType == "function" then
--             print("🧠 function:", key)
--         elseif valueType == "table" then
--             print("📦 table:", key)
--         else
--             print("🔹", key, "=", tostring(value))
--         end
--     end

--     print("=========== end ===========")
-- end

-- SnugUI.loginTrigger(function()
--     C_Timer.After(3, function()
--         SnugUI.functions.debugNamespace()
--     end)
-- end)
