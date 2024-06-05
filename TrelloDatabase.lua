-- This gets Data from a Trello board and turns it into a table.
-- Discord name: WLncstr
-- ROBLOX NAME: TheSingularFungi
local houses = {}
local HouseData = {} -- This will be our table with metatable functionality

local mt = {
    __index = function(table, key)
        if HouseData[key] then
            return HouseData[key]
        else
            HouseData[key] = {
                Name = key,
                Pedigree = "",
                Kingdom = "",
                Treasure = "",
                Nobility = "",
                Status = "",
            }
            return HouseData[key]
        end
    end
}

setmetatable(houses, mt)

function houses.Init()
    local https = game:GetService("HttpService")
    local api = require(game.ServerScriptService:WaitForChild("TrelloAPI"))
    local treldata = api:GetBoardID("BallaydenData") -- gets the Trello board

    -- Getting Houses
    local SorenNames = api:GetCardsInList(api:GetListID("Soren Houses", treldata)) -- this gets some of the houses
    local CreitheeNames = api:GetCardsInList(api:GetListID("Creithee Houses", treldata)) -- this gets some of the houses
    local ThaelariousNames = api:GetCardsInList(api:GetListID("Thaelarious Houses", treldata)) -- this gets some of the houses
    local AllHouses = {}

    for i, v in pairs(SorenNames) do
        table.insert(AllHouses, SorenNames[i])
    end
    for i, v in pairs(CreitheeNames) do
        table.insert(AllHouses, CreitheeNames[i])
    end
    for i, v in pairs(ThaelariousNames) do
        table.insert(AllHouses, ThaelariousNames[i])
    end
    -- These insert the houses into the 'AllHouses' table

    for _, card in pairs(AllHouses) do
        local id = api:GetCardID(card.name, treldata)
        local Datas = string.split(card.desc, "|-|")
        for i, v in pairs(Datas) do
            Datas[i] = v .. "|-|"
        end
        local TableWomb = houses[card.name]

        local function AddNewData(D, V) -- this is used to add a new data thingy to the house in the Trello.
            for i, v in pairs(Datas) do
                if string.find(string.gsub(v, "|-|", ""), D) then
                    return false
                end
            end
            api:EditCard(
                id,
                card.name,
                card.desc .. D .. V .. "|-|"
            )
            task.wait(1)
        end

        local function GetDataPiece(keyword) -- This function goes through the string and extracts the relevant data.
            for _, D in pairs(Datas) do
                if string.find(D, keyword) then
                    local returnD = string.gsub(D, keyword, "")
                    if keyword == "Status" then
                        returnD = string.gsub(returnD, " ", "")
                        returnD = string.gsub(returnD, "|-|", "")
                        returnD = string.gsub(returnD, ":", "")
                        returnD = string.gsub(returnD, ";;", " ")
                    else
                        returnD = string.gsub(returnD, " ", "")
                        returnD = string.gsub(returnD, "|-|", "")
                        returnD = string.gsub(returnD, ":", "")
                        returnD = string.gsub(returnD, "-", "")
                        returnD = string.gsub(returnD, ";;", " ")
                        returnD = string.gsub(returnD, "{{", "-")
                    end
                    return returnD
                end
            end
        end

        local function Filter() -- This filters data.
            local returnD = card.desc
            returnD = string.gsub(returnD, "Low-Class", "Low{{Class")
            print(returnD)
            api:EditCard(
                id,
                card.name,
                returnD
            )
        end

        local function GetDataPieceUnfiltered(keyword) -- This gets the unfiltered data.
            for _, D in pairs(Datas) do
                if string.find(D, keyword) then
                    local returnD = string.gsub(D, "|-|", "")
                    return returnD
                end
            end
        end

        local function Remove(keyword) -- This removes data from the card description.
            if keyword == nil then return end
            local newdesc = string.gsub(card.desc, keyword, "")
            print(newdesc)
            api:EditCard(
                id,
                card.name,
                newdesc
            )
        end

        for i, v in pairs(TableWomb) do
            if v ~= card.name then 
                TableWomb[i] = GetDataPiece(i)
            end
        end
        AddNewData("Pedigree: ", "0")
        AddNewData("Kingdom: ", card.name)
        AddNewData("Treasure: ", "0")
        AddNewData("Head Of House", "NA")
        -- Remove(GetDataPieceUnfiltered("Nobility"))
        AddNewData("Status: ", "Low-Class")
        Filter()
    end

    game.ReplicatedStorage.HousesLoaded.Value = true
end

function houses.ReturnData()
    return HouseData
end

return houses
