local addonName = ...

Rebuff = Rebuff or {}
Rebuff.addonName = addonName
Rebuff.frame = CreateFrame("Frame")

Rebuff.CHECK_INTERVAL = 3
Rebuff.REMINDER_THROTTLE = 12
Rebuff.MESSAGE_HIDE_DELAY = 5
Rebuff.SCALE_STEP = 0.05
Rebuff.SCALE_MIN = 0.50
Rebuff.SCALE_MAX = 2.50

Rebuff.playerClass = select(2, UnitClass("player"))
Rebuff.lastMessage = ""
Rebuff.lastMessageTime = 0
Rebuff.tickerStarted = false
Rebuff.hideTimer = nil

Rebuff.defaultsGlobal = {}

Rebuff.defaultsChar = {
    point = "CENTER",
    relativePoint = "CENTER",
    x = 0,
    y = 180,
    scale = 1.0,
    locked = true,
    sound = true,
    debug = false,
    useClassColors = false,
    themeStyle = "rebuff",

    popupPoint = "CENTER",
    popupRelativePoint = "CENTER",
    popupX = 0,
    popupY = -220,

    soundSource = "blizzard",
    blizzardSound = "RAID_WARNING",
    customSound = "None",
}

Rebuff.LSM = LibStub and LibStub("LibSharedMedia-3.0", true)

local function CopyDefaults(src, dst)
    if not src then
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

function Rebuff.EnsureDB()
    RebuffDB = RebuffDB or {}
    RebuffCharDB = RebuffCharDB or {}

    CopyDefaults(Rebuff.defaultsGlobal, RebuffDB)
    CopyDefaults(Rebuff.defaultsChar, RebuffCharDB)
end

function Rebuff.Debug(msg)
    if RebuffCharDB and RebuffCharDB.debug then
        print("|cff66ccffRebuff Debug:|r " .. tostring(msg))
    end
end

function Rebuff.ClampScale(value)
    if value < Rebuff.SCALE_MIN then
        return Rebuff.SCALE_MIN
    end
    if value > Rebuff.SCALE_MAX then
        return Rebuff.SCALE_MAX
    end
    return value
end

function Rebuff.PlayReminderSound()
    if not (RebuffCharDB and RebuffCharDB.sound) then
        return
    end

    if RebuffCharDB.soundSource == "lsm" and Rebuff.LSM and RebuffCharDB.customSound then
        local soundPath = Rebuff.LSM:Fetch("sound", RebuffCharDB.customSound, true)
        if soundPath and PlaySoundFile then
            PlaySoundFile(soundPath, "Master")
            return
        end
    end

    local soundKey = RebuffCharDB.blizzardSound or "RAID_WARNING"
    if SOUNDKIT and SOUNDKIT[soundKey] then
        PlaySound(SOUNDKIT[soundKey], "Master")
        return
    end

    if SOUNDKIT and SOUNDKIT.RAID_WARNING then
        PlaySound(SOUNDKIT.RAID_WARNING, "Master")
    end
end

function Rebuff.GetBlizzardSounds()
    return {
        "RAID_WARNING",
        "READY_CHECK",
        "UI_BATTLEGROUND_COUNTDOWN_TIMER",
        "ALARM_CLOCK_WARNING_3",
        "MAP_PING",
    }
end

function Rebuff.GetSharedMediaSounds()
    local list = { "None" }

    if Rebuff.LSM then
        local sounds = Rebuff.LSM:HashTable("sound")
        if sounds then
            for name in pairs(sounds) do
                table.insert(list, name)
            end
            table.sort(list)
        end
    end

    return list
end

function Rebuff.PreviewSound()
    Rebuff.PlayReminderSound()
end

function Rebuff.OpenConfig()
    if _G.RebuffConfigCategory and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(_G.RebuffConfigCategory:GetID())
    else
        print("Rebuff: config panel is not ready yet.")
    end
end

function Rebuff.CloseConfig()
    if SettingsPanel then
        if HideUIPanel then
            HideUIPanel(SettingsPanel)
        else
            SettingsPanel:Hide()
        end
    end
end

function Rebuff.CheckNow()
    if Rebuff.CheckBuffs then
        Rebuff.CheckBuffs()
    end
end

SLASH_REBUFF1 = "/rebuff"
SlashCmdList["REBUFF"] = function(msg)
    msg = msg and msg:lower():match("^%s*(.-)%s*$") or ""

    -- default: open config
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

    print("/rebuff")
    print("/rebuff check")
    print("/rebuff lock")
    print("/rebuff unlock")
end

Rebuff.frame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        Rebuff.EnsureDB()

        if Rebuff.BuildReminderFrame then
            Rebuff.BuildReminderFrame()
        end
        if Rebuff.BuildPlacementPopup then
            Rebuff.BuildPlacementPopup()
        end
        if Rebuff.ApplyPopupPosition then
            Rebuff.ApplyPopupPosition()
        end
        if Rebuff.ApplyVisualSettings then
            Rebuff.ApplyVisualSettings()
        end

        if not Rebuff.tickerStarted and Rebuff.CheckBuffs then
            Rebuff.tickerStarted = true
            C_Timer.NewTicker(Rebuff.CHECK_INTERVAL, Rebuff.CheckBuffs)
        end
    else
        if Rebuff.CheckBuffs then
            C_Timer.After(0.5, Rebuff.CheckBuffs)
        end
    end
end)

Rebuff.frame:RegisterEvent("PLAYER_LOGIN")
Rebuff.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
Rebuff.frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
Rebuff.frame:RegisterEvent("GROUP_ROSTER_UPDATE")
Rebuff.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
Rebuff.frame:RegisterEvent("SPELLS_CHANGED")
