local cService = game:GetService("CollectionService")
local repStore = game:GetService("ReplicatedStorage")
local config = require(repStore:WaitForChild("Config"):WaitForChild("configTutorial"))
local tService = game:GetService("TweenService")
intBoxFuncList = {}

function intBoxFuncList.startFunctions(gui,boxHolders)
    for i,v in pairs (game.Workspace:GetDescendants()) do
        if string.sub(v.Name,1,12) == config["MainIdentifierName"] and v.ClassName == "BoolValue" then
            cService:AddTag(v.Parent,config["MainIdentifierName"])
            local clone = gui:Clone()
            clone.Parent = v.Parent
            if v:FindFirstChild(config["TypeIdentifierName"]) then
                cService:AddTag(v.Parent,v.Type.Value)
            if v:FindFirstChild(config["ItemTypeIdentifierName"]) then
                cService:AddTag(v.Parent,config["SpawnItemTypeIdentifier"])
            end
            end
        elseif string.sub(v.Name,1,4) == "Move" and v.ClassName == "Part" then
            table.insert(boxHolders,v)
        end
    end
end

function intBoxFuncList.placeItemsCheck(closest,ItemService)
	for i,placeBox in pairs (cService:GetTagged(config["EmptyTypeIdentifier"])) do
		local interactableIdentifier = placeBox:FindFirstChild(config["MainIdentifierName"])
		if interactableIdentifier then
			local boolOcccupied =  interactableIdentifier:FindFirstChild(config["OccupiableBoolean"]) 
			if closest == placeBox and boolOcccupied then
				ItemService:TransferItem(placeBox)
			end
		end
	end
end

function intBoxFuncList.spawnItemsCheck(closest,ItemService)
	for i,spawnBlock in pairs (cService:GetTagged(config["SpawnItemTypeIdentifier"])) do
		local interactableIdentifier = spawnBlock:FindFirstChild(config["MainIdentifierName"])
		if interactableIdentifier then
			local itemNameRequested = interactableIdentifier:FindFirstChild(config["ItemTypeIdentifierName"])
			local interactableType = interactableIdentifier:FindFirstChild(config["TypeIdentifierName"]) 
			if closest == spawnBlock and itemNameRequested  and interactableType and interactableType.Value == config["SpawnItemTypeIdentifier"] then
				ItemService:AddItem(itemNameRequested.Value)
			end
		end
	end
end

function intBoxFuncList.matchBox(givenBox,boxHolders)
	for i,v in pairs (boxHolders) do
		local num = tonumber(string.sub(givenBox.Name,4))
		local boxNum = tonumber(string.sub(v.Name,5))
		if num ~= nil and num == boxNum then
			return v
		end
	end
end

function intBoxFuncList.moveBoxesCheck(closest,ItemService,boxHolders)
	local tableOfBoxesToUpdate = {}
	local tableToUpdateServer = {}
	local newTween

	for i,v in pairs (cService:GetTagged(config["MoveTypeIdentifier"])) do
		local matchedBox = intBoxFuncList.matchBox(v,boxHolders)
		local goal = {}
		goal.CFrame = matchedBox.CFrame
		newTween = tService:Create(v,TweenInfo.new(1.5,Enum.EasingStyle.Bounce),goal)
		newTween:Play()
		table.insert(tableOfBoxesToUpdate,v)
		tableToUpdateServer[v.Name] = matchedBox.CFrame
	end

	if newTween then
		newTween.Completed:Wait()
	end
	
	ItemService:UpdateLocation(tableToUpdateServer)
	for i,v in pairs (tableOfBoxesToUpdate) do
		cService:RemoveTag(v,config["MoveTypeIdentifier"])
		local type = v:FindFirstChild(config["MainIdentifierName"]):FindFirstChild(config["TypeIdentifierName"])
		local interactableIdentifier = v:FindFirstChild(config["MainIdentifierName"])
		if interactableIdentifier:FindFirstChild(config["ItemTypeIdentifierName"]) then
			cService:AddTag(v,config["SpawnItemTypeIdentifier"])
			type.Value = config["SpawnItemTypeIdentifier"]
		elseif interactableIdentifier:FindFirstChild(config["ChoppableBoolean"]) then
			cService:AddTag(v,config["ChoppableBoolean"])
			cService:AddTag(v,config["EmptyTypeIdentifier"])
			type.Value = config["ChoppableBoolean"]
		else
			cService:AddTag(v,config["EmptyTypeIdentifier"])
			type.Value = config["EmptyTypeIdentifier"]
		end
	end
end

function intBoxFuncList.chopItemsCheck(closest,ItemService)
    for i,blockTags in pairs (cService:GetTags(closest)) do
        local interactableIdentifier = closest:FindFirstChild(config["MainIdentifierName"])
        if blockTags == config["ChoppableBoolean"] and interactableIdentifier then
            local chopValue = interactableIdentifier:FindFirstChild(config["ChoppableBoolean"])
            if chopValue and chopValue.Value == false then
                ItemService:StartChopping(closest,chopValue)
            end
            break
        end
    end
end

return (intBoxFuncList)