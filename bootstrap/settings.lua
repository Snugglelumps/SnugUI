local SnugUI = _G.SnugUI
if not SnugUI then return end

local leftButtons = {}

local function LayoutLeftButtons()
    local prev = nil

    for _, button in ipairs(leftButtons) do
        if button:IsShown() then
            button:ClearAllPoints()

            if prev then
                button:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -4)
            else
                button:SetPoint("TOPLEFT", SnugUI.frames.leftBG, "TOPLEFT", 10, -10)
            end

            prev = button
        end
    end
end

local function maybeReloadWarning(def)
    if def and def.reloadWarning then
        if SnugUI.functions and SnugUI.functions.reloadUIRequest then
            SnugUI.functions.reloadUIRequest()
        end
    end
end

function SnugUI.api.generateSettingsUI(moduleName, buttonText, def, ddwidth)
    -- Create the settings namespace if it doesn't exist
    local function createSettingsNS(moduleName)
        SnugUI.settings[moduleName] = SnugUI.settings[moduleName] or {}
        SnugUI.leftButton.Highlights[moduleName] = SnugUI.leftButton.Highlights[moduleName] or {}
    end
    createSettingsNS(moduleName)

    -- Show/hide panels + highlights by ID (main or sub ID)
    local function showPanel(moduleName)
        local panel = SnugUI.panels[moduleName]
        local highlight = SnugUI.leftButton.Highlights[moduleName]
        for _, p in pairs(SnugUI.panels) do
            p:Hide()
        end
        for _, h in pairs(SnugUI.leftButton.Highlights) do
            h:Hide()
        end
        if panel then panel:Show() end
        if highlight then highlight:Show() end
    end

    -- Create the panel for the module (or sub)
    local function generatePanel(moduleName, titleDef)
        SnugUI.panels[moduleName] = CreateFrame("Frame", nil, SnugUI.frames.rightBG)
        SnugUI.panels[moduleName]:SetAllPoints()
        SnugUI.panels[moduleName]:Hide()

        SnugUI.panels[moduleName].text = SnugUI.panels[moduleName]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        SnugUI.panels[moduleName].text:SetPoint("CENTER")

        -- Title/message (using your existing function)
        titleDef = titleDef or {}
        if titleDef.title == nil then titleDef.title = "" end
        if titleDef.message == nil then titleDef.message = "" end

        local panel = SnugUI.panels[moduleName]
        local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", 0, -10)
        title:SetText(titleDef.title)

        local message = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        message:SetPoint("TOP", 0, -40)
        message:SetWidth(panel:GetWidth() - 15)
        message:SetJustifyH("CENTER")
        message:SetJustifyV("TOP")
        message:SetWordWrap(true)
        message:SetText(titleDef.message)

        local line = panel:CreateTexture(nil, "ARTWORK")
        line:SetHeight(1)
        line:SetPoint("TOPLEFT", message, "TOPLEFT", 0, -(message:GetStringHeight() + 10))
        line:SetPoint("TOPRIGHT", message, "TOPRIGHT", -10, -(message:GetStringHeight() + 10))
        line:SetTexture("Interface\\Buttons\\WHITE8x8")
        line:SetVertexColor(1, 1, 1, 0.2)

        panel._settingsStartY = -(message:GetStringHeight() + 60)
    end

    -- Create MAIN panel
    def = def or {}
    generatePanel(moduleName, def)

    -- Create a button (main or sub). Returns the created button.
    local function generateButton(moduleName, textLabel, opts)
        opts = opts or {}

        local button = CreateFrame("Button", nil, SnugUI.frames.leftBG)
        button:SetSize(180, 24)

        local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", (opts.indent or 5), 0)
        text:SetText(textLabel)

        -- Highlight wrapper frame and texture
        local highlightFrame = CreateFrame("Frame", nil, button)
        highlightFrame:SetPoint("TOPLEFT", -4, 0)
        highlightFrame:SetPoint("BOTTOMRIGHT", 4, 0)

        local tex = highlightFrame:CreateTexture(nil, "BACKGROUND")
        tex:SetPoint("TOPLEFT", -20, 0)
        tex:SetPoint("BOTTOMRIGHT", 20, 0)
        tex:SetTexture("Interface\\Common\\Search")
        tex:SetTexCoord(0.001953125, 0.248046875, 0.6171875, 0.828125)
        tex:SetAlpha(0.7)

        highlightFrame:Hide()
        SnugUI.leftButton.Highlights[moduleName] = highlightFrame

        table.insert(leftButtons, button)

        if opts.startHidden then
            button:Hide()
        end

        -- default click: show that panel
        button:SetScript("OnClick", function()
            showPanel(moduleName)
            LayoutLeftButtons()
        end)

        return button
    end

    -- MAIN button
    local mainButton = generateButton(moduleName, buttonText)

    -- SUB BUTTONS (simple list)
    if def.subButtons and type(def.subButtons) == "table" then
        mainButton._subButtons = mainButton._subButtons or {}

        for i, sub in ipairs(def.subButtons) do
            local subId = moduleName .. "::" .. sub.id

            generatePanel(subId, { title = sub.title, message = sub.message })

            -- create the sub-button (hidden, indented)
            local subBtn = generateButton(subId, tostring(sub.title), {
                startHidden = true,
                indent = 18, -- you can tweak this; this is the "positioned differently" part
            })

            table.insert(mainButton._subButtons, subBtn)
        end

        -- Parent click: toggle expansion AND show parent panel
        mainButton._expanded = false
        mainButton:SetScript("OnClick", function()
            mainButton._expanded = not mainButton._expanded

            for _, b in ipairs(mainButton._subButtons) do
                b:SetShown(mainButton._expanded)
            end

            showPanel(moduleName)
            LayoutLeftButtons()
        end)
    end
    LayoutLeftButtons()
end

local function makeProfileExport(moduleName, key, def, panel)
    -- prevent double-build if renderSettings gets called again
    if panel.__SnugUI_DetailsExportBuilt then return end
    panel.__SnugUI_DetailsExportBuilt = true

    local scrollFrame = CreateFrame("ScrollFrame", "SnugUIDetailsExportScroll", panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 16, -68)
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
    exportBox:SetFontObject(GameFontHighlightSmall)
    exportBox:SetWidth(400)
    exportBox:SetAutoFocus(false)
    exportBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    exportBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    exportBox:SetScript("OnTextChanged", function()
        scrollFrame:UpdateScrollChildRect()
    end)

    scrollFrame:SetScrollChild(exportBox)

    local function setDetailsExportBox()
        exportBox:SetText(def.exportString or "No export data found.")
        scrollFrame:UpdateScrollChildRect()
    end

    -- refresh when the panel is shown (so it’s always current)
    panel:HookScript("OnShow", setDetailsExportBox)

    -- optional: set once immediately (covers the case panel is already visible)
    setDetailsExportBox()
end


function SnugUI.api.addSetting(moduleName, key, settingType, def)
    -- def = {
    --     default = any,
    --     label = string,        -- optional
    --     options = {...},       -- dropdown only
    --     min = number,          -- slider only
    --     max = number,          -- slider only
    --     step = number,         -- slider only
    -- }

    def = def or {}
    def._type = settingType

    SnugUI.settings[moduleName] = SnugUI.settings[moduleName] or {}
    SnugUI.settings.defaults[moduleName] = SnugUI.settings.defaults[moduleName] or {}

    -- 1) store default in defaults table
    if def and def.default ~= nil then
        SnugUI.settings.defaults[moduleName][key] = def.default
    end

    -- 2) apply default into saved settings if missing
    if SnugUI.settings[moduleName][key] == nil and def and def.default ~= nil then 
        SnugUI.settings[moduleName][key] = def.default
    end

    SnugUI.settingDefs[moduleName] = SnugUI.settingDefs[moduleName] or {}
    SnugUI.settingDefs[moduleName][key] = def
end

local function getSetting(module, key)
    return SnugUI.settings[module] and SnugUI.settings[module][key]
end

local function setSetting(module, key, value)
    SnugUI.settings[module][key] = value
end

local function layoutXY(moduleName, def, panel)
    def = def or {}
    local layout = def.layout or {}

    local startY = (panel._settingsStartY - 15) or 0

    -- rows: fixed pitch
    local row = layout.row or 1
    local rowPitch = layout.rowPitch or 70  -- global-ish default; tweak once
    local y = startY - ((row - 1) * rowPitch) + (layout.yOff or 0)

    -- columns: fractions of usable width
    local padL = layout.padL or 0
    local padR = layout.padR or 0
    local w = panel:GetWidth() - padL - padR

    -- choose one of the guide lines: 1/3, 1/2, 2/3
    local col = layout.col or 1
    local dec
    if col == 1 then dec = .25
    elseif col == 2 then dec = .5
    elseif col == 3 then dec = .75
    else dec = 0 end  -- allow col=0 meaning "left edge"
    local x = padL + (w * dec) + (layout.xOff or 0)

    return x, y
end


local function makeCheckbox(moduleName, key, def, panel)
    local label = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    local checkbox = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")

    local x, y = layoutXY(moduleName, def, panel)
    local v = SnugUI.settings[moduleName][key]

    label:SetPoint("LEFT", panel, "TOPLEFT", x, y)
    label:SetText(def.label or key)

    checkbox:SetPoint("RIGHT", panel, "TOPLEFT", x, y)
    checkbox:SetChecked(v)
    checkbox:SetScript("OnClick", function(self)
        setSetting(moduleName, key, not not self:GetChecked())
        maybeReloadWarning(def)
    end)
end

local function makeText(moduleName, key, def, panel)
    local label = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    local x, y = layoutXY(moduleName, def, panel)
    label:SetText(def.label or key)

    local eb = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    eb:SetSize(def.width or 220, 20)
    eb:SetPoint("CENTER", label, "BOTTOMLEFT", 0, -6)
    eb:SetAutoFocus(false)
    eb:SetText(tostring(getSetting(moduleName, key) or def.default or ""))

    eb:SetScript("OnEnterPressed", function(self)
        setSetting(moduleName, key, self:GetText())
        maybeReloadWarning(def)
        self:ClearFocus()
    end)
end

local function makeSlider(moduleName, key, def, panel)
    local label = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    local slider = CreateFrame("Slider", nil, panel, "OptionsSliderTemplate")

    local x, y = layoutXY(moduleName, def, panel)
    local v = tonumber(getSetting(moduleName, key)) or def.default or def.min or 0

    label:SetText("Scale: " .. string.format("%.2f", v))
    label:SetPoint("CENTER", panel, "TOPLEFT", x, y + 10)

    slider:SetPoint("CENTER", panel, "TOPLEFT", x, y - 15)
    slider:SetWidth(def.width or 140)
    slider:SetMinMaxValues(def.min or 0, def.max or 100)
    slider:SetValueStep(def.step or 1)
    slider.Low:SetText(def.min_label or "")
    slider.High:SetText(def.max_label or "")

    slider:SetScript("OnValueChanged", function(_, v)
        setSetting(moduleName, key, v)
        maybeReloadWarning(def)
        label:SetText("Scale: " .. string.format("%.2f", v))
        if def.updateFunc then
            def.updateFunc(moduleName, key, v, slider)
        end
    end)

    slider:SetValue(v) -- must be after OnValueChanged to initialize label text
end

local function makeDropdown(moduleName, key, def, panel)
    local label = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    local name = "SnugUI_DD_" .. moduleName .. "_" .. key
    local dd = CreateFrame("Frame", name, panel, "UIDropDownMenuTemplate")

    local x, y = layoutXY(moduleName, def, panel)
    local width = def.layout.width or 40

    label:SetText(def.label or key)
    label:SetPoint("CENTER", panel, "TOPLEFT", x, y + 10)

    dd:SetWidth(width)
    dd:SetPoint("CENTER", panel, "TOPLEFT", x, y -20)


    if def.layout and def.layout.width then UIDropDownMenu_SetWidth(dd, def.layout.width) end

    local function apply(value, text)
        setSetting(moduleName, key, value)
        maybeReloadWarning(def)
        UIDropDownMenu_SetSelectedValue(dd, value)
        UIDropDownMenu_SetText(dd, text or "")
    end

    UIDropDownMenu_Initialize(dd, function(_, level)
        local cur = getSetting(moduleName, key)
        for _, opt in ipairs(def.options) do
            local info = UIDropDownMenu_CreateInfo()
            info.text, info.value = opt.text, opt.value
            info.checked = (cur == opt.value)
            info.func = function(btn) apply(btn.value, opt.text) end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    local v = getSetting(moduleName, key)
    if v == nil then v = def.default end

    local t
    for _, opt in ipairs(def.options) do
        if opt.value == v then t = opt.text; break end
    end
    apply(v, t)

    return dd
end

local function makeRadio(moduleName, key, def, panel)
    local label = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    local x, y = layoutXY(moduleName, def, panel)

    label:SetPoint("TOPLEFT", panel, "TOPLEFT", x , y + 5)
    label:SetText(def.label or key)

    local cur = getSetting(moduleName, key)
    if cur == nil then cur = def.default end

    --local y = -6
    for i, opt in ipairs(def.options or {}) do
        local rb = CreateFrame("CheckButton", nil, panel, "UIRadioButtonTemplate")
        rb:SetPoint("RIGHT", panel, "TOPLEFT", x -3, y - 20)
        y = y - 18  

        rb.text = rb:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        rb.text:SetPoint("LEFT", rb, "RIGHT", 6, 0)
        rb.text:SetText(opt.text or tostring(opt.value))

        rb:SetChecked(cur == opt.value)

        rb:SetScript("OnClick", function(self)
            -- set selected value
            setSetting(moduleName, key, opt.value)
            maybeReloadWarning(def)
            -- uncheck siblings (we can just re-sync all radios by walking options)
            -- simplest: re-render check state for radios we created
            for j = 1, #def.options do
                local other = def._radioButtons and def._radioButtons[j]
                if other then other:SetChecked(j == i) end
            end

            if def.updateFunc then
                def.updateFunc(moduleName, key, opt.value, self)
            end
        end)

        def._radioButtons = def._radioButtons or {}
        def._radioButtons[i] = rb
    end
end

local function makeEditBox(moduleName, key, def, panel)
    local label = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    local eb = CreateFrame("EditBox", moduleName .. key, panel, "InputBoxTemplate")
    local x, y = layoutXY(moduleName, def, panel)


    label:SetPoint("LEFT", panel, "TOPLEFT", x, y)
    label:SetText(def.label or key)

    eb:SetAutoFocus(false)
    eb:SetSize(def.layout.width or 220, 20)
    eb:SetPoint("RIGHT", panel, "TOPLEFT", x - 6, y)

    if def.maxLetters then eb:SetMaxLetters(def.maxLetters) end

    local vt = def.valueType or "string"
    if vt ~= "string" then eb:SetNumeric(true) end

    local function sync()
        local v = getSetting(moduleName, key)
        if v == nil then v = def.default end
        eb:SetText(v ~= nil and tostring(v) or "")
    end
    sync()

    local function commit()
        local t = eb:GetText() or ""
        if vt == "string" then
            if def.trim then t = t:match("^%s*(.-)%s*$") end
            setSetting(moduleName, key, t)
            maybeReloadWarning(def)
            return
        end

        local n = tonumber(t)
        if not n then return sync() end
        if vt == "int" then n = math.floor(n) end
        setSetting(moduleName, key, n)
        maybeReloadWarning(def)
    end

    eb:SetScript("OnTextChanged", function(self) commit(); self:ClearFocus() end)
    eb:SetScript("OnEscapePressed", function(self) sync(); self:ClearFocus() end)
end

local WIDGET = {
    checkbox = makeCheckbox,
    text = makeText,
    slider = makeSlider,
    dropdown = makeDropdown,
    radio = makeRadio,
    editbox = makeEditBox,
    profileExport = makeProfileExport,
}

function SnugUI.api.renderSettings(moduleName)
    local defs = SnugUI.settingDefs[moduleName]
    if not defs then return end

    local reset = {} -- panelId -> true

    for key, def in pairs(defs) do
        local f = WIDGET[def._type]
        if f then
            local panelId = moduleName
            if def.panel then
                panelId = moduleName .. "::" .. def.panel
            end

            local panel = SnugUI.panels[panelId]
            if panel then
                if not reset[panelId] then
                    panel._y = nil
                    reset[panelId] = true
                end
                f(moduleName, key, def, panel)
            end
        end
    end
end

-- local function testframe()
--     local panel = SnugUI.panels.minimap


--     local x = {
--         472 * .25,
--         472 * .5,
--         472 * .75,
--     }
--     local y = 0
--     for _, i in ipairs(x) do
--         local f = CreateFrame("Frame", nil, panel)
--         f:SetSize(2, 400)
--         f:SetPoint("TOPLEFT", panel, "TOPLEFT", i, y)

--         f:SetFrameStrata("HIGH")
--         f:SetFrameLevel(100)

--         local tex = f:CreateTexture(nil, "OVERLAY")
--         tex:SetAllPoints()
--         tex:SetColorTexture(1, 0, 0, 1)
--     end
-- end

-- local f = CreateFrame("Frame")
-- f:RegisterEvent("PLAYER_LOGIN")

-- f:SetScript("OnEvent", function()
--     local t = 0
--     f:SetScript("OnUpdate", function(self, e)
--         t = t + e
--         if t >= 1 then
--             self:SetScript("OnUpdate", nil)
--             testframe()
--         end
--     end)
-- end)