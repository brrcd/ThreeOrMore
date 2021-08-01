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
	local UIWindowWidth = 377;
	local UIWindowHeight = 375;
	--main frame
	UIConfig = CreateFrame("Frame", "ThreeOrMoreMasterFrame", UIParent, "ButtonFrameTemplate");
	UIConfig:SetSize(UIWindowWidth, UIWindowHeight);
	UIConfig:SetPoint("CENTER");

	--game field frame for our cell grid
	local GameWindow = CreateFrame("Frame", "GameWindowFrame", UIConfig, "ThinBorderTemplate");
	GameWindow:SetSize(UIWindowWidth-12, UIWindowHeight-88);
	GameWindow:SetPoint("CENTER", -1, -18);
	GameWindow:Hide();

	FieldCells = {};

	local firstRaceIndex;
	local secondRaceIndex;
	local firstCellIndex;
	local secondCellIndex;

	CreateCell = function(xOffset, yOffset, n)
		local race;
		local face;
		local index = n;
		local raceIndex;
		Cell = CreateFrame("Button", nil, UIConfig, "MultiBarButtonTemplate");
		local texture = Cell:CreateTexture();
	
		Cell:SetPoint("CENTER", GameWindow, "TOPLEFT", xOffset, yOffset);
		Cell:EnableMouse(true);
		Cell:RegisterForDrag("LeftButton", "RightButton");

		Cell:SetScript("OnClick", function()
			ActionButton_ShowOverlayGlow(self);
			if (firstRaceIndex == nil) then
				firstRaceIndex = raceIndex;
				firstCellIndex = index;
				print("first cell", firstRaceIndex, firstCellIndex);
			elseif (firstRaceIndex ~= nil and secondRaceIndex == nil) then
				secondRaceIndex = raceIndex;
				secondCellIndex = index;
				print("second cell", secondRaceIndex, secondCellIndex);
				if (math.abs(firstCellIndex - secondCellIndex) == 1 or 
				math.abs(firstCellIndex - secondCellIndex) == (COLUMNS_COUNT + 1)) then
					print("start swap");
					FieldCells[firstCellIndex].setRace(secondRaceIndex);
					FieldCells[secondCellIndex].setRace(firstRaceIndex);
					print("good?");
				else
					print("select other cell")
				end;
				firstRaceIndex = nil;
				secondRaceIndex = nil;
			end
		end)

		return {
			setRandomRace = function (self)
				local randomNumber = math.random(#Race);
				race = Race.getRace(randomNumber);
				face = string.sub(race,1,1);
				raceIndex = randomNumber;
				texture:SetAllPoints();
				texture:SetTexture(Face.getFaceImage(randomNumber));
			end,
			setRace = function (raceNum)
				race = Race.getRace(raceNum);
				face = string.sub(race,1,1);
				raceIndex = raceNum;
				texture:SetAllPoints();
				texture:SetTexture(Face.getFaceImage(raceNum));
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
				FieldCells[counter] = CreateCell(xOffset, yOffset, counter);
				xOffset = xOffset + cellWidth;
				counter = counter + 1;
			end
			yOffset = yOffset - cellWidth;
			xOffset = 23;
		end
	end

	FillFieldWithRaces = function()
        local rowsDoublesCount = 0;
        local prevRowCell;

        --initialize table for column doubles
		local prevColumnCell = {};
        local cX = COLUMNS_COUNT;
        local columnDoublesCount = {};
        for x = 0, cX, 1 do
            columnDoublesCount[x] = 0;
        end

		for x = 0, #FieldCells, 1 do
			FieldCells[x].setRandomRace();
			if (x > 1 and prevRowCell == FieldCells[x].getRace()) then
				rowsDoublesCount = rowsDoublesCount + 1;
			end;
			while (rowsDoublesCount == 1) do
				FieldCells[x].setRandomRace();
				rowsDoublesCount = 0;
			end;
			prevRowCell = FieldCells[x].getRace();
			-- TODO: column doubles checking
		end;
	end

	UIConfig.emptyField = CreateEmptyField(ROWS_COUNT, COLUMNS_COUNT);

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
	UIConfig.loadButton:SetSize(90, 20);
	UIConfig.loadButton:SetScript("OnClick", function()
		FillFieldWithRaces();
		firstRaceIndex = nil;
		secondRaceIndex = nil;
	end);
	UIConfig.resetButton = self:CreateButton("CENTER", UIConfig, "BOTTOM", 0, 15, "Reset");
    UIConfig.helloButton = self:CreateButton("CENTER", UIConfig, "BOTTOM", 125, 15, "Hello");
	UIConfig.helloButton:SetScript("OnClick", function ()
		print("Зачем ты нажал сюда?");
	end)
    
	UIConfig:Hide();
	return UIConfig;
end