local uis = game:GetService("UserInputService")
local cas = game:GetService("ContextActionService")
local p = game.Players.LocalPlayer
local cService = game:GetService("CollectionService")
local interactableDist = 8.5
local activeinteractables = {}
local isMobile = nil
local uiLoc = game:GetService("ReplicatedStorage"):WaitForChild("UILocation")
local gui =  uiLoc:WaitForChild("InteractablesGui")
local mobileGui = uiLoc:WaitForChild("InteractablesButton")
local RunService = game:GetService("RunService")
local mobileClone
local boxHolders = {}
local repStore = game:GetService("ReplicatedStorage")
local config = require(repStore:WaitForChild("Config"):WaitForChild("configTutorial"))
local intBoxFunctions = require(script.Parent:WaitForChild("intBoxesFunctions"))
local Knit = require(game:GetService("ReplicatedStorage").Knit)

local ItemService = Knit.GetService("ItemService")

--Runs beginning tag service
intBoxFunctions.startFunctions(gui,boxHolders)

--Determines if the player is on a mobile device
if uis.TouchEnabled then
	isMobile = true
    mobileClone = mobileGui:Clone()
    mobileClone.Parent = p:WaitForChild("PlayerGui"):WaitForChild("MiscUI")
else
	isMobile = false
end

local function moveBoxesCheck(closest)
	interactableDist = 6.5
	intBoxFunctions.moveBoxesCheck(closest,ItemService,boxHolders)
end

local function placeItemsCheck(closest)
	interactableDist = 6.5
	intBoxFunctions.placeItemsCheck(closest,ItemService)
end

local function spawnItemsCheck(closest)
	interactableDist = 6.5
	intBoxFunctions.spawnItemsCheck(closest,ItemService)
end

local function chopItemsCheck(closest)
	interactableDist = 6.5
	intBoxFunctions.chopItemsCheck(closest,ItemService)
end


local function calcDistance(p,optClosest)
	if optClosest then
		return (p:DistanceFromCharacter(optClosest.CFrame.Position))
	else
		local humanFrame = p.Character.HumanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(humanFrame.Position,humanFrame.LookVector*interactableDist)
		if raycastResult~=nil and raycastResult.Instance.Name == "RayCastDetector" then
			return(raycastResult.Instance)
		else
			return nil
		end
	end
end

local function disableGuiinteractables(exclusion)
	if isMobile == false then
		for i,v in pairs (activeinteractables) do
			if v~=exclusion then
				v.InteractablesGui.Enabled=false
			end
		end
	else
		mobileClone.Visible = false
	end
end

local listOfTagTypes = {
	config["MoveTypeIdentifier"],
	config["SpawnItemTypeIdentifier"],
	config["EmptyTypeIdentifier"],
	config["ChoppableBoolean"]
}

local function checkClosest(p,specifier,bool)
	local closest = nil

	local function nestedClosest()
		local objectOrNum = calcDistance(p)
		if objectOrNum ~= nil then
			for i,tagType in pairs (listOfTagTypes) do
				for j,taggedObj in pairs (cService:GetTagged(tagType)) do
					if taggedObj.Name == objectOrNum.Parent.Name then
						closest = objectOrNum.Parent
						return
					end
				end
			end
		end
	end
	
	
	nestedClosest()

	if (closest~= nil) and calcDistance(p,closest) <= interactableDist then
		if (isMobile==false) then
			closest.InteractablesGui.Enabled = true
			table.insert(activeinteractables,closest)
			disableGuiinteractables(closest)
		else
			mobileClone.Visible = true
		end
		
	else
		disableGuiinteractables(nil)
	end
	if not bool and closest~=nil and calcDistance(p,closest) <= interactableDist and specifier=="place" then
		placeItemsCheck(closest)
		spawnItemsCheck(closest)	
		moveBoxesCheck(closest)
	elseif not bool and closest~=nil and calcDistance(p,closest) <= interactableDist and specifier=="chop" then
		chopItemsCheck(closest)
    end
end

local createdBGs = {}

local looping = nil

local function loopInput()
	looping = true
	wait()
	checkClosest(p,true)
	if looping == false then
		return
	end
end


local TEXTBOX_FOCUSED = false

uis.TextBoxFocused:Connect(function(textBox)
	TEXTBOX_FOCUSED = true
end)

uis.TextBoxFocusReleased:Connect(function(textBox)
	TEXTBOX_FOCUSED = false
end)

uis.InputBegan:Connect(function(input,gameProcessed)
	if looping == nil or looping == false then
		looping = true
		RunService:BindToRenderStep("CheckClosest", 1, loopInput)
	end
	if (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.E and TEXTBOX_FOCUSED == false) then
		checkClosest(p,"place")
	elseif (input.UserInputType == Enum.UserInputType.MouseButton1 and TEXTBOX_FOCUSED == false) then
		checkClosest(p,"chop")
	else
		checkClosest(p,nil,true)
	end
end)

if mobileClone ~= nil then
    mobileClone.MouseButton1Click:Connect(function(m)
        checkClosest(p)
    end)
end
	