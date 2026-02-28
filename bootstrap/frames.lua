local SnugUI = _G.SnugUI

---<============================================================================================>---<<============
---<===Main Settings Frame===>---
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

---<============================================================================================>---<<============
---<===Buttons and Functionality===>---
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

SnugUI.buttons.apply:SetScript("OnClick", function()
    for _, func in pairs(SnugUI.commitRegistry) do
        if type(func) == "function" then
            pcall(func)
        end
    end
end)

SnugUI.buttons.reload:SetScript("OnClick", function()
    ReloadUI()
end)

SnugUI.buttons.close:SetScript("OnClick", function()
    SnugUI.frames.BG:Hide()
end)

function initReloadUIRequest()
    local reloadButton = SnugUI.buttons.reload
    if not reloadButton then return end

    if not reloadButton.reloadNote then
        reloadButton.reloadNote = reloadButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        reloadButton.reloadNote:SetPoint("LEFT", reloadButton, "RIGHT", 10, 0)
        reloadButton.reloadNote:SetText("|cffffcc00**Reload required|r")
    end

    reloadButton.reloadNote:Hide()
end

function SnugUI.functions.reloadUIRequest()
    local reloadButton = SnugUI.buttons.reload
    if reloadButton and reloadButton.reloadNote then
        reloadButton.reloadNote:Show()
    end
end
---<============================================================================================>---<<============
---<===Borders and Corners===>---
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



---<============================================================================================>---<<============
---<===AUX===>---
SnugUI.loginTrigger(function()
    initReloadUIRequest()
    table.insert(SnugUI.commitRegistry, updateAnchors)
end)