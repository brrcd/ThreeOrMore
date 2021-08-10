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
local ROW_X = FIELD_SIZE+1;
local COL_X = FIELD_SIZE+3;

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
			end,
			showGlow = function ()
				GlowButtonEffect:Show();
			end
		}
	end

	FieldCells = {}; --CreateCell function Array
	CellsArrayForGlow = {}; --Cell array
	local master_cell;
	local direction; --horizontal 0 or vertical 1 swap
	local swap_done = false;
	local master_cell_position; --top/left 0, mid 1 or bot/right 2

	local swap_two_cells = function (fc, sc, fr, sr)
		print("Начало смены клеток.");
		FieldCells[fc].setRace(sr);
		FieldCells[sc].setRace(fr);
		master_cell = sc;
		swap_done = true;
		print("Конец смены клеток.");
	end

	--column checking for match three to allow swap
		--if our cell is first from top check
	local chk_col_top = function (f_index, s_index)
		print(FieldCells[s_index+COL_X+1].getRace() ==
		FieldCells[s_index+2*(COL_X+1)].getRace() and
		FieldCells[s_index+2*(COL_X+1)].getRace() ==
		FieldCells[f_index].getRace());
		return FieldCells[s_index+COL_X+1].getRace() ==
		FieldCells[s_index+2*(COL_X+1)].getRace() and
		FieldCells[s_index+2*(COL_X+1)].getRace() ==
		FieldCells[f_index].getRace();
	end

		--if our cell is at middle
	local chk_col_mid = function (f_index, s_index)
		print(FieldCells[s_index-COL_X-1].getRace() ==
		FieldCells[s_index+COL_X+1].getRace() and
		FieldCells[s_index+COL_X+1].getRace() ==
		FieldCells[f_index].getRace());
		return FieldCells[s_index-COL_X-1].getRace() ==
		FieldCells[s_index+COL_X+1].getRace() and
		FieldCells[s_index+COL_X+1].getRace() ==
		FieldCells[f_index].getRace();
	end

		--if our cell is last from top check
	local chk_col_bot = function (f_index, s_index)
		print(FieldCells[s_index-COL_X-1].getRace() ==
		FieldCells[s_index-2*(COL_X+1)].getRace() and
		FieldCells[s_index-2*(COL_X+1)].getRace() ==
		FieldCells[f_index].getRace());
		return FieldCells[s_index-COL_X-1].getRace() ==
		FieldCells[s_index-2*(COL_X+1)].getRace() and
		FieldCells[s_index-2*(COL_X+1)].getRace() ==
		FieldCells[f_index].getRace();
	end

	--row checking
	local chk_row_left = function (f_index, s_index)
		print(FieldCells[s_index+1].getRace() ==
		FieldCells[s_index+2].getRace() and
		FieldCells[s_index+1].getRace() ==
		FieldCells[f_index].getRace());
		return FieldCells[s_index+1].getRace() ==
		FieldCells[s_index+2].getRace() and
		FieldCells[s_index+1].getRace() ==
		FieldCells[f_index].getRace();
	end

	local chk_row_mid = function (f_index, s_index)
		print(FieldCells[s_index-1].getRace() ==
		FieldCells[s_index+1].getRace() and
		FieldCells[s_index+1].getRace() ==
		FieldCells[f_index].getRace());
		return FieldCells[s_index-1].getRace() ==
		FieldCells[s_index+1].getRace() and
		FieldCells[s_index+1].getRace() ==
		FieldCells[f_index].getRace();
	end

	local chk_row_right = function (f_index, s_index)
		print(FieldCells[s_index-1].getRace() ==
		FieldCells[s_index-2].getRace() and
		FieldCells[s_index-1].getRace() ==
		FieldCells[f_index].getRace());
		return FieldCells[s_index-1].getRace() ==
		FieldCells[s_index-2].getRace() and
		FieldCells[s_index-1].getRace() ==
		FieldCells[f_index].getRace();
	end

	local chk_horizontal = function (f_c, s_c, f_r, s_r)
		if (swap_done == false) then
			print("hori chk")
			--if we swap at first row to prevent crash
			if (s_c <= COL_X) then
				if(chk_col_top(f_c, s_c)) then
					print("hori 0");
					swap_two_cells(f_c,s_c,f_r,s_r);
					direction = 0;
					master_cell_position = 0;
				end
			--same for last
			elseif (s_c >= ((COL_X+1) * ROW_X)) then
				if(chk_col_bot(f_c, s_c)) then
					print("hori x");
					swap_two_cells(f_c,s_c,f_r,s_r);
					direction = 0;
					master_cell_position = 2;
				end
			--second from top
			elseif (s_c > COL_X and s_c < ((COL_X+1)*2)) then
				if(chk_col_top(f_c, s_c) or chk_col_mid(f_c, s_c)) then
					if (chk_col_top(f_c, s_c)) then
						master_cell_position = 0;
					elseif (chk_col_mid(f_c, s_c)) then
						master_cell_position = 1;
					end
					print("hori 1");
					swap_two_cells(f_c,s_c,f_r,s_r);
					direction = 0;
				end
			--second from bot
			elseif (s_c >= ((COL_X+1) * (ROW_X-1)) and
				s_c < ((COL_X+1) * ROW_X)) then
				if(chk_col_mid(f_c, s_c) or chk_col_bot(f_c, s_c)) then
					if(chk_col_mid(f_c, s_c)) then
						master_cell_position = 1;
					elseif (chk_col_bot(f_c, s_c)) then
						master_cell_position = 2;
					end
					print("hori x-1");
					swap_two_cells(f_c,s_c,f_r,s_r);
					direction = 0;
				end
			elseif (chk_col_top(f_c, s_c) or chk_col_mid(f_c, s_c) or chk_col_bot(f_c, s_c)) then
				if(chk_col_top(f_c, s_c)) then
					master_cell_position = 0;
				elseif (chk_col_mid(f_c, s_c)) then
					master_cell_position = 1;
				elseif (chk_col_bot(f_c, s_c)) then
					master_cell_position = 2;
				end
					print("hori 0-x");
					swap_two_cells(f_c,s_c,f_r,s_r);
					direction = 0;
			end
		end
	end

	local chk_vertical = function (f_c, s_c, f_r, s_r)
		if (swap_done == false) then
			print("vert chk")
					--first column
			if (math.fmod((s_c+(COL_X+1)), (COL_X+1)) == 0) then
				if(chk_row_left(f_c, s_c)) then
					print("vert 0");
					swap_two_cells(f_c,s_c,f_r,s_r);
					direction = 1;
					master_cell_position = 0;
				end
			--second
			elseif (math.fmod((s_c+(COL_X+1)), (COL_X+1)) == 1) then
				if(chk_row_left(f_c, s_c) or chk_row_mid(f_c, s_c)) then
					if (chk_row_left(f_c, s_c)) then
						master_cell_position = 0;
					elseif (chk_row_mid(f_c, s_c)) then
						master_cell_position = 1;
					end
					print("vert 1");
					swap_two_cells(f_c,s_c,f_r,s_r);
					direction = 1;
				end
			--penult
			elseif (math.fmod((s_c+(COL_X+1)), (COL_X+1)) == (COL_X-1)) then
				if(chk_row_mid(f_c, s_c) or chk_row_right(f_c, s_c)) then
					if (chk_row_mid(f_c, s_c)) then
						master_cell_position = 1;
					elseif (chk_row_right(f_c, s_c)) then
						master_cell_position = 2;
					end
					print("vert x-1");
					swap_two_cells(f_c,s_c,f_r,s_r);
					direction = 1;
				end
			--last
			elseif (math.fmod((s_c+(COL_X+1)), (COL_X+1)) == COL_X) then
				if(chk_row_right(f_c, s_c)) then
					print("vert x");
					swap_two_cells(f_c,s_c,f_r,s_r);
					direction = 1;
					master_cell_position = 2;
				end
			elseif (chk_row_left(f_c, s_c) or chk_row_mid(f_c, s_c) or chk_row_right(f_c, s_c)) then
				if(chk_row_left(f_c, s_c)) then
					master_cell_position = 0;
				elseif (chk_row_mid(f_c, s_c)) then
					master_cell_position = 1;
				elseif (chk_row_right(f_c, s_c)) then
					master_cell_position = 2;
				end
					print("vert 0-x");
					swap_two_cells(f_c,s_c,f_r,s_r);
					direction = 1;
			end
		end
	end

	local f_R; --first cell race
	local s_R; --second cell race
	local f_C; --first cell
	local s_C; --second cell
	local glow_button

	CreateCell = function(xOffset, yOffset, n)
		local race;
		local index = n;
		local index_RACE; --we are getting it on Cell creation
		Cell = CreateFrame("Button", nil, UIConfig, "MultiBarButtonTemplate");
		local texture = Cell:CreateTexture();
		-- local cell = Cell;
		CellsArrayForGlow[index] = Cell;
	
		Cell:SetPoint("CENTER", GameWindow, "TOPLEFT", xOffset, yOffset);
		Cell:EnableMouse(true);
		Cell:RegisterForDrag("LeftButton", "RightButton");

		Cell:SetScript("OnClick", function()

			--this one swaps cells
			if (f_R == nil) then
				f_R = index_RACE;
				f_C = index;
				--creating glow effect on first click
				glow_button = GlowButton(CellsArrayForGlow[index]);
				print("Первая клетка расы :", race, ". Под индексом :", index);
			elseif (f_R ~= nil and s_R == nil) then
				s_R = index_RACE;
				s_C = index;
				--hiding glow effect on second click
				glow_button.hideGlow();
				print("Вторая клетка расы :", race, ". Под индексом :", index);

				--checking if we clicking neighbour cells
				if (math.abs(f_C - s_C) == 1 or math.abs(f_C - s_C) == (COL_X + 1) and swap_done == false) then
					chk_horizontal(f_C, s_C, f_R, s_R);
					chk_vertical(f_C, s_C, f_R, s_R);
					chk_horizontal(s_C, f_C, s_R, f_R);
					chk_vertical(s_C, f_C, s_R, f_R);
					--TODO: fix nil exceptions
					if(swap_done) then
						print(direction);
						print(master_cell_position);
						if (direction == 0 and master_cell_position == 0) then
							FieldCells[master_cell].setRandomRace();
							FieldCells[master_cell+(COL_X+1)].setRandomRace();
							FieldCells[master_cell+(2*(COL_X+1))].setRandomRace();
						elseif (direction == 1 and master_cell_position == 0) then
							FieldCells[master_cell].setRandomRace();
							FieldCells[master_cell+1].setRandomRace();
							FieldCells[master_cell+2].setRandomRace();
						end
						if (direction == 0 and master_cell_position == 1) then
							FieldCells[master_cell].setRandomRace();
							FieldCells[master_cell+(COL_X+1)].setRandomRace();
							FieldCells[master_cell-(COL_X+1)].setRandomRace();
						elseif (direction == 1 and master_cell_position == 1) then
							FieldCells[master_cell].setRandomRace();
							FieldCells[master_cell+1].setRandomRace();
							FieldCells[master_cell-1].setRandomRace();
						end
						if (direction == 0 and master_cell_position == 2) then
							FieldCells[master_cell].setRandomRace();
							FieldCells[master_cell-(COL_X+1)].setRandomRace();
							FieldCells[master_cell-(2*(COL_X+1))].setRandomRace();
						elseif (direction == 1 and master_cell_position == 2) then
							FieldCells[master_cell].setRandomRace();
							FieldCells[master_cell-1].setRandomRace();
							FieldCells[master_cell-2].setRandomRace();
						end
						swap_done = false;
					end
				else
					print("Неподходящая клетка!")
				end;
				
				f_R = nil;
				s_R = nil;
			end
		end)

		return {
			setRandomRace = function (self)
				local rand_num = math.random(#Race-2);
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
        local row_dbl_COUNT = 0;
        local prev_row_CELL;

        --initialize table for column doubles
		local prev_col_CELL = {};
        local cX = COL_X;
        local col_dbl_COUNT = {};
        for x = 0, cX, 1 do
            col_dbl_COUNT[x] = 0;
        end

		for x = 0, #FieldCells, 1 do
			FieldCells[x].setRandomRace();
			--row double checking to prevent cases with 3 in a row on field generation
			if (x > 1 and prev_row_CELL == FieldCells[x].getRace()) then
				row_dbl_COUNT = row_dbl_COUNT + 1;
			end;
			while (row_dbl_COUNT == 1) do
				FieldCells[x].setRandomRace();
				row_dbl_COUNT = 0;
			end;
			--column double checking
			if (x > cX and prev_col_CELL[x-(cX+1)] == FieldCells[x].getRace()) then
				col_dbl_COUNT[math.fmod(x, (cX+1))] = col_dbl_COUNT[math.fmod(x, (cX+1))] + 1;
			end
			while (col_dbl_COUNT[math.fmod(x, (cX+1))] == 1) do
				FieldCells[x].setRandomRace();
				col_dbl_COUNT[math.fmod(x, (cX+1))] = 0;
			end
			prev_row_CELL = FieldCells[x].getRace();
			prev_col_CELL[x] = FieldCells[x].getRace();
		end;
	end

	UIConfig.emptyField = CreateEmptyField(ROW_X, COL_X);

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
		print(#GlowButtonsArray, #FieldCells)
	end);

	UIConfig.resetButton = self:CreateButton("CENTER", UIConfig, "BOTTOM", 0, 15, "Reset");

    UIConfig.helloButton = self:CreateButton("CENTER", UIConfig, "BOTTOM", 125, 15, "Hello");
	UIConfig.helloButton:SetScript("OnClick", function ()
		print("Зачем ты нажал сюда?");
	end)
	UIConfig:Hide();
	
	return UIConfig;
end