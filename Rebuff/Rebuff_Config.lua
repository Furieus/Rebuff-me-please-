local addonName = ...

local panel = CreateFrame("Frame")
panel.name = "Rebuff"

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Rebuff")

local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
subtitle:SetText("Configure reminders, sounds, appearance, and placement options.")

local soundHeader = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
soundHeader:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -22)
soundHeader:SetText("Sound")

local soundCheck = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
soundCheck:SetPoint("TOPLEFT", soundHeader, "BOTTOMLEFT", 0, -12)
soundCheck.Text:SetText("Enable sound")

local soundSourceLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
soundSourceLabel:SetPoint("TOPLEFT", soundCheck, "BOTTOMLEFT", 4, -18)
soundSourceLabel:SetText("Sound source")

local soundSourceButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
soundSourceButton:SetPoint("LEFT", soundSourceLabel, "RIGHT", 20, 0)
soundSourceButton:SetSize(140, 22)
soundSourceButton:SetText("Blizzard")

local soundChoiceLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
soundChoiceLabel:SetPoint("TOPLEFT", soundSourceLabel, "BOTTOMLEFT", 0, -18)
soundChoiceLabel:SetText("Selected sound")

local soundChoiceButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
soundChoiceButton:SetPoint("LEFT", soundChoiceLabel, "RIGHT", 20, 0)
soundChoiceButton:SetSize(300, 22)
soundChoiceButton:SetText("RAID_WARNING")

local previewSoundButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
previewSoundButton:SetPoint("TOPLEFT", soundChoiceLabel, "BOTTOMLEFT", -4, -24)
previewSoundButton:SetSize(140, 24)
previewSoundButton:SetText("Preview Sound")

local appearanceHeader = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
appearanceHeader:SetPoint("TOPLEFT", previewSoundButton, "BOTTOMLEFT", 0, -24)
appearanceHeader:SetText("Appearance")

local classColorCheck = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
classColorCheck:SetPoint("TOPLEFT", appearanceHeader, "BOTTOMLEFT", 0, -12)
classColorCheck.Text:SetText("Use class colors")

local themeStyleLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
themeStyleLabel:SetPoint("TOPLEFT", classColorCheck, "BOTTOMLEFT", 4, -18)
themeStyleLabel:SetText("Theme style")

local themeStyleButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
themeStyleButton:SetPoint("LEFT", themeStyleLabel, "RIGHT", 20, 0)
themeStyleButton:SetSize(140, 22)
themeStyleButton:SetText("Rebuff")

local behaviorHeader = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
behaviorHeader:SetPoint("TOPLEFT", themeStyleLabel, "BOTTOMLEFT", 0, -28)
behaviorHeader:SetText("Behavior & Placement")

local debugCheck = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
debugCheck:SetPoint("TOPLEFT", behaviorHeader, "BOTTOMLEFT", 0, -12)
debugCheck.Text:SetText("Enable debug")

local lockCheck = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
lockCheck:SetPoint("TOPLEFT", debugCheck, "BOTTOMLEFT", 0, -12)
lockCheck.Text:SetText("Lock reminder frame")

local infoText = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
infoText:SetPoint("TOPLEFT", lockCheck, "BOTTOMLEFT", 4, -18)
infoText:SetWidth(460)
infoText:SetJustifyH("LEFT")
infoText:SetText("Unlocking closes this config and opens Rebuff placement mode. Use the floating placement popup to scale, reset, and lock it again.")

local resetButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
resetButton:SetPoint("TOPLEFT", infoText, "BOTTOMLEFT", -4, -24)
resetButton:SetSize(140, 24)
resetButton:SetText("Reset Settings")

local previewButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
previewButton:SetPoint("LEFT", resetButton, "RIGHT", 12, 0)
previewButton:SetSize(140, 24)
previewButton:SetText("Show Reminder")

local function GetCurrentSoundList()
    if not RebuffCharDB then
        return {}
    end

    if RebuffCharDB.soundSource == "lsm" then
        if Rebuff and Rebuff.GetSharedMediaSounds then
            return Rebuff.GetSharedMediaSounds()
        end
        return { "None" }
    end

    if Rebuff and Rebuff.GetBlizzardSounds then
        return Rebuff.GetBlizzardSounds()
    end

    return { "RAID_WARNING" }
end

local function GetCurrentSoundValue()
    if not RebuffCharDB then
        return ""
    end

    if RebuffCharDB.soundSource == "lsm" then
        return RebuffCharDB.customSound or "None"
    end

    return RebuffCharDB.blizzardSound or "RAID_WARNING"
end

local function SetCurrentSoundValue(value)
    if not RebuffCharDB then
        return
    end

    if RebuffCharDB.soundSource == "lsm" then
        RebuffCharDB.customSound = value
    else
        RebuffCharDB.blizzardSound = value
    end
end

local function RefreshPreviewButton()
    if Rebuff and Rebuff.IsPreviewActive and Rebuff.IsPreviewActive() then
        previewButton:SetText("Hide Reminder")
    else
        previewButton:SetText("Show Reminder")
    end
end

local function RefreshSoundControls()
    if not RebuffCharDB then
        return
    end

    if RebuffCharDB.soundSource == "lsm" then
        soundSourceButton:SetText("SharedMedia")
    else
        soundSourceButton:SetText("Blizzard")
    end

    soundChoiceButton:SetText(GetCurrentSoundValue())
end

local function RefreshThemeControls()
    if not RebuffCharDB then
        return
    end

    if RebuffCharDB.themeStyle == "tukui" then
        themeStyleButton:SetText("TukUI")
    elseif RebuffCharDB.themeStyle == "elvui" then
        themeStyleButton:SetText("ElvUI")
    else
        themeStyleButton:SetText("Default")
    end
end

local function RefreshPanel()
    if not RebuffCharDB then
        return
    end

    soundCheck:SetChecked(RebuffCharDB.sound)
    debugCheck:SetChecked(RebuffCharDB.debug)
    classColorCheck:SetChecked(RebuffCharDB.useClassColors)
    lockCheck:SetChecked(RebuffCharDB.locked)

    RefreshSoundControls()
    RefreshThemeControls()
    RefreshPreviewButton()
end

soundCheck:SetScript("OnClick", function(self)
    RebuffCharDB.sound = self:GetChecked() and true or false
end)

debugCheck:SetScript("OnClick", function(self)
    RebuffCharDB.debug = self:GetChecked() and true or false
end)

classColorCheck:SetScript("OnClick", function(self)
    RebuffCharDB.useClassColors = self:GetChecked() and true or false
    if Rebuff and Rebuff.ApplyVisualSettings then
        Rebuff.ApplyVisualSettings()
    end
end)

themeStyleButton:SetScript("OnClick", function()
    if not RebuffCharDB then
        return
    end

    if RebuffCharDB.themeStyle == "rebuff" then
        RebuffCharDB.themeStyle = "elvui"
    elseif RebuffCharDB.themeStyle == "elvui" then
        RebuffCharDB.themeStyle = "tukui"
    else
        RebuffCharDB.themeStyle = "rebuff"
    end

    RefreshThemeControls()

    if Rebuff and Rebuff.ApplyVisualSettings then
        Rebuff.ApplyVisualSettings()
    end
end)

lockCheck:SetScript("OnClick", function(self)
    local shouldLock = self:GetChecked() and true or false
    RebuffCharDB.locked = shouldLock

    if shouldLock then
        if Rebuff and Rebuff.ApplyVisualSettings then
            Rebuff.ApplyVisualSettings()
        end
        print("Rebuff: frame locked")
    else
        if Rebuff and Rebuff.EnterPlacementMode then
            Rebuff.EnterPlacementMode()
        end
    end
end)

soundSourceButton:SetScript("OnClick", function()
    if not RebuffCharDB then
        return
    end

    if RebuffCharDB.soundSource == "blizzard" then
        RebuffCharDB.soundSource = "lsm"

        local sounds = GetCurrentSoundList()
        if #sounds > 0 then
            RebuffCharDB.customSound = sounds[1]
        else
            RebuffCharDB.customSound = "None"
        end
    else
        RebuffCharDB.soundSource = "blizzard"
        RebuffCharDB.blizzardSound = RebuffCharDB.blizzardSound or "RAID_WARNING"
    end

    RefreshSoundControls()
end)

soundChoiceButton:SetScript("OnClick", function()
    if not RebuffCharDB then
        return
    end

    local list = GetCurrentSoundList()
    if #list == 0 then
        return
    end

    local current = GetCurrentSoundValue()
    local nextIndex = 1

    for i, value in ipairs(list) do
        if value == current then
            nextIndex = i + 1
            break
        end
    end

    if nextIndex > #list then
        nextIndex = 1
    end

    SetCurrentSoundValue(list[nextIndex])
    RefreshSoundControls()
end)

previewSoundButton:SetScript("OnClick", function()
    if Rebuff and Rebuff.PreviewSound then
        Rebuff.PreviewSound()
    end
end)

resetButton:SetScript("OnClick", function()
    if Rebuff and Rebuff.ResetConfig then
        Rebuff.ResetConfig()
        RefreshPanel()
    end
end)

previewButton:SetScript("OnClick", function()
    if not Rebuff then
        return
    end

    if RebuffCharDB and RebuffCharDB.locked then
        if Rebuff.EnterPlacementMode then
            Rebuff.EnterPlacementMode()
        end
    else
        if Rebuff.TogglePreviewReminder then
            Rebuff.TogglePreviewReminder()
        end
    end

    RefreshPreviewButton()
end)

panel:SetScript("OnShow", RefreshPanel)

local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name, panel.name)
Settings.RegisterAddOnCategory(category)

_G.RebuffConfigCategory = category