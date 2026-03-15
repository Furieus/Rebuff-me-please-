local function GetThemeStyle()
    if RebuffCharDB and RebuffCharDB.themeStyle then
        return RebuffCharDB.themeStyle
    end
    return "rebuff"
end

function Rebuff.GetDisplayIcon(spellID)
    return Rebuff.GetSpellIcon(spellID)
end

local function GetAccentColor()
    if RebuffCharDB and RebuffCharDB.useClassColors and RAID_CLASS_COLORS and Rebuff.playerClass then
        local color = RAID_CLASS_COLORS[Rebuff.playerClass]
        if color then
            return color.r, color.g, color.b
        end
    end

    local theme = GetThemeStyle()

    if theme == "elvui" then
        return 0.23, 0.51, 0.78
    elseif theme == "tukui" then
        return 0.34, 0.34, 0.34
    else
        return 0.82, 0.68, 0.28
    end
end

function Rebuff.ApplyFrameTheme(frame)
    if not frame then
        return
    end

    local r, g, b = GetAccentColor()
    local theme = GetThemeStyle()

    if theme == "tukui" then
        frame:SetBackdropColor(0.09, 0.09, 0.09, 0.97)
        frame:SetBackdropBorderColor(0.30, 0.30, 0.30, 1)

        if frame.accent then
            frame.accent:ClearAllPoints()
            frame.accent:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
            frame.accent:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 1)
            frame.accent:SetWidth(2)
            frame.accent:SetColorTexture(r, g, b, 0.95)
            frame.accent:Show()
        end

        if frame.iconBG then
            frame.iconBG:SetBackdropColor(0.13, 0.13, 0.13, 1)
            frame.iconBG:SetBackdropBorderColor(0.24, 0.24, 0.24, 1)
        end
    elseif theme == "elvui" then
        frame:SetBackdropColor(0.06, 0.06, 0.06, 0.92)
        frame:SetBackdropBorderColor(0.18, 0.18, 0.18, 1)

        if frame.accent then
            frame.accent:ClearAllPoints()
            frame.accent:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
            frame.accent:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 1)
            frame.accent:SetWidth(4)
            frame.accent:SetColorTexture(r, g, b, 1)
            frame.accent:Show()
        end

        if frame.iconBG then
            frame.iconBG:SetBackdropColor(0.10, 0.10, 0.10, 1)
            frame.iconBG:SetBackdropBorderColor(0.18, 0.18, 0.18, 1)
        end
    else
        frame:SetBackdropColor(0.12, 0.11, 0.10, 0.96)
        frame:SetBackdropBorderColor(0.22, 0.20, 0.18, 1)

        if frame.accent then
            frame.accent:ClearAllPoints()
            frame.accent:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
            frame.accent:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
            frame.accent:SetHeight(3)
            frame.accent:SetColorTexture(r, g, b, 1)
            frame.accent:Show()
        end

        if frame.iconBG then
            frame.iconBG:SetBackdropColor(0.16, 0.14, 0.12, 1)
            frame.iconBG:SetBackdropBorderColor(0.28, 0.24, 0.20, 1)
        end
    end

    if frame == Rebuff.reminderFrame and Rebuff.reminderText then
        if theme == "rebuff" then
            Rebuff.reminderText:SetTextColor(0.98, 0.96, 0.90)
            Rebuff.reminderMoveText:SetTextColor(0.74, 0.70, 0.62)
        elseif theme == "tukui" then
            Rebuff.reminderText:SetTextColor(0.94, 0.94, 0.94)
            Rebuff.reminderMoveText:SetTextColor(0.62, 0.62, 0.62)
        else
            Rebuff.reminderText:SetTextColor(0.95, 0.95, 0.95)
            Rebuff.reminderMoveText:SetTextColor(0.65, 0.65, 0.65)
        end
    end
end