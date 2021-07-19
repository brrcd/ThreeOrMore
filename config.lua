local _, core = ...;
core.Config = {};

local Config = core.Config;
local UIConfig;

local defaults = {
	theme = {
		r = 0, 
		g = 0.8,
		b = 1,
		hex = "00ccff"
	}
}

function Config:Toggle()
	local menu = UIConfig or Config:CreateMenu();
	menu:SetShown(not menu:IsShown());
end

function Config:GetThemeColor()
	local c = defaults.theme;
	return c.r, c.g, c.b, c.hex;
end

function Config:CreateButton(point, relativeFrame, relativePoint, xOffset, yOffset, text)
	local btn = CreateFrame("Button", nil, UIConfig, "GameMenuButtonTemplate");
	btn:SetPoint(point, relativeFrame, relativePoint, xOffset, yOffset);
	btn:SetSize(70, 20);
	btn:SetText(text);
	btn:SetNormalFontObject("GameFontNormalLarge");
	btn:SetHighlightFontObject("GameFontHighlightLarge");
	return btn;
end

local isCursorChanged = false;



function Config:CreateMenu()
	--main frame
	UIConfig = CreateFrame("Frame", "ThreeOrMoreMasterFrame", UIParent, "ButtonFrameTemplate");
	UIConfig:SetSize(400, 400);
	UIConfig:SetPoint("CENTER");

	local GameWindow = CreateFrame("Frame", "GameWindowFrame", UIConfig, "ThinBorderTemplate");
	GameWindow:SetSize(388, 312);
	GameWindow:SetPoint("CENTER", -1, -18);

	CreateActionBarSlot = function(xOffset)
		local slot = CreateFrame("Frame", nil, GameWindow, "MultiBarButtonTemplate");
		local texture = slot:CreateTexture();
		local cursor;
	
		slot:SetPoint("CENTER", GameWindow, "TOPLEFT", xOffset, -23);
		slot:EnableMouse(true);
		slot:RegisterForDrag("LeftButton", "RightButton");
		
		texture:SetAllPoints();
		texture:SetTexture("interface/icons/inv_mushroom_11")
	
		return slot;
	end
	
	CreateActionBar = function(slotsQuant)
		local slotWidth = 40;
		local slotOffset = 23;
	
		for x = slotsQuant,1,-1 do
			UIConfig.slot = CreateActionBarSlot(slotOffset);
			slotOffset = slotOffset + slotWidth;
		end
	end

	UIConfig.slotBar = CreateActionBar(5);

	--making main frame movable
	-- UIConfig:SetMovable(true);
	-- UIConfig:EnableMouse(true);
	-- UIConfig:RegisterForDrag("LeftButton");
	-- UIConfig:SetScript("OnDragStart", UIConfig.StartMoving);
	-- UIConfig:SetScript("OnDragStop", UIConfig.StopMovingOrSizing);

	--portrait
	UIConfig.portrait:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CharacterCreate-Factions");

	--title
	UIConfig.TitleText:ClearAllPoints();
	UIConfig.TitleText:SetPoint("LEFT", ThreeOrMoreMasterFrameTitleBg, "LEFT", 58, 0);
	UIConfig.TitleText:SetText("Three or more");

	--bottom buttons
	UIConfig.loadButton = self:CreateButton("CENTER", UIConfig, "BOTTOM", -125, 15, "Start game");
	UIConfig.resetButton = self:CreateButton("CENTER", UIConfig, "BOTTOM", 0, 15, "Reset");
    UIConfig.saveButton = self:CreateButton("CENTER", UIConfig, "BOTTOM", 125, 15, "Hello");
    
	UIConfig:Hide();
	return UIConfig;
end