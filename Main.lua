local Players = game:GetService("Players")
local player = Players.LocalPlayer

local isFlying = false

local function setCollisionGroupRecursive(parent, groupName)
    for _, descendant in pairs(parent:GetDescendants()) do
        if descendant:IsA("BasePart") then
            -- PhysicsService call retained, reference to HDAdminMain removed
        end
    end
end

local function toggleFly(enable, customSpeed)
    local flyType = "fly"
    
    if not enable then
        isFlying = false
        return
    end

    if isFlying then return end
    isFlying = true

    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not (hrp and humanoid) then
        isFlying = false
        return
    end

    local bodyPosition = Instance.new("BodyPosition")
    bodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyPosition.Position = hrp.Position + Vector3.new(0, 4, 0)
    bodyPosition.Name = "HDAdminFlyForce"
    bodyPosition.Parent = hrp

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.D = 50
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 200
    bodyGyro.Name = "HDAdminFlyGyro"
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp

    local tiltStep = 0
    local stationaryFrames = 0
    local lastTime = tick()
    local lastPosition = hrp.Position

    task.spawn(function()
        while isFlying and humanoid and hrp do
            local deltaTime = tick() - lastTime
            local camera = workspace.CurrentCamera
            local cameraDirection = (camera.Focus.Position - camera.CFrame.Position).Unit
            local flySpeed = customSpeed or 1
            
            -- Mobile & PC Direction Handling
            local moveDir = humanoid.MoveDirection
            local movementVector = Vector3.new()

            if moveDir.Magnitude > 0.05 then
                local cameraCF = camera.CFrame
                local moveLocal = cameraCF:VectorToObjectSpace(moveDir)
                movementVector = (cameraCF.RightVector * moveLocal.X) - (cameraCF.LookVector * moveLocal.Z)
                if movementVector.Magnitude > 0 then
                    movementVector = movementVector.Unit
                end
            end

            local movementCFrame = CFrame.new(movementVector * (flySpeed * 25 * deltaTime))
            local currentPos = bodyPosition.Position
            local targetCFrame = CFrame.new(currentPos, currentPos + cameraDirection) * movementCFrame
            
            local damping = 750 + flySpeed * 0.2

            local nextTiltStep
            if movementVector.Magnitude < 0.05 then
                stationaryFrames = stationaryFrames + 1
                nextTiltStep = 1
                if (hrp.Position - lastPosition).Magnitude > 6 and stationaryFrames >= 4 then
                    bodyPosition.Position = hrp.Position
                end
            else
                bodyPosition.D = damping
                nextTiltStep = tiltStep + 1
                bodyPosition.Position = targetCFrame.Position
                stationaryFrames = 0
            end

            tiltStep = math.abs(nextTiltStep) > 25 and 25 or nextTiltStep

            if bodyPosition.D == damping then
                local tiltAngle = tiltStep * movementVector.Z
                bodyGyro.CFrame = targetCFrame * CFrame.Angles(math.rad(tiltAngle), 0, 0)
            end

            lastTime = tick()
            lastPosition = hrp.Position
            humanoid.PlatformStand = true
            
            task.wait()
        end

        bodyPosition:Destroy()
        bodyGyro:Destroy()
        if humanoid then
            humanoid.PlatformStand = false
        end
        isFlying = false
    end)
end

-- Player Chat Commands (;fly, ;fly <speed>, ;fly me, ;fly me <speed>, ;unfly)
player.Chatted:Connect(function(msg)
    local lowerMsg = string.lower(msg)
    local args = string.split(lowerMsg, " ")

    if args[1] == ";fly" then
        local speed = nil
        if args[2] == "me" then
            if args[3] then
                speed = tonumber(args[3])
            end
        elseif args[2] then
            speed = tonumber(args[2])
        end
        toggleFly(true, speed)
    elseif lowerMsg == ";unfly" or lowerMsg == ";unfly me" then
        toggleFly(false)
    end
end)
