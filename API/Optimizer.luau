local SaliiiAPI = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local Settings = {
    FPSBoost = true,
    LowGraphics = false,
    DisableShadows = true,
    ReduceParticles = true,
    DisableAnimations = false,
    RenderDistance = 500,
    MaxFPS = 60,
    LODBias = 0.5,
    TextureQuality = "Medium",
    DisableWater = true,
    DisableTerrain = false,
    ReduceClutter = true,
    DisableDecals = true,
    DisableWeather = true,
    DisableExplosions = true,
    DisableSounds = false,
    OptimizeMeshes = true,
    ReduceNetwork = true
}

local PerformanceMetrics = {
    CurrentFPS = 60,
    AverageFPS = 60,
    MinFPS = 60,
    MaxFPS = 60,
    MemoryUsage = 0,
    RenderTime = 0,
    ActiveObjects = 0,
    DrawCalls = 0,
    ParticleCount = 0,
    LightCount = 0,
    AnimationCount = 0
}

local ScreenEffects = {
    WhiteScreenActive = false,
    BlackScreenActive = false,
    RenderingEnabled = true,
    OriginalRenderingState = nil,
    WhiteScreenGui = nil,
    BlackScreenGui = nil
}

local CachedObjects = {}
local OptimizerActive = false
local LowPerformanceMode = false
local AggressiveMode = false

local UPDATE_INTERVAL = 0.5
local METRICS_INTERVAL = 0.2
local lastOptimizeTime = 0
local lastMetricsTime = 0
local frameTimes = {}
local lastFrameTime = tick()
local fpsUpdateTime = tick()

local function restoreObject(obj)
    local data = CachedObjects[obj]
    if not data then return end
    for prop, val in pairs(data) do
        pcall(function()
            obj[prop] = val
        end)
    end
    CachedObjects[obj] = nil
end

local function resetAll()
    for obj, _ in pairs(CachedObjects) do
        restoreObject(obj)
    end
    CachedObjects = {}
    Lighting.GlobalShadows = true
    Lighting.FogEnd = 1000
    Lighting.FogStart = 0
    Lighting.Brightness = 1
    Lighting.ClockTime = 14
    Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
    Workspace.FallenPartsDestroyHeight = -500
    Workspace.Gravity = 196.2
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            effect.Enabled = true
        end
    end
end

local function optimizeGraphics()
    if not Settings.FPSBoost then return end
    if Settings.DisableShadows then
        Lighting.GlobalShadows = false
        for _, light in ipairs(Workspace:GetDescendants()) do
            if light:IsA("Light") then
                if not CachedObjects[light] then
                    CachedObjects[light] = {Shadows = light.Shadows, Brightness = light.Brightness}
                end
                light.Shadows = false
                if LowPerformanceMode then
                    light.Brightness = light.Brightness * 0.5
                end
            end
        end
    end
    if Settings.DisableWater then
        for _, water in ipairs(Workspace:GetDescendants()) do
            if water:IsA("Water") or (water:IsA("BasePart") and water.Material == Enum.Material.Water) then
                if not CachedObjects[water] then
                    CachedObjects[water] = {Material = water.Material, Transparency = water.Transparency}
                end
                water.Material = Enum.Material.Plastic
                water.Transparency = 1
            end
        end
    end
    if Settings.DisableTerrain then
        local terrain = Workspace.Terrain
        if terrain then
            if not CachedObjects["Terrain"] then
                CachedObjects["Terrain"] = {WaterReflectance = terrain.WaterReflectance, WaterWaveSize = terrain.WaterWaveSize}
            end
            terrain.WaterReflectance = 0
            terrain.WaterWaveSize = 0
            terrain.WaterRefraction = 0
            if AggressiveMode then
                terrain:Clear()
            end
        end
    end
    Lighting.FogEnd = Settings.RenderDistance
    Lighting.FogStart = Settings.RenderDistance * 0.7
    Lighting.Brightness = LowPerformanceMode and 2 or 1.5
    Lighting.ClockTime = 14
    Lighting.OutdoorAmbient = LowPerformanceMode and Color3.new(0.8, 0.8, 0.8) or Color3.new(0.5, 0.5, 0.5)
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            if part.Material == Enum.Material.Neon or part.Material == Enum.Material.ForceField then
                if not CachedObjects[part] then
                    CachedObjects[part] = {Material = part.Material}
                end
                part.Material = Enum.Material.Plastic
            end
            if part.Material == Enum.Material.Glass and LowPerformanceMode then
                part.Material = Enum.Material.SmoothPlastic
                part.Reflectance = 0
            end
            if part:IsA("MeshPart") and Settings.OptimizeMeshes then
                if not CachedObjects[part] then
                    CachedObjects[part] = {RenderFidelity = part.RenderFidelity}
                end
                part.RenderFidelity = Enum.RenderFidelity.Automatic
            end
        end
        if part:IsA("Decal") and Settings.DisableDecals then
            if not CachedObjects[part] then
                CachedObjects[part] = {Transparency = part.Transparency, Texture = part.Texture}
            end
            part.Transparency = 1
        end
    end
end

local function optimizeParticles()
    if not Settings.ReduceParticles then return end
    for _, particle in ipairs(Workspace:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            if not CachedObjects[particle] then
                CachedObjects[particle] = {
                    Rate = particle.Rate,
                    Enabled = particle.Enabled,
                    Lifetime = particle.Lifetime,
                    Speed = particle.Speed,
                    SpreadAngle = particle.SpreadAngle,
                    VelocityInheritance = particle.VelocityInheritance
                }
            end
            particle.Rate = math.floor(particle.Rate * (LowPerformanceMode and 0.1 or 0.3))
            particle.Lifetime = particle.Lifetime * 0.5
            particle.Speed = particle.Speed * 0.7
            particle.SpreadAngle = Vector2.new(5, 5)
            particle.VelocityInheritance = 0
            if LowPerformanceMode and AggressiveMode then
                particle.Enabled = false
            end
        elseif particle:IsA("Fire") then
            if not CachedObjects[particle] then
                CachedObjects[particle] = {Enabled = particle.Enabled, Size = particle.Size, Heat = particle.Heat}
            end
            particle.Size = particle.Size * 0.5
            particle.Heat = particle.Heat * 0.3
        elseif particle:IsA("Smoke") or particle:IsA("Sparkles") then
            if not CachedObjects[particle] then
                CachedObjects[particle] = {Enabled = particle.Enabled}
            end
            particle.Enabled = false
        elseif particle:IsA("Trail") then
            if not CachedObjects[particle] then
                CachedObjects[particle] = {Enabled = particle.Enabled, Lifetime = particle.Lifetime, MinLength = particle.MinLength}
            end
            particle.Lifetime = particle.Lifetime * 0.3
            particle.MinLength = 0
        end
    end
end

local function optimizeAnimations()
    if not Settings.DisableAnimations and not LowPerformanceMode then return end
    for _, character in ipairs(Workspace:GetDescendants()) do
        if character:IsA("Model") and character:FindFirstChild("Humanoid") then
            local humanoid = character.Humanoid
            if humanoid.Animator then
                local animator = humanoid.Animator
                if Settings.DisableAnimations then
                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                        track:Stop()
                    end
                elseif LowPerformanceMode then
                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                        track:AdjustSpeed(0.5)
                    end
                end
            end
            if LowPerformanceMode and AggressiveMode then
                for _, accessory in ipairs(character:GetChildren()) do
                    if accessory:IsA("Accessory") or accessory:IsA("Hat") then
                        if accessory.Handle then
                            if not CachedObjects[accessory] then
                                CachedObjects[accessory] = {Handle = accessory.Handle}
                            end
                            accessory.Handle.Visible = false
                        end
                    end
                end
            end
        end
    end
end

local function optimizeRenderDistance()
    local playerPos = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
    if not playerPos then return end
    local currentDist = AggressiveMode and Settings.RenderDistance * 0.4 or (LowPerformanceMode and Settings.RenderDistance * 0.6 or Settings.RenderDistance)
    local visibleCount = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Parent and not obj.Parent:IsA("Tool") and obj ~= playerPos then
            local distance = (playerPos.Position - obj.Position).Magnitude
            if distance <= currentDist then
                if not CachedObjects[obj] then
                    if obj.Visible == false then
                        CachedObjects[obj] = {Visible = false}
                    end
                end
                obj.Visible = true
                visibleCount = visibleCount + 1
            else
                if obj.Visible then
                    if not CachedObjects[obj] then
                        CachedObjects[obj] = {Visible = true}
                    end
                    obj.Visible = false
                end
            end
        end
    end
    PerformanceMetrics.DrawCalls = visibleCount
end

local function optimizePhysics()
    Workspace.FallenPartsDestroyHeight = -200
    Workspace.Gravity = AggressiveMode and 150 or 196.2
    if LowPerformanceMode or AggressiveMode then
        for _, constraint in ipairs(Workspace:GetDescendants()) do
            if constraint:IsA("Constraint") then
                if not CachedObjects[constraint] then
                    CachedObjects[constraint] = constraint.Enabled
                end
                constraint.Enabled = false
            end
        end
    end
    if AggressiveMode then
        for _, ragdoll in ipairs(Workspace:GetDescendants()) do
            if ragdoll:IsA("Ragdoll") or (ragdoll:IsA("Model") and ragdoll.Name:lower():find("ragdoll")) then
                ragdoll:Destroy()
            end
        end
        for _, bodyMover in ipairs(Workspace:GetDescendants()) do
            if bodyMover:IsA("BodyMover") then
                if not CachedObjects[bodyMover] then
                    CachedObjects[bodyMover] = bodyMover.Enabled
                end
                bodyMover.Enabled = false
            end
        end
    end
end

local function optimizeClutter()
    if not Settings.ReduceClutter and not Settings.OptimizeMeshes then return end
    for _, mesh in ipairs(Workspace:GetDescendants()) do
        if mesh:IsA("MeshPart") and Settings.OptimizeMeshes then
            if Settings.TextureQuality == "Low" or LowPerformanceMode then
                if mesh.MeshId ~= "" then
                    if not CachedObjects[mesh] then
                        CachedObjects[mesh] = mesh.MeshId
                    end
                    mesh.MeshId = ""
                end
                if mesh.TextureID ~= "" then
                    if not CachedObjects[mesh .. "Texture"] then
                        CachedObjects[mesh .. "Texture"] = mesh.TextureID
                    end
                    mesh.TextureID = ""
                end
            end
        end
        if mesh:IsA("UnionOperation") and (LowPerformanceMode or AggressiveMode) then
            if not CachedObjects[mesh] then
                CachedObjects[mesh] = mesh.Visible
            end
            mesh.Visible = false
        end
        if (mesh:IsA("CylinderMesh") or mesh:IsA("BlockMesh") or mesh:IsA("SpecialMesh")) and LowPerformanceMode then
            if not CachedObjects[mesh] then
                CachedObjects[mesh] = {Scale = mesh.Scale}
            end
            mesh.Scale = mesh.Scale * 0.8
        end
    end
    if Settings.ReduceClutter then
        for _, clutter in ipairs(Workspace:GetDescendants()) do
            if clutter:IsA("Model") and clutter ~= LocalPlayer.Character then
                local isDecoration = false
                for _, tag in ipairs(clutter:GetTags()) do
                    if tag == "Decoration" or tag == "Clutter" or tag == "Environment" then
                        isDecoration = true
                        break
                    end
                end
                if isDecoration then
                    if AggressiveMode then
                        clutter:Destroy()
                    elseif LowPerformanceMode then
                        for _, part in ipairs(clutter:GetDescendants()) do
                            if part:IsA("BasePart") then
                                if not CachedObjects[part] then
                                    CachedObjects[part] = part.Visible
                                end
                                part.Visible = false
                            end
                        end
                    end
                end
            end
        end
    end
end

local function optimizeWeatherAndEffects()
    if not Settings.DisableWeather then return end
    for _, atmosphere in ipairs(Lighting:GetChildren()) do
        if atmosphere:IsA("Atmosphere") then
            if not CachedObjects[atmosphere] then
                CachedObjects[atmosphere] = {Density = atmosphere.Density, Offset = atmosphere.Offset, Color = atmosphere.Color}
            end
            atmosphere.Density = 0
            atmosphere.Offset = 0
        end
        if atmosphere:IsA("Clouds") then
            if not CachedObjects[atmosphere] then
                CachedObjects[atmosphere] = {Enabled = atmosphere.Enabled}
            end
            atmosphere.Enabled = false
        end
    end
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") then
            if not CachedObjects[effect] then
                CachedObjects[effect] = {Enabled = effect.Enabled}
            end
            effect.Enabled = false
        end
    end
    if Settings.DisableExplosions then
        for _, explosion in ipairs(Workspace:GetDescendants()) do
            if explosion:IsA("Explosion") then
                if not CachedObjects[explosion] then
                    CachedObjects[explosion] = {BlastPressure = explosion.BlastPressure, BlastRadius = explosion.BlastRadius}
                end
                explosion.BlastPressure = 0
                explosion.BlastRadius = 1
                explosion.Visible = false
            end
        end
    end
    if Settings.DisableSounds then
        for _, sound in ipairs(Workspace:GetDescendants()) do
            if sound:IsA("Sound") then
                if not CachedObjects[sound] then
                    CachedObjects[sound] = {Volume = sound.Volume, Playing = sound.Playing}
                end
                sound.Volume = 0
                sound:Stop()
            end
        end
    end
end

local function optimizeNetwork()
    if not Settings.ReduceNetwork then return end
    if AggressiveMode then
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") or remote:IsA("UnreliableRemoteEvent") then
                remote.Parent = nil
            end
        end
        for _, remote in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                remote:Destroy()
            end
        end
    end
end

local function fullOptimization()
    if not OptimizerActive then return end
    optimizeGraphics()
    optimizeParticles()
    optimizeAnimations()
    optimizeRenderDistance()
    optimizePhysics()
    optimizeClutter()
    optimizeWeatherAndEffects()
    optimizeNetwork()
end

local function updateMetrics()
    local currentTime = tick()
    local delta = currentTime - lastFrameTime
    lastFrameTime = currentTime
    table.insert(frameTimes, delta)
    if #frameTimes > 120 then
        table.remove(frameTimes, 1)
    end
    if currentTime - fpsUpdateTime >= 1 then
        local total = 0
        for _, t in ipairs(frameTimes) do total = total + t end
        local avg = total / #frameTimes
        PerformanceMetrics.CurrentFPS = math.floor(1 / avg)
        PerformanceMetrics.AverageFPS = math.floor(PerformanceMetrics.AverageFPS * 0.95 + PerformanceMetrics.CurrentFPS * 0.05)
        if PerformanceMetrics.CurrentFPS < 30 then
            LowPerformanceMode = true
        elseif PerformanceMetrics.CurrentFPS > 45 then
            LowPerformanceMode = false
        end
        fpsUpdateTime = currentTime
    end
    PerformanceMetrics.RenderTime = delta * 1000
    PerformanceMetrics.ActiveObjects = #Workspace:GetDescendants()
    local pCount = 0
    local lCount = 0
    local aCount = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") then pCount = pCount + 1 end
        if obj:IsA("Light") then lCount = lCount + 1 end
        if obj:IsA("Animation") then aCount = aCount + 1 end
    end
    PerformanceMetrics.ParticleCount = pCount
    PerformanceMetrics.LightCount = lCount
    PerformanceMetrics.AnimationCount = aCount
    PerformanceMetrics.MemoryUsage = collectgarbage("count")
end

local function startOptimizerLoop()
    task.spawn(function()
        while OptimizerActive do
            local now = tick()
            if now - lastOptimizeTime >= UPDATE_INTERVAL then
                fullOptimization()
                lastOptimizeTime = now
            end
            if now - lastMetricsTime >= METRICS_INTERVAL then
                updateMetrics()
                lastMetricsTime = now
            end
            task.wait(0.05)
        end
    end)
end

local function startMemoryManagement()
    task.spawn(function()
        while OptimizerActive do
            task.wait(30)
            for obj, _ in pairs(CachedObjects) do
                if not obj or not obj.Parent then
                    CachedObjects[obj] = nil
                end
            end
            if collectgarbage("count") > 400 then
                collectgarbage()
            end
        end
    end)
end

function SaliiiAPI.WhiteScreen()
    if ScreenEffects.RenderingEnabled == nil then
        ScreenEffects.OriginalRenderingState = RunService:Is3dRenderingEnabled()
    end
    RunService:Set3dRenderingEnabled(false)
    ScreenEffects.RenderingEnabled = false
    ScreenEffects.WhiteScreenActive = true
    ScreenEffects.BlackScreenActive = false
    local gui = Instance.new("ScreenGui")
    gui.Name = "SaliiiWhiteScreen"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 999
    gui.IgnoreGuiInset = true
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = Color3.new(1, 1, 1)
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.Parent = gui
    gui.Parent = CoreGui
    ScreenEffects.WhiteScreenGui = gui
    return "White screen activated - 3D rendering disabled"
end

function SaliiiAPI.BlackScreen()
    if ScreenEffects.RenderingEnabled == nil then
        ScreenEffects.OriginalRenderingState = RunService:Is3dRenderingEnabled()
    end
    RunService:Set3dRenderingEnabled(false)
    ScreenEffects.RenderingEnabled = false
    ScreenEffects.BlackScreenActive = true
    ScreenEffects.WhiteScreenActive = false
    local gui = Instance.new("ScreenGui")
    gui.Name = "SaliiiBlackScreen"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 999
    gui.IgnoreGuiInset = true
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.Parent = gui
    gui.Parent = CoreGui
    ScreenEffects.BlackScreenGui = gui
    return "Black screen activated - 3D rendering disabled"
end

function SaliiiAPI.DisableWhiteScreen()
    if ScreenEffects.WhiteScreenGui then
        ScreenEffects.WhiteScreenGui:Destroy()
        ScreenEffects.WhiteScreenGui = nil
    end
    if ScreenEffects.BlackScreenGui then
        ScreenEffects.BlackScreenGui:Destroy()
        ScreenEffects.BlackScreenGui = nil
    end
    if ScreenEffects.OriginalRenderingState ~= nil then
        RunService:Set3dRenderingEnabled(ScreenEffects.OriginalRenderingState)
        ScreenEffects.RenderingEnabled = ScreenEffects.OriginalRenderingState
    else
        RunService:Set3dRenderingEnabled(true)
        ScreenEffects.RenderingEnabled = true
    end
    ScreenEffects.WhiteScreenActive = false
    ScreenEffects.BlackScreenActive = false
    return "White/Black screen disabled - 3D rendering restored"
end

function SaliiiAPI.DisableBlackScreen()
    return SaliiiAPI.DisableWhiteScreen()
end

function SaliiiAPI.FPSIMPROVE()
    if OptimizerActive then return "FPS Optimizer already active" end
    OptimizerActive = true
    lastOptimizeTime = tick()
    lastMetricsTime = tick()
    startOptimizerLoop()
    startMemoryManagement()
    return "FPS Optimizer started - Current FPS: " .. PerformanceMetrics.CurrentFPS
end

function SaliiiAPI.AggressiveMode()
    AggressiveMode = true
    Settings.RenderDistance = 300
    Settings.ReduceParticles = true
    Settings.DisableAnimations = true
    Settings.TextureQuality = "Low"
    return "Aggressive mode enabled - Maximum performance"
end

function SaliiiAPI.DisableAggressiveMode()
    AggressiveMode = false
    Settings.RenderDistance = 500
    return "Aggressive mode disabled"
end

function SaliiiAPI.SETSETTING(setting, value)
    if Settings[setting] ~= nil then
        Settings[setting] = value
        return setting .. " set to " .. tostring(value)
    end
    return "Invalid setting: " .. setting
end

function SaliiiAPI.GETSETTING(setting)
    return Settings[setting]
end

function SaliiiAPI.GETMETRICS()
    return {
        FPS = PerformanceMetrics.CurrentFPS,
        AverageFPS = PerformanceMetrics.AverageFPS,
        MemoryMB = math.floor(PerformanceMetrics.MemoryUsage),
        RenderTimeMS = math.floor(PerformanceMetrics.RenderTime * 100) / 100,
        ActiveObjects = PerformanceMetrics.ActiveObjects,
        DrawCalls = PerformanceMetrics.DrawCalls,
        Particles = PerformanceMetrics.ParticleCount,
        Lights = PerformanceMetrics.LightCount,
        Animations = PerformanceMetrics.AnimationCount,
        LowPerformanceMode = LowPerformanceMode,
        AggressiveMode = AggressiveMode
    }
end

function SaliiiAPI.STOPFPSIMPROVE()
    if not OptimizerActive then return "FPS Optimizer not active" end
    OptimizerActive = false
    resetAll()
    return "FPS Optimizer stopped - Settings restored"
end

function SaliiiAPI.BOOSTRENDERDISTANCE(distance)
    distance = distance or 300
    Settings.RenderDistance = distance
    return "Render distance set to " .. distance
end

function SaliiiAPI.TOGGLEFPSBOOST(state)
    Settings.FPSBoost = state
    return "FPS Boost " .. (state and "enabled" or "disabled")
end

function SaliiiAPI.TOGGLESHADOWS(state)
    Settings.DisableShadows = not state
    Lighting.GlobalShadows = state
    return "Shadows " .. (state and "enabled" or "disabled")
end

function SaliiiAPI.TOGGLEPARTICLES(state)
    Settings.ReduceParticles = not state
    return "Particles " .. (state and "full" or "reduced")
end

function SaliiiAPI.TOGGLEANIMATIONS(state)
    Settings.DisableAnimations = not state
    return "Animations " .. (state and "enabled" or "disabled")
end

function SaliiiAPI.TOGGLEWATER(state)
    Settings.DisableWater = not state
    return "Water effects " .. (state and "enabled" or "disabled")
end

function SaliiiAPI.TOGGLEDECALS(state)
    Settings.DisableDecals = not state
    return "Decals " .. (state and "enabled" or "disabled")
end

function SaliiiAPI.CLEARMEMORY()
    collectgarbage("collect")
    for obj, _ in pairs(CachedObjects) do
        if obj and not obj.Parent then
            CachedObjects[obj] = nil
        end
    end
    return "Memory cleared - Current usage: " .. math.floor(collectgarbage("count")) .. " KB"
end

function SaliiiAPI.GETSCREENSTATUS()
    return {
        WhiteScreen = ScreenEffects.WhiteScreenActive,
        BlackScreen = ScreenEffects.BlackScreenActive,
        RenderingEnabled = ScreenEffects.RenderingEnabled
    }
end

return SaliiiAPI
