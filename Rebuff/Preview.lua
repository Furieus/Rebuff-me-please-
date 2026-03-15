local previewIcons = {
    { spellID = 1126 },   -- Mark of the Wild
    { spellID = 1459 },   -- Arcane Intellect
    { spellID = 21562 },  -- Fortitude
    { spellID = 6673 },   -- Battle Shout
    { spellID = 462854 }, -- Skyfury
}

local previewMessages = {
    "Rebuff check: Somebody forgot something important.",
    "Reminder: Buffs are looking suspiciously absent.",
    "Production-quality panic: Rebuff frame preview active.",
    "Somebody skipped the buffs. We are judging silently.",
    "Rebuff preview: This is only a test. Probably.",
}

local previewIndex = 1
local fallbackPreviewIndex = 1

local function GetNextPreviewMessage()
    Rebuff.previewMessage = previewMessages[previewIndex]
    previewIndex = previewIndex + 1

    if previewIndex > #previewMessages then
        previewIndex = 1
    end

    return Rebuff.previewMessage
end

local function GetPlayerPreviewEntry()
    local classData = Rebuff.CLASS_BUFFS and Rebuff.CLASS_BUFFS[Rebuff.playerClass]
    if not classData or not classData.spellID then
        return nil
    end

    local spellName = Rebuff.GetSpellName and Rebuff.GetSpellName(classData.spellID)
    if not spellName then
        spellName = "Tracked Buff"
    end

    return {
        spellID = classData.spellID,
        texture = Rebuff.GetDisplayIcon and Rebuff.GetDisplayIcon(classData.spellID)
            or (Rebuff.GetSpellIcon and Rebuff.GetSpellIcon(classData.spellID))
            or nil,
        message = string.format("Cast %s - missing on: You, Party1", spellName),
    }
end

local function GetNextFallbackPreviewEntry()
    local entry = previewIcons[fallbackPreviewIndex]
    if not entry then
        return nil
    end

    fallbackPreviewIndex = fallbackPreviewIndex + 1
    if fallbackPreviewIndex > #previewIcons then
        fallbackPreviewIndex = 1
    end

    return {
        spellID = entry.spellID,
        texture = Rebuff.GetDisplayIcon and Rebuff.GetDisplayIcon(entry.spellID)
            or (Rebuff.GetSpellIcon and Rebuff.GetSpellIcon(entry.spellID))
            or nil,
        message = GetNextPreviewMessage(),
    }
end

local function GetNextPreviewEntry()
    local playerEntry = GetPlayerPreviewEntry()
    if playerEntry then
        playerEntry.message = GetNextPreviewMessage()
        return playerEntry
    end

    return GetNextFallbackPreviewEntry()
end

Rebuff.previewSpellID = previewIcons[1].spellID
Rebuff.previewTexture = Rebuff.GetDisplayIcon and Rebuff.GetDisplayIcon(Rebuff.previewSpellID)
    or (Rebuff.GetSpellIcon and Rebuff.GetSpellIcon(Rebuff.previewSpellID))
    or nil
Rebuff.previewMessage = previewMessages[1]
Rebuff.previewActive = Rebuff.previewActive or false

function Rebuff.IsPreviewActive()
    return Rebuff.previewActive
end

function Rebuff.ShowPreviewReminder()
    Rebuff.previewActive = true

    if Rebuff.hideTimer then
        Rebuff.hideTimer:Cancel()
        Rebuff.hideTimer = nil
    end

    local entry = GetNextPreviewEntry()
    if not entry then
        return
    end

    Rebuff.previewSpellID = entry.spellID
    Rebuff.previewTexture = entry.texture
    Rebuff.previewMessage = entry.message

    if Rebuff.PlayReminderSound then
        Rebuff.PlayReminderSound()
    end

    if Rebuff.ShowReminderFrame then
        Rebuff.ShowReminderFrame(Rebuff.previewSpellID, Rebuff.previewMessage, Rebuff.previewTexture)
    end

    if Rebuff.ShowPlacementPopup then
        Rebuff.ShowPlacementPopup()
    end

    print("|cffffcc00Rebuff:|r preview reminder shown")
end

function Rebuff.HidePreviewReminder()
    Rebuff.previewActive = false

    if Rebuff.hideTimer then
        Rebuff.hideTimer:Cancel()
        Rebuff.hideTimer = nil
    end

    if Rebuff.reminderFrame and RebuffCharDB and RebuffCharDB.locked then
        Rebuff.reminderFrame:Hide()
    elseif Rebuff.reminderFrame then
        Rebuff.reminderFrame:Show()
    end

    if Rebuff.ShowPlacementPopup then
        Rebuff.ShowPlacementPopup()
    end

    print("|cffffcc00Rebuff:|r preview reminder hidden")
end

function Rebuff.TogglePreviewReminder()
    if Rebuff.previewActive then
        Rebuff.HidePreviewReminder()
    else
        Rebuff.ShowPreviewReminder()
    end
end