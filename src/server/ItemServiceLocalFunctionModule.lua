functionList = {}

function functionList.InitializeRepItems(modelLoc,modelItems)
    for i,models in pairs (modelLoc:GetChildren()) do
        if models.ClassName == "Model" or models.ClassName == "Folder" then
            modelItems[models.Name] = models
        end
    end
end

function functionList.LocateItemInBox(box,modelItems,optSpecifier)
    for modelName,models in pairs (modelItems) do
        local foundModel = box:FindFirstChild(modelName) 
        if foundModel and optSpecifier=="wantToChop" then
            if string.sub(foundModel.Name,1,4) == "Chop" then
                return nil
            else
                return foundModel
            end
        elseif foundModel and optSpecifier=="unchopped" then
            local choppedModel = modelItems["Chopped "..modelName] 
            if choppedModel ~= nil then
                return choppedModel
            end
        end
    end
    return nil
end

function functionList.ModelToTool(model)
    local newTool = Instance.new("Tool")
    for i,v in pairs (model:GetChildren()) do
        v.Parent = newTool
    end
    newTool.Name = model.Name
    if newTool:FindFirstChild("WeldScript") then
        newTool.WeldScript.Disabled = false
    end
    model:Destroy()
    local contents = newTool:GetDescendants()
    for m = 1,#contents do
        if contents[m].ClassName == "Part" or contents[m].ClassName == "MeshPart" then
            contents[m].Anchored = false
        end
    end

    return newTool
end

function functionList.ToolToModel(tool)
    local newModel = Instance.new("Model")
    for i,v in pairs (tool:GetChildren()) do
        v.Parent = newModel
    end
    newModel.Name = tool.Name
    tool:Destroy()
    return newModel
end

function functionList.anchorObject(objectToAnchor)
    local handle = objectToAnchor:FindFirstChild("Handle") 
    if handle then
        handle.Anchored = true
    end
end

function functionList.BoxToPlayer(boxObjectFound,player,human)
    local newTool = functionList.ModelToTool(boxObjectFound)
    newTool.Parent = player.Character
    human:EquipTool(newTool)
end

function functionList.PlayerToBox(foundObject,spaceToBeTransferred,choppableHolder,optIdentifier)
    local newGroup
    if optIdentifier == "ServerToBox" then
        newGroup=foundObject
    else
        newGroup = functionList.ToolToModel(foundObject)
    end
    
    local board = spaceToBeTransferred:FindFirstChild("Cutting Board")
    print(spaceToBeTransferred.Name)
    if choppableHolder and board:FindFirstChild("Board") then
        newGroup.Handle.CFrame = board:FindFirstChild("Board").CFrame
        newGroup.Handle.Position = Vector3.new(newGroup.Handle.Position.X,newGroup.Handle.Position.Y+(board:FindFirstChild("Board").Size.Y/2)+(newGroup.Handle.Size.Y/2),newGroup.Handle.Position.Z)
    else
         newGroup.Handle.CFrame = spaceToBeTransferred.CFrame
         newGroup.Handle.Position = Vector3.new(newGroup.Handle.Position.X,newGroup.Handle.Position.Y+(spaceToBeTransferred.Size.Y/2)+(newGroup.Handle.Size.Y/2),newGroup.Handle.Position.Z)
    end
    newGroup.Parent = spaceToBeTransferred
    return newGroup
end



return functionList
