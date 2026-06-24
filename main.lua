local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local LOCKED = false
local currentTarget = nil
local debounce = false

-- red circle idk
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local targetCircle = Instance.new("Frame")
targetCircle.Size = UDim2.new(0, 40, 0, 40)
targetCircle.AnchorPoint = Vector2.new(0.5, 0.5)
targetCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
targetCircle.BorderSizePixel = 0
targetCircle.Visible = false
targetCircle.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = targetCircle

-- finder
local function getClosestTarget()
    local closest = nil
    local shortest = math.huge

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            local pos, visible = camera:WorldToViewportPoint(hrp.Position)

            if visible then
                local dist = (Vector2.new(pos.X, pos.Y) - camera.ViewportSize/2).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = hrp
                end
            end
        end
    end

    return closest
end

-- fixed toggle
UIS.InputBegan:Connect(function(input, gpe)
    if gpe or debounce then return end
    if input.KeyCode == Enum.KeyCode.X then
        debounce = true

        LOCKED = not LOCKED

        if LOCKED then
            currentTarget = getClosestTarget()
        else
            currentTarget = nil
            targetCircle.Visible = false
        end

        task.wait(0.2) -- debounce delay
        debounce = false
    end
end)

-- loop
RunService.RenderStepped:Connect(function()
    if LOCKED and currentTarget and currentTarget.Parent then
        local character = currentTarget.Parent
        local humanoid = character:FindFirstChildOfClass("Humanoid")

        -- checks if dead lolo
        if not humanoid or humanoid.Health <= 0 then
            LOCKED = false
            currentTarget = nil
            targetCircle.Visible = false
            return
        end

        local targetPos = currentTarget.Position
        local camPos = camera.CFrame.Position

        camera.CFrame = camera.CFrame:Lerp(
            CFrame.new(camPos, targetPos),
            0.2
        )

        local screenPos, visible = camera:WorldToViewportPoint(targetPos)

        if visible then
            targetCircle.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
            targetCircle.Visible = true
        else
            targetCircle.Visible = false
        end
    else
        targetCircle.Visible = false
    end
end)
