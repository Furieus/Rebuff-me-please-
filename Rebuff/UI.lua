function Rebuff.SaveFramePosition()
    if not Rebuff.reminderFrame or not RebuffCharDB then
        return
    end

    local point, _, relativePoint, x, y = Rebuff.reminderFrame:GetPoint(1)
    RebuffCharDB.point = point
    RebuffCharDB.relativePoint = relativePoint
    RebuffCharDB.x = x
    RebuffCharDB.y = y
end

function Rebuff.ApplyFramePosition()
    if not Rebuff.reminderFrame or not RebuffCharDB then
        return
    end

    Rebuff.reminderFrame:ClearAllPoints()
    Rebuff.reminderFrame:SetPoint(
        RebuffCharDB.point or Rebuff.defaultsChar.point,
        UIParent,
        RebuffCharDB.relativePoint or Rebuff.defaultsChar.relativePoint,
        RebuffCharDB.x or Rebuff.defaultsChar.x,
        RebuffCharDB.y or Rebuff.defaultsChar.y
    )
    Rebuff.reminderFrame:SetScale(RebuffCharDB.scale or Rebuff.defaultsChar.scale)
end

function Rebuff.SavePopupPosition()
    if not Rebuff.placementPopup or not RebuffCharDB then
        return
    end

    local point, _, relativePoint, x, y = Rebuff.placementPopup:GetPoint(1)
    RebuffCharDB.popupPoint = point
    RebuffCharDB.popupRelativePoint = relativePoint
    RebuffCharDB.popupX = x
    RebuffCharDB.popupY = y
end

function Rebuff.ApplyPopupPosition()
    if not Rebuff.placementPopup or not RebuffCharDB then
        return
    end

    Rebuff.placementPopup:ClearAllPoints()
    Rebuff.placementPopup:SetPoint(
        RebuffCharDB.popupPoint or Rebuff.defaultsChar.popupPoint,
        UIParent,
        RebuffCharDB.popupRelativePoint or Rebuff.defaultsChar.popupRelativePoint,
        RebuffCharDB.popupX or Rebuff.defaultsChar.popupX,
        RebuffCharDB.popupY or Rebuff.defaultsChar.popupY
    )
end

function Rebuff.UpdatePlacementScaleText()
    if Rebuff.placementScaleText and RebuffCharDB then
        Rebuff.placementScaleText:SetText(string.format("%d%%", math.floor((RebuffCharDB.scale or 1.0) * 100 + 0.5)))
    end
end

function Rebuff.ShowPlacementPopup()
    if Rebuff.placementPopup then
        Rebuff.UpdatePlacementScaleText()
        Rebuff.placementPopup:Show()
    end
end

function Rebuff.HidePlacementPopup()
    if Rebuff.placementPopup then
        Rebuff.placementPopup:Hide()
    end
end

function Rebuff.UpdateLockState()
    if not Rebuff.reminderFrame or not RebuffCharDB then
        return
    end

    if RebuffCharDB.locked then
        Rebuff.reminderFrame:EnableMouse(false)
        Rebuff.reminderFrame:RegisterForDrag()
        Rebuff.reminderMoveText:Hide()
        Rebuff.HidePlacementPopup()

        if not Rebuff.previewActive then
            Rebuff.reminderFrame:Hide()
        end
    else
        Rebuff.reminderFrame:EnableMouse(true)
        Rebuff.reminderFrame:RegisterForDrag("LeftButton")
        Rebuff.reminderMoveText:Show()
        Rebuff.reminderFrame:Show()
        Rebuff.ShowPlacementPopup()
    end
end

local function HideReminder()
    if Rebuff.previewActive then
        return
    end

    if Rebuff.reminderFrame and RebuffCharDB and RebuffCharDB.locked then
        Rebuff.reminderFrame:Hide()
    end
end

function Rebuff.ShowReminderFrame(spellID, text, forcedTexture)
    if not Rebuff.reminderFrame then
        return
    end

    local texture = forcedTexture or Rebuff.GetDisplayIcon(spellID)

    Rebuff.currentSpellID = spellID
    Rebuff.currentTexture = texture
    Rebuff.currentMessage = text

    if texture then
        Rebuff.reminderIcon:SetTexture(texture)
        Rebuff.reminderIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        Rebuff.reminderIcon:Show()
    else
        Rebuff.reminderIcon:SetTexture(nil)
        Rebuff.reminderIcon:Hide()
    end

    Rebuff.reminderText:SetText(text or "")
    Rebuff.reminderFrame:Show()

    if RebuffCharDB and RebuffCharDB.locked then
        Rebuff.reminderMoveText:Hide()
    else
        Rebuff.reminderMoveText:Show()
        Rebuff.ShowPlacementPopup()
    end

    if Rebuff.hideTimer then
        Rebuff.hideTimer:Cancel()
        Rebuff.hideTimer = nil
    end

    if RebuffCharDB and RebuffCharDB.locked and not Rebuff.previewActive then
        Rebuff.hideTimer = C_Timer.NewTimer(Rebuff.MESSAGE_HIDE_DELAY, HideReminder)
    end
end

function Rebuff.ResetReminderState()
    Rebuff.lastMessage = ""
    Rebuff.lastMessageTime = 0

    Rebuff.currentSpellID = nil
    Rebuff.currentTexture = nil
    Rebuff.currentMessage = nil

    if Rebuff.hideTimer then
        Rebuff.hideTimer:Cancel()
        Rebuff.hideTimer = nil
    end

    if Rebuff.previewActive then
        return
    end

    if Rebuff.reminderFrame and RebuffCharDB and RebuffCharDB.locked then
        Rebuff.reminderFrame:Hide()
    end
end

function Rebuff.BuildReminderFrame()
    Rebuff.reminderFrame = CreateFrame("Frame", "RebuffReminderFrame", UIParent, "BackdropTemplate")
    Rebuff.reminderFrame:SetSize(440, 52)
    Rebuff.reminderFrame:SetClampedToScreen(true)
    Rebuff.reminderFrame:SetMovable(true)
    Rebuff.reminderFrame:SetUserPlaced(false)
    Rebuff.reminderFrame:Hide()

    Rebuff.reminderFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = false,
        edgeSize = 1,
    })

    Rebuff.reminderFrame.accent = Rebuff.reminderFrame:CreateTexture(nil, "BORDER")
    Rebuff.reminderFrame.iconBG = CreateFrame("Frame", nil, Rebuff.reminderFrame, "BackdropTemplate")
    Rebuff.reminderFrame.iconBG:SetSize(30, 30)
    Rebuff.reminderFrame.iconBG:SetPoint("LEFT", 10, 0)
    Rebuff.reminderFrame.iconBG:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = false,
        edgeSize = 1,
    })

    Rebuff.reminderFrame:SetScript("OnDragStart", function(self)
        if RebuffCharDB and not RebuffCharDB.locked then
            self:StartMoving()
        end
    end)

    Rebuff.reminderFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Rebuff.SaveFramePosition()
    end)

    Rebuff.reminderIcon = Rebuff.reminderFrame.iconBG:CreateTexture(nil, "ARTWORK")
    Rebuff.reminderIcon:SetAllPoints()
    Rebuff.reminderIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    Rebuff.reminderText = Rebuff.reminderFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    Rebuff.reminderText:SetPoint("LEFT", Rebuff.reminderFrame.iconBG, "RIGHT", 10, 0)
    Rebuff.reminderText:SetPoint("RIGHT", -12, 0)
    Rebuff.reminderText:SetJustifyH("LEFT")

    Rebuff.reminderMoveText = Rebuff.reminderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    Rebuff.reminderMoveText:SetPoint("TOPLEFT", Rebuff.reminderFrame, "BOTTOMLEFT", 2, -4)
    Rebuff.reminderMoveText:SetText("Rebuff unlocked - drag to move")

    Rebuff.ApplyFrameTheme(Rebuff.reminderFrame)
    Rebuff.ApplyFramePosition()
end

function Rebuff.BuildPlacementPopup()
    Rebuff.placementPopup = CreateFrame("Frame", "RebuffPlacementPopup", UIParent, "BackdropTemplate")
    Rebuff.placementPopup:SetSize(220, 96)
    Rebuff.placementPopup:SetClampedToScreen(true)
    Rebuff.placementPopup:SetFrameStrata("DIALOG")
    Rebuff.placementPopup:SetMovable(true)
    Rebuff.placementPopup:EnableMouse(true)
    Rebuff.placementPopup:RegisterForDrag("LeftButton")
    Rebuff.placementPopup:Hide()

    Rebuff.placementPopup:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = false,
        edgeSize = 1,
    })

    Rebuff.placementPopup.accent = Rebuff.placementPopup:CreateTexture(nil, "BORDER")

    Rebuff.placementPopup:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)

    Rebuff.placementPopup:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Rebuff.SavePopupPosition()
    end)

    local title = Rebuff.placementPopup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -10)
    title:SetText("Rebuff Placement")
    title:SetTextColor(0.95, 0.95, 0.95)

    local moveText = Rebuff.placementPopup:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    moveText:SetPoint("TOP", title, "BOTTOM", 0, -2)
    moveText:SetText("Drag to move")
    moveText:SetTextColor(0.65, 0.65, 0.65)

    local minusButton = CreateFrame("Button", nil, Rebuff.placementPopup, "UIPanelButtonTemplate")
    minusButton:SetSize(28, 20)
    minusButton:SetPoint("TOPLEFT", 12, -44)
    minusButton:SetText("-")
    minusButton:SetScript("OnClick", function()
        RebuffCharDB.scale = Rebuff.ClampScale((RebuffCharDB.scale or 1.0) - Rebuff.SCALE_STEP)
        Rebuff.ApplyVisualSettings()
        Rebuff.SaveFramePosition()
    end)

    local plusButton = CreateFrame("Button", nil, Rebuff.placementPopup, "UIPanelButtonTemplate")
    plusButton:SetSize(28, 20)
    plusButton:SetPoint("TOPRIGHT", -12, -44)
    plusButton:SetText("+")
    plusButton:SetScript("OnClick", function()
        RebuffCharDB.scale = Rebuff.ClampScale((RebuffCharDB.scale or 1.0) + Rebuff.SCALE_STEP)
        Rebuff.ApplyVisualSettings()
        Rebuff.SaveFramePosition()
    end)

    Rebuff.placementScaleText = Rebuff.placementPopup:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    Rebuff.placementScaleText:SetPoint("CENTER", Rebuff.placementPopup, "TOP", 0, -54)
    Rebuff.placementScaleText:SetText("100%")
    Rebuff.placementScaleText:SetTextColor(0.90, 0.90, 0.90)

    local resetButton = CreateFrame("Button", nil, Rebuff.placementPopup, "UIPanelButtonTemplate")
    resetButton:SetSize(60, 20)
    resetButton:SetPoint("BOTTOMLEFT", 12, 10)
    resetButton:SetText("Reset")
    resetButton:SetScript("OnClick", function()
        RebuffCharDB.scale = Rebuff.defaultsChar.scale
        RebuffCharDB.point = Rebuff.defaultsChar.point
        RebuffCharDB.relativePoint = Rebuff.defaultsChar.relativePoint
        RebuffCharDB.x = Rebuff.defaultsChar.x
        RebuffCharDB.y = Rebuff.defaultsChar.y
        Rebuff.ApplyVisualSettings()
        Rebuff.SaveFramePosition()
    end)

    local lockButton = CreateFrame("Button", nil, Rebuff.placementPopup, "UIPanelButtonTemplate")
    lockButton:SetSize(60, 20)
    lockButton:SetPoint("BOTTOMRIGHT", -12, 10)
    lockButton:SetText("Lock")
    lockButton:SetScript("OnClick", function()
        Rebuff.LockPlacement()
    end)

    Rebuff.ApplyPopupPosition()
    Rebuff.ApplyFrameTheme(Rebuff.placementPopup)
    Rebuff.UpdatePlacementScaleText()
end

function Rebuff.ApplyVisualSettings()
    Rebuff.ApplyFramePosition()
    Rebuff.UpdatePlacementScaleText()
    Rebuff.UpdateLockState()

    Rebuff.ApplyFrameTheme(Rebuff.reminderFrame)
    Rebuff.ApplyFrameTheme(Rebuff.placementPopup)

    if Rebuff.previewActive then
        Rebuff.ShowReminderFrame(Rebuff.previewSpellID, Rebuff.previewMessage)
    end
end

function Rebuff.EnterPlacementMode()
    RebuffCharDB.locked = false
    Rebuff.ApplyVisualSettings()
    if Rebuff.ShowPreviewReminder then
        Rebuff.ShowPreviewReminder()
    end
    C_Timer.After(0.05, Rebuff.CloseConfig)
    print("Rebuff: frame unlocked for positioning")
end

function Rebuff.LockPlacement()
    Rebuff.SaveFramePosition()
    Rebuff.previewActive = false

    if Rebuff.hideTimer then
        Rebuff.hideTimer:Cancel()
        Rebuff.hideTimer = nil
    end

    RebuffCharDB.locked = true
    Rebuff.HidePlacementPopup()

    if Rebuff.reminderFrame then
        Rebuff.reminderFrame:Hide()
    end

    print("Rebuff: frame locked")
end

function Rebuff.ResetConfig()
    RebuffCharDB = RebuffCharDB or {}

    for k, v in pairs(Rebuff.defaultsChar) do
        RebuffCharDB[k] = v
    end

    Rebuff.previewActive = false

    if Rebuff.hideTimer then
        Rebuff.hideTimer:Cancel()
        Rebuff.hideTimer = nil
    end

    Rebuff.HidePlacementPopup()
    Rebuff.ApplyPopupPosition()
    Rebuff.ApplyVisualSettings()
    print("Rebuff: settings reset.")
end