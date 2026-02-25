local SnugUI = _G.SnugUI


local tabRects = {}

local function fadeInAll()
    for _, b in pairs(tabRects) do
        if b:IsShown() then
            UIFrameFadeIn(b, 0.15, b:GetAlpha(), 1)
        end
    end
end

local function fadeOutAll()
    local lop = 1
    for _, rect in pairs(tabRects) do
        if rect:IsShown() then
            UIFrameFadeOut(rect, lop, rect:GetAlpha(), 0)
            lop = lop + 0.5
        end
    end
end

local function createTabWords()
    local shownTabs2 = {}
    for i = 1, NUM_CHAT_WINDOWS do
        local tab = _G["ChatFrame" .. i .. "Tab"]
        local frame = _G["ChatFrame" .. i]
        if tab and frame and tab:IsVisible() then
            table.insert(shownTabs2, {tab = tab, index = i, frame = frame})
        end
    end

    for _, rect in pairs(tabRects) do
        rect:Hide()
    end

    local yoffset = 0
    for _, data in ipairs(shownTabs2) do
        local tab = data.tab
        local rect = tabRects[data.index]

        if not rect then --- creates a new frame only if non exist
            rect = CreateFrame("Button", nil, UIParent, "BackdropTemplate")
            rect:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background" })

            local text = rect:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            text:SetFont("Fonts\\FRIZQT__.TTF", 16, "")
            text:SetPoint("LEFT")
            rect.text = text

            tabRects[data.index] = rect

            rect:EnableMouse(true)
            rect:RegisterForClicks("AnyUp")
            rect:SetScript("OnMouseUp", function(self, button)
                local chatTab = _G["ChatFrame"..self.tabIndex.."Tab"]
                FCF_Tab_OnClick(chatTab, button)
            end)
            rect:SetScript("OnEnter", function(self)
                fadeInAll()
                self.text:SetTextColor(1, 1, 1)
            end)
            rect:SetScript("OnLeave", function(self)
                fadeOutAll()
                self.text:SetTextColor(1, 0.82, 0)
            end)
        end

        rect.tabIndex = data.index
        rect.text:SetText(tab:GetText())
        local width = rect.text:GetStringWidth() + 6
        local height = rect.text:GetStringHeight() + 6
        rect:SetSize(width, height)
        rect:SetBackdropColor(0, 0, 0, 0)
        if SnugUI.settings.anchors.leftAssignment == "Chat" then
            rect:ClearAllPoints()
            rect:SetPoint("TOPLEFT", shownTabs2[1].frame, "TOPRIGHT", 5, yoffset)
        elseif SnugUI.settings.anchors.rightAssignment == "Chat" then
            rect:ClearAllPoints()
            rect:SetPoint("TOPRIGHT", shownTabs2[1].frame, "TOPLEFT", 5, yoffset)
        end
        rect:Show()
        yoffset = yoffset - rect:GetHeight() - 5
    end
end

local function HideGeneralDockManager()
-- This function deliberately disrupts the GeneralDockManager to prevent it from rendering on screen.
-- This is necessary because hiding the chat tabs (e.g. with Hide()) breaks TabWords' ability
-- to index them properly. Additionally, the combat log's extra buttons inherit alpha from their parent tab,
-- so fully hiding the tabs isn't viable. This controlled "break" is a workaround to keep them functional but invisible.
    if GeneralDockManager and GeneralDockManager:IsVisible() then
        GeneralDockManager:ClearAllPoints()
        GeneralDockManager:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 0)
    end
end

local function hideBlizzardChatTabStuff()
    local elements = { "Left", "Middle", "Right", "HighlightLeft", "HighlightMiddle", "HighlightRight" }

    for i = 1, NUM_CHAT_WINDOWS do
        local base = "ChatFrame" .. i .. "Tab"

        for _, suffix in ipairs(elements) do
            local region = _G[base .. suffix]
            if region then region:Hide() end
        end

        -- local tabText = _G[base .. "Text"] -- delete on next version
        -- if tabText then
        --     tabText:SetFont("Fonts\\FRIZQT__.TTF", 12, "NONE") -- Adjust size/style here
        -- end
    end
end
---<===========================================================================================================>---<<AUX
SnugUI.loginTrigger(function()
    if SnugUI.settings.chat.tabStyle ~= "SnugUI" then return end
    createTabWords()
    HideGeneralDockManager()
    C_Timer.After(6, fadeOutAll)
    table.insert(SnugUI.commitRegistry, createTabWords)
    for _, funcName in ipairs({"FCF_DockUpdate", "FCF_OpenNewWindow", "FCF_Close"}) do
        hooksecurefunc(funcName, createTabWords)
    end
end)

SnugUI.loginTrigger(function()
    if SnugUI.settings.chat.tabStyle ~= "Blizzard" then return end
    hideBlizzardChatTabStuff()
end)