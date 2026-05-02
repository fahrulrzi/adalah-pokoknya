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
-- local LinkPrem1Month = "https://discord.gg/server-lu-atau-toko-lu" -- Link toko beli bulanan
-- local LinkPremPerm = "https://discord.gg/server-lu-atau-toko-lu" -- Link toko beli permanen

local function getHWID()
    local success, result = pcall(function() return game:GetService("RbxAnalyticsService"):GetClientId() end)
    if success and result then return result end
    return tostring(Player.UserId)
end
local myHwid = getHWID()
local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local KeyFileName = "KuliJawa_SavedKey.txt"

local function CheckSavedKey()
    -- Cek apakah eksekutor support file system dan filenya ada
    if isfile and readfile and isfile(KeyFileName) then
        local savedKey = readfile(KeyFileName)
        
        if savedKey and savedKey ~= "" then
            print("Mencoba Auto-Login dengan Saved Key...")
            
            -- Tembak API diem-diem
            local success, res = pcall(function() return httprequest({Url = WebAPI .. "?key=" .. savedKey .. "&hwid=" .. myHwid, Method = "GET"}) end)
            
            if success and res then
                local bodySuccess, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
                
                -- Kalo key di file masih aktif dan valid
                if bodySuccess and data and data.success == true then
                    local userTier = data.tier or "Free (12H)"
                    
                    local expTime = 0
                    local expString = tostring(data.expiry)

                    if expString == "Permanent" then
                        expTime = os.time() + 999999999 -- Angka gaban biar ga abis-abis
                    else
                        -- 1. Coba pake DateTime Roblox
                        local dt = DateTime.fromIsoDate(expString)
                        
                        if dt then
                            expTime = dt.UnixTimestamp
                        else
                            -- 2. Coba pake manual (jaga-jaga API lu ngirim spasi bukan huruf T)
                            local y, m, d, h, min, s = expString:match("(%d+)-(%d+)-(%d+)[T%s](%d+):(%d+):(%d+)")
                            if y then 
                                expTime = os.time({year=y, month=m, day=d, hour=h, min=min, sec=s}) 
                            end
                        end
                        
                        -- 🔥 3. JARING PENGAMAN (ANTI EXPIRED INSTAN) 🔥
                        -- Kalau hasil expTime gagal (jadi 0) atau waktunya di masa lalu
                        if expTime <= os.time() then
                            warn("⚠️ Format waktu dari DB gagal dibaca! Memaksa set 12 Jam.")
                            expTime = os.time() + (12 * 3600) -- Paksa 12 jam murni dari waktu lokal!
                        end
                    end

                    -- Bikin Global Key System
                    getgenv().KuliJawa_KeySystem = {
                        IsVerified = true,
                        KeyString = savedKey,
                        Tier = userTier,
                        ExpiryTime = expTime,
                        Duration = (data.expiry == "Permanent") and "Lifetime" or "Limited",
                        GetTimeLeft = function()
                            local ks = getgenv().KuliJawa_KeySystem
                            if ks.Duration == "Lifetime" then return "Permanent" end
                            local sisa = ks.ExpiryTime - os.time()
                            if sisa <= 0 then return "Expired" end
                            local rHours = math.floor(sisa / 3600)
                            local rMins = math.floor((sisa % 3600) / 60)
                            return string.format("%02dh %02dm", rHours, rMins)
                        end
                    }

                    -- Jalanin Heartbeat di Background
                    task.spawn(function()
                        while getgenv().KuliJawa_KeySystem.IsVerified do
                            task.wait(60)
                            pcall(function()
                                local pingRes = httprequest({
                                    Url = "https://key-system-telur.vercel.app/api/ping",
                                    Method = "POST",
                                    Headers = {["Content-Type"] = "application/json"},
                                    Body = HttpService:JSONEncode({key = savedKey, hwid = myHwid})
                                })
                                local pingData = HttpService:JSONDecode(pingRes.Body)
                                if pingData and pingData.action == "KICK" then
                                    getgenv().KuliJawa_KeySystem.IsVerified = false
                                    game.Players.LocalPlayer:Kick("❌ Session lu diambil alih atau Key Expired!")
                                    if delfile then delfile(KeyFileName) end -- Hapus file kalo ke-kick
                                end
                            end)
                        end
                    end)
                    
                    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Auto Login Success", Text = "Welcome back! Tier: " .. userTier, Duration = 5}) end)
                    
                    -- Langsung Panggil Script Utama
                    _G.AuthToken_EggHunter = "KuliJawa_M4nt4p_2026"
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/fahrulrzi/adalah-pokoknya/refs/heads/main/pros.lua"))()
                    _G.AuthToken_EggHunter = nil
                    
                    return true -- Ngabarin kalo Auto-Login Sukses
                else
                    -- Kalo Key expired atau gagal, hapus filenya biar user disuruh masukin manual lagi
                    if delfile then delfile(KeyFileName) end
                end
            end
        end
    end
    return false -- Kalo file ga ada atau gagal, return false
end

-- ========================================================
-- 🔥 EKSEKUSI AUTO LOGIN SEBELUM MUNCULIN UI 🔥
-- ========================================================
if CheckSavedKey() then
    return -- STOP SCRIPT DI SINI! Ga usah nampilin UI Login ke layar
end

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
Title.Text = "Kuli Jawa Maker - LOGIN"
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

-- local GetMonthBtn = Instance.new("TextButton")
-- GetMonthBtn.Size = UDim2.new(1, -20, 0, 30)
-- GetMonthBtn.Position = UDim2.new(0, 10, 0, 195)
-- GetMonthBtn.BackgroundColor3 = Color3.fromRGB(180, 120, 30) -- Warna Emas
-- GetMonthBtn.Text = "⭐ GET PREMIUM 1$ (1 MONTH)"
-- GetMonthBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
-- GetMonthBtn.Font = Enum.Font.GothamBold
-- GetMonthBtn.TextSize = 12
-- GetMonthBtn.Parent = Frame
-- Instance.new("UICorner", GetMonthBtn).CornerRadius = UDim.new(0, 4)

-- local GetPermBtn = Instance.new("TextButton")
-- GetPermBtn.Size = UDim2.new(1, -20, 0, 30)
-- GetPermBtn.Position = UDim2.new(0, 10, 0, 235)
-- GetPermBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 150) -- Warna Ungu Mewah
-- GetPermBtn.Text = "💎 GET PREMIUM 5$ (PERMANENT)"
-- GetPermBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
-- GetPermBtn.Font = Enum.Font.GothamBold
-- GetPermBtn.TextSize = 12
-- GetPermBtn.Parent = Frame
-- Instance.new("UICorner", GetPermBtn).CornerRadius = UDim.new(0, 4)


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
-- GetMonthBtn.MouseButton1Click:Connect(function() CopyLink(LinkPrem1Month, "Premium 1 Month") end)
-- GetPermBtn.MouseButton1Click:Connect(function() CopyLink(LinkPremPerm, "Premium Permanent") end)

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

                -- Simpen Key ke file biar besok-besok auto login
                if writefile then
                    writefile(KeyFileName, inputKey)
                end
                
                local userTier = data.tier or "Free (12H)"
                
                -- ========================================================
                -- 🔥 1. BIKIN GLOBAL KEY SYSTEM BUAT SCRIPT UTAMA 🔥
                -- ========================================================
                local expTime = 0
                    local expString = tostring(data.expiry)

                    if expString == "Permanent" then
                        expTime = os.time() + 999999999 -- Angka gaban biar ga abis-abis
                    else
                        -- 1. Coba pake DateTime Roblox
                        local dt = DateTime.fromIsoDate(expString)
                        
                        if dt then
                            expTime = dt.UnixTimestamp
                        else
                            -- 2. Coba pake manual (jaga-jaga API lu ngirim spasi bukan huruf T)
                            local y, m, d, h, min, s = expString:match("(%d+)-(%d+)-(%d+)[T%s](%d+):(%d+):(%d+)")
                            if y then 
                                expTime = os.time({year=y, month=m, day=d, hour=h, min=min, sec=s}) 
                            end
                        end
                        
                        -- 🔥 3. JARING PENGAMAN (ANTI EXPIRED INSTAN) 🔥
                        -- Kalau hasil expTime gagal (jadi 0) atau waktunya di masa lalu
                        if expTime <= os.time() then
                            warn("⚠️ Format waktu dari DB gagal dibaca! Memaksa set 12 Jam.")
                            expTime = os.time() + (12 * 3600) -- Paksa 12 jam murni dari waktu lokal!
                        end
                    end

                getgenv().KuliJawa_KeySystem = {
                    IsVerified = true,
                    KeyString = inputKey,
                    Tier = userTier,
                    ExpiryTime = expTime,
                    Duration = (data.expiry == "Permanent") and "Lifetime" or "Limited",
                    
                    -- Fungsi sakti buat ngitung sisa waktu di UI Utama
                    GetTimeLeft = function()
                        local ks = getgenv().KuliJawa_KeySystem
                        if ks.Duration == "Lifetime" then return "Permanent" end
                        
                        local sisa = ks.ExpiryTime - os.time()
                        if sisa <= 0 then return "Expired" end
                        
                        local rHours = math.floor(sisa / 3600)
                        local rMins = math.floor((sisa % 3600) / 60)
                        return string.format("%02dh %02dm", rHours, rMins)
                    end
                }

                -- ========================================================
                -- 🔥 2. JALANIN HEARTBEAT PING DI BACKGROUND 🔥
                -- ========================================================
                task.spawn(function()
                    while getgenv().KuliJawa_KeySystem.IsVerified do
                        task.wait(60) -- Ping tiap 60 detik
                        pcall(function()
                            local pingRes = httprequest({
                                Url = "https://key-system-telur.vercel.app/api/ping",
                                Method = "POST",
                                Headers = {["Content-Type"] = "application/json"},
                                Body = HttpService:JSONEncode({key = inputKey, hwid = myHwid})
                            })
                            local pingData = HttpService:JSONDecode(pingRes.Body)
                            if pingData and pingData.action == "KICK" then
                                getgenv().KuliJawa_KeySystem.IsVerified = false
                                game.Players.LocalPlayer:Kick("❌ Session lu diambil alih di Device lain atau Key Expired!")
                            end
                        end)
                    end
                end)
                
                -- ========================================================
                -- 🔥 3. LOAD MAIN SCRIPT 🔥
                -- ========================================================
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