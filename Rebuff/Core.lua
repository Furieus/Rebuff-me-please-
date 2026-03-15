local addonName, Rebuff = ...

Rebuff = Rebuff or {}
_G.Rebuff = Rebuff

Rebuff.addonName = addonName

Rebuff.CHECK_INTERVAL = 3
Rebuff.REMINDER_THROTTLE = 12
Rebuff.MESSAGE_HIDE_DELAY = 5
Rebuff.SCALE_MIN = 0.50
Rebuff.SCALE_MAX = 2.50
Rebuff.SCALE_STEP = 0.05

Rebuff.lastMessage = ""
Rebuff.lastMessageTime = 0
Rebuff.tickerStarted = false

Rebuff.defaultsGlobal = {
}

Rebuff.defaultsChar = {
    enabled = true,
    locked = true,
    debug = false,
    scale = 1.0,

    point = "CENTER",
    relativePoint = "CENTER",
    x = 0,
    y = 140,

    popupPoint = "CENTER",
    popupRelativePoint = "CENTER",
    popupX = 0,
    popupY = -120,

    soundEnabled = true,
    soundSource = "Blizzard",
    soundKit = "RaidWarning",

    themeStyle = "rebuff",
    useClassColors = false,

    enableSolo = true,
}

local frame = CreateFrame("Frame")
Rebuff.frame = frame

local function CopyDefaults(src, dst)
    if type(src) ~= "table" or type(dst) ~= "table" then
        return
    end

    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = dst[k] or {}
            CopyDefaults(v, dst[k])
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
end

function Rebuff.Debug(msg)
    if RebuffCharDB and RebuffCharDB.debug then
        print("|cffffcc00Rebuff Debug:|r " .. tostring(msg))
    end
end

function Rebuff.ClampScale(scale)
    if not scale then
        return 1.0
    end

    if scale < Rebuff.SCALE_MIN then
        return Rebuff.SCALE_MIN
    end

    if scale > Rebuff.SCALE_MAX then
        return Rebuff.SCALE_MAX
    end

    return scale
end

function Rebuff.OpenConfig()
    if Rebuff.ShowConfig then
        Rebuff.ShowConfig()
        return
    end

    if Settings and Settings.OpenToCategory and Rebuff.optionsCategoryID then
        Settings.OpenToCategory(Rebuff.optionsCategoryID)
        Settings.OpenToCategory(Rebuff.optionsCategoryID)
    end
end

function Rebuff.CloseConfig()
    if HideUIPanel and SettingsPanel and SettingsPanel:IsShown() then
        HideUIPanel(SettingsPanel)
    end
end

function Rebuff.PlayReminderSound()
    if not RebuffCharDB or not RebuffCharDB.soundEnabled then
        return
    end

    if Rebuff.PlayConfiguredSound then
        Rebuff.PlayConfiguredSound()
        return
    end

    if PlaySound then
        PlaySound(SOUNDKIT.RAID_WARNING, "Master")
    end
end

function Rebuff.RunChecks()
    if not RebuffCharDB or not RebuffCharDB.enabled then
        if Rebuff.ResetReminderState then
            Rebuff.ResetReminderState()
        end
        return
    end

    if InCombatLockdown() then
        return
    end

    if Rebuff.CheckPetState then
        local petSpellID, petMessage = Rebuff.CheckPetState()
        if petSpellID and petMessage then
            local now = GetTime()

            if petMessage ~= Rebuff.lastMessage then
                Rebuff.lastMessage = petMessage
                Rebuff.lastMessageTime = now
                Rebuff.PlayReminderSound()

                if Rebuff.ShowReminderFrame then
                    Rebuff.ShowReminderFrame(petSpellID, petMessage)
                end
            elseif (now - Rebuff.lastMessageTime) >= Rebuff.REMINDER_THROTTLE then
                Rebuff.lastMessageTime = now
                Rebuff.PlayReminderSound()

                if Rebuff.ShowReminderFrame then
                    Rebuff.ShowReminderFrame(petSpellID, petMessage)
                end
            end

            return
        end
    end

    if Rebuff.CheckBuffs then
        Rebuff.CheckBuffs()
    end
end

function Rebuff.CheckNow()
    Rebuff.RunChecks()
end

function Rebuff.StartTicker()
    if Rebuff.tickerStarted then
        return
    end

    Rebuff.tickerStarted = true

    C_Timer.NewTicker(Rebuff.CHECK_INTERVAL, function()
        Rebuff.RunChecks()
    end)
end

SLASH_REBUFF1 = "/rebuff"
SlashCmdList["REBUFF"] = function(msg)
    msg = msg and msg:lower():match("^%s*(.-)%s*$") or ""

    if msg == "" then
        Rebuff.OpenConfig()
        return
    end

    if msg == "check" then
        Rebuff.CheckNow()
        return
    end

    if msg == "lock" then
        if Rebuff.LockPlacement then
            Rebuff.LockPlacement()
        end
        return
    end

    if msg == "unlock" then
        if Rebuff.EnterPlacementMode then
            Rebuff.EnterPlacementMode()
        end
        return
    end

    print("|cffffcc00Rebuff commands:|r")
    print("/rebuff")
    print("/rebuff check")
    print("/rebuff lock")
    print("/rebuff unlock")
end

frame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...

        if loadedAddon ~= addonName then
            return
        end

        RebuffDB = RebuffDB or {}
        RebuffCharDB = RebuffCharDB or {}

        CopyDefaults(Rebuff.defaultsGlobal, RebuffDB)
        CopyDefaults(Rebuff.defaultsChar, RebuffCharDB)

        local _, class = UnitClass("player")
        Rebuff.playerClass = class

        if Rebuff.BuildReminderFrame then
            Rebuff.BuildReminderFrame()
        end

        if Rebuff.BuildPlacementPopup then
            Rebuff.BuildPlacementPopup()
        end

        if Rebuff.ApplyVisualSettings then
            Rebuff.ApplyVisualSettings()
        end

        if Rebuff.SetupConfig then
            Rebuff.SetupConfig()
        end

        Rebuff.StartTicker()
        Rebuff.Debug("Initialized")
    elseif event == "PLAYER_ENTERING_WORLD" then
        Rebuff.RunChecks()
    elseif event == "GROUP_ROSTER_UPDATE" then
        Rebuff.RunChecks()
    elseif event == "UNIT_AURA" then
        local unit = ...
        if unit == "player" or unit == "pet" or unit == "party1" or unit == "party2" or unit == "party3" or unit == "party4" then
            Rebuff.RunChecks()
        end
    elseif event == "UNIT_PET" then
        local unit = ...
        if unit == "player" then
            Rebuff.RunChecks()
        end
    end
end)

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("UNIT_AURA")
frame:RegisterEvent("UNIT_PET")