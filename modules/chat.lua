local SnugUI = _G.SnugUI
if not SnugUI then return end


local function GetAnchorTarget()
    local anchors = SnugUI.settings.anchors
    if not anchors then return nil end

    if (anchors.leftAssignment == "chat" and SnugUI.frames.leftAnchor) then
        return SnugUI.frames.leftAnchor
    elseif (anchors.rightAssignment == "chat" and SnugUI.frames.rightAnchor) then
        return SnugUI.frames.rightAnchor
    end
    
    return nil
end

-- Anchors the chat frame and its edit box to the selected anchor
local function AnchorChatToAssignedAnchor()
    local anchor = GetAnchorTarget()
    if anchor and ChatFrame1 and ChatFrame1EditBox then
        -- Chat frame
        ChatFrame1:ClearAllPoints()
        for i = 1, 9 do
            local frame = _G["ChatFrame"..i]
            if frame then
                frame:SetClampedToScreen(false)
                FCF_SetLocked(frame, true)
            end
        end
        ChatFrame1:SetPoint("TOPLEFT", anchor, "TOPLEFT", 2, -3)
        ChatFrame1:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -2, 2)
        ChatFrame1:SetUserPlaced(true)

        -- Edit box (Prat or default height offset)
        local offsetY = IsAddOnLoaded("Prat-3.0") and 2 or 6
        local editBox = ChatFrame1EditBox

        for i = 1, 10 do
            local editbox = _G["ChatFrame"..i.."EditBox"]
            if editbox then
                editbox:ClearAllPoints()
                editbox:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, offsetY)
                editbox:SetPoint("BOTTOMRIGHT", anchor, "TOPRIGHT", 0, offsetY)
                editbox:SetHeight(20)
            end
        end
    end
end

local function HideChatButtons()
    for i = 1, NUM_CHAT_WINDOWS do
        local frame = _G["ChatFrame"..i]
        if frame then
            local up = _G[frame:GetName().."ButtonFrameUpButton"]
            local down = _G[frame:GetName().."ButtonFrameDownButton"]
            local bottom = _G[frame:GetName().."ButtonFrameBottomButton"]
            if up then up:Hide() end
            if down then down:Hide() end
            if bottom then bottom:Hide() end
        end
    end
end

---<===========================================================================================================>---<<AUX
SnugUI.loginTrigger(function()
    AnchorChatToAssignedAnchor()
    HideChatButtons()
    table.insert(SnugUI.commitRegistry, AnchorChatToAssignedAnchor)
end)