local _, SnugUI = ...

local function GetAnchorTarget()
    local anchors = SnugUI.settings.anchors
    if not anchors then return nil end

    if (anchors.leftAssignment == "Details!" and SnugUI.frames.leftAnchor) then
        return SnugUI.frames.leftAnchor
    elseif (anchors.rightAssignment == "Details!" and SnugUI.frames.rightAnchor) then
        return SnugUI.frames.rightAnchor
    end

    return nil
end

local function AnchorDetailsToAssignedAnchor()
    if not Details or not Details.GetInstance then return end
    local instance = Details:GetInstance(1)
    if not (instance and instance.baseframe) then return end

    local targetAnchor = GetAnchorTarget()
    if not targetAnchor then return end

    local frame = instance.baseframe
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", targetAnchor, "TOPLEFT", 1, -1)
    frame:SetPoint("BOTTOMRIGHT", targetAnchor, "BOTTOMRIGHT", -1, 1)
    if instance then
        instance:LockInstance(true)
    end
end

---<===========================================================================================================>---<<AUX
SnugUI.loginTrigger(function()
    -- Initialization
    AnchorDetailsToAssignedAnchor()

    -- Hooks
    local anchor = GetAnchorTarget()
    if anchor and not anchor.care then
        anchor:HookScript("OnSizeChanged", AnchorDetailsToAssignedAnchor)
        anchor.care = true
    end
    -- Commit Registry
    table.insert(SnugUI.commitRegistry, AnchorDetailsToAssignedAnchor)
end)