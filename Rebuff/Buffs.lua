Rebuff.CLASS_BUFFS = {
    DRUID = {
        spellID = 1126,
        buffs = { "Mark of the Wild" },
        shortName = "Mark of the Wild",
        trackMode = "group",
    },
    MAGE = {
        spellID = 1459,
        buffs = { "Arcane Intellect" },
        shortName = "Arcane Intellect",
        trackMode = "group",
    },
    PRIEST = {
        spellID = 21562,
        buffs = { "Power Word: Fortitude", "Fortitude" },
        shortName = "Fortitude",
        trackMode = "group",
    },
    WARRIOR = {
        spellID = 6673,
        buffs = { "Battle Shout" },
        shortName = "Battle Shout",
        trackMode = "group",
    },
    SHAMAN = {
        spellID = 462854, -- Skyfury
        buffs = { "Skyfury" },
        shortName = "Skyfury",
        trackMode = "group",
    },
    WARLOCK = {
        spellID = 20707, -- Soulstone display/default icon reference
        knownSpellIDs = {
            20707,
            693,
        },
        buffs = {
            "Soulstone",
            "Soulstone Resurrection",
        },
        shortName = "Soulstone",
        trackMode = "single",
    },
}

function Rebuff.GetSpellName(spellID)
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        if info and info.name then
            return info.name
        end
    end

    if GetSpellInfo then
        return GetSpellInfo(spellID)
    end

    return nil
end

function Rebuff.GetSpellIcon(spellID)
    if not spellID then
        return nil
    end

    if C_Spell and C_Spell.GetSpellTexture then
        local texture = C_Spell.GetSpellTexture(spellID)
        if texture then
            return texture
        end
    end

    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        if info then
            if info.iconID then
                return info.iconID
            end
            if info.originalIconID then
                return info.originalIconID
            end
        end
    end

    if GetSpellTexture then
        local texture = GetSpellTexture(spellID)
        if texture then
            return texture
        end
    end

    if spellID == 1126 then
        return 136078   -- Mark of the Wild
    elseif spellID == 1459 then
        return 135932   -- Arcane Intellect
    elseif spellID == 21562 then
        return 135987   -- Fortitude
    elseif spellID == 6673 then
        return 132333   -- Battle Shout
    elseif spellID == 20707 or spellID == 693 then
        return 136210   -- Soulstone fallback
    elseif spellID == 688 then
        return 136218   -- Summon Imp fallback
    end

    return 134400
end

function Rebuff.GetDisplayIcon(spellID)
    return Rebuff.GetSpellIcon(spellID)
end

local function InRelevantInstance()
    local inInstance, instanceType = IsInInstance()

    if not inInstance then
        return false
    end

    if instanceType == "party" or instanceType == "raid" then
        return true
    end

    if RebuffCharDB and RebuffCharDB.enableSolo and instanceType ~= "none" then
        return true
    end

    return false
end

local function CanCheck()
    if not InRelevantInstance() then
        return false
    end

    if InCombatLockdown() then
        return false
    end

    return true
end

local function IsSpellKnownSafe(spellID)
    if not spellID then
        return false
    end

    if C_SpellBook and C_SpellBook.IsSpellKnown then
        return C_SpellBook.IsSpellKnown(spellID)
    elseif IsSpellKnown then
        return IsSpellKnown(spellID)
    end

    return false
end

local function GetKnownSpellIDForClassData(classData)
    if not classData then
        return nil
    end

    if classData.knownSpellIDs then
        for _, candidateID in ipairs(classData.knownSpellIDs) do
            if IsSpellKnownSafe(candidateID) then
                return candidateID
            end
        end
    end

    if classData.spellID and IsSpellKnownSafe(classData.spellID) then
        return classData.spellID
    end

    return nil
end

local function PlayerProvidesTrackedBuff()
    local classData = Rebuff.CLASS_BUFFS[Rebuff.playerClass]
    if not classData then
        Rebuff.Debug("No tracked buff for class: " .. tostring(Rebuff.playerClass))
        return nil, nil, nil
    end

    local knownSpellID = GetKnownSpellIDForClassData(classData)
    if not knownSpellID then
        return nil, nil, nil
    end

    local displaySpellID = classData.spellID or knownSpellID
    local spellName = Rebuff.GetSpellName(displaySpellID) or classData.shortName

    if not spellName then
        return nil, nil, nil
    end

    return displaySpellID, spellName, classData
end

local function UnitHasAnyTrackedBuff(unit, buffNames)
    if not UnitExists(unit) or not buffNames then
        return false
    end

    for _, spellName in ipairs(buffNames) do
        if spellName then
            if C_UnitAuras and C_UnitAuras.GetAuraDataBySpellName then
                if C_UnitAuras.GetAuraDataBySpellName(unit, spellName, "HELPFUL") ~= nil then
                    return true
                end
            elseif AuraUtil and AuraUtil.FindAuraByName then
                if AuraUtil.FindAuraByName(spellName, unit, "HELPFUL") ~= nil then
                    return true
                end
            end
        end
    end

    return false
end

local function GetUnitsToCheck()
    local units = {}
    local seen = {}

    local function AddUnit(unit)
        if not UnitExists(unit) then
            return
        end

        local guid = UnitGUID(unit)
        if guid and not seen[guid] then
            seen[guid] = true
            table.insert(units, unit)
        end
    end

    AddUnit("player")

    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            AddUnit("raid" .. i)
        end
    elseif IsInGroup() then
        for i = 1, GetNumSubgroupMembers() do
            AddUnit("party" .. i)
        end
    end

    return units
end

local function GetMissingBuffList(buffNames)
    local missing = {}

    for _, unit in ipairs(GetUnitsToCheck()) do
        if UnitExists(unit) and not UnitIsDeadOrGhost(unit) then
            if not UnitHasAnyTrackedBuff(unit, buffNames) then
                if UnitIsUnit(unit, "player") then
                    table.insert(missing, "You")
                else
                    table.insert(missing, GetUnitName(unit, true) or unit)
                end
            end
        end
    end

    return missing
end

local function AnyUnitHasTrackedBuff(buffNames)
    for _, unit in ipairs(GetUnitsToCheck()) do
        if UnitExists(unit) and not UnitIsDeadOrGhost(unit) then
            if UnitHasAnyTrackedBuff(unit, buffNames) then
                return true, unit
            end
        end
    end

    return false, nil
end

local function CanPlayerCastNow(spellID)
    local usable, noMana = false, false

    if C_Spell and C_Spell.IsSpellUsable then
        usable, noMana = C_Spell.IsSpellUsable(spellID)
    elseif IsUsableSpell then
        usable, noMana = IsUsableSpell(spellID)
    end

    if not usable or noMana then
        return false
    end

    local startTime, duration, enabled

    if C_Spell and C_Spell.GetSpellCooldown then
        local cd = C_Spell.GetSpellCooldown(spellID)
        if cd then
            startTime = cd.startTime
            duration = cd.duration
            enabled = cd.isEnabled and 1 or 0
        end
    elseif GetSpellCooldown then
        startTime, duration, enabled = GetSpellCooldown(spellID)
    end

    if enabled == 0 then
        return false
    end

    if startTime and duration and duration > 0 then
        return false
    end

    return true
end

local function ShouldShow(msg)
    local now = GetTime()

    if msg ~= Rebuff.lastMessage then
        Rebuff.lastMessage = msg
        Rebuff.lastMessageTime = now
        return true
    end

    if (now - Rebuff.lastMessageTime) >= Rebuff.REMINDER_THROTTLE then
        Rebuff.lastMessageTime = now
        return true
    end

    return false
end

Rebuff.CheckBuffs = function()
    if not CanCheck() then
        if Rebuff.ResetReminderState then
            Rebuff.ResetReminderState()
        end
        return
    end

    local spellID, spellName, classData = PlayerProvidesTrackedBuff()
    if not spellID or not spellName or not classData then
        if Rebuff.ResetReminderState then
            Rebuff.ResetReminderState()
        end
        return
    end

    if classData.trackMode == "single" then
        local hasTrackedBuff = AnyUnitHasTrackedBuff(classData.buffs)

        if hasTrackedBuff then
            if Rebuff.ResetReminderState then
                Rebuff.ResetReminderState()
            end
            return
        end

        -- Soulstone should not nag while unavailable/cooling down
        if not CanPlayerCastNow(spellID) then
            if Rebuff.ResetReminderState then
                Rebuff.ResetReminderState()
            end
            return
        end

        local msg = string.format("Cast %s - no target currently has it", spellName)

        if ShouldShow(msg) then
            Rebuff.PlayReminderSound()
            if Rebuff.ShowReminderFrame then
                Rebuff.ShowReminderFrame(spellID, msg)
            end
            print("|cffffcc00Rebuff:|r " .. msg)
        end

        return
    end

    local missing = GetMissingBuffList(classData.buffs)
    if not missing or #missing == 0 then
        if Rebuff.ResetReminderState then
            Rebuff.ResetReminderState()
        end
        return
    end

    local msg
    if CanPlayerCastNow(spellID) then
        if #missing <= 5 then
            msg = string.format("Cast %s - missing on: %s", spellName, table.concat(missing, ", "))
        else
            msg = string.format("Cast %s - missing on %d players", spellName, #missing)
        end
    else
        if #missing <= 5 then
            msg = string.format("%s missing on: %s", spellName, table.concat(missing, ", "))
        else
            msg = string.format("%s missing on %d players", spellName, #missing)
        end
    end

    if ShouldShow(msg) then
        Rebuff.PlayReminderSound()
        if Rebuff.ShowReminderFrame then
            Rebuff.ShowReminderFrame(spellID, msg)
        end
        print("|cffffcc00Rebuff:|r " .. msg)
    end
end