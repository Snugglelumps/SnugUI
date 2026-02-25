local SnugUI = _G.SnugUI
if not SnugUI then return end


local leftOffset = -150

function SnugUI.api.generateSettingsUI(moduleName, buttonText, def, ddwidth)
    -- Create the settings namespace if it doesn't exist
    local function createSettingsNS(moduleName)
        SnugUI.settings[moduleName] = SnugUI.settings[moduleName] or {}
        SnugUI.leftButton.Highlights[moduleName] = SnugUI.leftButton.Highlights[moduleName] or {}
    end
    createSettingsNS(moduleName)

    -- Create the panel for the module
    local function generatePanel(moduleName, buttonText)
        SnugUI.panels[moduleName] = CreateFrame("Frame", nil, SnugUI.frames.rightBG)
        SnugUI.panels[moduleName]:SetAllPoints()
        SnugUI.panels[moduleName]:Hide()

        SnugUI.panels[moduleName].text = SnugUI.panels[moduleName]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        SnugUI.panels[moduleName].text:SetPoint("CENTER")
        print("Generated Panel:", SnugUI.panels[moduleName])
    end
    generatePanel(moduleName, buttonText)

    local function generateTitleandMessage(moduleName, def)
        def = def or {}

        if def.title == nil then def.title = "" end
        if def.message == nil then def.message = "" end

        local panel = SnugUI.panels[moduleName]
        local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", 0, -10)
        title:SetText(def.title)

        local message = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        message:SetPoint("TOP", 0, -40)  -- anchor left side to parent
        message:SetWidth(panel:GetWidth() - 15)
        message:SetJustifyH("CENTER")
        message:SetJustifyV("TOP")
        message:SetWordWrap(true)
        message:SetText(def.message)

        local line = panel:CreateTexture(nil, "ARTWORK")
        line:SetHeight(1)
        line:SetPoint("TOPLEFT", message, "TOPLEFT", 0, -(message:GetStringHeight() + 10))
        line:SetPoint("TOPRIGHT", message, "TOPRIGHT", -10, -(message:GetStringHeight() + 10))
        line:SetTexture("Interface\\Buttons\\WHITE8x8")
        line:SetVertexColor(1, 1, 1, 0.2)

        panel._settingsStartY = -(message:GetStringHeight() + 60)
        -- print("for [" .. moduleName .. "] panel._settingsStartY =", panel._settingsStartY)
    end
    generateTitleandMessage(moduleName, def)

    -- Create the button for the module including show/hide and highlight logic
    local function generateButton(moduleName, buttonText)
        local button = CreateFrame("Button", nil, SnugUI.frames.leftBG)
        button:SetSize(180, 24)
        button:SetPoint("TOPLEFT", 10, leftOffset)

        local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", 5, 0)
        text:SetText(buttonText)

        leftOffset = leftOffset - 20

        -- Highlight wrapper frame and texture
        local highlightFrame = CreateFrame("Frame", nil, button)
        highlightFrame:SetPoint("TOPLEFT", -4, 0)
        highlightFrame:SetPoint("BOTTOMRIGHT", 4, 0)

        local tex = highlightFrame:CreateTexture(nil, "BACKGROUND")
        tex:SetPoint("TOPLEFT", -20, 0)
        tex:SetPoint("BOTTOMRIGHT", 20, 0)
        tex:SetTexture("Interface\\Common\\Search") -- note slashes
        tex:SetTexCoord(0.001953125, 0.248046875, 0.6171875, 0.828125)
        tex:SetAlpha(0.7)

        highlightFrame:Hide()
        SnugUI.leftButton.Highlights[moduleName] = highlightFrame


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

        button:SetScript("OnClick", function()
            showPanel(moduleName)
        end)
    end
    generateButton(moduleName, buttonText)

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

local function layoutXY(moduleName, def)
    local panel = SnugUI.panels[moduleName]
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


local function makeCheckbox(moduleName, key, def)
    local panel = SnugUI.panels[moduleName]
    local x, y = layoutXY(moduleName, def)
    local cb = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    cb:SetPoint("RIGHT", panel, "TOPLEFT", x, y)

    cb.label = cb:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    cb.label:SetPoint("LEFT", cb, "RIGHT", 6, 0)
    cb.label:SetText(def.label or key)

    local v = SnugUI.settings[moduleName][key]
    cb:SetChecked(v)

    cb:SetScript("OnClick", function(self)
        setSetting(moduleName, key, not not self:GetChecked())
        -- print("Applied setting", moduleName, key, not not self:GetChecked())
    end)
    return cb
end

local function makeText(moduleName, key, def)
    local panel = SnugUI.panels[moduleName]
    local label = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    local x, y = layoutXY(moduleName, def)
    label:SetText(def.label or key)

    local eb = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    eb:SetSize(def.width or 220, 20)
    eb:SetPoint("CENTER", label, "BOTTOMLEFT", 0, -6)
    eb:SetAutoFocus(false)
    eb:SetText(tostring(getSetting(moduleName, key) or def.default or ""))

    eb:SetScript("OnEnterPressed", function(self)
        setSetting(moduleName, key, self:GetText())
        self:ClearFocus()
    end)
end

local function makeSlider(moduleName, key, def)
    local panel = SnugUI.panels[moduleName]
    local s = CreateFrame("Slider", nil, panel, "OptionsSliderTemplate")
    s:SetScript("OnValueChanged", function(_, v)
        setSetting(moduleName, key, v)
        s.Text:SetText(key .. " " .. string.format("%.2f", v))
    end)

    local yOff = 25
    local x, y = layoutXY(moduleName, def)
    s:SetPoint("CENTER", panel, "TOPLEFT", x, y - yOff)
    s:SetWidth(def.width or 140)
    s:SetMinMaxValues(def.min or 0, def.max or 100)
    s:SetValueStep(def.step or 1)
    s.Low:SetText(def.min_label or "")
    s.High:SetText(def.max_label or "")
    -- s.Text:SetText([key] ... SnugUI.settings[module][key])

    local v = tonumber(getSetting(moduleName, key)) or def.default or def.min or 0
    s:SetValue(v) -- will call your handler once; you can delete the explicit setSetting below if you want
    s:SetScript("OnValueChanged", function(self, v)
        setSetting(moduleName, key, v)
        self.Text:SetText(key .. " " .. string.format("%.2f", v))

        if def.updateFunc then
            def.updateFunc(moduleName, key, v, self)
        end
    end)
end

local function makeDropdown(moduleName, key, def)
    local panel = SnugUI.panels[moduleName]
    local label = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    local name = "SnugUI_DD_" .. moduleName .. "_" .. key
    local dd = CreateFrame("Frame", name, panel, "UIDropDownMenuTemplate")

    local x, y = layoutXY(moduleName, def)
    local width = def.layout.width or 40

    label:SetText(def.label or key)
    label:SetPoint("CENTER", panel, "TOPLEFT", x, y + 10)

    dd:SetWidth(width)
    dd:SetPoint("CENTER", panel, "TOPLEFT", x, y -20)


    if def.layout and def.layout.width then UIDropDownMenu_SetWidth(dd, def.layout.width) end

    local function apply(value, text)
        setSetting(moduleName, key, value)
        UIDropDownMenu_SetSelectedValue(dd, value)
        UIDropDownMenu_SetText(dd, text or "")
        -- print("Applied setting", moduleName, key, value)
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

local function makeRadio(moduleName, key, def)
    local panel = SnugUI.panels[moduleName]
    local label = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    local x, y = layoutXY(moduleName, def)
    label:SetPoint("TOPLEFT", x, y)
    label:SetText(def.label or key)

    local cur = getSetting(moduleName, key)
    if cur == nil then cur = def.default end

    --local y = -6
    for i, opt in ipairs(def.options or {}) do
        local rb = CreateFrame("CheckButton", nil, panel, "UIRadioButtonTemplate")
        rb:SetPoint("RIGHT", panel, "TOPLEFT", x, y)
        y = y - 18

        rb.text = rb:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        rb.text:SetPoint("LEFT", rb, "RIGHT", 6, 0)
        rb.text:SetText(opt.text or tostring(opt.value))

        rb:SetChecked(cur == opt.value)

        rb:SetScript("OnClick", function(self)
            -- set selected value
            setSetting(moduleName, key, opt.value)

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

local WIDGET = {
    checkbox = makeCheckbox,
    text = makeText,
    slider = makeSlider,
    dropdown = makeDropdown,
    radio = makeRadio,
}

function SnugUI.api.renderSettings(moduleName)
    local panel = SnugUI.panels[moduleName]
    if not panel then return end
    panel._y = nil

    local defs = SnugUI.settingDefs[moduleName]
    if not defs then return end

    -- build a temporary list of keys
    local keys = {}
    for k in pairs(defs) do
        keys[#keys + 1] = k
    end

    -- sort keys by def.layout.order (higher first)
    table.sort(keys, function(a, b)
        local da, db = defs[a], defs[b]
        return ((da.layout and da.layout.order) or 0) >
               ((db.layout and db.layout.order) or 0)
    end)

    -- render in sorted order
    for key, def in pairs(defs) do
        local f = WIDGET[def._type]
        if f then
            f(moduleName, key, def)
        end
    end
end

local function testframe()
    local panel = SnugUI.panels.minimap
    print("panel:", panel)
    print("panel shown/visible:", panel:IsShown(), panel:IsVisible(), "alpha:", panel:GetEffectiveAlpha())

    local x = {
        472 * .2,
        472 * .5,
        472 * .8,
    }
    local y = 0
    for _, i in ipairs(x) do
        local f = CreateFrame("Frame", nil, panel)
        f:SetSize(2, 400)
        f:SetPoint("TOPLEFT", panel, "TOPLEFT", i, y)

        f:SetFrameStrata("HIGH")
        f:SetFrameLevel(100)

        local tex = f:CreateTexture(nil, "OVERLAY")
        tex:SetAllPoints()
        tex:SetColorTexture(1, 0, 0, 1)
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")

f:SetScript("OnEvent", function()
    local t = 0
    f:SetScript("OnUpdate", function(self, e)
        t = t + e
        if t >= 1 then
            self:SetScript("OnUpdate", nil)
            testframe()
        end
    end)
end)