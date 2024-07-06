local cubeNames = {
    "",
    "",
    "Inferno Cube",
    "Glitch Cube",
    "",
    "",
    "Pastel Cube",
    "",
    "",
    "Spore Blossom",
    "Technosphere",
    "Event Horizon",
    "Stellar Nebula"
}

local teleporting = false
local teleportConnection

local function teleportPlayer()
    local player = game.Players.LocalPlayer

    if player and player.Character then
        local character = player.Character

        for _, cubeName in ipairs(cubeNames) do
            local cubeModel = game.Workspace:FindFirstChild(cubeName)

            if cubeModel and cubeModel:IsA("Model") then
                local modelCenter = cubeModel:GetModelCFrame().p
                character:SetPrimaryPartCFrame(CFrame.new(modelCenter))
                break
            end
        end
    else
        print("Игрок или его Character не найдены.")
    end
end

local function createGui()
    local ScreenGui = Instance.new("ScreenGui")
    local MenuFrame = Instance.new("Frame")
    local ToggleButtonFrame = Instance.new("Frame")
    local ToggleButton = Instance.new("TextButton")
    local CollapseButton = Instance.new("TextButton")
    local LoadingFrame = Instance.new("Frame")
    local LoadingBar = Instance.new("Frame")

    ScreenGui.Name = "TeleportGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    ScreenGui.DisplayOrder = 1000 


    LoadingFrame.Size = UDim2.new(0, 150, 0, 50)
    LoadingFrame.Position = UDim2.new(0.5, -75, 0.5, 20)
    LoadingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    LoadingFrame.BackgroundTransparency = 0.2
    LoadingFrame.BorderSizePixel = 0
    LoadingFrame.Parent = ScreenGui

    local LoadingUICorner = Instance.new("UICorner")
    LoadingUICorner.CornerRadius = UDim.new(0.2, 0)
    LoadingUICorner.Parent = LoadingFrame

    local LoadingText = Instance.new("TextLabel")
    LoadingText.Text = "Loading"
    LoadingText.Size = UDim2.new(1, 0, 1, -10)
    LoadingText.Position = UDim2.new(0, 0, 0, 0)
    LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadingText.BackgroundTransparency = 1
    LoadingText.Parent = LoadingFrame

    LoadingBar.Size = UDim2.new(0, 0, 0, 5)
    LoadingBar.Position = UDim2.new(0, 0, 1, -5)
    LoadingBar.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
    LoadingBar.Parent = LoadingFrame

    local progressTween = game:GetService("TweenService"):Create(LoadingBar, TweenInfo.new(2.5, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 0, 5)})
    progressTween:Play()

    wait(2.5)
    LoadingFrame:Destroy()


    MenuFrame.Size = UDim2.new(0, 200, 0, 100)
    MenuFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
    MenuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MenuFrame.BackgroundTransparency = 0.2
    MenuFrame.BorderSizePixel = 0
    MenuFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MenuFrame.Draggable = true
    MenuFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.2, 0)
    UICorner.Parent = MenuFrame

    ToggleButtonFrame.Size = UDim2.new(0, 100, 0, 40)
    ToggleButtonFrame.Position = UDim2.new(0.5, -50, 0.5, -20)
    ToggleButtonFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    ToggleButtonFrame.Parent = MenuFrame

    local ButtonFrameUICorner = Instance.new("UICorner")
    ButtonFrameUICorner.CornerRadius = UDim.new(0.2, 0)
    ButtonFrameUICorner.Parent = ToggleButtonFrame

    ToggleButton.Size = UDim2.new(0.5, -5, 1, -10)
    ToggleButton.Position = UDim2.new(0, 5, 0, 5)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    ToggleButton.Text = ""
    ToggleButton.Parent = ToggleButtonFrame

    local ButtonUICorner = Instance.new("UICorner")
    ButtonUICorner.CornerRadius = UDim.new(0.2, 0)
    ButtonUICorner.Parent = ToggleButton

    CollapseButton.Size = UDim2.new(0, 50, 0, 30)
    CollapseButton.Position = UDim2.new(0.5, -25, 0, 10)
    CollapseButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    CollapseButton.BackgroundTransparency = 0
    CollapseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CollapseButton.Text = "X"
    CollapseButton.AnchorPoint = Vector2.new(0.5, 0)
    CollapseButton.Parent = ScreenGui

    local CollapseButtonUICorner = Instance.new("UICorner")
    CollapseButtonUICorner.CornerRadius = UDim.new(0.2, 0)
    CollapseButtonUICorner.Parent = CollapseButton

    local UIS = game:GetService("UserInputService")
    local dragging
    local dragInput
    local dragStart
    local startPos
    local guiCollapsed = false

    local function update(input)
        local delta = input.Position - dragStart
        MenuFrame:TweenPosition(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y), "Out", "Quad", 0.2, true)
    end

    MenuFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MenuFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    MenuFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    local initialPosition

    local function toggleTeleport()
        teleporting = not teleporting

        if teleporting then
            local player = game.Players.LocalPlayer
            if player and player.Character and player.Character.PrimaryPart then
                initialPosition = player.Character.PrimaryPart.Position
            end

            ToggleButton:TweenSizeAndPosition(UDim2.new(1, -10, 1, -10), UDim2.new(0, 5, 0, 5), "Out", "Quad", 0.2, true)
            ToggleButton.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
            teleportConnection = game:GetService("RunService").Stepped:Connect(function()
                teleportPlayer()
                wait(0.2)
            end)
        else
            ToggleButton:TweenSizeAndPosition(UDim2.new(0.5, -5, 1, -10), UDim2.new(0, 5, 0, 5), "Out", "Quad", 0.2, true)
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
            if teleportConnection then
                teleportConnection:Disconnect()
            end

            if initialPosition then
                local player = game.Players.LocalPlayer
                if player and player.Character then
                    local character = player.Character
                    character:SetPrimaryPartCFrame(CFrame.new(initialPosition))
                end
            end
        end
    end

    ToggleButton.MouseButton1Click:Connect(toggleTeleport)

    CollapseButton.MouseButton1Click:Connect(function()
        guiCollapsed = not guiCollapsed
        if guiCollapsed then
            MenuFrame:TweenSizeAndPosition(UDim2.new(0, 200, 0, 0), UDim2.new(0.5, -100, 0.5, -50), "Out", "Quad", 0.2, true)
            ToggleButtonFrame:TweenSizeAndPosition(UDim2.new(0, 0, 0, 0), UDim2.new(0.5, 0, 0.5, 0), "Out", "Quad", 0.2, true)
            ToggleButton:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.2, true, function()
                ToggleButton.Visible = false
            end)
            CollapseButton.Text = ">"
        else
            ToggleButton.Visible = true
            MenuFrame:TweenSizeAndPosition(UDim2.new(0, 200, 0, 100), UDim2.new(0.5, -100, 0.5, -50), "Out", "Quad", 0.2, true)
            ToggleButtonFrame:TweenSizeAndPosition(UDim2.new(0, 100, 0, 40), UDim2.new(0.5, -50, 0.5, -20), "Out", "Quad", 0.2, true)
            ToggleButton:TweenSize(UDim2.new(0.5, -5, 1, -10), "Out", "Quad", 0.2, true)
            CollapseButton.Text = "X"
        end
    end)

    local function showClosingMessage()
        local message = Instance.new("TextLabel")
        message.Text = "Closing... Bye!"
        message.Size = UDim2.new(0, 200, 0, 50)
        message.Position = UDim2.new(1, -210, 1, -60)
        message.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        message.TextColor3 = Color3.fromRGB(255, 255, 255)
        message.TextScaled = true
        message.BackgroundTransparency = 0.5
        message.Parent = ScreenGui

        local messageUICorner = Instance.new("UICorner")
        messageUICorner.CornerRadius = UDim.new(0.2, 0)
        messageUICorner.Parent = message

        local progressBar = Instance.new("Frame")
        progressBar.Size = UDim2.new(1, 0, 0, 5)
        progressBar.Position = UDim2.new(0, 0, 1, -5)
        progressBar.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
        progressBar.Parent = message

        local progressTween = game:GetService("TweenService"):Create(progressBar, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 5)})
        progressTween:Play()


        message:TweenPosition(UDim2.new(1, -210, 1, -110), "Out", "Quad", 0.5, true)
        game:GetService("TweenService"):Create(message, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5, TextTransparency = 0.5}):Play()

        wait(1.5)


        game:GetService("TweenService"):Create(message, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        wait(0.5)
        message:Destroy()
    end

    local function removeGui()

        if teleporting then
            teleporting = false
            if teleportConnection then
                teleportConnection:Disconnect()
            end
            if initialPosition then
                local player = game.Players.LocalPlayer
                if player and player.Character then
                    local character = player.Character
                    character:SetPrimaryPartCFrame(CFrame.new(initialPosition))
                end
            end
        end

        showClosingMessage()
        wait(0.2)

        MenuFrame:TweenSizeAndPosition(UDim2.new(0, 200, 0, 0), UDim2.new(0.5, -100, 0.5, -50), "Out", "Quad", 0.5, true)
        game:GetService("TweenService"):Create(MenuFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
        ToggleButtonFrame:TweenSizeAndPosition(UDim2.new(0, 0, 0, 0), UDim2.new(0.5, 0, 0.5, 0), "Out", "Quad", 0.5, true)
        game:GetService("TweenService"):Create(ToggleButtonFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
        game:GetService("TweenService"):Create(CollapseButton, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
        wait(0.5)
        ScreenGui:Destroy()
    end

    UIS.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.L then
            removeGui()
        end
    end)

    MenuFrame.BackgroundTransparency = 1
    local fadeInTween = game:GetService("TweenService"):Create(MenuFrame, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.2})
    fadeInTween:Play()
end

game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        wait(1)
        createGui()
    end)
end)

if game.Players.LocalPlayer and game.Players.LocalPlayer.Character then
    createGui()
else
    game.Players.LocalPlayer.CharacterAdded:Connect(function()
        wait(1)
        createGui()
    end)
end
