local Things = Workspace:WaitForChild("__THINGS")
local Active = Things.__INSTANCE_CONTAINER:WaitForChild("Active")
local Player = game.Players.LocalPlayer
local character = Player.Character
local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
local ActiveBlocks = workspace.__THINGS.__INSTANCE_CONTAINER.Active.AdvancedDigsite.Important.ActiveBlocks
local ActiveChests = workspace.__THINGS.__INSTANCE_CONTAINER.Active.AdvancedDigsite.Important.ActiveChests

local CurrentActive = function()
    return Active:GetChildren()[1]
end

local GetChest = function()
    for i, v in pairs(ActiveChests:GetChildren()) do
        return v
    end
    return nil
end
 
local Dig = function () -- yes Dig my ass out pls mmm daddy
    local Chest = GetChest()
    if Chest then
        humanoidRootPart.CFrame = Chest:FindFirstChildWhichIsA("BasePart").CFrame
        ReplicatedStorage:WaitForChild("Network"):WaitForChild("Instancing_FireCustomFromClient"):FireServer(CurrentActive().Name, "DigChest", Chest:GetAttribute('Coord'))
        task.wait(0.05)
    else
        local blocks = ActiveBlocks:GetChildren()
        local Block = blocks[#blocks]
        j = 1
        while Block.Parent == ActiveBlocks and j < 100 do
            humanoidRootPart.CFrame = Block.CFrame
            game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Instancing_FireCustomFromClient"):FireServer(CurrentActive().Name, "DigBlock", Block:GetAttribute('Coord'))
            task.wait(0.05)
            j = j + 1
        end
    end
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Ani's script PS99",
    SubTitle = "by Ani",
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
    local Toggle = Tabs.Digging:AddToggle("DigSite", {Title = "Auto AdvancedDigsite", Default = false})
    local DefaultVelocity = 0
    Toggle:OnChanged(function()
        Toggle = Options.DigSite.Value
        game:GetService("RunService").Stepped:Connect(function()
            if Toggle then
                for i,v in next, Player.Character:GetChildren() do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                        DefaultVelocity = v.Velocity
                        v.Velocity = Vector3.new(0,0,0)
                    end
                end
            else
                for i,v in next, Player.Character:GetChildren() do
                    if v:IsA("BasePart") then
                        v.CanCollide = true
                        v.Velocity = DefaultVelocity
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
    end)
end
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("AniHub")
SaveManager:SetFolder("AniHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Fluent:Notify({
    Title = "Ani's fix script'",
    Content = "script loaded.",
    Duration = 4
})

SaveManager:LoadAutoloadConfig()
