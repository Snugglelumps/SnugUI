local SnugUI = _G.SnugUI
local moduleName = "blizz"

local function anchorTooltip(tooltip)
    if not SnugUI.settings[moduleName].enable then return end
    if not (SnugUI.frames and SnugUI.frames.rightAnchor and SnugUI.frames.leftAnchor) then return end

    local params = {
        TOPLEFT     = { "TOPLEFT",     SnugUI.frames.leftAnchor,  "TOPRIGHT",     10, 0 },
        BOTTOMLEFT  = { "BOTTOMLEFT",  SnugUI.frames.leftAnchor,  "BOTTOMRIGHT",  10, 0 },
        TOPRIGHT    = { "TOPRIGHT",    SnugUI.frames.rightAnchor, "TOPLEFT",      -10, 0 },
        BOTTOMRIGHT = { "BOTTOMRIGHT", SnugUI.frames.rightAnchor, "BOTTOMLEFT",   -10, 0 },
    }

    local key = SnugUI.settings[moduleName].tooltipAnchor or "TOPRIGHT"
    local p = params[key] or params.TOPRIGHT

    tooltip:ClearAllPoints()
    tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    tooltip:SetPoint(p[1], p[2], p[3], p[4], p[5])
end

local hooked
local function hookTooltip()
    if hooked then return end
    hooked = true
    hooksecurefunc("GameTooltip_SetDefaultAnchor", anchorTooltip)
end

local function scaleTooltip()
    local scale = tonumber(SnugUI.settings[moduleName].scale) or 1
    GameTooltip:SetScale(scale)
end

local function makeSettings()
    SnugUI.api.generateSettingsUI(moduleName, "Blizzard", {
        title = "Blizzard UI Tweaks",
        message = "These settings adjust the default behavior of Blizzard UI elements. They may not work with all addons, and may cause unexpected behavior in some cases. Use with caution.",
    })
    SnugUI.api.addSetting(moduleName, "enable", {
        type = "checkbox",
        default = true,
        label = "Anchor tooltips to SnugUI anchors",
        layout = {
            order = 100,
            col = 1,
        }
    })
    SnugUI.api.addSetting(moduleName, "tooltipAnchor", {
        type = "dropdown",
        default = "Right Anchor",
        label = "Tooltip Anchor",
        options = {
            {value="TOPLEFT", text="Top of Left Anchor"},
            {value="BOTTOMLEFT", text="Bottom of Left Anchor"},
            {value="TOPRIGHT", text="Top of Right Anchor"},
            {value="BOTTOMRIGHT", text="Bottom of Right Anchor"},
        },
        layout = {
            order = 99,
            col = 2,
            width = 140,
        }
    })
    SnugUI.api.addSetting(moduleName, "scale", {
        type = "slider",
        default = 1,
        label = "Tooltip Scale",
        min_label = "Min",
        max_label = "Max",
        min = 0.5,
        max = 2,
        step = 0.05,
        layout = {
            order = 98,
            col = 1,
            width = 140,
        }
    })
    SnugUI.api.renderSettings(moduleName)
end


SnugUI.loginTrigger(function()
    scaleTooltip()
    table.insert(SnugUI.commitRegistry, scaleTooltip)
    hookTooltip()
    makeSettings()
end)