local p = game.Players.LocalPlayer
local char = p.Character
local human = char:WaitForChild("Humanoid")
local camera = game.Workspace:WaitForChild("Camera")		
local cameraPos = game.Workspace:WaitForChild("pos1")
local TweenService = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local cService = game:GetService("CollectionService")
local aniList = {}
local fxList = {}
local tweenTypes = {
    TweenInfo.new(0,Enum.EasingStyle.Linear),
    TweenInfo.new(5.5,Enum.EasingStyle.Linear),
    TweenInfo.new(0,Enum.EasingStyle.Linear),
    TweenInfo.new(3.5,Enum.EasingStyle.Linear),
    TweenInfo.new(0,Enum.EasingStyle.Linear),
    TweenInfo.new(6,Enum.EasingStyle.Quad),
    TweenInfo.new(4,Enum.EasingStyle.Quad)
}
local faceSave
local statusTween = false
local debounce = false
local startUpComplete = false
local animIdle
local animStand
local animLook
local config = require(game:GetService("ReplicatedStorage"):WaitForChild("Config"):WaitForChild("configTutorial"))
local Knit = require(game:GetService("ReplicatedStorage").Knit)

local ItemService = Knit.GetService("ItemService")

local function locateInstance(name,searchType)
    local search1 = game.Workspace:FindFirstChild(name)
    if searchType == nil and search1~=nil then
        return search1
    end
end

local function updateCameraSettings(newCamera)
    local dof = camera:FindFirstChild("DepthOfField")
    if dof == nil then
        newCamera.DepthOfField.Parent = camera
    end
    if dof then
        local goal = {
        }
        goal.InFocusRadius = newCamera.DepthOfField.InFocusRadius
        local dofTween = TweenService:Create(dof,TweenInfo.new(1),goal)
        dofTween:Play()
    end
end

local function animLoad(newAnim,optOld,boolWaitForDone)
    newAnim:Play()
    if optOld then
        repeat wait() until newAnim.IsPlaying == true
        if optOld.IsPlaying == true then
            optOld.Looped = false
        end
    end
    if boolWaitForDone == true then
        repeat wait() until newAnim.IsPlaying == false
    end
end

local cameraTween
local currentPos 
local function tweenCam (newPos)
    if newPos == ("cancelTween") and cameraTween ~= nil and cameraTween.Instance.Name ~= "pos"..(#tweenTypes-1) then
        statusTween = false
        if (cameraTween.Instance.Name == "pos"..(#tweenTypes-1)) then
            startUpComplete = true
        end
        cameraTween:Cancel()
        updateCameraSettings(locateInstance("pos"..currentPos))
        return
    end
    local newCamera = game.Workspace:FindFirstChild("pos"..newPos)
    if newCamera then
        currentPos = newPos
        updateCameraSettings(newCamera)
        local tweenInfo = tweenTypes[newPos]
        local goal = {}
        goal.CFrame = newCamera.CFrame
        cameraTween = TweenService:Create(camera,tweenInfo,goal)
        cameraTween:Play()
        cameraTween.Completed:Connect(function()
            statusTween = false
            if (newPos==(#tweenTypes-1)) then
                startUpComplete = true
            end
        end)
    end
end

local boxHolders = {}
local function matchBox(givenBox)
	for i,v in pairs (boxHolders) do
		local num = tonumber(string.sub(givenBox.Name,4))
		local boxNum = tonumber(string.sub(v.Name,6))
		if num ~= nil and boxNum~=nil and num == boxNum then
			return v
		end
	end
end

local function tweenBoxes ()
    for i,v in pairs (game.Workspace:GetDescendants()) do
        local type = v:FindFirstChild(config["TypeIdentifierName"])
        if string.sub(v.Name,1,12) == config["MainIdentifierName"] and v.ClassName == "BoolValue" and type and type.Value == config["ShoreTypeIdentifier"] then
            cService:AddTag(v.Parent,v.Type.Value)
        elseif string.sub(v.Name,1,5) == "Shore" and v.ClassName == "Part" then
            table.insert(boxHolders,v)
        end
    end

    local tableToUpdate = {}
    local newTween
    for i,v in pairs (cService:GetTagged("ShoreBox")) do
		local matchedBox = matchBox(v)
		local goal = {}
		goal.CFrame = matchedBox.CFrame
		newTween = TweenService:Create(v,TweenInfo.new(2,Enum.EasingStyle.Bounce),goal)
		newTween:Play()
		cService:RemoveTag(v,config["ShoreTypeIdentifier"])
        v.Interactable.Type.Value = config["MoveTypeIdentifier"]
        cService:AddTag(v,config["MoveTypeIdentifier"])
        tableToUpdate[v.Name] = matchedBox.CFrame
	end
    if newTween then
		newTween.Completed:Wait()
	end
    ItemService:UpdateLocation(tableToUpdate)
end

local function cameraScriptable()
    while camera.CameraType ~= Enum.CameraType.Scriptable do
        wait()			
        camera.CameraType = Enum.CameraType.Scriptable
    end
end

local function cameraNormal()
    while camera.CameraType ~= Enum.CameraType.Custom do
        wait()			
        camera.CameraType = Enum.CameraType.Custom
    end
end

local function startUpTasks ()
    for i,v in pairs (game:GetService("ReplicatedStorage"):WaitForChild("AnimationLocation"):GetChildren()) do
        aniList[v.Name] = v
    end
    for i,v in pairs (game:GetService("ReplicatedStorage"):WaitForChild("EffectsLocation"):GetChildren()) do
        if v.ClassName == "ParticleEmitter" then
            fxList[v.Name] = v
        end
    end

    cameraScriptable()
    camera.CFrame = cameraPos.CFrame

    if debounce == false then
        debounce = true
        if human:WaitForChild("Animator",3) then
            animIdle = human.Animator:LoadAnimation(aniList["beachIdle"])
            human.WalkSpeed = 0
            human.JumpHeight = 0
            animLoad(animIdle)
            local ff = char:FindFirstChild("ForceField") 
            local head = char:FindFirstChild("Head")
            if ff and head then
                char.ForceField:Destroy()
                faceSave = head.face.Texture
                head.face.Texture = "http://www.roblox.com/asset/?id=161124757"
                local sleepyZEmitter = fxList["sleepyZ"]:Clone()
                sleepyZEmitter.Parent = head
            end
        end
    end
end

local function cameraTasks (pui)
    local frame = pui:FindFirstChild("MainFrame")
    if frame then
        local tInfo = TweenInfo.new(3)
        local goal = {}
        goal.Transparency = 1
        local newTween = TweenService:Create(frame,tInfo,goal)
        newTween:Play()
    end
    for i = 1,(#tweenTypes-1) do
        repeat wait() until statusTween==false
        statusTween=true
        tweenCam(i)
    end
end

local woken = false
local function wakeUp()
    local head = char:FindFirstChild("Head")
    if head and head:FindFirstChild("sleepyZ") then
        head.face.Texture = faceSave
        head.sleepyZ:Destroy()
        tweenCam(7)
        animStand = human.Animator:LoadAnimation(aniList["beachStandUp"])
        animLoad(animStand,animIdle,true)
        animLook = human.Animator:LoadAnimation(aniList["beachLookAround"])
        animLoad(animLook,animStand,true)
        cameraNormal()
        human.WalkSpeed = 18
        human.JumpHeight = 7.2
        tweenBoxes()
    end
end

local TEXTBOX_FOCUSED = false

uis.TextBoxFocused:Connect(function(textBox)
	TEXTBOX_FOCUSED = true
end)

uis.TextBoxFocusReleased:Connect(function(textBox)
	TEXTBOX_FOCUSED = false
end)

local function isValidInputType (inputType)
   inputType = inputType.UserInputType
   if inputType == Enum.UserInputType.Touch or inputType == Enum.UserInputType.Keyboard or inputType == Enum.UserInputType.MouseButton1 or inputType == Enum.UserInputType.MouseButton2 or inputType == Enum.UserInputType.MouseButton3 or inputType == Enum.UserInputType.MouseWheel then 
        return true
   else
       return false
    end
end

local debounceIn = false
uis.InputBegan:Connect(function(inpt)
    if debounceIn == false and isValidInputType(inpt) then
        debounceIn = true
        if TEXTBOX_FOCUSED == false and woken == false and startUpComplete == true then
            woken = true
            wakeUp()
        elseif TEXTBOX_FOCUSED == false and woken == false and startUpComplete == false then
            tweenCam("cancelTween")
        end
        debounceIn = false
    else
        return
    end
end)

startUpTasks()
local pui = p:WaitForChild("PlayerGui"):WaitForChild("LoadingScreen")
cameraTasks(pui)

