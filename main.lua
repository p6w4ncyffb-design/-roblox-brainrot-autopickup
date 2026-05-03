-- Brainrot auto pickup with Rayfield UI
-- Paste this into your executor or local script environment

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local function getRootPart()
    if not player.Character then return nil end
    return player.Character:FindFirstChild("HumanoidRootPart")
        or player.Character:FindFirstChild("Torso")
        or player.Character:FindFirstChild("UpperTorso")
end

local function getPickupPart(item)
    if not item then return nil end
    if item:IsA("BasePart") then
        return item
    end

    local handle = item:FindFirstChild("Handle")
    if handle and handle:IsA("BasePart") then
        return handle
    end

    for _, descendant in ipairs(item:GetDescendants()) do
        if descendant:IsA("BasePart") then
            return descendant
        end
    end

    return nil
end

local function isBrainrot(item)
    if not item then return false end
    local name = item.Name:lower()
    if name:find("brainrot") then
        return true
    end
    local parent = item.Parent
    return parent and parent.Name:lower():find("brainrot")
end

local function tryPickup(item)
    local root = getRootPart()
    if not root or not item or not item.Parent then
        return
    end

    local pickupPart = getPickupPart(item)
    if not pickupPart then
        return
    end

    if typeof(firetouchinterest) == "function" then
        firetouchinterest(pickupPart, root, 0)
        task.wait(0.08)
        firetouchinterest(pickupPart, root, 1)
    else
        root.CFrame = pickupPart.CFrame + Vector3.new(0, 3, 0)
    end
end

local function scanForBrainrots()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and isBrainrot(obj) then
            tryPickup(obj)
        elseif obj:IsA("Model") and isBrainrot(obj) then
            tryPickup(obj)
        end
    end
end

local enabled = false

-- Load Rayfield UI library
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

local Window = Rayfield:CreateWindow({
    Name = "Brainrot AutoPickup",
    LoadingTitle = "Brainrot Scanner",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BrainrotUI",
        FileName = "BrainrotConfig",
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

Window:CreateToggle({
    Name = "Auto Pickup Brainrots",
    CurrentValue = false,
    Flag = "AutoPickupToggle",
    Callback = function(value)
        enabled = value
    end,
})

Window:CreateSection("Status")
Window:CreateLabel({Name = "Toggle the switch to start or stop brainrot scanning."})

task.spawn(function()
    while task.wait(0.4) do
        if enabled then
            scanForBrainrots()
        end
    end
end)

workspace.DescendantAdded:Connect(function(descendant)
    if enabled and (isBrainrot(descendant) or (descendant.Parent and isBrainrot(descendant.Parent))) then
        task.wait(0.1)
        scanForBrainrots()
    end
end)

print("Brainrot UI loaded")
