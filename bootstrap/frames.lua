local SnugUI = _G.SnugUI

---<===================================================================================================>---<<2.1 Anchors
---<==============================[Creates the right and left anchor frames. They are exposed globally via their names.]


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
    local w = SnugUI.settings.anchors.width
    local h = SnugUI.settings.anchors.height

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
    local w = tonumber(SnugUI.settings.anchors.width)-- or 420
    local h = tonumber(SnugUI.settings.anchors.height)-- or 200

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

---<=================================================================================>---<<2.2 Settings Frames and Title
---<======================================================[Creates main settings window, title, and  left/right panels.]
SnugUI.frames.BG = CreateFrame("Frame", "SnugUI Settings", UIParent, "BackdropTemplate")
SnugUI.frames.BG:SetSize(690, 420)
SnugUI.frames.BG:SetPoint("CENTER")
SnugUI.frames.BG:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background" })
SnugUI.frames.BG:SetBackdropColor(0, 0, 0, 0.6)
SnugUI.frames.BG:SetMovable(true)
SnugUI.frames.BG:EnableMouse(true)
SnugUI.frames.BG:RegisterForDrag("LeftButton")
SnugUI.frames.BG:SetScript("OnDragStart", SnugUI.frames.BG.StartMoving)
SnugUI.frames.BG:SetScript("OnDragStop", SnugUI.frames.BG.StopMovingOrSizing)
SnugUI.frames.BG:Hide()
table.insert(UISpecialFrames, "SnugUI Settings")

SnugUI.frames.leftBG = CreateFrame("Frame", nil, SnugUI.frames.BG, "BackdropTemplate")
SnugUI.frames.leftBG:SetSize(200, 358)
SnugUI.frames.leftBG:SetPoint("TOPLEFT", SnugUI.frames.BG, "TOPLEFT", 8, -20)
SnugUI.frames.leftBG:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
SnugUI.frames.leftBG:SetBackdropColor(0.1, 0.1, 0.1, 0.8)

SnugUI.frames.rightBG = CreateFrame("Frame", nil, SnugUI.frames.BG, "BackdropTemplate")
SnugUI.frames.rightBG:SetSize(472, 358)
SnugUI.frames.rightBG:SetPoint("TOPRIGHT", SnugUI.frames.BG, "TOPRIGHT", -8, -20)
SnugUI.frames.rightBG:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
SnugUI.frames.rightBG:SetBackdropColor(0.1, 0.1, 0.1, 0.8)

-- Title Frames
local titleFrame = CreateFrame("Frame", nil, SnugUI.frames.BG, "BackdropTemplate")
titleFrame:SetSize(100, 36)
titleFrame:SetPoint("TOP", SnugUI.frames.BG, "TOP", 0, 18)
local texMid = titleFrame:CreateTexture(nil, "OVERLAY")
texMid:SetTexture("interface/framegeneral/uiframediamondmetalheader2x")
texMid:SetTexCoord(0, 0.5, 0.00390625, 0.30859375)
texMid:SetSize(60, 39)
texMid:SetPoint("CENTER", titleFrame, "CENTER")
local texLeft = titleFrame:CreateTexture(nil, "OVERLAY")
texLeft:SetTexture("interface/framegeneral/uiframediamondmetalheader2x")
texLeft:SetTexCoord(0.0078125, 0.5078125, 0.31640625, 0.62109375)
texLeft:SetSize(32, 39)
texLeft:SetPoint("LEFT", titleFrame, "LEFT", -12, 0)
local texRight = titleFrame:CreateTexture(nil, "OVERLAY")
texRight:SetTexture("interface/framegeneral/uiframediamondmetalheader2x")
texRight:SetTexCoord(0.0078125, 0.5078125, 0.62890625, 0.93359375)
texRight:SetSize(32, 39)
texRight:SetPoint("RIGHT", titleFrame, "RIGHT", 12, 0)

titleFrame:SetBackdropColor(1, 0.1, 0.1, 0.9)
local label = titleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
label:SetPoint("CENTER")
label:SetText("SnugUI Settings")

---<=================================================================================>---<<2.3 Pre-declaration of Panels
SnugUI.panels.about = CreateFrame("Frame", nil, SnugUI.frames.rightBG)
SnugUI.panels.about:SetAllPoints()
SnugUI.panels.about:Hide()

SnugUI.panels.general = CreateFrame("Frame", nil, SnugUI.frames.rightBG)
SnugUI.panels.general:SetAllPoints()
SnugUI.panels.general:Hide()

SnugUI.panels.chat = CreateFrame("Frame", nil, SnugUI.frames.rightBG)
SnugUI.panels.chat:SetAllPoints()
SnugUI.panels.chat:Hide()

SnugUI.panels.profiles = CreateFrame("Frame", nil, SnugUI.frames.rightBG)
SnugUI.panels.profiles:SetAllPoints()
SnugUI.panels.profiles:Hide()

SnugUI.panels.details = CreateFrame("Frame", nil, SnugUI.frames.rightBG)
SnugUI.panels.details:SetAllPoints()
SnugUI.panels.details:Hide()

SnugUI.panels.prat = CreateFrame("Frame", nil, SnugUI.frames.rightBG)
SnugUI.panels.prat:SetAllPoints()
SnugUI.panels.prat:Hide()

SnugUI.panels.SUF = CreateFrame("Frame", nil, SnugUI.frames.rightBG)
SnugUI.panels.SUF:SetAllPoints()
SnugUI.panels.SUF:Hide()

SnugUI.panels.WA = CreateFrame("Frame", nil, SnugUI.frames.rightBG)
SnugUI.panels.WA:SetAllPoints()
SnugUI.panels.WA:Hide()

SnugUI.panels.qol = CreateFrame("Frame", nil, SnugUI.frames.rightBG)
SnugUI.panels.qol:SetAllPoints()
SnugUI.panels.qol:Hide()

SnugUI.panels.minimap = CreateFrame("Frame", nil, SnugUI.frames.rightBG)
SnugUI.panels.minimap:SetAllPoints()
SnugUI.panels.minimap:Hide()

---<===========================================================================================>---<<2.4 Sidebar Buttons
---<===========================================[Includes logic for highlight states and corresponding panel visibility.]
local sidebarLabels = { "About", "General", "Minimap", "QOL", "Profiles" }
local subLabels     = { "Details!", "Shadowed Unit Frames", "WeakAuras" }

local sidebarButtons = {}
local subButtons     = {}
local subVisible     = false

-- Map of panel names to their frames
local panelMap = {
    About     = SnugUI.panels.about,
    General   = SnugUI.panels.general,
    Chat      = SnugUI.panels.chat,
    QOL       = SnugUI.panels.qol,
    Minimap   = SnugUI.panels.minimap,
    Profiles  = SnugUI.panels.profiles,
    ["Details!"] = SnugUI.panels.details,
    --["Prat 3.0"] = SnugUI.panels.prat,
    ["Shadowed Unit Frames"] = SnugUI.panels.SUF,
    WeakAuras    = SnugUI.panels.WA,
}

-- Utility to hide highlights on a set of buttons
local function HideHighlights(buttons)
    for _, btn in pairs(buttons) do
        if btn.highlight then btn.highlight:Hide() end
    end
end

-- Clear all sidebar and sub-button highlights
local function ClearSidebarHighlights()
    HideHighlights(sidebarButtons)
    HideHighlights(subButtons)
end

-- Show only the selected panel
local function ShowPanel(name)
    for _, panel in pairs(panelMap) do
        panel:Hide()
    end
    if panelMap[name] then
        panelMap[name]:Show()
    end
end

-- Toggle visibility of sub-buttons under Profiles
local function ToggleSubButtons()
    subVisible = not subVisible
    for _, btn in ipairs(subButtons) do
        btn:SetShown(subVisible)
    end
    sidebarButtons["Profiles"].toggleText:SetText(subVisible and "−" or "+")
end

-- Sidebar layout parameters
local startY, spacing = -5, -28
local yOffset = startY

-- Create main sidebar buttons
for _, label in ipairs(sidebarLabels) do
    local btn = CreateFrame("Button", nil, SnugUI.frames.leftBG)
    btn:SetSize(180, 24)
    btn:SetPoint("TOPLEFT", 10, yOffset)

    -- Highlight wrapper and texture
    local wrapper = CreateFrame("Frame", nil, btn)
    wrapper:SetPoint("TOPLEFT", -4, 0)
    wrapper:SetPoint("BOTTOMRIGHT", 4, 0)
    --wrapper:SetClipsChildren(true)

    local highlight = wrapper:CreateTexture(nil, "BACKGROUND")
    highlight:SetPoint("TOPLEFT", -20, 0)
    highlight:SetPoint("BOTTOMRIGHT", 20, 0)
    highlight:SetTexture("interface/common/search")
    highlight:SetTexCoord(0.001953125, 0.248046875, 0.6171875, 0.828125)
    highlight:SetAlpha(0.7)
    highlight:Hide()
    btn.highlight = highlight

    local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", 4, 0)
    text:SetText(label)
    btn.text = text

    -- Profiles toggle indicator
    if label == "Profiles" then
        local toggle = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        toggle:SetPoint("RIGHT", -4, 0)
        toggle:SetText("+")
        btn.toggleText = toggle

        btn:SetScript("OnClick", function()
            ClearSidebarHighlights()
            btn.highlight:Show()
            ToggleSubButtons()
        end)
    else
        btn:SetScript("OnClick", function()
            ClearSidebarHighlights()
            btn.highlight:Show()
            ShowPanel(label)
        end)
    end

    btn:SetScript("OnEnter", function() text:SetTextColor(1, 1, 1) end)
    btn:SetScript("OnLeave", function() text:SetTextColor(1, 0.82, 0) end)

    sidebarButtons[label] = btn
    yOffset = yOffset + spacing
end

-- Create sub-buttons under 'Profiles'
for _, label in ipairs(subLabels) do
    local btn = CreateFrame("Button", nil, SnugUI.frames.leftBG)
    btn:SetSize(160, 22)
    btn:SetPoint("TOPLEFT", 20, yOffset)
    btn:Hide()

    local highlight = btn:CreateTexture(nil, "BACKGROUND")
    highlight:SetAllPoints()
    highlight:SetTexture("interface/garrison/garrisonmissionui1")
    highlight:SetTexCoord(0.001953125, 0.783203125, 0.6513671875, 0.7001953125)
    highlight:SetAlpha(0.8)
    highlight:Hide()
    btn.highlight = highlight

    local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("LEFT", 8, 0)
    text:SetText(label)
    btn.text = text

    btn:SetScript("OnClick", function()
        ClearSidebarHighlights()
        btn.highlight:Show()
        ShowPanel(label)
    end)

    btn:SetScript("OnEnter", function() text:SetTextColor(1, 1, 1) end)
    btn:SetScript("OnLeave", function() text:SetTextColor(1, 0.82, 0) end)

    table.insert(subButtons, btn)
    yOffset = yOffset + spacing
end

SnugUI.buttons.apply = CreateFrame("Button", nil, SnugUI.frames.BG, "UIPanelButtonTemplate")
SnugUI.buttons.apply:SetSize(100, 24)
SnugUI.buttons.apply:SetPoint("BOTTOMLEFT", 10, 10)
SnugUI.buttons.apply:SetText("Apply")

SnugUI.buttons.reload = CreateFrame("Button", nil, SnugUI.frames.BG, "UIPanelButtonTemplate")
SnugUI.buttons.reload:SetSize(100, 24)
SnugUI.buttons.reload:SetPoint("LEFT", SnugUI.buttons.apply, "RIGHT", 10, 0)
SnugUI.buttons.reload:SetText("Reload UI")

SnugUI.buttons.close = CreateFrame("Button", nil, SnugUI.frames.BG, "UIPanelButtonTemplate")
SnugUI.buttons.close:SetSize(100, 24)
SnugUI.buttons.close:SetPoint("BOTTOMRIGHT", -10, 10)
SnugUI.buttons.close:SetText("Close")

---<===================================================================================================>---<<2.5 Borders
-- Universal border piece creator
local function AddBorderPiece(config)
    local tex = config.parent:CreateTexture(nil, config.layer or "BORDER")
    tex:SetTexture(config.texture)
    tex:SetTexCoord(unpack(config.texCoord))

    tex:SetPoint(config.pointA, config.parent, config.pointA, config.offsetAX or 0, config.offsetAY or 0)
    tex:SetPoint(config.pointB, config.parent, config.pointB, config.offsetBX or 0, config.offsetBY or 0)

    if config.width then tex:SetWidth(config.width) end
    if config.height then tex:SetHeight(config.height) end
    if config.rotation then tex:SetRotation(config.rotation) end
    if config.alpha then tex:SetAlpha(config.alpha) end
    return tex
end

-- Universal corner creator
local function AddCornerPiece(cfg)
    local tex = cfg.parent:CreateTexture(nil, cfg.layer or "ARTWORK")
    tex:SetTexture(cfg.texture)
    tex:SetTexCoord(unpack(cfg.texCoord))
    local offset = cfg.outset or 0
    local x = (cfg.offsetX or 0) + (cfg.point:find("LEFT") and -offset or offset)
    local y = (cfg.offsetY or 0) + (cfg.point:find("TOP") and offset or -offset)
    tex:SetPoint(cfg.point, cfg.parent, cfg.point, x, y)
    tex:SetSize(cfg.size, cfg.size)
    if cfg.rotation then tex:SetRotation(cfg.rotation) end
    return tex
end

local borderConfig = {
    top = {
        texture = "interface/framegeneral/uiframediamondmetal",
        texCoord = { 0, 0.5, 0.13671875, 0.26171875 },
        pointA = "TOPLEFT",
        pointB = "TOPRIGHT",
        height = 32,
        offsetAY = 8,
    },
    bottom = {
        texture = "interface/framegeneral/uiframediamondmetal",
        texCoord = { 0, 0.5, 0.00390625, 0.12890625 },
        pointA = "BOTTOMLEFT",
        pointB = "BOTTOMRIGHT",
        height = 32,
        offsetAY = -8,
    },
    left = {
        texture = "interface/framegeneral/uiframediamondmetalvertical",
        texCoord = { 0.0078125, 0.2578125, 0, 1 },
        pointA = "TOPLEFT",
        pointB = "BOTTOMLEFT",
        width = 32,
        offsetAX = -8,
    },
    right = {
        texture = "interface/framegeneral/uiframediamondmetalvertical",
        texCoord = { 0.2734375, 0.5234375, 0, 1 },
        pointA = "TOPRIGHT",
        pointB = "BOTTOMRIGHT",
        width = 32,
        offsetAX = 8,
    },
}
for _, cfg in pairs(borderConfig) do
    cfg.parent = SnugUI.frames.BG
    AddBorderPiece(cfg)
end

local cornerConfig = {
    topleft = {
        texture = "interface/framegeneral/uiframediamondmetal",
        texCoord = { 0.015625, 0.515625, 0.53515625, 0.66015625 },
        point = "TOPLEFT",
        size = 32,
        outset = 8,
    },
    topright = {
        texture = "interface/framegeneral/uiframediamondmetal",
        texCoord = { 0.015625, 0.515625, 0.66796875, 0.79296875 },
        point = "TOPRIGHT",
        size = 32,
        outset = 8,
    },
    bottomleft = {
        texture = "interface/framegeneral/uiframediamondmetal",
        texCoord = { 0.015625, 0.515625, 0.26953125, 0.39453125 },
        point = "BOTTOMLEFT",
        size = 32,
        outset = 8,
    },
    bottomright = {
        texture = "interface/framegeneral/uiframediamondmetal",
        texCoord = { 0.015625, 0.515625, 0.40234375, 0.52734375 },
        point = "BOTTOMRIGHT",
        size = 32,
        outset = 8,
    },
}
for _, cfg in pairs(cornerConfig) do
    cfg.parent = SnugUI.frames.BG
    AddCornerPiece(cfg)
end
---<====================================================================================================>---<<2.6 Labels
local l = SnugUI.panels.general:CreateFontString(nil, "OVERLAY", "GameFontNormal")
l:SetFont("Fonts\\FRIZQT__.TTF", 16, "")
l:SetPoint("TOPLEFT", 16, -16)
l:SetText("Anchor Settings")

--local l = SnugUI.panels.general:CreateFontString(nil, "OVERLAY", "GameFontNormal")
--l:SetFont("Fonts\\FRIZQT__.TTF", 16, "")
--l:SetPoint("TOP", 0, -116)
--l:SetText("Anchor Content")

local l = SnugUI.panels.general:CreateFontString(nil, "OVERLAY", "GameFontNormal")
l:SetFont("Fonts\\FRIZQT__.TTF", 16, "")
l:SetPoint("TOPLEFT", 16, -124)
l:SetText("Styles")

local divider = SnugUI.panels.general:CreateTexture(nil, "ARTWORK")
divider:SetColorTexture(1, 1, 1, 0.2)
divider:SetSize(SnugUI.panels.general:GetWidth() - 32, 2)
divider:SetPoint("TOP", SnugUI.panels.general, "TOP", 0, -108)

local divider = SnugUI.panels.minimap:CreateTexture(nil, "ARTWORK")
divider:SetColorTexture(1, 1, 1, 0.2)
divider:SetSize(SnugUI.panels.minimap:GetWidth() - 32, 2)
divider:SetPoint("TOP", SnugUI.panels.minimap, "TOP", 0, -68)


---<===========================================================================================================>---<<AUX
SnugUI.loginTrigger(function()
    createAnchors()
    table.insert(SnugUI.commitRegistry, updateAnchors)
end)