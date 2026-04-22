--[[
   ________  ___       ________  ___      ___  _______   ________  
  ╱  _____╲╱╱  ╲     ╱╱  ____  ╲╱  ╱     ╱  ╱╱╱  ____ ╲╱╱  ___   ╲ 
 ╱  ╱      ╱╱  ╱    ╱╱  ╱    ╱ ╱  ╱     ╱  ╱╱╱  ╱____╱╱╱  ╱   ╱  ╱ 
╱  ╱      ╱╱  ╱____╱╱  ╱____╱ ╱  ╱     ╱  ╱╱╱  ╱____ ╱╱  ╱___╱  ╱  
╲________╱╲________╱╲________╱╲________╱ ╲________╱╲________╱   
 CLOVER DEVELOPMENT | NEXT-GEN EDITION (https://discord.gg/v4MnRRwrV7)

 This script is developed by Clover Development.
 Unauthorized modification, reverse engineering, or 
 redistribution of this script is strictly prohibited.

 Copyright © 2026 Clover Development. All Rights Reserved.
]]--

-----------//// Wait Until Game Load ////-----------

repeat task.wait() until game:IsLoaded()
local API = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sindex-Saliii/Clover/refs/heads/main/API/Optimizer.luau"))()
-----------//// Configs ////-----------
getgenv().CloverConfigs = CloverConfigs or nil
-----------//// Improve FPS ////-----------

getgenv().optimizefps = optimize_fps or false
getgenv().whitescreen = white_screen or false
getgenv().blackscreen = black_screen or false
getgenv().boostfpspromax = boostfps_promax or false
if getgenv().optimizefps then
   API.FPSIMPROVE()
end
if getgenv().white_screen then
    print("[ Clover ] - Rendering: White Screen")
    API.WhiteScreen()
end
if getgenv().black_screen then
    print("[ Clover ] - Rendering: Black Screen")
    API.BlackScreen()
end
if getgenv().clearmemory then
   API.CLEARMEMORY()
end
if getgenv().boostfpspromax then
   API.AggressiveMode()
end

-----------//// Supported Game Data ////-----------

local SupportedGames = {
    [77747658251236] = "Sailor Piece (First Sea)",
    [130167267952199] = "Sailor Piece (Second Sea)",
    [138161219313147] = "Unbox A Factory"
}

local GameName = SupportedGames[game.PlaceId]
local IsSupported = GameName ~= nil

-----------//// Clover Loading UI ////-----------

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Loading = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")
local Logo = Instance.new("ImageLabel")
local Title = Instance.new("TextLabel")
local Status = Instance.new("TextLabel")
local BarBackground = Instance.new("Frame")
local BarFill = Instance.new("Frame")
local FillCorner = Instance.new("UICorner")

Loading.Name = "CloverLoading"
Loading.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
Loading.DisplayOrder = 999

MainFrame.Name = "MainFrame"
MainFrame.Parent = Loading
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.2
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 0, 0, 85)
MainFrame.ClipsDescendants = true

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

UIStroke.Color = Color3.fromRGB(85, 255, 127)
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.6
UIStroke.Parent = MainFrame

Logo.Name = "Logo"
Logo.Parent = MainFrame
Logo.BackgroundTransparency = 1
Logo.Position = UDim2.new(0, 15, 0.5, -25)
Logo.Size = UDim2.new(0, 50, 0, 50)
Logo.Image = "rbxassetid://89414650056737"
Logo.ImageTransparency = 1

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 75, 0, 15)
Title.Size = UDim2.new(0, 200, 0, 25)
Title.Font = Enum.Font.FredokaOne
Title.Text = "CLOVER DEVELOPMENT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextTransparency = 1

Status.Name = "Status"
Status.Parent = MainFrame
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0, 75, 0, 40)
Status.Size = UDim2.new(0, 250, 0, 20)
Status.Font = Enum.Font.GothamBold
Status.Text = "Checking Game Support..."
Status.TextColor3 = Color3.fromRGB(85, 255, 127)
Status.TextSize = 12
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.TextTransparency = 1

BarBackground.Name = "BarBackground"
BarBackground.Parent = MainFrame
BarBackground.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BarBackground.BackgroundTransparency = 0.9
BarBackground.Position = UDim2.new(0, 75, 0, 65)
BarBackground.Size = UDim2.new(0, 260, 0, 4)

BarFill.Name = "BarFill"
BarFill.Parent = BarBackground
BarFill.BackgroundColor3 = Color3.fromRGB(85, 255, 127)
BarFill.Size = UDim2.new(0, 0, 1, 0)

FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = BarFill

local tInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
TweenService:Create(MainFrame, tInfo, {Size = UDim2.new(0, 360, 0, 85)}):Play()
task.wait(0.5)
TweenService:Create(Logo, tInfo, {ImageTransparency = 0}):Play()
TweenService:Create(Title, tInfo, {TextTransparency = 0}):Play()
TweenService:Create(Status, tInfo, {TextTransparency = 0.3}):Play()
task.wait(0.5)

if IsSupported then
    Status.Text = "✅ Game Supported: " .. GameName
    TweenService:Create(BarFill, tInfo, {Size = UDim2.new(0.3, 0, 1, 0)}):Play()
    task.wait(1.5)
else
    Status.Text = "❌ Unsupported Game!"
    Status.TextColor3 = Color3.fromRGB(255, 85, 85)
    UIStroke.Color = Color3.fromRGB(255, 85, 85)
    task.wait(2)
    Players.LocalPlayer:Kick("Unsupported Game. \n Join https://discord.gg/v4MnRRwrV7")
    return
end

----------//// Check Executor Environment ////-----------

Status.Text = "Checking Environment..."
TweenService:Create(BarFill, TweenInfo.new(0.5), {Size = UDim2.new(0.6, 0, 1, 0)}):Play()

local function cloverCheck(name, func)
    local status = func and "✅ Support" or "❌ Not Support"
    print("[ Clover Auth ] - " .. status .. " [" .. name .. "]")
end

cloverCheck("HOOKFUNCTION", hookfunction)
cloverCheck("HOOKMETAMETHOD", hookmetamethod)
cloverCheck("WRITEFILE", writefile)
cloverCheck("READFILE", readfile)
cloverCheck("GETCONNECTIONS", getconnections)
cloverCheck("REQUEST", (request or http_request or syn.request))
cloverCheck("GETRAWMT", getrawmetatable)
cloverCheck("SETRAWMT", setrawmetatable)
cloverCheck("SETREADONLY", setreadonly)
cloverCheck("ISREADONLY", isreadonly)
cloverCheck("SETMETATABLE", setmetatable)
cloverCheck("GETMETATABLE", getmetatable)
cloverCheck("REQUIRE", pcall(function() return require(game:GetService("CoreGui")) end))

----------//// Auto Rejoin ////-----------


getgenv().autorejoin = auto_rejoin or false
if getgenv().autorejoin then
    local TeleportService = game:GetService("TeleportService")
    local CoreGui = game:GetService("CoreGui")

    task.spawn(function()
        pcall(function()
            local promptOverlay = CoreGui:FindFirstChild("RobloxPromptGui"):WaitForChild("promptOverlay")
            promptOverlay.ChildAdded:Connect(function(child)
                task.wait(1)
                if child.Name == 'ErrorPrompt' then
                    TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
                end
            end)
        end)
    end)
end

----------//// Finalize Loading & Script Execution ////-----------

Status.Text = "Fetching Script..."
TweenService:Create(BarFill, TweenInfo.new(0.5), {Size = UDim2.new(0.8, 0, 1, 0)}):Play()

local scriptUrl = string.format("https://raw.githubusercontent.com/Sindex-Saliii/Clover/refs/heads/main/scripts/%d.luau", game.PlaceId)
local success, content = pcall(game.HttpGet, game, scriptUrl)

if success and content and content ~= "404: Not Found" then
    Status.Text = "Authentication Success!"
    TweenService:Create(BarFill, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.wait(1.2)
    TweenService:Create(MainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 0, 0, 85), BackgroundTransparency = 1}):Play()
    TweenService:Create(Logo, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
    TweenService:Create(Title, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(Status, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    task.wait(0.8)
    Loading:Destroy()
    
    loadstring(content)()
else
    Status.Text = "❌ Script Load Failed!"
    Status.TextColor3 = Color3.fromRGB(255, 85, 85)
    task.wait(2)
    Loading:Destroy()
    warn("[ Clover Auth ] - Could not find script for this PlaceID.")
end
