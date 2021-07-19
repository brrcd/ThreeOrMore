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

local FIELDSIZE = 5;
local ROWSCOUNT = FIELDSIZE;
local COLUMNSCOUNT = FIELDSIZE;

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

	--game field frame
	local GameWindow = CreateFrame("Frame", "GameWindowFrame", UIConfig, "ThinBorderTemplate");
	GameWindow:SetSize(388, 312);
	GameWindow:SetPoint("CENTER", -1, -18);

	CreateCell = function(xOffset, yOffset)
		local cell = CreateFrame("Button", nil, GameWindow, "MultiBarButtonTemplate");
		local texture = cell:CreateTexture();
		local cursor;
	
		cell:SetPoint("CENTER", GameWindow, "TOPLEFT", xOffset, yOffset);
		cell:EnableMouse(true);
		cell:RegisterForDrag("LeftButton", "RightButton");
		
		texture:SetAllPoints();
		texture:SetTexture("interface/icons/inv_mushroom_11")

		cell:SetScript("OnClick", function()
			ActionButton_ShowOverlayGlow(self)
		end)
	
		return cell;
	end
	
	CreateGameField = function(columnsCount, rowsCount)
		local cellWidth = 40;
		local xOffset = 23;
		local yOffset = -23;
	
		for y = rowsCount, 1, -1 do
			for x = columnsCount, 1, -1 do
				UIConfig.cell = CreateCell(xOffset, yOffset);
				xOffset = xOffset + cellWidth;
			end
			yOffset = yOffset - cellWidth;
			xOffset = 23;
		end
	end

	UIConfig.gameField = CreateGameField(ROWSCOUNT, COLUMNSCOUNT);

	--making main frame movable
	UIConfig:SetMovable(true);
	UIConfig:EnableMouse(true);
	UIConfig:RegisterForDrag("LeftButton");
	UIConfig:SetScript("OnDragStart", UIConfig.StartMoving);
	UIConfig:SetScript("OnDragStop", UIConfig.StopMovingOrSizing);

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