local SnugUI = _G.SnugUI

local moduleName = "about"

local function makeSettings()
    SnugUI.api.generateSettingsUI(moduleName, "About", {
        title = "About SnugUI",
        message = "SnugUI is a small, modular UI layer for World of Warcraft. It provides a lightweight settings panel, anchor controls, and a handful of focused UI tweaks designed to integrate cleanly with other addons.",
    })
    SnugUI.api.renderSettings(moduleName)
end

SnugUI.loginTrigger(function()
    makeSettings()
end)