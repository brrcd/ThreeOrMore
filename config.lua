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

------------------------------------------------------------------------

local FIELD_SIZE = 5;
local ROWS_COUNT = FIELD_SIZE+1;
local COLUMNS_COUNT = FIELD_SIZE+3;

Race = {
    getRace = function (index)
        return Race[index];
    end,
    "Orc",
    "Elf",
    "Undead",
    "Human",
    "Tauren",
    "Draenei",
    "BloodElf",
    "Gnome"
};

Face = {
	getFaceImage = function (index)
		return Face[index];
	end,
	"interface/icons/inv_mushroom_11",
	"interface/icons/inv_mushroom_12",
	"interface/icons/inv_mushroom_13",
	"interface/icons/inv_mushroom_09",
	"interface/icons/inv_mushroom_08",
	"interface/icons/inv_mushroom_07",
	"interface/icons/inv_mushroom_06",
	"interface/icons/inv_mushroom_10"
};

function Config:CreateButton(point, relativeFrame, relativePoint, xOffset, yOffset, text)
	local btn = CreateFrame("Button", nil, UIConfig, "GameMenuButtonTemplate");
	btn:SetPoint(point, relativeFrame, relativePoint, xOffset, yOffset);
	btn:SetSize(70, 20);
	btn:SetText(text);
	btn:SetNormalFontObject("GameFontNormalLarge");
	btn:SetHighlightFontObject("GameFontHighlightLarge");
	return btn;
end

function Config:CreateMenu()
	--main frame
	UIConfig = CreateFrame("Frame", "ThreeOrMoreMasterFrame", UIParent, "ButtonFrameTemplate");
	UIConfig:SetSize(400, 400);
	UIConfig:SetPoint("CENTER");

	--game field frame for where we placing our cells
	local GameWindow = CreateFrame("Frame", "GameWindowFrame", UIConfig, "ThinBorderTemplate");
	GameWindow:SetSize(388, 312);
	GameWindow:SetPoint("CENTER", -1, -18);

	FieldCells = {};

	-- CreateCell = function(xOffset, yOffset, index)
	-- 	local race = Race.getRace(index);
	-- 	--getting first character of race as face
	-- 	local face = string.sub(race,1,1);

	-- 	local cell = CreateFrame("Button", nil, GameWindow, "MultiBarButtonTemplate");
	-- 	local texture = cell:CreateTexture();
	
	-- 	cell:SetPoint("CENTER", GameWindow, "TOPLEFT", xOffset, yOffset);
	-- 	cell:EnableMouse(true);
	-- 	cell:RegisterForDrag("LeftButton", "RightButton");
		
	-- 	texture:SetAllPoints();
	-- 	texture:SetTexture(Face.getFaceImage(index));

	-- 	cell:SetScript("OnClick", function()
	-- 		ActionButton_ShowOverlayGlow(self)
	-- 		print("clicked", face);
	-- 	end)
	
	-- 	return {
	-- 		getRace = function (self)
	-- 			return race;
	-- 		end,
	-- 		getFace = function (self)
	-- 			return face;
	-- 		end
	-- 	};
	-- end

	CreateCell = function(xOffset, yOffset)
		local race;
		local face;
		local cell = CreateFrame("Button", nil, GameWindow, "MultiBarButtonTemplate");
		local texture = cell:CreateTexture();
	
		cell:SetPoint("CENTER", GameWindow, "TOPLEFT", xOffset, yOffset);
		cell:EnableMouse(true);
		cell:RegisterForDrag("LeftButton", "RightButton");

		cell:SetScript("OnClick", function()
			ActionButton_ShowOverlayGlow(self)
			print("clicked", face);
		end)

		return {
			setRace = function (self)
				local randomNumber = math.random(#Race);
				race = Race.getRace(randomNumber);
				face = string.sub(race,1,1);
				texture:SetAllPoints();
				texture:SetTexture(Face.getFaceImage(randomNumber));
			end,
			getRace = function (self)
				return race;
			end,
			getFace = function (self)
				return face;
			end
		}
	end
	
	CreateEmptyField = function(rowsCount, columnsCount)
		local cellWidth = 40;
		local xOffset = 23;
		local yOffset = -23;
		local counter = 0;
	
		for y = 0, rowsCount, 1 do
			for x = 0, columnsCount, 1 do
				FieldCells[counter] = CreateCell(xOffset, yOffset);
				xOffset = xOffset + cellWidth;
				counter = counter + 1;
			end
			yOffset = yOffset - cellWidth;
			xOffset = 23;
		end
	end

	FillFieldWithRaces = function()
		for x = #FieldCells, 0, -1 do
			FieldCells[x].setRace();
		end;
	end

	UIConfig.emptyField = CreateEmptyField(ROWS_COUNT, COLUMNS_COUNT);
	--UIConfig.filledField = FillFieldWithRaces();

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
	UIConfig.loadButton:SetScript("OnClick", function()
		FillFieldWithRaces()
	end);
	UIConfig.resetButton = self:CreateButton("CENTER", UIConfig, "BOTTOM", 0, 15, "Reset");
    UIConfig.saveButton = self:CreateButton("CENTER", UIConfig, "BOTTOM", 125, 15, "Hello");
    
	UIConfig:Hide();
	return UIConfig;
end