local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer

if not Player then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    Player = Players.LocalPlayer
end

-- 1. CEK GAME ID
local TargetGameID = 129827112113663
if game.PlaceId ~= TargetGameID then
    Player:Kick("❌ SALAH GAME NGAB! Script ini khusus buat game Telur.")
    return 
end

-- 2. SETUP API VERCEL (⚠️ GANTI PAKE LINK VERCEL LU ⚠️)
local WebStart = "https://key-system-telur.vercel.app/start" 
local WebAPI = "https://key-system-telur.vercel.app/api/verify"

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
Frame.Size = UDim2.new(0, 300, 0, 150)
Frame.Position = UDim2.new(0.5, -150, 0.5, -75)
Frame.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", Frame).Color = Color3.fromRGB(0, 255, 255)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "🔑 EGG HUNTER - LOGIN"
Title.TextColor3 = Color3.fromRGB(200, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1
Title.Parent = Frame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -20, 0, 35)
KeyInput.Position = UDim2.new(0, 10, 0, 45)
KeyInput.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.PlaceholderText = "Masukin Key lu di sini..."
KeyInput.Font = Enum.Font.Gotham
KeyInput.Parent = Frame
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 5)

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0.45, 0, 0, 35)
GetKeyBtn.Position = UDim2.new(0, 10, 1, -45)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
GetKeyBtn.Text = "GET KEY"
GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.Parent = Frame
Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 5)

local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(0.45, 0, 0, 35)
VerifyBtn.Position = UDim2.new(1, -145, 1, -45)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
VerifyBtn.Text = "VERIFY KEY"
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.Parent = Frame
Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 5)

-- 4. LOGIKA TOMBOL
GetKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(WebStart) 
        pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Sistem Key", Text = "Link udah di-copy! Paste di browser lu.", Duration = 4}) end)
    else
        warn("Executor lu ga support copy link ngab!")
    end
end)

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
                task.wait(1)
                ScreenGui:Destroy()
                
                -- SALAMAN RAHASIA & PANGGIL SCRIPT UTAMA
                _G.AuthToken_EggHunter = "KuliJawa_M4nt4p_2026"
                loadstring(game:HttpGet("https://raw.githubusercontent.com/KuliJawa-Maker/ojis/refs/heads/main/game/129827112113663.lua"))()
                _G.AuthToken_EggHunter = nil
            else
                VerifyBtn.Text = "VERIFY KEY"
                pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Akses Ditolak", Text = data.message or "Key lu salah kocak!", Duration = 3}) end)
            end
        else
            VerifyBtn.Text = "VERIFY KEY"
            warn("Gagal connect ke Vercel API!")
        end
    else
        VerifyBtn.Text = "VERIFY KEY"
        warn("Executor lu ga support HTTP Request!")
    end
end)
