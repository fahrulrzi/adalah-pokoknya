local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer

if not Player then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    Player = Players.LocalPlayer
end

local TargetGameID = 129827112113663
if game.PlaceId ~= TargetGameID then
    Player:Kick("Game not found! This script is only for the Prospecting game.")
    return 
end

-- 2. SETUP API VERCEL & LINK KEY
local WebAPI = "https://key-system-telur.vercel.app/api/verify"

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
    if isfile and readfile and isfile(KeyFileName) then
        local savedKey = readfile(KeyFileName)
        
        if savedKey and savedKey ~= "" then
            print("Mencoba Auto-Login dengan Saved Key...")
            
            local success, res = pcall(function() return httprequest({Url = WebAPI .. "?key=" .. savedKey .. "&hwid=" .. myHwid, Method = "GET"}) end)
            
            if success and res then
                local bodySuccess, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
                
                if bodySuccess and data and data.success == true then
                    local userTier = data.tier or "Free (12H)"
                    
                    local expTime = 0

                    if data.expiry == "Permanent" then
                        expTime = os.time() + 315360000 -- 10 Tahun
                    else
                        local dt = DateTime.fromIsoDate(data.expiry)
                        if dt then
                            expTime = dt.UnixTimestamp
                        else
                            warn("⚠️ [KULI JAWA] Gagal parsing ISO Date: " .. tostring(data.expiry))
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
                                    _G.KuliJawa_IsFarming = false
                                    
                                    if delfile and isfile(KeyFileName) then 
                                        delfile(KeyFileName) 
                                    end 
                                    
                                    pcall(function() 
                                        game:GetService("StarterGui"):SetCore("SendNotification", {
                                            Title = "Sesi Berakhir", 
                                            Text = "Key expired atau dipakai di device lain!", 
                                            Duration = 5
                                        }) 
                                    end)
                                    
                                    if getgenv().KuliJawa_MainUI then 
                                        getgenv().KuliJawa_MainUI:Destroy() 
                                    end
                                    
                                    task.wait(1)
                                    loadstring(game:HttpGet("https://raw.githubusercontent.com/KuliJawa-Maker/ojis/refs/heads/main/main.lua"))()
                                end
                            end)
                        end
                    end)
                    
                    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Auto Login Success", Text = "Welcome back! Tier: " .. userTier, Duration = 5}) end)
                    
                    _G.AuthToken_EggHunter = "KuliJawa_M4nt4p_2026"
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/KuliJawa-Maker/ojis/refs/heads/main/game/129827112113663.lua"))()
                    _G.AuthToken_EggHunter = nil
                    
                    return true
                else
                    if delfile then delfile(KeyFileName) end
                end
            end
        end
    end
    return false 
end

if CheckSavedKey() then
    return 
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

local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(1, -20, 0, 35)
VerifyBtn.Position = UDim2.new(0, 10, 0, 85)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
VerifyBtn.Text = "VERIFY KEY"
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.Parent = Frame
Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 5)

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 0, 20)
InfoLabel.Position = UDim2.new(0, 10, 0, 130)
InfoLabel.Text = "👇 Select & Copy Key Link 👇"
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
InfoLabel.Font = Enum.Font.GothamMedium
InfoLabel.TextSize = 12
InfoLabel.BackgroundTransparency = 1
InfoLabel.Parent = Frame

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

                if writefile then
                    writefile(KeyFileName, inputKey)
                end
                
                local userTier = data.tier or "Free (12H)"
                local expTime = 0

                if data.expiry == "Permanent" then
                    expTime = os.time() + 315360000
                else
                    local dt = DateTime.fromIsoDate(data.expiry)
                    if dt then
                        expTime = dt.UnixTimestamp
                    else
                        warn("⚠️ [KULI JAWA] Gagal parsing ISO Date: " .. tostring(data.expiry))
                    end
                end

                getgenv().KuliJawa_KeySystem = {
                    IsVerified = true,
                    KeyString = inputKey,
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

                task.spawn(function()
                    while getgenv().KuliJawa_KeySystem.IsVerified do
                        task.wait(60)
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
                                _G.KuliJawa_IsFarming = false 
                                
                                if isfile and delfile and isfile(KeyFileName) then 
                                    delfile(KeyFileName) 
                                end
                                
                                -- Notif Santuy
                                pcall(function() 
                                    game:GetService("StarterGui"):SetCore("SendNotification", {
                                        Title = "Sesi Berakhir", 
                                        Text = "Key expired atau dipakai di device lain!", 
                                        Duration = 5
                                    }) 
                                end)
                                
                                if getgenv().KuliJawa_MainUI then 
                                    getgenv().KuliJawa_MainUI:Destroy() 
                                end
                                
                                task.wait(1)
                                -- Load UI Login lagi
                                loadstring(game:HttpGet("https://raw.githubusercontent.com/KuliJawa-Maker/ojis/refs/heads/main/main.lua"))()
                            end
                        end)
                    end
                end)
                
                pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Access Granted", Text = "Welcome! Your tier is : " .. userTier, Duration = 5}) end)
                
                task.wait(1)
                ScreenGui:Destroy()
                
                -- SALAMAN RAHASIA & PANGGIL SCRIPT UTAMA
                _G.AuthToken_EggHunter = "KuliJawa_M4nt4p_2026"
                loadstring(game:HttpGet("https://raw.githubusercontent.com/KuliJawa-Maker/ojis/refs/heads/main/game/129827112113663.lua"))()
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