local FIELD_SIZE = 5;
local ROW_COUNT = FIELD_SIZE;
local COLUMN_COUNT = FIELD_SIZE;

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

function Cell(index)
    local race = Race.getRace(index);
    local face = string.sub(race,1,1);
    return {
        getRace = function (self)
            return race;
        end,
        getFace = function (self)
            return face;
        end
    }
end

GameField = {
    initialFill = function ()
        local rowsDoublesCount = 0;
        local prevRowCell;
        local prevColumnCell = {};
        --initialize table for column doubles
        local cX = COLUMN_COUNT;
        local columnDoublesCount = {};
        for x = 0, cX, 1 do
            columnDoublesCount[x] = 0;
        end
        --filing field with Race faces
        for x = 1, ROW_COUNT*cX, 1 do
            GameField[x] = Cell(math.random(#Race));
            --checking for row doubles
            if (x > 1 and prevRowCell == GameField[x].getFace()) then
                rowsDoublesCount = rowsDoublesCount + 1;
            end
            while (rowsDoublesCount == 1) do
                GameField[x] = Cell(math.random(#Race));
                rowsDoublesCount = 0;
            end
            --checking for column doubles
            if (x > cX and prevColumnCell[x - cX] == GameField[x].getFace()) then
                columnDoublesCount[x % cX] = columnDoublesCount[x % cX] + 1;
            end
            while (columnDoublesCount[x % cX] == 1) do
                GameField[x] = Cell(math.random(#Race));
                columnDoublesCount[x % cX] = 0;
            end
            --saving previous cell for further checking
            prevRowCell = GameField[x].getFace();
            prevColumnCell[x] = GameField[x].getFace();
        end
    end,
}