local btn = game:GetService("Players").LocalPlayer.PlayerGui.ToolUI.MobileDig.AutoButton

btn.MouseButton1Click:Connect(function()
    print("==== CEK OFFSET ====")
    if btn:IsA("ImageButton") then
        print("ImageRectOffset : " .. tostring(btn.ImageRectOffset))
    else
        print("Bukan ImageButton cuy!")
    end
    print("====================")
end)
