local Things = workspace:WaitForChild("__THINGS")
local Active = Things.__INSTANCE_CONTAINER:WaitForChild("Active")
local Player = game.Players.LocalPlayer
local character = Player.Character
local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
local Active = Things.__INSTANCE_CONTAINER.Active
local ActiveBlocks = Active.AdvancedDigsite.Important.ActiveBlocks
local ActiveChests = Active.AdvancedDigsite.Important.ActiveChests

local CurrentActive = function()
    return Active:GetChildren()[1]
end

local GetChest = function()
    for i, v in pairs(ActiveChests:GetChildren()) do
        return v
    end
    return nil
end
 
local GetBlock = function()
    local blocks = ActiveBlocks:GetChildren()
    for i, v in pairs(ActiveBlocks:GetChildren()) do
        local CurrentBlock = blocks[#blocks - i + 1]
        if CurrentBlock.Color.R > 0.067 or CurrentBlock.Color.G > 0.067 or CurrentBlock.Color.B > 0.067 then
            local coord = CurrentBlock:GetAttribute('Coord')
            if (coord.X > 1 and coord.X < 16 and coord.Z > 1 and coord.Z < 16) then
                return CurrentBlock
            end
        end
    end
    return nil
end
 
local Dig = function () 
    local Chest = GetChest()
    if Chest then
        j = 1
        while Chest.Parent == ActiveChests and j < 20 do
            humanoidRootPart.CFrame = Chest:FindFirstChildWhichIsA("BasePart").CFrame
            game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Instancing_FireCustomFromClient"):FireServer(CurrentActive().Name, "DigChest", Chest:GetAttribute('Coord'))
            task.wait(0.2)
        end
        if j == 20 then
            Chest.Parent = nil
        end
    else
        local Block = GetBlock()
        j = 1
        while Block.Parent == ActiveBlocks and j < 100 do
            humanoidRootPart.CFrame = Block.CFrame
            game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Instancing_FireCustomFromClient"):FireServer(CurrentActive().Name, "DigBlock", Block:GetAttribute('Coord'))
            task.wait(0.2)
            j = j + 1
        end
        if Block.Parent == ActiveBlocks then
            Block:Destroy()
        end
    end
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Dig",
    SubTitle = "Pro Digging Script",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.Delete -- Used when theres no MinimizeKeybind
})

local Tabs = {
    Digging = Window:AddTab({ Title = "Digging", Icon = "" }),
}

local Options = Fluent.Options

do
    local Toggle = Tabs.Digging:AddToggle("DigSite", {Title = "AutoDigsite", Default = false})
    Toggle:OnChanged(function()
        Toggle = Options.DigSite.Value
        game:GetService("RunService").Stepped:Connect(function()
            if Toggle then
                for i,v in next, Player.Character:GetChildren() do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                        v.Velocity = Vector3.new(0,0,0)
                    end
                end
            else
                for i,v in next, Player.Character:GetChildren() do
                    if v:IsA("BasePart") then
                        v.CanCollide = true
                    end
                end
            end
        end)
        spawn(function()
            while Toggle and wait() do
                pcall(function()
                    Dig()
                end)
            end
        end)
        spawn(function()
            while Toggle and wait() do
                pcall(function()
                    for i, v in workspace.__THINGS.Orbs:GetChildren() do
                        v.Position = humanoidRootPart.Position
                    end
                    task.wait(1)
                end)
            end
        end)
    end)
end
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("AniHub")
SaveManager:SetFolder("AniHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Digging)
SaveManager:BuildConfigSection(Tabs.Digging)


Window:SelectTab(1)

Fluent:Notify({
    Title = "script'",
    Content = "script loaded.",
    Duration = 4
})

SaveManager:LoadAutoloadConfig()
