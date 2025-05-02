local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local AimbotKey = Enum.KeyCode.R
local AimPartName = "Head"
local selectedTarget = nil
local function isAlive(player)
    local char = player.Character
    local humanoid = char and char:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end


local function isTeammate(player)
    return player.Team == LocalPlayer.Team
end


local function getClosestPlayer()
    local closest, shortestDistance = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer 
            and not isTeammate(player) 
            and isAlive(player) 
            and player.Character 
            and player.Character:FindFirstChild(AimPartName) then

            local part = player.Character[AimPartName]
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closest = player
                end
            end
        end
    end
    return closest
end


local function resetHitbox(player)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local part = char.HumanoidRootPart
        part.Size = Vector3.new(2, 2, 1)
        part.Transparency = 1
        part.CanCollide = false
        part.Material = Enum.Material.Plastic
    end
end


local function createESP(player)
    if player.Character and player.Character:FindFirstChild("Head") then
        if not player.Character:FindFirstChild("ESPName") then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESPName"
            billboard.Size = UDim2.new(0, 100, 0, 40)
            billboard.StudsOffset = Vector3.new(0, 2, 0)
            billboard.AlwaysOnTop = true
            billboard.Adornee = player.Character.Head
            billboard.Parent = player.Character

            local text = Instance.new("TextLabel", billboard)
            text.Size = UDim2.new(1, 0, 1, 0)
            text.BackgroundTransparency = 1
            text.Text = player.Name
            text.TextColor3 = Color3.fromRGB(255, 0, 255)
            text.TextStrokeTransparency = 0
            text.Font = Enum.Font.SourceSansBold
            text.TextScaled = true
        end
    end
end


UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == AimbotKey then
        if selectedTarget == nil then
            selectedTarget = getClosestPlayer()
        else
            selectedTarget = nil
        end
    end
end)


RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player) and not isTeammate(player) then
            resetHitbox(player)
            createESP(player)
        end
    end

    
    if selectedTarget then
        if not isAlive(selectedTarget) or isTeammate(selectedTarget) then
            selectedTarget = nil
        end
    end

   
    if not selectedTarget then
        selectedTarget = getClosestPlayer()
    end

  
    if selectedTarget and selectedTarget.Character and selectedTarget.Character:FindFirstChild(AimPartName) then
        local aimPart = selectedTarget.Character[AimPartName]
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPart.Position)
    end
end)
