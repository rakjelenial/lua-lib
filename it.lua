-- 📁 File: main.lua
-- Fish It Auto Tool (Full GUI with LinoriaLib)

-- Load LinoriaLib
local repo = 'https://raw.githubusercontent.com/rakjelenial/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()

-- Create UI Window
local Window = Library:CreateWindow({
    Title = 'Fish It Auto Tool',
    Center = true,
    AutoShow = true
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Teleport = Window:AddTab('Teleport'),
    ['UI Settings'] = Window:AddTab('UI Settings')
}

ThemeManager:SetLibrary(Library)
ThemeManager:ApplyToTab(Tabs['UI Settings'])

-- Flags
local autoPerfect, autoSell, autoTap = false, false, false
local chosenIsland = nil

-- UI - Main Tab
local MainBox = Tabs.Main:AddLeftGroupbox('Features')
MainBox:AddToggle('AutoPerfect', {
    Text = '🎯 Auto Cast 2.0x',
    Default = false,
    Callback = function(v) autoPerfect = v end
})

MainBox:AddToggle('AutoSell', {
    Text = '💰 Auto Sell Ikan',
    Default = false,
    Callback = function(v) autoSell = v end
})

MainBox:AddToggle('AutoTap', {
    Text = '🐟 Auto Tap (Tombol Bulat)',
    Default = false,
    Callback = function(v) autoTap = v end
})

-- UI - Teleport
local TPBox = Tabs.Teleport:AddLeftGroupbox('Teleport ke Pulau')
local islands = {
    ['Fisherman Island'] = Vector3.new(120, 20, -140),
    ['Snowcap Island'] = Vector3.new(385, 20, -120),
    ['Mystic Jungle'] = Vector3.new(730, 25, 90)
}
TPBox:AddDropdown('IslandPicker', {
    Text = 'Pilih Pulau',
    Values = table.keys(islands),
    Default = 1,
    Callback = function(v) chosenIsland = v end
})

TPBox:AddButton('Teleport Sekarang', function()
    local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
    if hrp and chosenIsland and islands[chosenIsland] then
        hrp.CFrame = CFrame.new(islands[chosenIsland])
    end
end)

-- Service dan Remotes
local RS = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local VIM = game:GetService('VirtualInputManager')
local net = RS.Packages._Index['sleitnick_net@0.2.0'].net
local miniGameRF = net:WaitForChild('RF/RequestFishingMinigameStarted')
local sellRF = net:WaitForChild('RF/SellItem')
local fishEvent = net:WaitForChild('RE/ObtainedNewFishNotification')

-- Auto 2.0x Cast
hookmetamethod(game, '__namecall', function(Self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    if Method == 'InvokeServer' and Self == miniGameRF and autoPerfect then
        local x = 0.5 + math.random(-3,3)*0.001
        local y = 2.0 + math.random()*0.03
        task.wait(0.1 + math.random()*0.1)
        return Self:InvokeServer(x, y)
    end
    return getrawmetatable(game).__namecall(Self, ...)
end)

-- Auto Sell Fish
fishEvent.OnClientEvent:Connect(function(_, _, data)
    if not autoSell then return end
    local item = data and data.InventoryItem
    if item and item.Rarity then
        local rarity = item.Rarity:lower()
        if not rarity:find('mythic') and not rarity:find('unique') then
            task.wait(0.2)
            sellRF:InvokeServer(item.UUID)
        end
    end
end)

-- Auto Tap (Tombol Bulat Geser)
local function CreateTapButton()
    local gui = Instance.new('ScreenGui', game.CoreGui)
    gui.Name = 'TapButtonGUI'

    local btn = Instance.new('TextButton', gui)
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.Position = UDim2.new(0, 400, 0, 400)
    btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    btn.BackgroundTransparency = 0.5
    btn.Text = ''
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false

    local uicorner = Instance.new('UICorner', btn)
    uicorner.CornerRadius = UDim.new(1, 0)

    -- drag
    local dragging, offset = false, Vector2.zero
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            offset = i.Position - btn.AbsolutePosition
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local newPos = i.Position - offset
            btn.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- auto click loop
    task.spawn(function()
        while task.wait(0.1) do
            if not autoTap then continue end
            local pos = btn.AbsolutePosition
            local size = btn.AbsoluteSize
            local x = pos.X + size.X / 2
            local y = pos.Y + size.Y / 2
            VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
            task.wait(0.02)
            VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
        end
    end)
end

CreateTapButton()

-- END OF SCRIPT
