local SnugUI = _G.SnugUI


SnugUISettings = SnugUISettings or {}
SnugUI.settings = SnugUISettings
-- Ensure the functions namespace exists so files loaded in unexpected order won't error
-- Ensure functions namespace exists (bootstrap should normally do this)
-- SnugUI.functions = SnugUI.functions or {}



---<==========================================================================================>---<<3.1 Reload Indicator
function SnugUI.functions.reloadUIRequest()
    SnugUI.settings.reloadUI = SnugUI.settings.reloadUI or false
    if SnugUI.settings.reloadUI then return end

    local reloadButton = SnugUI.buttons.reload
    if not reloadButton then return end

    if not reloadButton.reloadNote then
        local note = reloadButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        note:SetPoint("LEFT", reloadButton, "RIGHT", 10, 0)
        note:SetText("|cffffcc00**Reload required|r")
        reloadButton.reloadNote = note
    end

    reloadButton.reloadNote:Show()

    SnugUI.settings.reloadUI = true
end
---<=========================================================================================>---<<3.2 Anchor Dimensions
local function initAnchorDimensions()
    local panel = SnugUI.panels.general
    local UIclientWidth, UIclientHeight = UIParent:GetWidth(), UIParent:GetHeight()

    local widthInput = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    widthInput:SetSize(60, 20)
    widthInput:SetPoint("TOPLEFT", panel, "TOPLEFT", 108, -60)
    widthInput:SetAutoFocus(false)
    widthInput:SetNumeric(true)
    widthInput:SetText(tostring(SnugUI.settings.anchors.width))
    widthInput:SetScript("OnTextChanged", function(self)
        local value = tonumber(self:GetText())
        if not value then
            return -- do nothing if input is empty or not a number
        end
        if value > math.floor(0.5 + UIclientWidth / 2) then
            SnugUI.settings.anchors.width = math.floor(0.5 + UIclientWidth / 2)
            widthInput:SetText(tostring(SnugUI.settings.anchors.width))
        elseif value >= 1 then
            SnugUI.settings.anchors.width = value
        end
    end)
    local widthLabel = widthInput:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    widthLabel:SetPoint("BOTTOM", widthInput, "TOP", -4, 4)
    widthLabel:SetText("Width")

    local heightInput = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    heightInput:SetSize(60, 20)
    heightInput:SetPoint("TOPLEFT", panel, "TOPLEFT", 32, -60)
    heightInput:SetAutoFocus(false)
    heightInput:SetNumeric(true)
    heightInput:SetText(tostring(SnugUI.settings.anchors.height))
    heightInput:SetScript("OnTextChanged", function(self)
        local value = tonumber(self:GetText())
        if not value then
            return -- do nothing if input is empty or not a number
        end
        if value > math.floor(0.5 + UIclientHeight) then
            SnugUI.settings.anchors.height = math.floor(0.5 + UIclientHeight)
            heightInput:SetText(tostring(SnugUI.settings.anchors.height))
        elseif value >= 1 then
            SnugUI.settings.anchors.height = value
        end
    end)
    local heightLabel = heightInput:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    heightLabel:SetPoint("BOTTOM", heightInput, "TOP", -3, 4)
    heightLabel:SetText("Height")

    if SnugUI.settings.debug then
        local pw, ph = GetPhysicalScreenSize()
        local uw, uh = UIParent:GetWidth(), UIParent:GetHeight()
        print("Physical:", pw, ph)
        print("UIParent:", uw, uh)
    end
end

---<========================================================================================>---<<3.3 Anchor Assignments
local anchorOptions = { "", "Chat", "Details!" }

local function CreateAnchorDropdown(parent, sideKey, x, y)
    SnugUI.dropdowns = SnugUI.dropdowns or {}
    local settings = SnugUI.settings.anchors

    -- Dropdown
    local dropdown = CreateFrame("Frame", "SnugUIAnchorDropdown" .. sideKey, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPRIGHT", parent, "TOPRIGHT", x, y)
    UIDropDownMenu_SetWidth(dropdown, 90)
    SnugUI.dropdowns[sideKey] = dropdown

    -- Label
    local label = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("BOTTOM", dropdown, "TOP", 0, 4)
    label:SetText((sideKey == "left") and "Left Anchor" or "Right Anchor")

    -- Menu Initialization
    UIDropDownMenu_Initialize(dropdown, function(self, level)
        for _, option in ipairs(anchorOptions) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = (option == "") and "—" or option
            info.value = option
            info.checked = (settings[sideKey .. "Assignment"] == option)
            info.func = function(selfArg)
                local otherKey = (sideKey == "left") and "right" or "left"
                if settings[otherKey .. "Assignment"] == selfArg.value then
                    settings[otherKey .. "Assignment"] = ""
                    local otherDrop = SnugUI.dropdowns[otherKey]
                    if otherDrop then
                        UIDropDownMenu_SetSelectedValue(otherDrop, "")
                        UIDropDownMenu_SetText(otherDrop, "—")
                    end
                end
                settings[sideKey .. "Assignment"] = selfArg.value
                UIDropDownMenu_SetSelectedValue(dropdown, selfArg.value)
                UIDropDownMenu_SetText(dropdown, (selfArg.value == "") and "—" or selfArg.value)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    -- Initial Value
    local value = settings[sideKey .. "Assignment"]
    if not tContains(anchorOptions, value) then
        value = ""
        settings[sideKey .. "Assignment"] = value
    end
    UIDropDownMenu_SetSelectedValue(dropdown, value)
    UIDropDownMenu_SetText(dropdown, (value == "") and "—" or value)

    return dropdown
end


local function initAnchorAssignments()
    CreateAnchorDropdown(SnugUI.panels.general, "left", -128, -58)
    CreateAnchorDropdown(SnugUI.panels.general, "right", -10, -58)
end

---<==========================================================================================>---<<3.4 Minimap Settings


-- local function initMinimapSettingsPanel()
--     local panel = SnugUI.panels.minimap

--     SnugUI.settings.testSlider = SnugUI.settings.testSlider or 1

--     local label = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
--     label:SetPoint("TOPLEFT", 24, -90)
--     label:SetText("Minimap Scale")

--     local slider = CreateFrame("Slider", nil, panel)
--     slider:SetOrientation("HORIZONTAL")
--     slider:SetSize(200, 16)
--     slider:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -10)
--     slider:SetMinMaxValues(0.7750, 1.9625)
--     slider:SetValueStep(0.00625)
--     slider:SetValue(SnugUI.settings.minimap.scale)
--     slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")

--     local track = slider:CreateTexture(nil, "BACKGROUND")
--     track:SetPoint("LEFT", slider, "LEFT", 16, 0)
--     track:SetPoint("RIGHT", slider, "RIGHT", -16, 0)
--     track:SetHeight(6)
--     track:SetTexture(0.3, 0.3, 0.3, 0.8)

--     local valueText = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
--     valueText:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -8)
--     valueText:SetText("Value: " .. SnugUI.settings.testSlider)

--     slider:SetScript("OnValueChanged", function(self, value)
--         local step = 0.00625
--         value = math.floor(value / step + 0.5) * step
--         SnugUI.settings.minimap.scale = value
--         MinimapCluster:SetScale(value)
--         valueText:SetText("Value: " .. value)
--         print(string.format("scale = %.5f", value))

--     end)
-- end


---<=============================================================================================>---<<3.5 Chat Settings
local tabOptions = { "SnugUI", "Blizzard" }
local function CreateTabSystemDropdown()
    local panel = SnugUI.panels.general

    local dropdown = CreateFrame("Frame", "SnugUITabSystemDropdown", panel, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", panel, "TOPLEFT", 8, -166)
    UIDropDownMenu_SetWidth(dropdown, 120)

    local label = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("BOTTOM", dropdown, "TOP", 0, 4)
    label:SetText("Chat Tab Style:")

    UIDropDownMenu_Initialize(dropdown, function(self, level)
        for _, option in ipairs(tabOptions) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = option
            info.value = option
            info.checked = (SnugUI.settings.chat.tabStyle == option)
            info.func = function(selfArg)
                SnugUI.settings.chat.tabStyle = selfArg.value
                UIDropDownMenu_SetSelectedValue(dropdown, selfArg.value)
                _G[dropdown:GetName() .. "Text"]:SetText(selfArg.value)
                SnugUI.functions.reloadUIRequest()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    local value = SnugUI.settings.chat.tabStyle
    if not tContains(tabOptions, value) then
        value = "SnugUI"
        SnugUI.settings.chat.tabStyle = value
    end
    UIDropDownMenu_SetSelectedValue(dropdown, value)
    _G[dropdown:GetName() .. "Text"]:SetText(value)
end

---<============================================================================================>---<<3.6 Details! Panel
local panel = SnugUI.panels.details

local header = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
header:SetPoint("TOPLEFT", 16, -16)
header:SetText("Use the string below to import the SnugUI profile for Details!")

local scrollFrame = CreateFrame("ScrollFrame", "SnugUIDetailsExportScroll", panel, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 16, -48)
scrollFrame:SetPoint("BOTTOMRIGHT", -32, 16)

local bg = CreateFrame("Frame", nil, scrollFrame, "BackdropTemplate")
bg:SetPoint("TOPLEFT", -4, 4)
bg:SetPoint("BOTTOMRIGHT", 4, -4)
bg:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
bg:SetBackdropColor(0, 0, 0, 0.4)
bg:SetBackdropBorderColor(1, 1, 1, 0.6)

local exportBox = CreateFrame("EditBox", "SnugUIDetailsExportBox", scrollFrame)
exportBox:SetMultiLine(true)
exportBox:SetFontObject("GameFontHighlightSmall")
exportBox:SetWidth(400)
exportBox:SetAutoFocus(false)
exportBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
exportBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
exportBox:SetScript("OnTextChanged", function()
    scrollFrame:UpdateScrollChildRect()
end)

scrollFrame:SetScrollChild(exportBox)
local function setDetailsExportBox()
    exportBox:SetText(Details_Profile or "No export data found.")
end

---<========================================================================================>---<< Shadowed Unit frames Panel
local panel = SnugUI.panels.SUF

local header = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
header:SetPoint("TOPLEFT", 16, -16)
header:SetText("Go to '/SUF > General > Layout Manager > Import' to import.")

local scrollFrame = CreateFrame("ScrollFrame", "SnugUISUFExportScroll", panel, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 16, -48)
scrollFrame:SetPoint("BOTTOMRIGHT", -32, 16)

local bg = CreateFrame("Frame", nil, scrollFrame, "BackdropTemplate")
bg:SetPoint("TOPLEFT", -4, 4)
bg:SetPoint("BOTTOMRIGHT", 4, -4)
bg:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
bg:SetBackdropColor(0, 0, 0, 0.4)
bg:SetBackdropBorderColor(1, 1, 1, 0.6)

local exportBox = CreateFrame("EditBox", "SnugUIWAExportBox", scrollFrame)
exportBox:SetMultiLine(true)
exportBox:SetFontObject("GameFontHighlightSmall")
exportBox:SetWidth(400)
exportBox:SetAutoFocus(false)
exportBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
exportBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
exportBox:SetScript("OnTextChanged", function()
    scrollFrame:UpdateScrollChildRect()
end)

scrollFrame:SetScrollChild(exportBox)
local function setSUFExportBox()
    exportBox:SetText(SUF_Profile or "No export data found.")
end

---<============================================================================================>---<< WeakAuras Panel
local panel = SnugUI.panels.WA

local header = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
header:SetPoint("TOPLEFT", 16, -16)
header:SetText("Use the string below to import the SnugUI profile for WeakAuras")

local scrollFrame = CreateFrame("ScrollFrame", "SnugUIWAExportScroll", panel, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 16, -48)
scrollFrame:SetPoint("BOTTOMRIGHT", -32, 16)

local bg = CreateFrame("Frame", nil, scrollFrame, "BackdropTemplate")
bg:SetPoint("TOPLEFT", -4, 4)
bg:SetPoint("BOTTOMRIGHT", 4, -4)
bg:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
bg:SetBackdropColor(0, 0, 0, 0.4)
bg:SetBackdropBorderColor(1, 1, 1, 0.6)

local exportBox = CreateFrame("EditBox", "SnugUIWAExportBox", scrollFrame)
exportBox:SetMultiLine(true)
exportBox:SetFontObject("GameFontHighlightSmall")
exportBox:SetWidth(400)
exportBox:SetAutoFocus(false)
exportBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
exportBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
exportBox:SetScript("OnTextChanged", function()
    scrollFrame:UpdateScrollChildRect()
end)

scrollFrame:SetScrollChild(exportBox)
local function setWAExportBox()
    exportBox:SetText(WeakAuras_export or "No export data found.")
end
---<======================================================================================>---<<3.7 Buttons and Commands
SLASH_SnugUI1 = "/sui"
SlashCmdList["SnugUI"] = function()
    if SnugUI.frames.BG:IsShown() then
        SnugUI.frames.BG:Hide()
    else
        SnugUI.frames.BG:Show()
    end
end
SnugUI.loginTrigger(function()
    if SnugUI.settings.debug then
        C_Timer.After(1, function()
            SnugUI.frames.BG:Show()
        end)
    end
end)

SnugUI.buttons.apply:SetScript("OnClick", function()
    for _, func in pairs(SnugUI.commitRegistry) do
        if type(func) == "function" then
            pcall(func)
        end
    end
end)
local function buttonTooltips()
    SnugUI.buttons.apply:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Applies layout changes immediately", 1, 1, 1)
        GameTooltip:Show()
    end)
end

SnugUI.buttons.reload:SetScript("OnClick", function()
    ReloadUI()
end)

SnugUI.buttons.close:SetScript("OnClick", function()
    SnugUI.frames.BG:Hide()
end)

---<================================================================================================>---<<3.8 About Page
local panel = SnugUI.panels.about
local function CreateAboutLine(text, font, anchorTo, offsetX, offsetY)
    local line = panel:CreateFontString(nil, "OVERLAY", font or "GameFontHighlight")
    line:SetPoint("TOPLEFT", anchorTo or panel, offsetX or 16, offsetY or -16)
    line:SetJustifyH("LEFT")
    line:SetText(text)
    return line
end

-- Title
local title = CreateAboutLine("About SnugUI", "GameFontNormalLarge", nil, 16, -16)

local missionStatement = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
missionStatement:SetPoint("TOPLEFT", 16, -32)
missionStatement:SetWidth(440) -- or however wide your about panel is
missionStatement:SetJustifyH("LEFT")
missionStatement:SetJustifyV("TOP")
missionStatement:SetTextColor(1, 1, 1)
missionStatement:SetText("SnugUI is a lightweight UI style that brings everything together with minimal fuss. It aims to unify your interface visually while staying out of the way, using clean, efficient tweaks to keep things cohesive without overcomplicating.")

local recAddons = CreateAboutLine("Recommended", "GameFontNormal", nil, 32, -96)
local recAddons = CreateAboutLine("Addons", "GameFontNormal", nil, 75, -112)

-- local function CreateThanksEntry(parent, x, y, name, author, url)
--     local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
--     label:SetPoint("TOPLEFT", x, y)
--     label:SetText("|cffffffff•|r |cff00ccff" .. name .. "|r by " .. author)

--     local editBox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
--     editBox:SetSize(320, 18)
--     editBox:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 13, 4)
--     editBox:SetText(url)
--     editBox:SetAutoFocus(false)
--     editBox:SetScript("OnEscapePressed", editBox.ClearFocus)
--     editBox:SetScript("OnEditFocusGained", function(self)
--         self:HighlightText()
--     end)

--     editBox.Left:Hide()
--     editBox.Middle:Hide()
--     editBox.Right:Hide()
--     editBox:SetFontObject("GameFontHighlightSmall")

--     return label, editBox
-- end

--CreateThanksEntry(panel, 148, -96, "Masque", "StormFX", "https://www.curseforge.com/wow/addons/masque")
--CreateThanksEntry(panel, 148, -128, "Masque_SnugUI", "Snugglelumps", "https://www.curseforge.com/wow/addons/masque_SnugUI")
--CreateThanksEntry(panel, 148, -160, "Details! Damage Meter", "Tercioo", "https://www.curseforge.com/wow/addons/details")
--CreateThanksEntry(panel, 148, -192, "Prat 3.0", "sylvanaar", "https://www.curseforge.com/wow/addons/prat-3-0")

-- local specialThanks = CreateAboutLine("Special Thanks", "GameFontNormal", nil, 33, -232)

-- local function CreateSpecialEntry(parent, x, y, name, author, url)
--     local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
--     label:SetPoint("TOPLEFT", x, y)
--     label:SetText("|cffffffff•|r |cff00ccff" .. name .. "|r by " .. author)

--     local editBox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
--     editBox:SetSize(320, 18)
--     editBox:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 13, 4)
--     editBox:SetText(url)
--     editBox:SetAutoFocus(false)
--     editBox:SetScript("OnEscapePressed", editBox.ClearFocus)
--     editBox:SetScript("OnEditFocusGained", function(self)
--         self:HighlightText()
--     end)

--     editBox.Left:Hide()
--     editBox.Middle:Hide()
--     editBox.Right:Hide()
--     editBox:SetFontObject("GameFontHighlightSmall")

--     return label, editBox
-- end

-- CreateSpecialEntry(panel, 148, -232, "DevTool", "brittyazel", "https://github.com/brittyazel")
-- CreateSpecialEntry(panel, 148, -264, "TextureAtlasViewer", "LanceDH", "https://github.com/LanceDH")

-- local thankyou = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
-- thankyou:SetPoint("TOPLEFT", 16, -306)
-- thankyou:SetWidth(440) -- or however wide your about panel is
-- thankyou:SetJustifyH("LEFT")
-- thankyou:SetJustifyV("TOP")
-- thankyou:SetTextColor(1, 1, 1)
-- thankyou:SetText("And a general thanks to all of you who take the time to build something for the game you love (and leave helpful comments). This is the first time I have tried anything like this, without the vast endeavors of this community I would not have made it very far. --|cff00ccffSnugglelumps|r")

---<=======================================================================================================>---<<3.9 QOL

local function createQuestButton()
    local label1 = SnugUI.panels.qol:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label1:SetPoint("LEFT", SnugUI.panels.qol, "TOPLEFT", 10, -15)
    label1:SetText("Quest Item Button")

    local checkbox = CreateFrame("CheckButton", nil, SnugUI.panels.qol, "ChatConfigCheckButtonTemplate")
    checkbox:SetPoint("LEFT", label1, "RIGHT", 4, 0)
    checkbox:SetChecked(SnugUI.settings.qol.questButton)
    checkbox:SetHitRectInsets(0, 0, 0, 0)

    checkbox:SetScript("OnClick", function(self)
        local enabled = self:GetChecked()
        SnugUI.settings.qol.questButton = enabled
        SnugUI.functions.reloadUIRequest()
    end)
end

local function createQuestHotkey()
    local label2 = SnugUI.panels.qol:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label2:SetPoint("LEFT", SnugUI.panels.qol, "TOPLEFT", 300, -15)
    label2:SetText("Hotkey:")

    local editBox = CreateFrame("EditBox", nil, SnugUI.panels.qol, "InputBoxTemplate")
    editBox:SetSize(30, 20)
    editBox:SetPoint("LEFT", label2, "RIGHT", 4, 0)
    editBox:SetAutoFocus(false)
    editBox:SetMaxLetters(1)

    -- Initialize with current setting
    editBox:SetText(SnugUI.settings.qol.questHotkey or "")

    editBox:SetScript("OnTextChanged", function(self)
        local char = self:GetText():sub(1, 1):upper()
        self:SetText(char) -- ensure only one character stays
        SnugUI.settings.qol.questHotkey = char
    end)

    editBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    editBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
end

---<===========================================================================================================>---<<AUX
SnugUI.loginTrigger(function()
    -- Initialization
    initAnchorDimensions()
    initAnchorAssignments()
    CreateTabSystemDropdown()
    setDetailsExportBox()
    setSUFExportBox()
    setWAExportBox()
    createQuestButton()
    createQuestHotkey()
    -- initMinimapSettingsPanel()
end)
