local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer

if not Player then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    Player = Players.LocalPlayer
end

-- 1. CEK GAME ID
local TargetGameID = 129827112113663
if game.PlaceId ~= TargetGameID then
    Player:Kick("Game not found! This script is only for the Prospecting game.")
    return 
end

-- 2. SETUP API VERCEL & LINK KEY
local WebAPI = "https://key-system-telur.vercel.app/api/verify"

-- 🔥 TARUH LINK WEB/STORE LU DI SINI 🔥
local LinkFree12H = "https://key-system-telur.vercel.app/start" -- Linkvertise lu
local LinkPrem1Month = "https://discord.gg/server-lu-atau-toko-lu" -- Link toko beli bulanan
local LinkPremPerm = "https://discord.gg/server-lu-atau-toko-lu" -- Link toko beli permanen

local function getHWID()
    local success, result = pcall(function() return game:GetService("RbxAnalyticsService"):GetClientId() end)
    if success and result then return result end
    return tostring(Player.UserId)
end
local myHwid = getHWID()
local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- 3. UI LOGIN ANTI CRASH
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomLoginUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true 

local uiParent
pcall(function() uiParent = gethui() end)
if not uiParent then pcall(function() uiParent = game:GetService("CoreGui") end) end
if not uiParent then uiParent = Player:WaitForChild("PlayerGui", 5) end

if uiParent then ScreenGui.Parent = uiParent else warn("❌ Gagal load UI Login!") return end

local Frame = Instance.new("Frame")
-- 🔥 Kotaknya gw manjangin ke bawah (jadi 280) biar muat 3 tombol 🔥
Frame.Size = UDim2.new(0, 300, 0, 280) 
Frame.Position = UDim2.new(0.5, -150, 0.5, -140)
Frame.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
Frame.Active = true 
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", Frame).Color = Color3.fromRGB(0, 255, 255)

-- LOGIKA DRAG 
local dragging, dragInput, dragStart, startPos
Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
        dragging = true dragStart = input.Position startPos = Frame.Position 
    end
end)
Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "🔑 EGG HUNTER - LOGIN"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1
Title.Parent = Frame

-- TOMBOL CLOSE (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = Frame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -20, 0, 35)
KeyInput.Position = UDim2.new(0, 10, 0, 40)
KeyInput.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.PlaceholderText = "Paste your key here..."
KeyInput.Font = Enum.Font.Gotham
KeyInput.Parent = Frame
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 5)

-- Tombol Verify gw pindah ke atas tepat di bawah input
local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(1, -20, 0, 35)
VerifyBtn.Position = UDim2.new(0, 10, 0, 85)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
VerifyBtn.Text = "VERIFY KEY"
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.Parent = Frame
Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 5)

-- Garis Pembatas / Teks Info
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 0, 20)
InfoLabel.Position = UDim2.new(0, 10, 0, 130)
InfoLabel.Text = "👇 Select & Copy Key Link 👇"
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
InfoLabel.Font = Enum.Font.GothamMedium
InfoLabel.TextSize = 12
InfoLabel.BackgroundTransparency = 1
InfoLabel.Parent = Frame

-- 🔥 3 TOMBOL PILIHAN KEY 🔥
local GetFreeBtn = Instance.new("TextButton")
GetFreeBtn.Size = UDim2.new(1, -20, 0, 30)
GetFreeBtn.Position = UDim2.new(0, 10, 0, 155)
GetFreeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
GetFreeBtn.Text = "🆓 GET FREE KEY (12H)"
GetFreeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetFreeBtn.Font = Enum.Font.GothamBold
GetFreeBtn.TextSize = 12
GetFreeBtn.Parent = Frame
Instance.new("UICorner", GetFreeBtn).CornerRadius = UDim.new(0, 4)

local GetMonthBtn = Instance.new("TextButton")
GetMonthBtn.Size = UDim2.new(1, -20, 0, 30)
GetMonthBtn.Position = UDim2.new(0, 10, 0, 195)
GetMonthBtn.BackgroundColor3 = Color3.fromRGB(180, 120, 30) -- Warna Emas
GetMonthBtn.Text = "⭐ GET PREMIUM 1$ (1 MONTH)"
GetMonthBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetMonthBtn.Font = Enum.Font.GothamBold
GetMonthBtn.TextSize = 12
GetMonthBtn.Parent = Frame
Instance.new("UICorner", GetMonthBtn).CornerRadius = UDim.new(0, 4)

local GetPermBtn = Instance.new("TextButton")
GetPermBtn.Size = UDim2.new(1, -20, 0, 30)
GetPermBtn.Position = UDim2.new(0, 10, 0, 235)
GetPermBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 150) -- Warna Ungu Mewah
GetPermBtn.Text = "💎 GET PREMIUM 5$ (PERMANENT)"
GetPermBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetPermBtn.Font = Enum.Font.GothamBold
GetPermBtn.TextSize = 12
GetPermBtn.Parent = Frame
Instance.new("UICorner", GetPermBtn).CornerRadius = UDim.new(0, 4)


-- 4. LOGIKA TOMBOL
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Fungsi rahasia biar kode copy link ga panjang dan ga diulang-ulang
local function CopyLink(linkUrl, tierName)
    if setclipboard then
        setclipboard(linkUrl) 
        pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Link Copied!", Text = "Link " .. tierName .. " has been copied to your clipboard.", Duration = 4}) end)
    else
        warn("Executor lu ga support copy link ngab!")
    end
end

GetFreeBtn.MouseButton1Click:Connect(function() CopyLink(LinkFree12H, "Free 12H") end)
GetMonthBtn.MouseButton1Click:Connect(function() CopyLink(LinkPrem1Month, "Premium 1 Month") end)
GetPermBtn.MouseButton1Click:Connect(function() CopyLink(LinkPremPerm, "Premium Permanent") end)

VerifyBtn.MouseButton1Click:Connect(function()
    local inputKey = KeyInput.Text
    if inputKey == "" then return end
    
    VerifyBtn.Text = "Checking..."
    
    if httprequest then
        local success, res = pcall(function() return httprequest({Url = WebAPI .. "?key=" .. inputKey .. "&hwid=" .. myHwid, Method = "GET"}) end)
        
        if success and res then
            local bodySuccess, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
            
            if bodySuccess and data and data.success == true then
                VerifyBtn.Text = "SUCCESS!"
                VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                
                local userTier = data.tier or "Free (12H)"
                _G.KuliJawa_Tier = userTier 
                
                pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Access Granted", Text = "Welcome! Your tier is : " .. userTier, Duration = 5}) end)
                
                task.wait(1)
                ScreenGui:Destroy()
                
                -- SALAMAN RAHASIA & PANGGIL SCRIPT UTAMA
                _G.AuthToken_EggHunter = "KuliJawa_M4nt4p_2026"
                loadstring(game:HttpGet("https://raw.githubusercontent.com/fahrulrzi/adalah-pokoknya/refs/heads/main/pros.lua"))()
                _G.AuthToken_EggHunter = nil
            else
                VerifyBtn.Text = "VERIFY KEY"
                pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Access Denied", Text = data.message or "Your key is invalid or expired!", Duration = 3}) end)
            end
        else
            VerifyBtn.Text = "VERIFY KEY"
            warn("HTTP Request failed: " .. tostring(res))
        end
    else
        VerifyBtn.Text = "VERIFY KEY"
        warn("Your executor does not support HTTP Requests!")
    end
end)