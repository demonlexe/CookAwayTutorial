local p = game.Players.LocalPlayer
local rep = game:GetService("ReplicatedStorage")
local pUI = p:WaitForChild("PlayerGui")

local loadScreen = rep:WaitForChild("UILocation"):WaitForChild("LoadingScreen"):Clone()
loadScreen.Parent = pUI
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType["Backpack"],false)
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType["Health"],false)