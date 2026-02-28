-- Ive done some cool shit in my life.. this tho.. this im ashamed of. it #works, for now i guess.

local SnugUI = _G.SnugUI

local moduleName = "qol"

local questButtonParent = CreateFrame("Frame", "QuestButtonFrame", UIParent, "BackdropTemplate")
questButtonParent:SetSize(44, 44)
questButtonParent:SetPoint("CENTER")
questButtonParent:SetFrameStrata("LOW")
questButtonParent:SetMovable(true)
questButtonParent:SetUserPlaced(true)

SnugUI.frames.questButtonParent = questButtonParent

-- Top-level table for button methods to hook
local hookFunctions = {
    "SetPoint",
    "SetParent",
    "Show",
    "SetShown",
    "Hide",
    "SetAttribute",
}

local isUpdatingQuestButtons = false
function SnugUI.functions.updateQuestItemButtons()
    if isUpdatingQuestButtons then return end
    isUpdatingQuestButtons = true

    local anchored = {}
    local firstButton = nil
    local parent = SnugUI.frames.questButtonParent
    if not parent then
        isUpdatingQuestButtons = false
        return
    end

    for i = 1, 10 do
        local button = _G["WatchFrameItem"..i]
        if not button then break end

        -- Hook button methods if not already hooked
        if button and not button.__SnugUI_Hooked then
            for _, funcName in ipairs(hookFunctions) do
                hooksecurefunc(button, funcName, function()
                    if SnugUI and SnugUI.functions.updateQuestItemButtons then
                        SnugUI.functions.updateQuestItemButtons()
                    end
                end)
            end
            button.__SnugUI_Hooked = true
        end

        if button:IsShown() then
            button:EnableMouse(true)
            button:RegisterForDrag("LeftButton")
            if not button.__SnugUI_DragScripts then
                button:SetScript("OnDragStart", function()
                    parent:StartMoving()
                end)
                button:SetScript("OnDragStop", function()
                    parent:StopMovingOrSizing()
                end)
                button.__SnugUI_DragScripts = true
            end
            button:SetScale(1.4)
            button:SetFrameStrata("MEDIUM")
            button:ClearAllPoints()
            if #anchored == 0 then
                button:SetPoint("CENTER", parent, "CENTER", 0, 0)
                firstButton = button
            else
                button:SetPoint("LEFT", anchored[#anchored], "RIGHT", 5, 0)
            end
            table.insert(anchored, button)
        end

        -- Only show keyLabel for the first button, hide for others
        if button.keyLabel then
            if button == firstButton and SnugUI.settings.qol.questHotkey then
                button.keyLabel:Show()
                button.keyLabel:SetText(SnugUI.settings.qol.questHotkey:upper())
            else
                button.keyLabel:Hide()
            end
        end
    end

    if firstButton and SnugUI.settings.qol.questHotkey then
        SetOverrideBindingClick(firstButton, true, SnugUI.settings.qol.questHotkey, firstButton:GetName(), "LeftButton")
        if not firstButton.keyLabel then
            firstButton.keyLabel = firstButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            firstButton.keyLabel:SetPoint("TOPLEFT", firstButton, "TOPLEFT", 2, -2)
            firstButton.keyLabel:SetTextColor(1, 1, 1)
        end
        firstButton.keyLabel:Show()
        firstButton.keyLabel:SetText(SnugUI.settings.qol.questHotkey:upper())
    end

    isUpdatingQuestButtons = false
end

function ensureAutoLootOn()
    if not GetCVarBool("autoLootDefault") then
        SetCVar("autoLootDefault", 1)
    end
end

local function makeSettings()
    SnugUI.api.generateSettingsUI(moduleName, "Quality of Life", {
        title = "Quality of Life Improvements",
        message = "These settings adjust various aspects of the user interface to improve quality of life. Like everything I write, its probably wrong and bound to break, so... fair warning I guess",
    })
    SnugUI.api.addSetting(moduleName, "questButton", "checkbox", {
        default = false,
        label = "Use SnugUI quest item buttons",
        layout = {
            col = 1,
            row = 1,
        },
        updateFunc = function()
            SnugUI.functions.updateQuestItemButtons()
        end,
    })
    SnugUI.api.addSetting(moduleName, "questHotkey", "editbox", {
        default = "G",
        label = "Hotkey for quest item button",
        valueType = "string",
        maxLetters = 1,
        layout = {
            col = 1,
            row = 2,
            width = 30,
            rowPitch = 35,
        },
        updateFunc = function()
            SnugUI.functions.updateQuestItemButtons()
        end,
    })
    SnugUI.api.addSetting(moduleName, "autoautoloot", "checkbox", {
        default = true,
        label = "Auto loot automatically enabled",
        layout = {
            col = 1,
            row = 3,
        },
        reloadWarning = true,
    })
    SnugUI.api.renderSettings(moduleName)
end







SnugUI.loginTrigger(function()
    makeSettings()
    if not SnugUI.settings.qol.questButton then return end
    hooksecurefunc("WatchFrame_Update", function()
        SnugUI.functions.updateQuestItemButtons()
    end)
    ensureAutoLootOn()
end)