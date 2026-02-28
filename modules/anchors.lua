local SnugUI = _G.SnugUI

local moduleName = "anchors"

---<============================================================================================>---<<============
---<===Anchor Frames===>---
local function CreateRectangle(name, parent)
    parent = parent or UIParent

    local f = CreateFrame("Frame", name, parent)
    f:SetFrameStrata("BACKGROUND")

    f:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets   = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    f:SetBackdropColor(0, 0, 0, 0.25)
    f:SetBackdropBorderColor(0, 0, 0, 1)

    return f
end

local function createAnchors()
    local h = tonumber(SnugUI.settings[moduleName].anchorHeight) or 420
    local w = tonumber(SnugUI.settings[moduleName].anchorWidth) or 200

    -- left
    SnugUI.frames.leftAnchor = CreateRectangle("SnugUILeftAnchor", UIParent)
    SnugUI.frames.leftAnchor:ClearAllPoints()
    SnugUI.frames.leftAnchor:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 1, 1)
    SnugUI.frames.leftAnchor:SetSize(w, h)
    SnugUI.frames.leftAnchor:EnableMouse(true)

    -- right
    SnugUI.frames.rightAnchor = CreateRectangle("SnugUIRightAnchor", UIParent)
    SnugUI.frames.rightAnchor:ClearAllPoints()
    SnugUI.frames.rightAnchor:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -1, 1)
    SnugUI.frames.rightAnchor:SetSize(w, h)
    SnugUI.frames.rightAnchor:EnableMouse(true)
end

local function updateAnchors()
    -- grabs settings, can add defaults
    local h = tonumber(SnugUI.settings[moduleName].anchorHeight)-- or 420
    local w = tonumber(SnugUI.settings[moduleName].anchorWidth)-- or 200

    -- Helper to update one anchor
    local function resize(anchor, point, relPoint, x, y)
        if not anchor then return end
        anchor:ClearAllPoints()
        anchor:SetPoint(point, UIParent, relPoint, x, y)
        anchor:SetSize(w, h)
    end

    -- Apply to left & right
    resize(SnugUI.frames.leftAnchor,  "BOTTOMLEFT",  "BOTTOMLEFT",  1,  1)
    resize(SnugUI.frames.rightAnchor, "BOTTOMRIGHT", "BOTTOMRIGHT", -1,  1)
end





local function makeSettings()
    SnugUI.api.generateSettingsUI(moduleName, "Anchors", {
        title = "Anchor Settings",
        message = "",
    })

    SnugUI.api.addSetting(moduleName, "anchorHeight", "editbox", {
        default = "200",
        label = "Height of anchor frames",
        valueType = "string",
        maxLetters = 3,
        layout = {
            col = 1,
            row = 1,
            width = 60,
        },
    })

    SnugUI.api.addSetting(moduleName, "anchorWidth", "editbox", {
        default = "420",
        label = "Width of anchor frames",
        valueType = "int",
        maxLetters = 3,
        layout = {
            col = 2,
            row = 1,
            width = 60,
        },
    })

    SnugUI.api.addSetting(moduleName, "leftAssignment", "dropdown", {
        default = "chat",
        label = "Left Assignment",
        options = {
            {value="chat", text="Chat"},
            {value="details", text="Details!"},
        },
        layout = {
            col = 1,
            row = 2,
        },
    })

    SnugUI.api.addSetting(moduleName, "rightAssignment", "dropdown", {
        default = "details",
        label = "Right Assignment",
        options = {
            {value="chat", text="Chat"},
            {value="details", text="Details!"},
        },
        layout = {
            col = 2,
            row = 2,
        },
     })
    SnugUI.api.renderSettings(moduleName)
end







SnugUI.loginTrigger(function()
    table.insert(SnugUI.commitRegistry, updateAnchors)
    makeSettings()
    createAnchors()
end)