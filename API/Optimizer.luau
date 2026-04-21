local SaliiiAPI = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

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
    OriginalRenderingState = nil
}

local CachedObjects = {}
local OriginalProperties = {}
local ActiveTweens = {}
local OptimizerActive = false
local FrameTimes = {}
local LastFrameTime = tick()
local FPSUpdateTime = tick()
local FrameCounter = 0
local LowPerformanceMode = false
local AggressiveMode = false

local function UpdatePerformanceMetrics(deltaTime)
    FrameCounter = FrameCounter + 1
    local currentTime = tick()
    local frameTime = currentTime - LastFrameTime
    LastFrameTime = currentTime
    
    table.insert(FrameTimes, frameTime)
    if #FrameTimes > 120 then
        table.remove(FrameTimes, 1)
    end
    
    if currentTime - FPSUpdateTime >= 1 then
        local totalTime = 0
        for _, ft in ipairs(FrameTimes) do
            totalTime = totalTime + ft
        end
        local avgFrameTime = totalTime / #FrameTimes
        PerformanceMetrics.CurrentFPS = math.floor(1 / avgFrameTime)
        PerformanceMetrics.AverageFPS = math.floor(PerformanceMetrics.AverageFPS * 0.95 + PerformanceMetrics.CurrentFPS * 0.05)
        
        if PerformanceMetrics.CurrentFPS < 30 then
            LowPerformanceMode = true
        elseif PerformanceMetrics.CurrentFPS > 45 and LowPerformanceMode then
            LowPerformanceMode = false
        end
        
        FPSUpdateTime = currentTime
        FrameCounter = 0
    end
    
    PerformanceMetrics.RenderTime = deltaTime * 1000
    PerformanceMetrics.ActiveObjects = #Workspace:GetDescendants()
    
    local particleCount = 0
    local lightCount = 0
    local animationCount = 0
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") then particleCount = particleCount + 1 end
        if obj:IsA("Light") then lightCount = lightCount + 1 end
        if obj:IsA("Animation") then animationCount = animationCount + 1 end
    end
    
    PerformanceMetrics.ParticleCount = particleCount
    PerformanceMetrics.LightCount = lightCount
    PerformanceMetrics.AnimationCount = animationCount
end

local function OptimizeGraphics()
    if Settings.DisableShadows then
        Lighting.GlobalShadows = false
        for _, light in ipairs(Workspace:GetDescendants()) do
            if light:IsA("Light") then
                if not OriginalProperties[light] then
                    OriginalProperties[light] = {Shadows = light.Shadows, Brightness = light.Brightness}
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
                if not OriginalProperties[water] then
                    OriginalProperties[water] = {Material = water.Material, Transparency = water.Transparency}
                end
                water.Material = Enum.Material.Plastic
                water.Transparency = 1
            end
        end
    end
    
    if Settings.DisableTerrain then
        local terrain = Workspace.Terrain
        if terrain then
            if not OriginalProperties["Terrain"] then
                OriginalProperties["Terrain"] = {WaterReflectance = terrain.WaterReflectance, WaterWaveSize = terrain.WaterWaveSize}
            end
            terrain.WaterReflectance = 0
            terrain.WaterWaveSize = 0
            terrain.WaterRefraction = 0
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
                if not OriginalProperties[part] then
                    OriginalProperties[part] = {Material = part.Material}
                end
                part.Material = Enum.Material.Plastic
            end
            
            if part.Material == Enum.Material.Glass and LowPerformanceMode then
                part.Material = Enum.Material.SmoothPlastic
                part.Reflectance = 0
            end
            
            if part:IsA("MeshPart") and Settings.OptimizeMeshes then
                if not OriginalProperties[part] then
                    OriginalProperties[part] = {RenderFidelity = part.RenderFidelity}
                end
                part.RenderFidelity = Enum.RenderFidelity.Automatic
            end
        end
        
        if part:IsA("Decal") and Settings.DisableDecals then
            if not OriginalProperties[part] then
                OriginalProperties[part] = {Transparency = part.Transparency, Texture = part.Texture}
            end
            part.Transparency = 1
        end
    end
end

local function OptimizeParticles()
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
            if Settings.ReduceParticles then
                particle.Rate = math.floor(particle.Rate * (LowPerformanceMode and 0.1 or 0.3))
                particle.Lifetime = particle.Lifetime * 0.5
                particle.Speed = particle.Speed * 0.7
                particle.SpreadAngle = Vector2.new(5, 5)
                particle.VelocityInheritance = 0
            end
            if LowPerformanceMode and AggressiveMode then
                particle.Enabled = false
            end
        elseif particle:IsA("Fire") then
            if not CachedObjects[particle] then
                CachedObjects[particle] = {
                    Enabled = particle.Enabled,
                    Size = particle.Size,
                    Heat = particle.Heat
                }
            end
            if Settings.ReduceParticles then
                particle.Size = particle.Size * 0.5
                particle.Heat = particle.Heat * 0.3
            end
        elseif particle:IsA("Smoke") then
            if not CachedObjects[particle] then
                CachedObjects[particle] = {
                    Enabled = particle.Enabled,
                    RiseVelocity = particle.RiseVelocity,
                    Opacity = particle.Opacity
                }
            end
            if Settings.ReduceParticles then
                particle.Enabled = false
            end
        elseif particle:IsA("Sparkles") then
            if not CachedObjects[particle] then
                CachedObjects[particle] = {Enabled = particle.Enabled}
            end
            if Settings.ReduceParticles then
                particle.Enabled = false
            end
        elseif particle:IsA("Trail") then
            if not CachedObjects[particle] then
                CachedObjects[particle] = {
                    Enabled = particle.Enabled,
                    Lifetime = particle.Lifetime,
                    MinLength = particle.MinLength
                }
            end
            if Settings.ReduceParticles then
                particle.Lifetime = particle.Lifetime * 0.3
                particle.MinLength = 0
            end
        end
    end
end

local function OptimizeAnimations()
    for _, character in ipairs(Workspace:GetDescendants()) do
        if character:IsA("Model") and character:FindFirstChild("Humanoid") then
            local humanoid = character.Humanoid
            if humanoid.Animator then
                local animator = humanoid.Animator
                if not CachedObjects[animator] then
                    CachedObjects[animator] = {}
                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                        table.insert(CachedObjects[animator], {track = track, time = track.TimePosition})
                    end
                end
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
                        if not CachedObjects[accessory] then
                            CachedObjects[accessory] = {Handle = accessory.Handle}
                        end
                        if accessory.Handle then
                            accessory.Handle.Visible = false
                        end
                    end
                end
            end
        end
    end
end

local function OptimizeRenderDistance()
    local playerPos = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
    if not playerPos then return end
    
    local currentDist = AggressiveMode and Settings.RenderDistance * 0.4 or (LowPerformanceMode and Settings.RenderDistance * 0.6 or Settings.RenderDistance)
    
    local renderQueue = {}
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Parent and not obj.Parent:IsA("Tool") and obj ~= playerPos then
            local distance = (playerPos.Position - obj.Position).Magnitude
            table.insert(renderQueue, {obj = obj, dist = distance})
        end
    end
    
    table.sort(renderQueue, function(a, b) return a.dist < b.dist end)
    
    local visibleCount = 0
    for _, item in ipairs(renderQueue) do
        if item.dist <= currentDist then
            if CachedObjects[item.obj] == false then
                item.obj.Visible = true
                CachedObjects[item.obj] = nil
            end
            visibleCount = visibleCount + 1
        else
            if item.obj.Visible then
                if not CachedObjects[item.obj] then
                    CachedObjects[item.obj] = item.obj.Visible
                end
                item.obj.Visible = false
            end
        end
    end
    
    PerformanceMetrics.DrawCalls = visibleCount
end

local function OptimizePhysics()
    Workspace.FallenPartsDestroyHeight = -200
    Workspace.Gravity = AggressiveMode and 150 or 196.2
    
    for _, constraint in ipairs(Workspace:GetDescendants()) do
        if constraint:IsA("Constraint") then
            if not CachedObjects[constraint] then
                CachedObjects[constraint] = constraint.Enabled
            end
            if LowPerformanceMode or AggressiveMode then
                constraint.Enabled = false
            end
        end
    end
    
    for _, ragdoll in ipairs(Workspace:GetDescendants()) do
        if ragdoll:IsA("Ragdoll") or (ragdoll:IsA("Model") and ragdoll.Name:lower():find("ragdoll")) then
            if not CachedObjects[ragdoll] then
                CachedObjects[ragdoll] = {Parent = ragdoll.Parent}
            end
            if AggressiveMode then
                ragdoll:Destroy()
            end
        end
    end
    
    if AggressiveMode then
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

local function OptimizeClutter()
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
        
        if mesh:IsA("CylinderMesh") or mesh:IsA("BlockMesh") or mesh:IsA("SpecialMesh") then
            if LowPerformanceMode then
                if not CachedObjects[mesh] then
                    CachedObjects[mesh] = {Scale = mesh.Scale}
                end
                mesh.Scale = mesh.Scale * 0.8
            end
        end
    end
    
    for _, terrain in ipairs(Workspace:GetDescendants()) do
        if terrain:IsA("Terrain") and Settings.DisableTerrain then
            terrain.WaterWaveSize = 0
            terrain.WaterReflectance = 0
            terrain.WaterRefraction = 0
            if AggressiveMode then
                terrain:Clear()
            end
        end
    end
    
    for _, clutter in ipairs(Workspace:GetDescendants()) do
        if clutter:IsA("Model") and Settings.ReduceClutter then
            local isDecoration = false
            for _, tag in ipairs(clutter:GetTags()) do
                if tag == "Decoration" or tag == "Clutter" or tag == "Environment" then
                    isDecoration = true
                    break
                end
            end
            if isDecoration and clutter ~= LocalPlayer.Character then
                if not CachedObjects[clutter] then
                    CachedObjects[clutter] = clutter.Parent
                end
                if AggressiveMode then
                    clutter:Destroy()
                elseif LowPerformanceMode then
                    clutter.Archivable = false
                    for _, part in ipairs(clutter:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Visible = false
                        end
                    end
                end
            end
        end
    end
end

local function OptimizeWeatherAndEffects()
    if Settings.DisableWeather then
        for _, atmosphere in ipairs(Lighting:GetChildren()) do
            if atmosphere:IsA("Atmosphere") then
                if not CachedObjects[atmosphere] then
                    CachedObjects[atmosphere] = {
                        Density = atmosphere.Density,
                        Offset = atmosphere.Offset,
                        Color = atmosphere.Color
                    }
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
        
        for _, bloom in ipairs(Lighting:GetChildren()) do
            if bloom:IsA("BloomEffect") or bloom:IsA("BlurEffect") or bloom:IsA("SunRaysEffect") then
                if not CachedObjects[bloom] then
                    CachedObjects[bloom] = {Enabled = bloom.Enabled}
                end
                bloom.Enabled = false
            end
            if bloom:IsA("ColorCorrectionEffect") then
                if not CachedObjects[bloom] then
                    CachedObjects[bloom] = {Enabled = bloom.Enabled}
                end
                bloom.Enabled = false
            end
        end
    end
    
    if Settings.DisableExplosions then
        for _, explosion in ipairs(Workspace:GetDescendants()) do
            if explosion:IsA("Explosion") then
                if not CachedObjects[explosion] then
                    CachedObjects[explosion] = {
                        BlastPressure = explosion.BlastPressure,
                        BlastRadius = explosion.BlastRadius
                    }
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

local function OptimizeNetwork()
    if not Settings.ReduceNetwork then return end
    
    local remoteQueue = {}
    
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") or remote:IsA("UnreliableRemoteEvent") then
            if not CachedObjects[remote] then
                CachedObjects[remote] = {Parent = remote.Parent}
            end
            if AggressiveMode then
                remote.Parent = nil
            end
        end
    end
    
    for _, remote in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            if AggressiveMode then
                remote:Destroy()
            end
        end
    end
end

local function StartMemoryManagement()
    spawn(function()
        while OptimizerActive do
            wait(30)
            for obj, _ in pairs(CachedObjects) do
                if not obj or not obj.Parent then
                    CachedObjects[obj] = nil
                end
            end
            local mem = collectgarbage("count")
            PerformanceMetrics.MemoryUsage = mem
            if mem > 400 then
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
    
    RunService.RenderStepped:Connect(function(deltaTime)
        if not OptimizerActive then return end
        UpdatePerformanceMetrics(deltaTime)
    end)
    
    RunService.Heartbeat:Connect(function()
        if not OptimizerActive then return end
        
        if Settings.FPSBoost then
            OptimizeGraphics()
            OptimizePhysics()
            OptimizeClutter()
            OptimizeWeatherAndEffects()
            OptimizeNetwork()
            
            if Settings.ReduceParticles then
                OptimizeParticles()
            end
            
            if Settings.DisableAnimations then
                OptimizeAnimations()
            end
            
            OptimizeRenderDistance()
        end
    end)
    
    StartMemoryManagement()
    
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
    
    for obj, props in pairs(CachedObjects) do
        if obj and obj.Parent then
            for prop, value in pairs(props) do
                pcall(function()
                    obj[prop] = value
                end)
            end
        end
    end
    
    for obj, original in pairs(OriginalProperties) do
        if obj and obj.Parent then
            pcall(function()
                if type(original) == "table" then
                    for prop, val in pairs(original) do
                        obj[prop] = val
                    end
                else
                    obj.Shadows = original
                end
            end)
        end
    end
    
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
    
    CachedObjects = {}
    OriginalProperties = {}
    
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
