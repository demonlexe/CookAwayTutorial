local Knit = require(game:GetService("ReplicatedStorage").Knit)
local repStore = game:GetService("ReplicatedStorage")
local modelLoc = repStore:WaitForChild("ModelLocation")
local modelItems = {}
local config = require(game:GetService("ReplicatedStorage"):WaitForChild("Config"):WaitForChild("configTutorial"))
local ItemService = require(script.Parent:WaitForChild("ItemServiceCreator"))
local ItemServiceFunctions = require(script.Parent:WaitForChild("ItemServiceLocalFunctionModule"))
local initializedRepItems = false

function ItemService:CleanItems(player)
    for i,v in pairs (player:FindFirstChild("Backpack"):GetChildren()) do
        v:Destroy()
    end
    for i,v in pairs (player.Character:GetChildren()) do
        if v.ClassName == "Tool" then
            v:Destroy()
        end
    end
end

function ItemService:AddItem(player, itemInputByPlayer)
    if itemInputByPlayer then
        if initializedRepItems == false then
            initializedRepItems = true
            ItemServiceFunctions.InitializeRepItems(modelLoc,modelItems)
        end
        
        ItemService:CleanItems(player)
        local item = modelItems[itemInputByPlayer]
        if item then
            local itemClone = ItemServiceFunctions.ModelToTool(item:Clone())
            itemClone.Parent = player.Character
            local human = player.Character:FindFirstChildOfClass("Humanoid")
            for i,v in pairs(human:FindFirstChild("Animator"):GetPlayingAnimationTracks()) do
                print("found anim")
                v.Looped = false
                v:Stop()
            end
            human:EquipTool(itemClone)
        end
    end
end

function ItemService:UpdateLocation(player, dictionaryOfLocations)
    for i,v in pairs (game.Workspace:GetDescendants()) do
        for j,k in pairs (dictionaryOfLocations) do
            if j == v.Name then
                v.CFrame = k
            end
        end
    end
end

function ItemService:StartChopping(player,spaceToChop,chopValue)
    local human = player.Character:FindFirstChildOfClass("Humanoid")
    if human then
        chopValue.Value = true
        local animChop = human:FindFirstChild("Animator"):LoadAnimation(repStore:FindFirstChild("AnimationLocation"):FindFirstChild("chopAnim"))
        animChop:Play()
        animChop.Stopped:Connect(function()
            local model = ItemServiceFunctions.LocateItemInBox(spaceToChop,modelItems,"wantToChop")
            local choppedModel = ItemServiceFunctions.LocateItemInBox(spaceToChop,modelItems,"unchopped")
            if model~=nil and choppedModel~=nil then
                model:Destroy()
                local foundObject = choppedModel:Clone()
                local newGroup = ItemServiceFunctions.PlayerToBox(foundObject,spaceToChop,chopValue,"ServerToBox")
                ItemServiceFunctions.anchorObject(newGroup)
            end
        end)
    end
end

function ItemService:TransferItem(player, spaceToBeTransferred)
    local human = player.Character:FindFirstChildOfClass("Humanoid")
    local foundObject = nil
    local function locateItem(searchType)
        local function nestedLocateItem(v)
            if searchType == "player" then
                if v.ClassName == "Tool" then
                    human:UnequipTools()
                    foundObject = v
                    foundObject.Parent = script
                    return true
                end
            end
        end
        if searchType == "player" then
            for i,v in pairs (player.Character:GetChildren()) do
                if nestedLocateItem(v) == true or foundObject ~= nil then
                    break
                end
            end
            for i,v in pairs (player.Backpack:GetChildren()) do
                if nestedLocateItem(v) == true or foundObject ~= nil then
                    break
                end
            end
            --ItemService:CleanItems(player)
        elseif searchType == "boxes" then
            for i,v in pairs (modelItems) do
                local findModel = spaceToBeTransferred:FindFirstChild(v.Name)
                if findModel then
                    if findModel.ClassName == "Model" then
                        foundObject = findModel
                        findModel.Parent = script
                    end
                end
            end
        end
        
    end

    local interactable = spaceToBeTransferred:FindFirstChild(config["MainIdentifierName"])
    if interactable then
        local occupiedHolder = interactable:FindFirstChild(config["OccupiableBoolean"])
        local choppableHolder =  interactable:FindFirstChild(config["ChoppableBoolean"])
        if occupiedHolder and occupiedHolder.Value == false then
            locateItem("player")
            if foundObject~=nil then
                local newGroup = ItemServiceFunctions.PlayerToBox(foundObject,spaceToBeTransferred,choppableHolder)
                ItemServiceFunctions.anchorObject(newGroup)
            end
            occupiedHolder.Value = true
        elseif occupiedHolder and occupiedHolder.Value == true then
            locateItem("boxes")
            if foundObject~=nil then
                local boxObjectFound = foundObject
                foundObject = nil
                locateItem("player")
                if foundObject ~= nil then
                    local newGroup = ItemServiceFunctions.PlayerToBox(foundObject,spaceToBeTransferred,choppableHolder)
                    ItemServiceFunctions.anchorObject(newGroup)
                    ItemServiceFunctions.BoxToPlayer(boxObjectFound,player,human)
                else
                    ItemServiceFunctions.BoxToPlayer(boxObjectFound,player,human)
                    occupiedHolder.Value = false
                end
            end
        end
    end
end

function ItemService.Client:AddItem(player, item)
    return self.Server:AddItem(player, item)
end
function ItemService.Client:TransferItem(player, spaceToBeTransferred)
    return self.Server:TransferItem(player, spaceToBeTransferred)
end
function ItemService.Client:UpdateLocation(player, dictionaryOfLocations)
    return self.Server:UpdateLocation(player, dictionaryOfLocations)
end
function ItemService.Client:StartChopping(player,spaceToChop,chopValue)
    return self.Server:StartChopping(player,spaceToChop,chopValue)
end

Knit.Start():Catch(warn)