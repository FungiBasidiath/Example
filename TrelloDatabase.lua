--This gets Data from a trello board and turns it into a table.
-- Discord name: WLncstr
-- ROBLOX NAME: TheSingularFungi
local houses = {}


local HouseData = { --This creates the basic tables with all the kingdoms. 
	["Soren"] = {

	},
	["Creithee"] = {

	},
	["Thaelarious"] = {

	},
}


function houses.Init()
	local https = game:GetService("HttpService")
	local api = require(game.ServerScriptService:WaitForChild("TrelloAPI"))
	local treldata = api:GetBoardID("BallaydenData") --gets the trello
	--Getting Houses
	local SorenNames = api:GetCardsInList(api:GetListID("Soren Houses",treldata))--this gets some of the houses
	local CreitheeNames = api:GetCardsInList(api:GetListID("Creithee Houses",treldata))--this gets some of the houses
	local ThaelariousNames = api:GetCardsInList(api:GetListID("Thaelarious Houses",treldata)) --this gets some of the houses
	local AllHouses = {}

	for i,v in pairs(SorenNames) do
		table.insert(AllHouses,SorenNames[i])
	end
	for i,v in pairs(CreitheeNames) do
		table.insert(AllHouses,CreitheeNames[i])
	end
	for i,v in pairs(ThaelariousNames) do
		table.insert(AllHouses,ThaelariousNames[i])
	end
	--These insert the houses into the 'allhouses' table



	for Kingdom,Value in pairs(HouseData) do
		for index,card in pairs(api:GetCardsInList(api:GetListID(Kingdom.." Houses",treldata))) do
			local id = api:GetCardID(card.name,treldata)
			local Datas = string.split(card.desc,"|-|")
			for i,v in pairs(Datas) do 
				Datas[i] = v.."|-|" 
			end 
			local TableWomb = {
				[card.name] = {
					["Name"] = card.name,
					["Pedigree"] = "",
					["Kingdom"] = "",
					["Treasure"] = "",
					["Nobility"] = "",
					["Status"] = "",
				}--Creates basic template for house. 
			}

			local function AddNewData(D,V)--this is used to a new data  thingy to the house in the trello.  
				--print(card.desc..D..V.."|-|")
				for i,v in pairs(Datas) do
					if string.find(string.gsub(v,"|-|",""),D) then
						return false
					end
				end
				api:EditCard(
					id,
					card.name,
					card.desc..D..V.."|-|"
				)
				task.wait(1)
			end
			local function GetDataPiece(keyword) --This whole functions goes through the string and takes out all the unnecessary crap. Then it returns the ultimate value of the data.
				for _,D in pairs(Datas) do

					if string.find(D,keyword) then
						local returnD = string.gsub(D,keyword,"")
						if keyword == "Status" then
							returnD = string.gsub(returnD," ","")
							returnD = string.gsub(returnD,"|-|","")
							returnD = string.gsub(returnD,":","")
							returnD = string.gsub(returnD,";;"," ")
						else
							returnD = string.gsub(returnD," ","")
							returnD = string.gsub(returnD,"|-|","")
							returnD = string.gsub(returnD,":","")
							returnD = string.gsub(returnD,"-","")
							returnD = string.gsub(returnD,";;"," ")
							returnD = string.gsub(returnD,"{{","-")
						end
						return returnD
					end
				end
			end
			local function Filter() -- this just filters stuff i wanna filter. 

				local returnD = card.desc
				returnD = string.gsub(returnD,"Low-Class","Low{{Class")
				print(returnD)
				api:EditCard(
					id,
					card.name,
					returnD
				)

			end
			local function GetDataPieceUnfiltered(keyword) -- this just gets the ulfiltered data. 
				for _,D in pairs(Datas) do
					if string.find(D,keyword) then
						local returnD = string.gsub(D,"|-|","")
						return returnD
					end
				end
			end
			local function Remove(keyword) --this removes things from the card description, thus, taking away the data. It can be used if something goes wrong and the script spams things into the trello cards.
				if keyword == nil then return end
				local newdesc = string.gsub(card.desc,keyword,"")
				print(newdesc)
				api:EditCard(
					id,
					card.name,
					newdesc
				)
			end

			for i,v in pairs(TableWomb[card.name]) do
				if v ~= card.name then 
					TableWomb[card.name][i] = GetDataPiece(i)
				end
			end
			AddNewData("Pedigree: ","0")
			AddNewData("Kingdom: ",Kingdom)
			AddNewData("Treasure: ","0")
			AddNewData("Head Of House","NA")
			--Remove(GetDataPieceUnfiltered("Nobility"))
			AddNewData("Status: ","Low-Class")
			Filter()
			HouseData[GetDataPiece("Kingdom")][card.name] = TableWomb[card.name]

		end
	end	
	game.ReplicatedStorage.HousesLoaded.Value = true

end

function houses.ReturnData()
	return HouseData
end

return houses
