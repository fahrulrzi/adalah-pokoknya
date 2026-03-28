local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer

-- ==========================================
-- 1. BIKIN GUI DASAR
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EggPathfinderGUI"
ScreenGui.ResetOnSpawn = false

local success, target = pcall(function() return gethui() end)
ScreenGui.Parent = (success and target) or game:GetService("CoreGui") or Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 150)
MainFrame.Position = UDim2.new(0.5, 150, 0.5, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "🥚 EGG PATHFINDER"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 50)
StatusLabel.Position = UDim2.new(0, 10, 0, 40)
StatusLabel.Text = "Status: Idle\nEggs in Server: ..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 13
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = MainFrame

local WalkBtn = Instance.new("TextButton")
WalkBtn.Size = UDim2.new(1, -30, 0, 40)
WalkBtn.Position = UDim2.new(0, 15, 1, -50)
WalkBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
WalkBtn.Text = "WALK TO NEAREST EGG"
WalkBtn.TextColor3 = Color3.new(1, 1, 1)
WalkBtn.Font = Enum.Font.GothamBold
WalkBtn.Parent = MainFrame
Instance.new("UICorner", WalkBtn).CornerRadius = UDim.new(0, 6)

-- Sistem Drag
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input) dragging = false end)

-- ==========================================
-- 2. LOGIKA JALAN OTOMATIS (PATHFINDING)
-- ==========================================
local isWalking = false
local currentPath = nil

local function FindEggs()
    local eggs = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "EasterEgg" and v.Parent then table.insert(eggs, v) end
    end
    return eggs
end

local function GetNearestEgg()
    local eggs = FindEggs()
    local nearest = nil
    local dist = math.huge
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    for _, egg in ipairs(eggs) do
        local pos = egg:IsA("Model") and egg:GetPivot().Position or egg.Position
        local d = (hrp.Position - pos).Magnitude
        if d < dist then dist = d; nearest = egg end
    end
    return nearest
end

local function StopWalking()
    isWalking = false
    WalkBtn.Text = "WALK TO NEAREST EGG"
    WalkBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
end

WalkBtn.MouseButton1Click:Connect(function()
    if isWalking then StopWalking() return end
    
    local targetEgg = GetNearestEgg()
    if not targetEgg then 
        StatusLabel.Text = "No Eggs Found!"
        return 
    end

    isWalking = true
    WalkBtn.Text = "STOP WALKING"
    WalkBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)

    task.spawn(function()
        while isWalking and targetEgg and targetEgg.Parent do
            local char = Player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp then break end

            local targetPos = targetEgg:IsA("Model") and targetEgg:GetPivot().Position or targetEgg.Position
            local distance = (hrp.Position - targetPos).Magnitude
            
            StatusLabel.Text = string.format("Target: EasterEgg\nDistance: %.1f studs", distance)

            if distance < 4 then
                StatusLabel.Text = "Reached Egg!"
                -- Senggol Bacok
                if firetouchinterest then
                    firetouchinterest(hrp, targetEgg:IsA("BasePart") and targetEgg or targetEgg:FindFirstChildWhichIsA("BasePart"), 0)
                end
                task.wait(0.5)
                StopWalking()
                break
            end

            -- Bikin Path
            local path = PathfindingService:CreatePath({AgentCanJump = true, AgentRadius = 3})
            path:ComputeAsync(hrp.Position, targetPos)
            
            if path.Status == Enum.PathStatus.Success then
                local waypoints = path:GetWaypoints()
                for i = 1, math.min(3, #waypoints) do -- Jalan per 3 titik biar update-nya cepet
                    if not isWalking then break end
                    hum:MoveTo(waypoints[i].Position)
                    if waypoints[i].Action == Enum.WaypointsAction.Jump then
                        hum.Jump = true
                    end
                    hum.MoveToFinished:Wait()
                end
            else
                -- Kalo pathfinding gagal (mungkin di pulau seberang), pake bantuan dikit
                hum:MoveTo(targetPos) 
                task.wait(0.5)
            end
            task.wait(0.1)
        end
        StopWalking()
    end)
end)

-- Update counter egg
task.spawn(function()
    while true do
        local count = #FindEggs()
        if not isWalking then
            StatusLabel.Text = "Status: Idle\nEggs in Server ada: " .. count
        end
        task.wait(1)
    end
end)
