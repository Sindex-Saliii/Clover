local API = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sindex-Saliii/Clover/refs/heads/main/API/Optimizer.luau"))()

getgenv().CloverConfigs = CloverConfigs or nil

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

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Loading = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UIGradient = Instance.new("UIGradient")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")
local Shadow = Instance.new("ImageLabel")
local Logo = Instance.new("ImageLabel")
local Glow = Instance.new("ImageLabel")
local Title = Instance.new("TextLabel")
local Status = Instance.new("TextLabel")
local BarBackground = Instance.new("Frame")
local BarFill = Instance.new("Frame")
local FillCorner = Instance.new("UICorner")
local Dots = Instance.new("TextLabel")

Loading.Name = "LuchemyLoading"
Loading.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
Loading.DisplayOrder = 999

MainFrame.Name = "MainFrame"
MainFrame.Parent = Loading
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 40, 20)
MainFrame.BackgroundTransparency = 0.25
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 0, 0, 110)
MainFrame.ClipsDescendants = true

UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 60, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 25, 10))
})
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

UICorner.CornerRadius = UDim.new(0, 16)
UICorner.Parent = MainFrame

UIStroke.Color = Color3.fromRGB(0, 255, 150)
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.4
UIStroke.Parent = MainFrame

Shadow.Name = "Shadow"
Shadow.Parent = MainFrame
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.Size = UDim2.new(1, 20, 1, 20)
Shadow.Image = "rbxassetid://13159005881"
Shadow.ImageColor3 = Color3.fromRGB(0, 255, 150)
Shadow.ImageTransparency = 0.6
Shadow.ZIndex = 0

Logo.Name = "Logo"
Logo.Parent = MainFrame
Logo.BackgroundTransparency = 1
Logo.Position = UDim2.new(0, 20, 0.5, -30)
Logo.Size = UDim2.new(0, 60, 0, 60)
Logo.Image = "rbxassetid://89414650056737"
Logo.ImageTransparency = 1
Logo.ZIndex = 2

Glow.Name = "Glow"
Glow.Parent = MainFrame
Glow.BackgroundTransparency = 1
Glow.Position = UDim2.new(0, 20, 0.5, -30)
Glow.Size = UDim2.new(0, 80, 0, 80)
Glow.Image = "rbxassetid://13159005881"
Glow.ImageColor3 = Color3.fromRGB(0, 255, 150)
Glow.ImageTransparency = 1
Glow.ZIndex = 1

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 90, 0, 18)
Title.Size = UDim2.new(0, 240, 0, 28)
Title.Font = Enum.Font.FredokaOne
Title.Text = "LUCHEMY BY CLOVER"
Title.TextColor3 = Color3.fromRGB(220, 255, 230)
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextTransparency = 1
Title.ZIndex = 2

Status.Name = "Status"
Status.Parent = MainFrame
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0, 90, 0, 48)
Status.Size = UDim2.new(0, 260, 0, 22)
Status.Font = Enum.Font.GothamBold
Status.Text = "Initializing..."
Status.TextColor3 = Color3.fromRGB(100, 255, 180)
Status.TextSize = 13
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.TextTransparency = 1
Status.ZIndex = 2

BarBackground.Name = "BarBackground"
BarBackground.Parent = MainFrame
BarBackground.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BarBackground.BackgroundTransparency = 0.85
BarBackground.Position = UDim2.new(0, 90, 0, 78)
BarBackground.Size = UDim2.new(0, 250, 0, 5)
BarBackground.ZIndex = 2

BarFill.Name = "BarFill"
BarFill.Parent = BarBackground
BarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.ZIndex = 3

FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = BarFill

Dots.Name = "Dots"
Dots.Parent = MainFrame
Dots.BackgroundTransparency = 1
Dots.Position = UDim2.new(1, -30, 0.5, -10)
Dots.Size = UDim2.new(0, 20, 0, 20)
Dots.Font = Enum.Font.GothamBold
Dots.Text = "."
Dots.TextColor3 = Color3.fromRGB(0, 255, 150)
Dots.TextSize = 20
Dots.TextTransparency = 1
Dots.ZIndex = 2
Dots.Visible = false

local tInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
TweenService:Create(MainFrame, tInfo, {Size = UDim2.new(0, 380, 0, 110)}):Play()
task.wait(0.4)
TweenService:Create(Logo, tInfo, {ImageTransparency = 0}):Play()
TweenService:Create(Glow, tInfo, {ImageTransparency = 0.5}):Play()
TweenService:Create(Title, tInfo, {TextTransparency = 0}):Play()
TweenService:Create(Status, tInfo, {TextTransparency = 0.2}):Play()
task.wait(0.5)

local dotIndex = 1
local dotCycle = task.spawn(function()
    while true do
        Dots.Visible = true
        local dots = ""
        for i = 1, dotIndex do dots = dots .. "." end
        Dots.Text = dots
        task.wait(0.4)
        dotIndex = (dotIndex % 3) + 1
    end
end)

Status.Text = "Checking environment..."
TweenService:Create(BarFill, TweenInfo.new(0.5), {Size = UDim2.new(0.15, 0, 1, 0)}):Play()

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

Status.Text = "Fetching script..."
TweenService:Create(BarFill, TweenInfo.new(0.6), {Size = UDim2.new(0.5, 0, 1, 0)}):Play()

local scriptUrl = string.format("https://raw.githubusercontent.com/Sindex-Saliii/Clover/refs/heads/main/scripts/%d.lua", game.PlaceId)
local success, content = pcall(game.HttpGet, game, scriptUrl)

if success and content and content ~= "404: Not Found" then
    Status.Text = "Authentication success!"
    TweenService:Create(BarFill, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.wait(0.8)
    local fadeOut = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(MainFrame, fadeOut, {Size = UDim2.new(0, 0, 0, 110), BackgroundTransparency = 1}):Play()
    TweenService:Create(Logo, fadeOut, {ImageTransparency = 1}):Play()
    TweenService:Create(Glow, fadeOut, {ImageTransparency = 1}):Play()
    TweenService:Create(Title, fadeOut, {TextTransparency = 1}):Play()
    TweenService:Create(Status, fadeOut, {TextTransparency = 1}):Play()
    TweenService:Create(Dots, fadeOut, {TextTransparency = 1}):Play()
    task.wait(0.6)
    Loading:Destroy()
    loadstring(content)()
else
    Status.Text = "❌ Script load failed!"
    Status.TextColor3 = Color3.fromRGB(255, 100, 100)
    TweenService:Create(BarFill, TweenInfo.new(0.5), {Size = UDim2.new(0, 0, 1, 0)}):Play()
    task.wait(2)
    Loading:Destroy()
    warn("[ Clover Auth ] - Could not find script for this PlaceID.")
end
