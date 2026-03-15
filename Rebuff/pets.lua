local WARLOCK_PET_ICON_SPELL_ID = 688 -- Summon Imp

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

local function WarlockHasActivePet()
    if not UnitExists("pet") then
        return false
    end

    if UnitIsDead("pet") or UnitIsDeadOrGhost("pet") then
        return false
    end

    return true
end

function Rebuff.CheckPetState()
    if Rebuff.playerClass ~= "WARLOCK" then
        return nil, nil
    end

    if not InRelevantInstance() then
        return nil, nil
    end

    if not WarlockHasActivePet() then
        return WARLOCK_PET_ICON_SPELL_ID, "Summon your demon"
    end

    return nil, nil
end