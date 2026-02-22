-- Credits to stassart on curse.com for suggesting to use InCombatLockdown() checks in the code

-- Debug function. Adds message to the chatbox (only visible to the local player)
function dout(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg);
end

function tokenize(str)
	local tbl = {};
	for v in string.gmatch(str, "[^ ]+") do
		tinsert(tbl, v);
	end
	return tbl;
end

-- Safe initialization of characterSettings (3.3.5 compatible)
-- CALL THIS FIRST in any function that uses characterSettings
local function InitCharacterSettings()
    if not characterSettings then
        characterSettings = {}
    end
    if not characterSettings.StatusText then
        characterSettings.StatusText = {
            ShortNumeric = true,
            ShowPercent = true,
            ShowMax = true
        }
    end
end

-- Helper: Trim whitespace (3.3.5 compatible - strtrim doesn't exist!)
local function trim(str)
    if not str then return "" end
    return (str:gsub("^%s*(.-)%s*$", "%1"))
end

-- Create the addon main instance
local UnitFramesImproved = CreateFrame('Button', 'UnitFramesImproved');

-- REMOVED: Top-level characterSettings.StatusText block (runs too early!)

-- Event listener to make sure we enable the addon at the right time
function UnitFramesImproved:PLAYER_ENTERING_WORLD()
    -- Initialize settings FIRST before using them
    InitCharacterSettings()
    
	-- Set some default settings
	if (characterSettings == nil) then
		UnitFramesImproved_LoadDefaultSettings();
	end
	
	EnableUnitFramesImproved();
    
    -- Macumba's changes
    BuffFrame:SetScale(1.6)
    for i=1,4 do _G["PartyMemberFrame"..i.."HealthBarText"]:SetFont("Fonts\\FRIZQT__.TTF", 7, "OUTLINE")end
    for i=1,4 do _G["PartyMemberFrame"..i.."HealthBarText"]:SetPoint("TOP", 20, -13)end
    for i=1,4 do _G["PartyMemberFrame"..i.."ManaBarText"]:SetFont("Fonts\\FRIZQT__.TTF", 7, "OUTLINE")end
    for i=1,4 do _G["PartyMemberFrame"..i]:SetScale(1.6)end
    for i=1,4 do _G["PartyMemberFrame"..i.."Name"]:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")end
    for i=1,4 do _G["PartyMemberFrame"..i.."PVPIcon"]:Hide()end
    PlayerPVPIcon:Hide()
    PlayerName:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
    PlayerName:SetPoint("CENTER",50,38);
    PlayerFrameHealthBarText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
    PlayerFrameHealthBarText:SetPoint("CENTER", 50, 13);
    PlayerFrameManaBarText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
    PlayerFrameGroupIndicator:Hide()
    TargetFrameTextureFrameName:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
    TargetFrameTextureFrameName:SetPoint("CENTER",-50,38);
    TargetFrameTextureFrameHealthBarText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
    TargetFrameTextureFrameHealthBarText:SetPoint("CENTER", -50, 13);
    TargetFrameTextureFrameManaBarText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
    TargetFrameSpellBarText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    FocusFrameTextureFrameName:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
    FocusFrameTextureFrameName:SetPoint("CENTER",-50,38);
    FocusFrameTextureFrameHealthBarText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
    FocusFrameTextureFrameHealthBarText:SetPoint("CENTER", -50, 13);
    FocusFrameTextureFrameManaBarText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
end

-- Disable Threat on party frames 
local function DisablePartyFrameFlash()
    for i = 1, MAX_PARTY_MEMBERS do
        local flashTexture = _G["PartyMemberFrame"..i.."Flash"]
        if flashTexture then
            flashTexture:Hide()
            flashTexture:SetAlpha(0)
			for i=1,4 do _G["PartyMemberFrame"..i.."PVPIcon"]:Hide()end
			PlayerFrameGroupIndicator:Hide()
        end
    end
end
hooksecurefunc("PartyMemberFrame_UpdateMember", DisablePartyFrameFlash)
hooksecurefunc("PartyMemberFrame_UpdateArt", DisablePartyFrameFlash)
function PartyMemberFrame_UpdateMemberHealth(self, elapsed)
    _G[self:GetName().."Flash"]:Hide()
end
hooksecurefunc("UnitThreatSituation", function(unit)
    if string.find(unit, "party") then
        local frame = _G["PartyMemberFrame"..unit:match("%d")]
        if frame then
            _G[frame:GetName().."Flash"]:Hide()
        end
    end
end)

-- Event listener for VARIABLES_LOADED
function UnitFramesImproved:VARIABLES_LOADED()
    -- Initialize settings FIRST
    InitCharacterSettings()
    
	dout("UnitFramesImproved settings loaded!");
	
	if (characterSettings == nil) then
		UnitFramesImproved_LoadDefaultSettings();
	end
	
	if (not (characterSettings["PlayerFrameAnchor"] == nil)) then
		StaticPopup_Show("LAYOUT_RESETDEFAULT");
		characterSettings["PlayerFrameX"] = nil;
		characterSettings["PlayerFrameY"] = nil;
		characterSettings["PlayerFrameMoved"] = nil;
		characterSettings["PlayerFrameAnchor"] = nil;
	end
	
	UnitFramesImproved_ApplySettings(characterSettings);
end

function UnitFramesImproved_ApplySettings(settings)
    InitCharacterSettings() -- Safety
	UnitFramesImproved_SetFrameScale(settings["FrameScale"])
end

function UnitFramesImproved_LoadDefaultSettings()
	characterSettings = {}
	characterSettings["FrameScale"] = "1.0";
    -- Initialize StatusText defaults here too
    characterSettings.StatusText = {
        ShortNumeric = true,
        ShowPercent = true,
        ShowMax = true
    }
	
	if not TargetFrame:IsUserPlaced() then
		TargetFrame:SetPoint("TOPLEFT", PlayerFrame, "TOPRIGHT", 36, 0);
	end
end

function EnableUnitFramesImproved()
    -- Initialize settings before hooking
    InitCharacterSettings()
    
	hooksecurefunc("TextStatusBar_UpdateTextString", UnitFramesImproved_TextStatusBar_UpdateTextString);
	hooksecurefunc("PlayerFrame_ToPlayerArt", UnitFramesImproved_PlayerFrame_ToPlayerArt);
	hooksecurefunc("PlayerFrame_ToVehicleArt", UnitFramesImproved_PlayerFrame_ToVehicleArt);
	hooksecurefunc("TargetFrame_Update", UnitFramesImproved_TargetFrame_Update);
	if TargetFrame and TargetFrame:IsVisible() then
		UnitFramesImproved_TargetFrame_Update(TargetFrame)
	end
	hooksecurefunc("TargetFrame_CheckFaction", UnitFramesImproved_TargetFrame_CheckFaction);
	hooksecurefunc("TargetFrame_CheckClassification", UnitFramesImproved_TargetFrame_CheckClassification);
	hooksecurefunc("BossTargetFrame_OnLoad", UnitFramesImproved_BossTargetFrame_Style);

	if not TargetFrame:IsUserPlaced() then
		if not InCombatLockdown() then 
			TargetFrame:SetPoint("TOPLEFT", PlayerFrame, "TOPRIGHT", 36, 0);
		end
	end
	
	UnitFramesImproved_Style_PlayerFrame();
	UnitFramesImproved_BossTargetFrame_Style(Boss1TargetFrame);
	UnitFramesImproved_BossTargetFrame_Style(Boss2TargetFrame);
	UnitFramesImproved_BossTargetFrame_Style(Boss3TargetFrame);
	UnitFramesImproved_BossTargetFrame_Style(Boss4TargetFrame);
	UnitFramesImproved_Style_TargetFrame(TargetFrame);
	UnitFramesImproved_Style_TargetFrame(FocusFrame);
	
	-- Register events for tap status updates (fixes gray color delay)
	local TapStatusFrame = CreateFrame("Frame")
	TapStatusFrame:RegisterEvent("UNIT_FACTION")
	TapStatusFrame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
	TapStatusFrame:SetScript("OnEvent", function(self, event, unit)
		if unit == "target" and TargetFrame and TargetFrame.healthbar then
			UnitFramesImproved_TargetFrame_Update(TargetFrame)
		elseif unit == "focus" and FocusFrame and FocusFrame.healthbar then
			-- Reuse the same logic for focus
			if FocusFrame.healthbar then
				if ( not UnitPlayerControlled(FocusFrame.unit) and UnitIsTapped(FocusFrame.unit) and not UnitIsTappedByPlayer(FocusFrame.unit) and not UnitIsTappedByAllThreatList(FocusFrame.unit) ) then
					FocusFrame.healthbar:SetStatusBarColor(0.5, 0.5, 0.5)
				else
					FocusFrame.healthbar:SetStatusBarColor(UnitColor(FocusFrame.healthbar.unit))
				end
			end
		end
	end)
end



function UnitFramesImproved_Style_PlayerFrame()
    InitCharacterSettings() -- Safety if this function ever uses StatusText settings
	if not InCombatLockdown() then 
		-- PlayerFrameHealthBar.lockColor = true;
		-- PlayerFrameHealthBar.capNumericDisplay = true;
		PlayerFrameHealthBar:SetWidth(115);
		PlayerFrameHealthBar:SetHeight(29);
		PlayerFrameHealthBar:SetPoint("TOPLEFT",106,-22);
		PlayerFrameHealthBarText:SetPoint("CENTER",50,6);
	end
    PlayerFrameTexture:SetTexture("Interface\\Addons\\UnitFramesImproved\\Textures\\UI-TargetingFrame");
    PlayerStatusTexture:SetTexture("Interface\\Addons\\UnitFramesImproved\\Textures\\UI-Player-Status");
    
	for i,v in pairs({
		PlayerFrameTexture,
   		TargetFrameTextureFrameTexture,
  		PetFrameTexture,
		PartyMemberFrame1Texture,
		PartyMemberFrame2Texture,
		PartyMemberFrame3Texture,
		PartyMemberFrame4Texture,
		PartyMemberFrame1PetFrameTexture,
		PartyMemberFrame2PetFrameTexture,
		PartyMemberFrame3PetFrameTexture,
		PartyMemberFrame4PetFrameTexture,
   		FocusFrameTextureFrameTexture,
   		TargetFrameToTTextureFrameTexture,
   		FocusFrameToTTextureFrameTexture,
		CastingBarFrameBorder,
		FocusFrameSpellBarBorder,
		TargetFrameSpellBarBorder,
              }) do
                 v:SetVertexColor(.05, .05, .05)
	end  
    if not UnitFramesImproved_PlayerHealthBarHooked then
        hooksecurefunc("UnitFrameHealthBar_Update", function(self, unit)
            if self == PlayerFrameHealthBar and unit == "player" then
                local r, g, b = UnitColor("player")
                self:SetStatusBarColor(r, g, b)
            end
        end)
        
        -- Also hook OnValueChanged just in case smooth bars bypass the Update call
        hooksecurefunc(PlayerFrameHealthBar, "SetValue", function(self)
            if self:GetParent() == PlayerFrame then
                local r, g, b = UnitColor("player")
                self:SetStatusBarColor(r, g, b)
            end
        end)
        
        UnitFramesImproved_PlayerHealthBarHooked = true
    end
    
    -- Initial apply
    local r, g, b = UnitColor("player")
    PlayerFrameHealthBar:SetStatusBarColor(r, g, b)
end

function UnitFramesImproved_Style_TargetFrame(self)
    InitCharacterSettings()
	if not InCombatLockdown() then 
		self.healthbar.lockColor = true;
		self.healthbar:SetWidth(119);
		self.healthbar:SetHeight(29);
		self.healthbar:SetPoint("TOPLEFT",7,-22);
		self.healthbar.TextString:SetPoint("CENTER",-50,6);
		self.deadText:SetPoint("CENTER",-50,6);
		self.nameBackground:Hide();
		for i=1,4 do _G["PartyMemberFrame"..i.."PVPIcon"]:Hide()end
	end
end

function UnitFramesImproved_BossTargetFrame_Style(self)
    InitCharacterSettings()
	self.borderTexture:SetTexture("Interface\\Addons\\UnitFramesImproved\\Textures\\UI-UnitFrame-Boss");
	UnitFramesImproved_Style_TargetFrame(self);
	if (not (characterSettings["FrameScale"] == nil)) then
		if not InCombatLockdown() then 
			self:SetScale(characterSettings["FrameScale"] * 0.9);
		end
	end
end

function UnitFramesImproved_SetFrameScale(scale)
    InitCharacterSettings()
	if not InCombatLockdown() then 
		PlayerFrame:SetScale(scale);
		TargetFrame:SetScale(scale);
		FocusFrame:SetScale(scale);
		ComboFrame:SetScale(scale);
		RuneButtonIndividual1:SetScale(scale);
		RuneButtonIndividual2:SetScale(scale);
		RuneButtonIndividual3:SetScale(scale);
		RuneButtonIndividual4:SetScale(scale);
		RuneButtonIndividual5:SetScale(scale);
		RuneButtonIndividual6:SetScale(scale);
		Boss1TargetFrame:SetScale(scale*0.9);
		Boss2TargetFrame:SetScale(scale*0.9);
		Boss3TargetFrame:SetScale(scale*0.9);
		Boss4TargetFrame:SetScale(scale*0.9);
		characterSettings["FrameScale"] = scale;
	end
end

local function ApplyThicknessToFocusFrame(self)
    if not self or not UnitExists("focus") then return end

    local classification = UnitClassification("focus")
    if (classification == "worldboss" or classification == "elite") then
        FocusFrame.borderTexture:SetTexture("Interface\\Addons\\UnitFramesImproved\\Textures\\UI-TargetingFrame-Elite")
        FocusFrame.borderTexture:SetVertexColor(1, 1, 1)
    elseif (classification == "rareelite") then
        FocusFrame.borderTexture:SetTexture("Interface\\Addons\\UnitFramesImproved\\Textures\\UI-TargetingFrame-Rare-Elite")
        FocusFrame.borderTexture:SetVertexColor(1, 1, 1)
    elseif (classification == "rare") then
        FocusFrame.borderTexture:SetTexture("Interface\\Addons\\UnitFramesImproved\\Textures\\UI-TargetingFrame-Rare")
        FocusFrame.borderTexture:SetVertexColor(1, 1, 1)
    else
        FocusFrame.borderTexture:SetTexture("Interface\\Addons\\UnitFramesImproved\\Textures\\UI-TargetingFrame")
        FocusFrame.borderTexture:SetVertexColor(0.05, 0.05, 0.05)
    end

    -- Adjust the health and mana bars, name, and other elements
    FocusFrame.highLevelTexture:SetPoint("CENTER", FocusFrame.levelText, "CENTER", 0, 0)
    FocusFrame.nameBackground:Hide()
    FocusFrame.name:SetPoint("LEFT", FocusFrame, 13, 40)
    FocusFrame.healthbar:SetSize(119, 27)
    FocusFrame.healthbar:SetPoint("TOPLEFT", 5, -24)
    FocusFrame.manabar:SetPoint("TOPLEFT", 7, -52)
    FocusFrame.manabar:SetSize(119, 13)

    if FocusFrame.Background then
        FocusFrame.Background:SetSize(119, 42)
        FocusFrame.Background:SetPoint("BOTTOMLEFT", FocusFrame, "BOTTOMLEFT", 7, 35)
    end
end

local function OnEvent(self, event, arg1)
    if event == "PLAYER_FOCUS_CHANGED" then
        ApplyThicknessToFocusFrame(FocusFrame)
    elseif event == "UNIT_CLASSIFICATION_CHANGED" and arg1 == "focus" then
        ApplyThicknessToFocusFrame(FocusFrame)
    end
end

local function InitializeFocusFrameCustomization()
    -- Create a frame to listen for events
    local focusFrameEventHandler = CreateFrame("Frame")
    focusFrameEventHandler:RegisterEvent("PLAYER_FOCUS_CHANGED")
    focusFrameEventHandler:RegisterEvent("UNIT_CLASSIFICATION_CHANGED")

    -- Set the event handler function
    focusFrameEventHandler:SetScript("OnEvent", OnEvent)
end

-- Call this function during the PLAYER_LOGIN or ADDON_LOADED event
InitializeFocusFrameCustomization()

-- StatusText Slash Commands
SLASH_UNITFRAMESIMPROVED1 = "/unitframesimproved";
SLASH_UNITFRAMESIMPROVED2 = "/ufi";

SlashCmdList["UNITFRAMESIMPROVED"] = function(msg)
	InitCharacterSettings() -- MUST be first
    local cmd = strlower(trim(msg or ""))
    
    if cmd == "short" or cmd == "shortnumeric" then
        characterSettings.StatusText.ShortNumeric = not characterSettings.StatusText.ShortNumeric
        dout("StatusText: Short numeric format " .. (characterSettings.StatusText.ShortNumeric and "ENABLED" or "DISABLED"))
        dout("  Example: " .. (characterSettings.StatusText.ShortNumeric and "15.2k (100%)" or "15234 (100%)"))
    elseif cmd == "percent" or cmd == "showpercent" then
        characterSettings.StatusText.ShowPercent = not characterSettings.StatusText.ShowPercent
        dout("StatusText: Percent display " .. (characterSettings.StatusText.ShowPercent and "ENABLED" or "DISABLED"))
        if characterSettings.StatusText.ShowPercent then
            dout("  Format: Value (Percent%)  e.g., 15k (100%)")
        else
            dout("  Format: Value / Max  e.g., 15234 / 15500")
        end
    elseif cmd == "max" or cmd == "showmax" then
        characterSettings.StatusText.ShowMax = not characterSettings.StatusText.ShowMax
        dout("StatusText: Max value display " .. (characterSettings.StatusText.ShowMax and "ENABLED" or "DISABLED"))
    elseif cmd == "reset" then
        characterSettings.StatusText.ShortNumeric = true
        characterSettings.StatusText.ShowPercent = true
        characterSettings.StatusText.ShowMax = true
        dout("StatusText: Settings reset to defaults")
        dout("  ShortNumeric: ON | ShowPercent: ON | ShowMax: ON")
    elseif cmd == "" or cmd == "help" then
		dout("UnitFramesImproved Commands:")
		dout("  /ufi short      - Toggle short numeric (1k vs 1000)")
		dout("  /ufi percent    - Toggle percent display (adds (100%))")
		dout("  /ufi max        - Toggle / Max display (1000 / 1000)")
		dout("  /ufi scale #    - Set frame scale (0.5 to 2.0)")
		dout("  /ufi reset      - Reset all StatusText settings")
		dout("  /ufi help       - Show this help")
		dout("")
		dout("Current settings:")
		dout("  ShortNumeric: " .. (characterSettings.StatusText.ShortNumeric and "ON" or "OFF"))
		dout("  ShowPercent:  " .. (characterSettings.StatusText.ShowPercent and "ON" or "OFF"))
		dout("  ShowMax:      " .. (characterSettings.StatusText.ShowMax and "ON" or "OFF"))
		dout("  FrameScale:   " .. (characterSettings["FrameScale"] or "1.0"))
    else
        local tokens = tokenize(msg)
        if table.getn(tokens) > 0 then
            local subcmd = strlower(tokens[1])
            if subcmd == "scale" then
                if table.getn(tokens) > 1 then
                    UnitFramesImproved_SetFrameScale(tokens[2])
                else
                    dout("Please supply a number, between 0.0 and 10.0 as the second parameter.")
                end
            elseif subcmd == "reset" and tokens[2] == nil then
                StaticPopup_Show("LAYOUT_RESET");
            elseif subcmd == "settings" then
                if InterfaceOptionsFrame_OpenToCategory then
                    InterfaceOptionsFrame_OpenToCategory("UnitFramesImproved")
                end
            else
                dout("Unknown command. Type /ufi help for StatusText options.")
                dout("Other UFI commands: /ufi scale # | /ufi reset | /ufi settings")
            end
        else
            dout("Unknown command. Type /ufi help for options.")
        end
    end
    
    -- Force refresh all bars
    for _, barName in ipairs({
        "PlayerFrameHealthBar", "PlayerFrameManaBar",
        "TargetFrameHealthBar", "TargetFrameManaBar",
        "FocusFrameHealthBar", "FocusFrameManaBar",
    }) do
        local bar = _G[barName]
        if bar and bar.TextString then
            UnitFramesImproved_TextStatusBar_UpdateTextString(bar)
        end
    end
end

-- Setup the static popup dialog for resetting the UI
StaticPopupDialogs["LAYOUT_RESET"] = {
	text = "Are you sure you want to reset your scale?",
	button1 = "Yes",
	button2 = "No",
	OnAccept = function()
		UnitFramesImproved_LoadDefaultSettings();
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true
}

StaticPopupDialogs["LAYOUT_RESETDEFAULT"] = {
	text = "In order for UnitFramesImproved to work properly,\nyour old layout settings need to be reset.\nThis will reload your UI.",
	button1 = "Reset",
	button2 = "Ignore",
	OnAccept = function()
		PlayerFrame:SetUserPlaced(false);
		ReloadUI();
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true
}

-- Helper: Short numeric format
local function ShortValue(val)
    if not val then return 0 end
    if val >= 1000000 then
        return string.format("%.1fm", val / 1000000)
    elseif val >= 1000 then
        return string.format("%.1fk", val / 1000)
    else
        return val
    end
end

-- Helper: Round to nearest integer
local function round(value)
    return math.floor(value + 0.5)
end

-- Main text update function - FIXED formatting logic
function UnitFramesImproved_TextStatusBar_UpdateTextString(textStatusBar)
    InitCharacterSettings()
    
    local textString = textStatusBar.TextString
    if not textString then return end
    
    local value = textStatusBar.finalValue or textStatusBar:GetValue()
    local _, valueMax = textStatusBar:GetMinMaxValues()
    
    if not valueMax or valueMax == 0 then
        textString:Hide()
        return
    end

    local unit = textStatusBar.unit
    if unit and (UnitIsDead(unit) or UnitIsGhost(unit) or not UnitIsConnected(unit)) then
        textString:SetText(UnitIsDead(unit) and "Dead" or "Offline")
        textString:Show()
        return
    end

    local settings = characterSettings.StatusText
    
    -- Format value and max independently based on ShortNumeric setting
    local displayValue = settings.ShortNumeric and ShortValue(value) or value
    local displayMax = settings.ShortNumeric and ShortValue(valueMax) or valueMax
    
    -- Start with base value
    local text = tostring(displayValue)
    
    -- Add / Max if ShowMax is enabled (INDEPENDENT of other settings)
    if settings.ShowMax then
        text = string.format("%s / %s", text, displayMax)
    end
    
    -- Add (Percent%) if ShowPercent is enabled (INDEPENDENT of other settings)
    if settings.ShowPercent then
        local percent = round((value / valueMax) * 100)
        text = string.format("%s (%d%%)", text, percent)
    end
    
    -- Handle zero power bars (Rage/Energy at 0) - still respect settings
    if value == 0 and textStatusBar ~= textStatusBar:GetParent().healthbar then
        local displayMaxZero = settings.ShortNumeric and ShortValue(valueMax) or valueMax
        if settings.ShowMax then
            text = string.format("0 / %s", displayMaxZero)
        else
            text = "0"
        end
        if settings.ShowPercent then
            text = string.format("%s (0%%)", text)
        end
    end
    
    textString:SetText(text)
    textString:Show()
end


function UnitFramesImproved_PlayerFrame_ToPlayerArt(self)
	if not InCombatLockdown() then
		UnitFramesImproved_Style_PlayerFrame();
	end
end

function UnitFramesImproved_PlayerFrame_ToVehicleArt(self)
	if not InCombatLockdown() then
		PlayerFrameHealthBar:SetHeight(12);
		PlayerFrameHealthBarText:SetPoint("CENTER",50,3);
	end
end

function UnitFramesImproved_TargetFrame_Update(self)
	if ( not UnitPlayerControlled(self.unit) and UnitIsTapped(self.unit) and not UnitIsTappedByPlayer(self.unit) and not UnitIsTappedByAllThreatList(self.unit) ) then
		self.healthbar:SetStatusBarColor(0.5, 0.5, 0.5);
	else
		self.healthbar:SetStatusBarColor(UnitColor(self.healthbar.unit));
	end
end

function UnitFramesImproved_TargetFrame_CheckClassification(self, forceNormalTexture)
	local texture;
	local classification = UnitClassification(self.unit);
	if ( classification == "worldboss" or classification == "elite" ) then
		texture = "Interface\\Addons\\UnitFramesImproved\\Textures\\UI-TargetingFrame-Elite";
		TargetFrameToTTextureFrameTexture:SetVertexColor(1, 1, 1)
		TargetFrameTextureFrameTexture:SetVertexColor(1, 1, 1)
	elseif ( classification == "rareelite" ) then
		texture = "Interface\\Addons\\UnitFramesImproved\\Textures\\UI-TargetingFrame-Rare-Elite";
		TargetFrameToTTextureFrameTexture:SetVertexColor(1, 1, 1)
		TargetFrameTextureFrameTexture:SetVertexColor(1, 1, 1)
	elseif ( classification == "rare" ) then
		texture = "Interface\\Addons\\UnitFramesImproved\\Textures\\UI-TargetingFrame-Rare";
		TargetFrameToTTextureFrameTexture:SetVertexColor(1, 1, 1)
		TargetFrameTextureFrameTexture:SetVertexColor(1, 1, 1)
	else
		TargetFrameToTTextureFrameTexture:SetVertexColor(.05, .05, .05)
		TargetFrameTextureFrameTexture:SetVertexColor(.05, .05, .05)
	end
	if ( texture and not forceNormalTexture) then
		self.borderTexture:SetTexture(texture);
	else
		self.borderTexture:SetTexture("Interface\\Addons\\UnitFramesImproved\\Textures\\UI-TargetingFrame");
	end
end

function UnitFramesImproved_TargetFrame_CheckFaction(self)
	local factionGroup = UnitFactionGroup(self.unit);
	if ( UnitIsPVPFreeForAll(self.unit) ) then
		self.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
		self.pvpIcon:Hide();
		PlayerPVPIcon:Hide()
		for i=1,4 do _G["PartyMemberFrame"..i.."PVPIcon"]:Hide()end
	elseif ( factionGroup and UnitIsPVP(self.unit) and UnitIsEnemy("player", self.unit) ) then
		self.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
		self.pvpIcon:Hide();
		PlayerPVPIcon:Hide()
		for i=1,4 do _G["PartyMemberFrame"..i.."PVPIcon"]:Hide()end
	elseif ( factionGroup ) then
		self.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
		self.pvpIcon:Hide();
		PlayerPVPIcon:Hide()
		for i=1,4 do _G["PartyMemberFrame"..i.."PVPIcon"]:Hide()end
	else
		self.pvpIcon:Hide();
		PlayerPVPIcon:Hide()
		for i=1,4 do _G["PartyMemberFrame"..i.."PVPIcon"]:Hide()end
	end
end

-- Utility functions
function UnitColor(unit)
    -- Always return gray for invalid units
    if not UnitExists(unit) then 
        return 0.5, 0.5, 0.5 
    end
    
    -- DEAD/DISCONNECTED: Gray
    if UnitIsDead(unit) or UnitIsGhost(unit) or not UnitIsConnected(unit) then
        return 0.5, 0.5, 0.5
    end
    
    -- TAPPED BY OTHER PLAYER: Gray (CRITICAL FIX)
    if not UnitPlayerControlled(unit) and UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) and not UnitIsTappedByAllThreatList(unit) then
        return 0.5, 0.5, 0.5
    end
    
    -- PLAYERS: Class color
    if UnitIsPlayer(unit) then
        local _, englishClass = UnitClass(unit)
        if englishClass and RAID_CLASS_COLORS and RAID_CLASS_COLORS[englishClass] then
            local c = RAID_CLASS_COLORS[englishClass]
            return c.r, c.g, c.b
        end
    end
    
    -- NPCs: Reaction color
    if UnitIsFriend("player", unit) then
        return 0.0, 1.0, 0.0  -- Green for friendly
    elseif UnitIsEnemy("player", unit) then
        return 1.0, 0.0, 0.0  -- Red for hostile
    end
    
    return 1.0, 1.0, 0.0  -- Yellow for neutral
end

local function UpdatePartyFramesColor()
    for i = 1, MAX_PARTY_MEMBERS do
        local frameName = "PartyMemberFrame" .. i
        local frame = _G[frameName]
        if frame and frame:IsShown() then
            local healthBar = _G[frameName .. "HealthBar"]
            if healthBar then
                local unit = "party" .. i
                if UnitExists(unit) then
                    local r, g, b = UnitColor(unit)
                    healthBar:SetStatusBarColor(r, g, b)
                else
                    healthBar:SetStatusBarColor(0.5, 0.5, 0.5)
                end
            end
        end
    end
end

local partyFrameUpdater = CreateFrame("Frame")
partyFrameUpdater:RegisterEvent("PARTY_MEMBERS_CHANGED")
partyFrameUpdater:RegisterEvent("GROUP_ROSTER_UPDATE")
partyFrameUpdater:SetScript("OnEvent", function()
    UpdatePartyFramesColor()
end)
UpdatePartyFramesColor()

-- Bootstrap
function UnitFramesImproved_StartUp(self)
	self:SetScript('OnEvent', function(self, event) self[event](self) end);
	self:RegisterEvent('PLAYER_ENTERING_WORLD');
	self:RegisterEvent('VARIABLES_LOADED');
end

UnitFramesImproved_StartUp(UnitFramesImproved);

-- Table Dump Functions -- http://lua-users.org/wiki/TableSerialization
function print_r (t, indent, done)
  done = done or {}
  indent = indent or ''
  local nextIndent
  for key, value in pairs (t) do
    if type (value) == "table" and not done [value] then
      nextIndent = nextIndent or (indent .. string.rep(' ',string.len(tostring (key))+2))
      done [value] = true
      print (indent .. "[" .. tostring (key) .. "] => Table {");
      print  (nextIndent .. "{");
      print_r (value, nextIndent .. string.rep(' ',2), done)
      print  (nextIndent .. "}");
    else
      print  (indent .. "[" .. tostring (key) .. "] => " .. tostring (value).."")
    end
  end
end