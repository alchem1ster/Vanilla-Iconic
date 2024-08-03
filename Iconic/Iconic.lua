local _G = getfenv(0)

local lastMacroButtonMousedOver
local numMacroIcons
local availableMacroIcons = {}

local function HookScript(frame, script, hook)
    local handler = frame:GetScript(script)
    frame:SetScript(script, function(a1, a2, a3, a4, a5, a6, a7)
        hook(function(a1, a2, a3, a4, a5, a6, a7)
            if handler then
                handler(a1, a2, a3, a4, a5, a6, a7)
            end
        end)
    end)
end

local function hooksecurefunc(arg1, arg2, arg3)
	if type(arg1) == "string" then
		arg1, arg2, arg3 = _G, arg1, arg2
	end
	local orig = arg1[arg2]
	arg1[arg2] = function(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
		local x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,x17,x18,x19,x20 = orig(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
		
		arg3(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
		
		return x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,x17,x18,x19,x20
	end
end


local function customFind(str, pattern)
    local startIdx, endIdx = string.find(str, pattern)
    if startIdx then
        return string.sub(str, startIdx, endIdx)
    end
    return nil
end

function Iconic_MacroPopupFrame_Update()
    local macroPopupIcon, macroPopupButton
    local macroPopupOffset = FauxScrollFrame_GetOffset(MacroPopupScrollFrame)
    local numMacroIconsFound, filteredMacroIconID, macroIconID, texturePath, stringFound
    local userInput = string.lower(IconicFrame:GetText())
    userInput = gsub(userInput, "%%", "")
    local filteredMacroIconIDs = {}

    for macroIconID = 1, numMacroIcons do
        texturePath = GetMacroIconInfo(macroIconID)
        if texturePath then
            local textureName = string.lower(customFind(texturePath, ".*\\(.*)"))
            stringFound = customFind(textureName, userInput)
            if stringFound then
                tinsert(filteredMacroIconIDs, macroIconID)
            end
        end
    end
    numMacroIconsFound = table.getn(filteredMacroIconIDs)

    for buttonID = 1, NUM_MACRO_ICONS_SHOWN do
        macroPopupIcon = _G["MacroPopupButton" .. buttonID .. "Icon"]
        macroPopupButton = _G["MacroPopupButton" .. buttonID]
        filteredMacroIconID = (macroPopupOffset * NUM_ICONS_PER_ROW) + buttonID

        if filteredMacroIconID <= numMacroIconsFound then
            macroIconID = filteredMacroIconIDs[filteredMacroIconID]
            texturePath = GetMacroIconInfo(macroIconID)
            macroPopupIcon:SetTexture(texturePath)
            macroPopupButton:Show()
        else
            macroPopupIcon:SetTexture("")
            macroPopupButton:Hide()
        end

        if MacroPopupFrame.selectedIcon and (macroIconID == MacroPopupFrame.selectedIcon) then
            macroPopupButton:SetChecked(1)
        elseif MacroPopupFrame.selectedIconTexture == texturePath then
            macroPopupButton:SetChecked(1)
        else
            macroPopupButton:SetChecked(nil)
        end
    end

    FauxScrollFrame_Update(MacroPopupScrollFrame, ceil(numMacroIconsFound / NUM_ICONS_PER_ROW), NUM_ICON_ROWS, MACRO_ICON_ROW_HEIGHT)
end

function Iconic_MacroPopupButton_OnEnter()
	if not customFind(this:GetName(), "MacroPopupButton") then
		return
	end
    local iconName = this:GetName() .. "Icon"
    local texturePath = _G[iconName]:GetTexture()
    if texturePath then
        local textureName = customFind(texturePath, ".*\\(.*)")
        local textureNameKeywords = gsub(textureName, "_", ", ")

        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:AddLine(textureNameKeywords)
        lastMacroButtonMousedOver = this
        GameTooltip:Show()
    end
end

local function Iconic_UpdateAfterScroll(frame)
	if not customFind(frame:GetName(), "MacroPopupButton") then
		return
	end
    local iconName = frame:GetName() .. "Icon"
    local texturePath = _G[iconName]:GetTexture()
    if texturePath then
        local textureName = customFind(texturePath, ".*\\(.*)")
        local textureNameKeywords = gsub(textureName, "_", ", ")

        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
        GameTooltip:AddLine(textureNameKeywords)
        lastMacroButtonMousedOver = frame
        GameTooltip:Show()
    end
end

function Iconic_MacroPopupButton_OnLeave()
    GameTooltip:Hide()
    lastMacroButtonMousedOver = nil
end

function Iconic_MacroPopupButton_OnClick()
    local iconName = this:GetName() .. "Icon"
    local texturePath = _G[iconName]:GetTexture()
    if texturePath then
		MacroPopupFrame.selectedIcon = availableMacroIcons[texturePath]
		MacroFrameSelectedMacroButtonIcon:SetTexture(texturePath);
		MacroPopupOkayButton_Update();
		MacroPopupFrame_Update();
    end
end

function Iconic_TooltipRefresh()
	if arg1 then
		local scrollbar = getglobal("MacroPopupScrollFrameScrollBar");
		scrollbar:SetValue(arg1);
		this.offset = floor((arg1 / MACRO_ICON_ROW_HEIGHT) + 0.5);
		Iconic_MacroPopupFrame_Update();
	end
	if lastMacroButtonMousedOver then
        Iconic_UpdateAfterScroll(GetMouseFocus())
    end
end

function Iconic_MacroPopupScroll_ResetPosition()
    if MacroPopupScrollFrame:GetVerticalScroll() > 0 then
        MacroPopupScrollFrame:SetVerticalScroll(0)
    end
end

if not IsAddOnLoaded("Blizzard_MacroUI") then
    LoadAddOn("Blizzard_MacroUI")
end

numMacroIcons = GetNumMacroIcons()
for i = 1, numMacroIcons do
    local texture = GetMacroIconInfo(i)
    if texture then
        availableMacroIcons[texture] = i
    end
end

for i = 1, NUM_MACRO_ICONS_SHOWN do
    local MacroPopupButton = _G["MacroPopupButton" .. i]
    HookScript(MacroPopupButton, "OnEnter", Iconic_MacroPopupButton_OnEnter)
    HookScript(MacroPopupButton, "OnLeave", Iconic_MacroPopupButton_OnLeave)
    HookScript(MacroPopupButton, "OnClick", Iconic_MacroPopupButton_OnClick)
end

HookScript(MacroPopupScrollFrame, "OnVerticalScroll", Iconic_TooltipRefresh)

hooksecurefunc(_G, "MacroPopupFrame_Update", Iconic_MacroPopupFrame_Update)
