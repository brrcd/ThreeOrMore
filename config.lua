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
    "NightElf",
    "Undead",
    "Human",
    "Tauren",
    "Draenei",
    "BloodElf",
    "Gnome",
	"Troll",
	"Dwarf"
};

-- SORT RACES CORRECTLY
Face = {
	getFaceImage = function (index)
		return Face[index];
	end,
	"interface/addons/threeormore/art/orc_bg",
	"interface/addons/threeormore/art/nightelf_bg",
	"interface/addons/threeormore/art/undead_bg",
	"interface/addons/threeormore/art/human_bg",
	"interface/addons/threeormore/art/tauren_bg",
	"interface/addons/threeormore/art/draenei_bg",
	"interface/addons/threeormore/art/bloodelf_bg",
	"interface/addons/threeormore/art/gnome_bg",
	"interface/addons/threeormore/art/troll_bg",
	"interface/addons/threeormore/art/dwarf_bg"
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

	--glow effect for our button
	local GlowButton = function (parent)
		GlowButtonEffect = CreateFrame("Frame", "GlowEffect", parent, "GlowBorderTemplate");
		GlowButtonEffect:SetSize(40, 40);
		GlowButtonEffect:SetPoint("CENTER");

		return{
			hideGlow = function ()
				GlowButtonEffect:Hide();
			end
		}
	end

	FieldCells = {};
	CellsArray = {};

	local swap_two_cells = function (fc, sc, fr, sr)
		print("Начало смены клеток.");
		FieldCells[fc].setRace(sr);
		FieldCells[sc].setRace(fr);
		print("Конец смены клеток.");
	end

	--column checkin
	local chk_col_top = function (f_index, s_index)
		return FieldCells[s_index+COLUMNS_COUNT+1].getRace() ==
		FieldCells[s_index+2*(COLUMNS_COUNT+1)].getRace() and
		FieldCells[s_index+2*(COLUMNS_COUNT+1)].getRace() ==
		FieldCells[f_index].getRace();
	end

	local chk_col_mid = function (f_index, s_index)
		return FieldCells[s_index-COLUMNS_COUNT-1].getRace() ==
		FieldCells[s_index+COLUMNS_COUNT+1].getRace() and
		FieldCells[s_index+COLUMNS_COUNT+1].getRace() ==
		FieldCells[f_index].getRace();
	end

	local chk_col_bot = function (f_index, s_index)
		return FieldCells[s_index-COLUMNS_COUNT-1].getRace() ==
		FieldCells[s_index-2*(COLUMNS_COUNT+1)].getRace() and
		FieldCells[s_index-2*(COLUMNS_COUNT+1)].getRace() ==
		FieldCells[f_index].getRace();
	end

	--row checking
	local chk_row_left = function (f_index, s_index)
		return FieldCells[s_index+1].getRace() ==
		FieldCells[s_index+2].getRace() and
		FieldCells[s_index+1].getRace() ==
		FieldCells[f_index].getRace();
	end

	local chk_row_mid = function (f_index, s_index)
		return FieldCells[s_index-1].getRace() ==
		FieldCells[s_index+1].getRace() and
		FieldCells[s_index+1].getRace() ==
		FieldCells[f_index].getRace();
	end

	local chk_row_right = function (f_index, s_index)
		return FieldCells[s_index-1].getRace() ==
		FieldCells[s_index-2].getRace() and
		FieldCells[s_index-1].getRace() ==
		FieldCells[f_index].getRace();
	end

	local chk_horizontal = function (f_c, s_c, f_r, s_r)
		--if we swap at first row to prevent crash
		if (s_c <= COLUMNS_COUNT) then
			if(chk_col_top(f_c, s_c)) then
				swap_two_cells(f_c,s_c,f_r,s_r);
			end
		--same for last
		elseif (s_c >= ((COLUMNS_COUNT+1) * ROWS_COUNT)) then
			if(chk_col_bot(f_c, s_c)) then
				swap_two_cells(f_c,s_c,f_r,s_r);
			end
		--second from top
		elseif (s_c > COLUMNS_COUNT and s_c < ((COLUMNS_COUNT+1)*2)) then
			if(chk_col_top(f_c, s_c) or chk_col_mid(f_c, s_c)) then
				swap_two_cells(f_c,s_c,f_r,s_r);
			end
		--second from bot
		elseif (s_c >= ((COLUMNS_COUNT+1) * (ROWS_COUNT-1)) and
			s_c < ((COLUMNS_COUNT+1) * ROWS_COUNT)) then
			if(chk_col_mid(f_c, s_c) or chk_col_bot(f_c, s_c)) then
				swap_two_cells(f_c,s_c,f_r,s_r);
			end
		elseif (chk_col_top(f_c, s_c) or
			chk_col_mid(f_c, s_c) or
			chk_col_bot(f_c, s_c)) then
				swap_two_cells(f_c,s_c,f_r,s_r);
		else
			print("horizontal")
		end
	end

	local chk_vertical = function (f_c, s_c, f_r, s_r)
		--if we swap at first column to prevent crash
		if (math.fmod((s_c+(COLUMNS_COUNT+1)), (COLUMNS_COUNT+1)) == 0) then
			if(chk_row_left(f_c, s_c)) then
				swap_two_cells(f_c,s_c,f_r,s_r);
			end
		elseif (math.fmod((s_c+(COLUMNS_COUNT+1)), (COLUMNS_COUNT+1)) == 1) then
			if(chk_row_left(f_c, s_c) or chk_row_mid(f_c, s_c)) then
				swap_two_cells(f_c,s_c,f_r,s_r);
			end
		elseif (math.fmod((s_c+(COLUMNS_COUNT+1)), (COLUMNS_COUNT+1)) == (COLUMNS_COUNT-1)) then
			if(chk_row_mid(f_c, s_c) or chk_row_right(f_c, s_c)) then
				swap_two_cells(f_c,s_c,f_r,s_r);
			end
		elseif (math.fmod((s_c+(COLUMNS_COUNT+1)), (COLUMNS_COUNT+1)) == COLUMNS_COUNT) then
			if(chk_row_right(f_c, s_c)) then
				swap_two_cells(f_c,s_c,f_r,s_r);
			end
		elseif (chk_row_left(f_c, s_c) or
			chk_row_mid(f_c, s_c) or
			chk_row_right(f_c, s_c)) then
				swap_two_cells(f_c,s_c,f_r,s_r);
		else
			print("vertical")
		end
	end

	local f_R;
	local s_R;
	local f_C;
	local s_C;
	local glow_button

	CreateCell = function(xOffset, yOffset, n)
		local race;
		local index = n;
		local index_RACE;
		Cell = CreateFrame("Button", nil, UIConfig, "MultiBarButtonTemplate");
		local texture = Cell:CreateTexture();
		local cell = Cell;
		CellsArray[index] = cell;
	
		Cell:SetPoint("CENTER", GameWindow, "TOPLEFT", xOffset, yOffset);
		Cell:EnableMouse(true);
		Cell:RegisterForDrag("LeftButton", "RightButton");

		Cell:SetScript("OnClick", function()
			ActionButton_ShowOverlayGlow(self);

			--this one swaps cells
			if (f_R == nil) then
				f_R = index_RACE;
				f_C = index;
				--creating glow effect on first click
				glow_button = GlowButton(CellsArray[index]);
				print("Первая клетка расы :", race, ". Под индексом :", index);
			elseif (f_R ~= nil and s_R == nil) then
				s_R = index_RACE;
				s_C = index;
				--hiding glow effect on second click
				glow_button.hideGlow();
				print("Вторая клетка расы :", race, ". Под индексом :", index);

				--checking if we clicking neighbour cells
				if (math.abs(f_C - s_C) == 1 or math.abs(f_C - s_C) == (COLUMNS_COUNT + 1)) then
					chk_horizontal(f_C, s_C, f_R, s_R);
					chk_vertical(f_C, s_C, f_R, s_R);
				else
					print("select other cell")
				end;

				f_R = nil;
				s_R = nil;
			end
		end)

		return {
			setRandomRace = function (self)
				local rand_num = math.random(#Race);
				race = Race.getRace(rand_num);
				index_RACE = rand_num;
				texture:SetAllPoints();
				texture:SetTexture(Face.getFaceImage(rand_num));
			end,
			setRace = function (race_index)
				race = Race.getRace(race_index);
				index_RACE = race_index;
				texture:SetAllPoints();
				texture:SetTexture(Face.getFaceImage(race_index));
			end,
			getRace = function (self)
				return race;
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
		f_R = nil;
		s_R = nil;
	end);
	UIConfig.resetButton = self:CreateButton("CENTER", UIConfig, "BOTTOM", 0, 15, "Reset");
    UIConfig.helloButton = self:CreateButton("CENTER", UIConfig, "BOTTOM", 125, 15, "Hello");
	UIConfig.helloButton:SetScript("OnClick", function ()
		print("Зачем ты нажал сюда?");
	end)
	UIConfig:Hide();
	return UIConfig;
end