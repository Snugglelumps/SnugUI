local SnugUI = _G.SnugUI

local moduleName = "minimap"

local function anchorBuffs()
    ConsolidatedBuffs:SetParent(MinimapCluster)
    ConsolidatedBuffs:ClearAllPoints()
    ConsolidatedBuffs:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -40, 0)
end


local function SnugUIMinimap()
    local toHide = {
            MinimapBorder,
            MinimapBorderTop,
        }
    for _, frame in ipairs(toHide) do
        if frame then frame:Hide() end
    end
    -- Add a 1px black border around the minimap
    Minimap:SetMaskTexture("Interface\\Buttons\\WHITE8x8")
    local border = CreateFrame("Frame", nil, Minimap, "BackdropTemplate")
    border:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -0.5, 0.5)
    border:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 0.5, -0.5)
    border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 0.5,
    })
    border:SetBackdropBorderColor(0, 0, 0, 1)
    border:SetFrameStrata("BACKGROUND")
    border:Show()
  
    -- offset = -math.abs(30 - ( 8 * SnugUI.settings.minimap.scale)  )
    -- Minimap:ClearAllPoints()
    -- Minimap:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", offset, offset)
    -- Minimap:SetClampedToScreen(false)

    anchorBuffs()
end


local function blizzardMinimap()
    Minimap:SetMaskTexture("Textures\\MinimapMask")
    anchorBuffs()
end


function applyMinimapStyle()
    if SnugUI.settings[moduleName].style == "SnugUI" then
        SnugUIMinimap()
    end
    if SnugUI.settings[moduleName].style == "Blizzard" then
        blizzardMinimap()
    end
end


local previousScale
local function applyMinimapScale()
    local currentScale = SnugUI.settings.minimap.scale
    if previousScale == currentScale then return end
        -- MinimapCluster exists in some clients; fall back to Minimap if not present
        if MinimapCluster and type(MinimapCluster.SetScale) == "function" then
            MinimapCluster:SetScale(currentScale)
        elseif Minimap and type(Minimap.SetScale) == "function" then
            Minimap:SetScale(currentScale)
        else
            print("SnugUI: unable to apply minimap scale - no known minimap cluster object")
        end
    previousScale = currentScale
end

local function makeAnchorFrame()
    if not SnugUI.settings[moduleName].anchorMinimapButtons then return end
    local f = CreateFrame("Frame", "SnugUIMinimapButtonAnchor", UIParent)
    
    if SnugUI.settings[moduleName].MMButtAnchor then
        f:SetWidth(10)
        f:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", 0, 0)
        f:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMLEFT", 0, 0)
    else
        f:SetHeight(24)
        f:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", 0, 0)
        f:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, 0)
    end

    f:SetFrameStrata("BACKGROUND")

    local t = f:CreateTexture(nil, "BACKGROUND")
    t:SetAllPoints()
    -- t:SetColorTexture(1, 0, 0, 1)
end

local function CollectMinimapButtons()
    local buttons = {}

    local f = EnumerateFrames()
    while f do
        local name = f:GetName()
        if name and (name:match("^Lib") or name:match("^pfBr")) then
            local p = f:GetParent()
            if p == Minimap then
                buttons[#buttons + 1] = f  -- store the frame, not just the name
            end
        end
        f = EnumerateFrames(f)
    end

    if MiniMapTracking then table.insert(buttons, 1, MiniMapTracking) end -- should probably reorder, but whatevs
    return buttons
end

local function ReanchorButtons()
    if not SnugUI.settings[moduleName].anchorMinimapButtons then return end

    local buttons = CollectMinimapButtons()
    local anchor = SnugUIMinimapButtonAnchor -- use frame ref

    if SnugUI.settings[moduleName].MMButtAnchor then
        -- vertical stack (upwards from anchor bottom-left)
        for i = 1, #buttons do
            local b = buttons[i]
            b:ClearAllPoints()
            b:SetPoint("CENTER", anchor, "BOTTOMLEFT", 0, (i - 1) * 26)
        end
    else
        -- horizontal row (rightwards from anchor bottom-left)
        for i = 1, #buttons do
            local b = buttons[i]
            b:ClearAllPoints()
            b:SetPoint("CENTER", anchor, "BOTTOMLEFT", (i - 1) * 26, 0)
        end
    end
end


local function makeSettings()
    SnugUI.api.generateSettingsUI(moduleName, "Minimap", {
        title = "Minimap",
        message = "Customize the appearance and behavior of the minimap.",
    })

    SnugUI.api.addSetting(moduleName, "style", "dropdown", {
        default = "SnugUI",
        label = "Minimap style",
        options = { 
            {value="SnugUI", text="SnugUI"}, 
            {value="Blizzard", text="Blizzard"}, 
        },
        layout = {
            col = 1,
            row = 1,
            width = 100,
        },
        reloadWarning = true,
    })

    SnugUI.api.addSetting(moduleName, "scale", "slider", {
        default = 1,
        label = "Minimap Scale",
        min_label = "Min",
        max_label = "Max",
        min = 0.5,
        max = 2,
        step = 0.01,
        updateFunc = applyMinimapScale,
        layout = {
            col = 3,
            row = 1,
            --width = 140,
        }
    })

    SnugUI.api.addSetting(moduleName, "anchorMinimapButtons", "checkbox", {
        default = false,
        label = "Clamp minimap buttons to edge",
        layout = {
            col = 1,
            row = 2,
        },
        reloadWarning = true,
     })

     SnugUI.api.addSetting(moduleName, "MMButtAnchor", "radio", {
        default = false,
        label = "...and on what edge?",
        options = {
            {value=false, text="Bottom"},
            {value=true, text="Left"},
        },
        layout = {
            col = 1,
            row = 3,
            rowPitch = 45,
        }
     })
    SnugUI.api.renderSettings(moduleName)
end
---<===========================================================================================================>---<<AUX
SnugUI.loginTrigger(function()
    makeSettings()
    applyMinimapStyle()
    SnugUI.commitRegistry["applyMinimapScale"] = function()
        applyMinimapScale()
    end
    table.insert(SnugUI.commitRegistry, makeAnchorFrame)
    table.insert(SnugUI.commitRegistry, ReanchorButtons)
    makeAnchorFrame()
    ReanchorButtons()
end)
