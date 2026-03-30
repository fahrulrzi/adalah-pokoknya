local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Player = Players.LocalPlayer

if not Player then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    Player = Players.LocalPlayer
end

-- ==========================================
-- GLOBAL SETTINGS
-- ==========================================
_G.ESPToggled = false
_G.MagnetToggled = false
_G.IsWorking = false

local espTextTable = {} 
local ESP_COLOR = Color3.fromRGB(0, 255, 255)
local MAGNET_RADIUS = 25 

-- ==========================================
-- 1. UI COMPACT & MINIMIZE
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CompactEggHunterV7"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true 

local uiParent
pcall(function() uiParent = gethui() end)
if not uiParent then pcall(function() uiParent = game:GetService("CoreGui") end) end
if not uiParent then uiParent = Player:WaitForChild("PlayerGui", 5) end

if uiParent then ScreenGui.Parent = uiParent else return end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 180, 0, 140)
MainFrame.Position = UDim2.new(0.95, -185, 0.5, -70)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(50, 60, 80)

local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = input.Position startPos = MainFrame.Position end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 22)
Title.BackgroundTransparency = 1
Title.Text = "🥚 EGG HUNTER V7"
Title.TextColor3 = Color3.fromRGB(200, 255, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.Parent = MainFrame

local ServerCountLabel = Instance.new("TextLabel")
ServerCountLabel.Size = UDim2.new(1, -10, 0, 15)
ServerCountLabel.Position = UDim2.new(0, 5, 0, 25)
ServerCountLabel.BackgroundTransparency = 1
ServerCountLabel.Text = "Server: --"
ServerCountLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
ServerCountLabel.Font = Enum.Font.GothamMedium
ServerCountLabel.TextSize = 10
ServerCountLabel.Parent = MainFrame

local EspBtn = Instance.new("TextButton")
EspBtn.Size = UDim2.new(1, -10, 0, 25)
EspBtn.Position = UDim2.new(0, 5, 0, 45)
EspBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
EspBtn.Text = "ESP: OFF"
EspBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EspBtn.Font = Enum.Font.GothamBold
EspBtn.TextSize = 11
EspBtn.Parent = MainFrame
Instance.new("UICorner", EspBtn).CornerRadius = UDim.new(0, 4)

local MagnetBtn = Instance.new("TextButton")
MagnetBtn.Size = UDim2.new(1, -10, 0, 25)
MagnetBtn.Position = UDim2.new(0, 5, 0, 75)
MagnetBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
MagnetBtn.Text = "MAGNET: OFF"
MagnetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MagnetBtn.Font = Enum.Font.GothamBold
MagnetBtn.TextSize = 11
MagnetBtn.Parent = MainFrame
Instance.new("UICorner", MagnetBtn).CornerRadius = UDim.new(0, 4)

local ActionBtn = Instance.new("TextButton")
ActionBtn.Size = UDim2.new(1, -10, 0, 30)
ActionBtn.Position = UDim2.new(0, 5, 1, -35)
ActionBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
ActionBtn.Text = "AUTO-NGEGRAB (1x)"
ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionBtn.Font = Enum.Font.GothamBold
ActionBtn.TextSize = 11
ActionBtn.Parent = MainFrame
Instance.new("UICorner", ActionBtn).CornerRadius = UDim.new(0, 4)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 18, 0, 18)
CloseBtn.Position = UDim2.new(1, -22, 0, 2)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 10
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 18, 0, 18)
MinimizeBtn.Position = UDim2.new(1, -44, 0, 2)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 12
MinimizeBtn.Parent = MainFrame
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 4)

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 30, 0, 30)
OpenBtn.Position = UDim2.new(1, -35, 0.5, -15)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
OpenBtn.Text = "🥚"
OpenBtn.TextSize = 15
OpenBtn.Visible = false
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(150, 255, 150)

MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true OpenBtn.Visible = false end)

-- ==========================================
-- 2. LOGIKA ESP (RADAR FIX 100%)
-- ==========================================
local function FindAllEggs()
    local found = {}
    -- FIX MAUT: Kita scan SELURUH map tanpa kecuali pake GetDescendants
    -- Biar sekecil apapun sub-foldernya, telurnya bakal tetep ketarik!
    for _, obj in ipairs(workspace:GetDescendants()) do 
        if obj.Name == "EasterEgg" and obj.Parent then 
            table.insert(found, obj) 
        end 
    end
    return found
end

local function ClearAllESP()
    for obj, billboard in pairs(espTextTable) do if billboard and billboard.Parent then billboard:Destroy() end end
    espTextTable = {}
    
    for _, egg in ipairs(FindAllEggs()) do
        if egg:FindFirstChild("EggESP_Text") then egg.EggESP_Text:Destroy() end
    end
end

local function CreateESPText(obj)
    if obj:FindFirstChild("EggESP_Text") then return end

    -- Kita ga pake Highlight lagi biar ga kena limit 31 objek dari Roblox
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EggESP_Text"
    billboard.Size = UDim2.new(0, 80, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = obj
    billboard.Parent = obj
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "TextElement"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "[egg]\n[...]"
    textLabel.TextColor3 = ESP_COLOR
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 12
    textLabel.TextStrokeTransparency = 0
    textLabel.Parent = billboard

    espTextTable[obj] = billboard
end

EspBtn.MouseButton1Click:Connect(function()
    _G.ESPToggled = not _G.ESPToggled
    EspBtn.Text = _G.ESPToggled and "ESP: ON" or "ESP: OFF"
    EspBtn.BackgroundColor3 = _G.ESPToggled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
    if not _G.ESPToggled then ClearAllESP() end
end)

MagnetBtn.MouseButton1Click:Connect(function()
    _G.MagnetToggled = not _G.MagnetToggled
    MagnetBtn.Text = _G.MagnetToggled and "MAGNET: ON" or "MAGNET: OFF"
    MagnetBtn.BackgroundColor3 = _G.MagnetToggled and Color3.fromRGB(150, 100, 30) or Color3.fromRGB(150, 50, 50)
end)

RunService.RenderStepped:Connect(function()
    if _G.ESPToggled then
        local char = Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if hrp and hum and hum.Health > 0 then
            local hrpPos = hrp.Position
            for egg, billboard in pairs(espTextTable) do
                if egg.Parent and billboard.Parent and billboard:FindFirstChild("TextElement") then
                    local eggPos = egg:IsA("Model") and egg:GetPivot().Position or egg.Position
                    local dist = (hrpPos - eggPos).Magnitude
                    billboard.TextElement.Text = "[egg]\n[" .. tostring(math.floor(dist)) .. "]"
                end
            end
        end
    end
end)

-- ==========================================
-- 3. BACKGROUND LOOP (Telor + MAGNET AURA)
-- ==========================================
task.spawn(function()
    while MainFrame.Parent do
        local currentEggs = FindAllEggs()
        if ServerCountLabel then ServerCountLabel.Text = "Server: " .. #currentEggs end
        
        if _G.MagnetToggled then
            local char = Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, egg in ipairs(currentEggs) do
                    local eggPos = egg:IsA("Model") and egg:GetPivot().Position or egg.Position
                    if (hrp.Position - eggPos).Magnitude <= MAGNET_RADIUS then
                        local eggPart = egg:IsA("BasePart") and egg or egg:FindFirstChildWhichIsA("BasePart")
                        if eggPart and firetouchinterest then
                            pcall(function()
                                firetouchinterest(hrp, eggPart, 0)
                                task.wait(0.01)
                                firetouchinterest(hrp, eggPart, 1)
                            end)
                        end
                    end
                end
            end
        end
        
        if _G.ESPToggled then
            for _, egg in ipairs(currentEggs) do CreateESPText(egg) end
            for egg, _ in pairs(espTextTable) do if not egg.Parent then espTextTable[egg] = nil end end
        end
        
        task.wait(1) -- Dikasih jeda 1 detik biar map scan-nya ga bikin HP panas
    end
end)

-- ==========================================
-- 4. LOGIKA HYBRID TP + JALAN
-- ==========================================
local currentEggIndex = 1
local FastTravelRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("FastTravel")
local WaypointsFolder = workspace:WaitForChild("Map"):WaitForChild("Waypoints")

local function GetClosestWaypoint(targetPosition)
    local closestWP = nil
    local shortestDist = math.huge
    for _, wp in ipairs(WaypointsFolder:GetChildren()) do
        if wp:IsA("Model") and wp.PrimaryPart then
            local dist = (wp.PrimaryPart.Position - targetPosition).Magnitude
            if dist < shortestDist then shortestDist = dist closestWP = wp end
        end
    end
    return closestWP
end

ActionBtn.MouseButton1Click:Connect(function()
    if _G.IsWorking then _G.IsWorking = false ActionBtn.Text = "STOPPING..." return end
    
    local cEggs = FindAllEggs()
    if #cEggs == 0 then
        ActionBtn.Text = "KOSONG!"
        task.delay(1.5, function() if not _G.IsWorking then ActionBtn.Text = "AUTO-NGEGRAB (1x)" end end)
        return
    end

    if currentEggIndex > #cEggs then currentEggIndex = 1 end
    local targetEgg = cEggs[currentEggIndex]
    
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if hrp and hum and targetEgg and targetEgg.Parent then
        local targetPos = targetEgg:IsA("Model") and targetEgg:GetPivot().Position or targetEgg.Position
        
        if targetPos then
            _G.IsWorking = true
            ActionBtn.Text = "🛑 STOP"
            ActionBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
            
            task.spawn(function()
                local destWP = GetClosestWaypoint(targetPos)
                local sourceWP = GetClosestWaypoint(hrp.Position)
                
                if destWP and sourceWP and destWP ~= sourceWP then
                    ActionBtn.Text = "🛑 FT OTW..."
                    pcall(function() FastTravelRemote:FireServer(sourceWP, destWP) end)
                    task.wait(2.5) 
                end
                
                if not _G.IsWorking then return end
                ActionBtn.Text = "🛑 LARI..."
                
                local path = PathfindingService:CreatePath({AgentRadius = 3, AgentHeight = 5, AgentCanJump = true, WaypointSpacing = 4})
                local success = pcall(function() path:ComputeAsync(hrp.Position, targetPos) end)
                
                if success and path.Status == Enum.PathStatus.Success then
                    local waypoints = path:GetWaypoints()
                    for i, wp in ipairs(waypoints) do
                        if not _G.IsWorking then break end
                        if not targetEgg.Parent then break end 
                        if wp.Action == Enum.PathWaypointAction.Jump then hum.Jump = true end
                        hum:MoveTo(wp.Position)
                        local timeout = 2
                        local startTimer = tick()
                        repeat task.wait(0.1) until not _G.IsWorking or not targetEgg.Parent or (hrp.Position - wp.Position).Magnitude < 3 or (tick() - startTimer) > timeout
                    end
                    
                    if _G.IsWorking then
                        _G.IsWorking = false
                        currentEggIndex = currentEggIndex + 1
                        ActionBtn.Text = "SAMPE! (NEXT)"
                        ActionBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
                        task.delay(1.5, function() if not _G.IsWorking then ActionBtn.Text = "AUTO-NGEGRAB (1x)" ActionBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 180) end end)
                    end
                else
                    _G.IsWorking = false
                    ActionBtn.Text = "BUNTU!"
                    task.delay(2, function() ActionBtn.Text = "AUTO-NGEGRAB (1x)" end)
                end
            end)
        end
    end
end)

CloseBtn.MouseButton1Click:Connect(function() _G.IsWorking = false ClearAllESP() ScreenGui:Destroy() end)

pcall(function() StarterGui:SetCore("SendNotification", {Title = "Egg Hunter V7", Text = "Radar Diperluas 100%! Limit Breaker ON.", Duration = 4}) end)
