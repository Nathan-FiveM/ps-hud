Gears = {
    [1] = {0.90},--1
    [2] = {3.33, 0.90},--2
    [3] = {3.33, 1.57, 0.90},--3
    [4] = {3.33, 1.83, 1.22, 0.90},--4
    [5] = {3.33, 1.92, 1.36, 1.05, 0.90},--5
    [6] = {3.33, 1.95, 1.39, 1.09, 0.95, 0.90},--6
    [7] = {4.00, 2.34, 1.67, 1.31, 1.14, 1.08, 0.90},--7
    [8] = {5.31, 3.11, 2.22, 1.74, 1.51, 1.43, 1.20, 0.90},--8
    [9] = {7.70, 4.51, 3.22, 2.52, 2.20, 2.08, 1.73, 1.31, 0.90}--9
}
CustomVehicles = {
    [GetHashKey('omnis')] = { 
        [5] = {3.885, 2.312, 1.51848, 1.0688, 0.90},--5 Audi 4 trans
        [6] = {3.33,2.5, 2.0, 1.633, 1.089, 0.90},--6 2008 Subaru Impreza WRC2008 (S14) trans
    },
}
local vehicle = nil
local numgears = nil
local topspeedGTA = nil
local topspeedms = nil
local acc = nil
local hash = nil
local selectedgear = 0 
local hbrake = nil

local manualon = false

local incar = false

local currspeedlimit = nil
local ready = false
local realistic = true

local disable = false

-- Global variable
isInVehicleModel = false

CreateThread(function()
    local hasBeenSet = false
    local vehicleModels = {'sultan', 'tyrus'}

    while true do
        Wait(100) 

        local player = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(player, false)
        local model = GetEntityModel(vehicle)

        -- check if the model of the current vehicle is in the vehicleModels table
        isInVehicleModel = false
        for i, modelName in ipairs(vehicleModels) do
            if model == GetHashKey(modelName) then
                isInVehicleModel = true
                break
            end
        end

        if IsPedInAnyVehicle(player, false) and isInVehicleModel then
            if not hasBeenSet then
                manualon = true
                print("A manual car? cool cool")
                hasBeenSet = true
            end
        else
            manualon = false
            hasBeenSet = false
        end
    end
end)

function getinfo(gea)
    if isInVehicleModel then
        if gea == 0 then
            return "N"
        elseif gea == -1 then
            return "R"
        else
            return gea
        end
    else
        return "A"
    end
end

CreateThread(function()
    while true do
        Wait(100) 

        local ped = PlayerPedId()
        local newveh = GetVehiclePedIsIn(ped,false)
        local class = GetVehicleClass(newveh)

        if newveh == vehicle then

        elseif newveh == 0 and vehicle ~= nil then
            resetvehicle()
        else
            if GetPedInVehicleSeat(newveh,-1) == ped then
                if class ~= 13 and class ~= 14 and class ~= 15 and class ~= 16 and class ~= 21 then
                    vehicle = newveh
                    hash = GetEntityModel(newveh)
                   
                    
                    if GetVehicleMod(vehicle,13) < 0 then
                        numgears = GetVehicleHandlingInt(newveh, "CHandlingData", "nInitialDriveGears")
                    else
                        numgears = GetVehicleHandlingInt(newveh, "CHandlingData", "nInitialDriveGears") + 1
                    end
                    
                    

                    hbrake = GetVehicleHandlingFloat(newveh, "CHandlingData", "fHandBrakeForce")
                    
                    topspeedGTA = GetVehicleHandlingFloat(newveh, "CHandlingData", "fInitialDriveMaxFlatVel")
                    topspeedms = (topspeedGTA * 1.32)/3.6

                    acc = GetVehicleHandlingFloat(newveh, "CHandlingData", "fInitialDriveForce")
                    --SetVehicleMaxSpeed(newveh,topspeedms)
                    selectedgear = 0
                    Wait(50)
                    ready = true
                end
            end
        end

    end
end)

function resetvehicle()
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce", acc)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel",topspeedGTA)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fHandBrakeForce", hbrake)
    SetVehicleHighGear(vehicle, numgears)
    ModifyVehicleTopSpeed(vehicle,1)
    --SetVehicleMaxSpeed(vehicle,topspeedms)
    SetVehicleHandbrake(vehicle, false)
    
    vehicle = nil
    numgears = nil
    topspeedGTA = nil
    topspeedms = nil
    acc = nil
    hash = nil
    hbrake = nil
    selectedgear = 0
    currspeedlimit = nil
    ready = false
end

CreateThread(function()
    while true do
        Wait(0) 
        local player = PlayerPedId() -- get the player ped
        local vehicle = GetVehiclePedIsIn(player, false) -- get the vehicle the player is in
        if manualon == true and vehicle ~= nil then
            DisableControlAction(0, 14, true)
            DisableControlAction(0, 16, true)
        end
    end
end)

-- SHIFT Alert --
local isCooldown = false

-- Define a variable to save the user's preference for the beep sound
local beepSoundEnabled = false

CreateThread(function()
    local hasPlayed = false -- add this line
    while true do
        Wait(0) -- prevent the script from running too fast
        local player = PlayerPedId() -- get the player ped
        if IsPedInAnyVehicle(player, false) then -- check if the player is in a vehicle
            local vehicle = GetVehiclePedIsIn(player, false) -- get the vehicle the player is in
            local rpm = GetVehicleCurrentRpm(vehicle) -- get the current RPM of the vehicle
            if rpm >= 0.99 and not isCooldown and not hasPlayed and beepSoundEnabled then -- check if RPM is at maximum and sound has not been played
                TriggerEvent("InteractSound_CL:PlayOnOne","beep",0.05) -- play the beep sound
                hasPlayed = true -- set hasPlayed to true after playing the sound
                isCooldown = true -- start cooldown period
                Wait(1000) -- wait for 2 seconds (2000 milliseconds)
                isCooldown = false -- end cooldown period
            elseif rpm < 0.96 then -- reset hasPlayed when RPM drops below maximum
                hasPlayed = false
            end
        end
    end
end)

-- Function to toggle the beep sound on or off
function toggleBeepSound()
    beepSoundEnabled = not beepSoundEnabled
end

-- Register a new command to toggle the beep sound on or off
RegisterCommand('shiftalert', function()
    toggleBeepSound()
    if beepSoundEnabled then
        TriggerEvent('DoLongHudText', 'Shift alert sound enabled', 1)
    else
        TriggerEvent('DoLongHudText', 'Shift alert sound disabled', 2)
    end
end, false)

function SimulateGears()
    local engineup = GetVehicleMod(vehicle,11)
    if selectedgear > 0 then
        local ratio
        if CustomVehicles[hash] ~= nil then
            if selectedgear ~= 0 and selectedgear ~= nil  then
                if numgears ~= nil and selectedgear ~= nil then
                    ratio = CustomVehicles[hash][numgears][selectedgear] * (1/0.9)
                else
		            ratio = Gears[numgears][selectedgear] * (1/0.9)
                end
            end
        else
            if selectedgear ~= 0 and selectedgear ~= nil then
                if numgears ~= nil and selectedgear ~= nil then
                    ratio = Gears[numgears][selectedgear] * (1/0.9)
                else
                end
            end
        end
        if ratio ~= nil then
            SetVehicleHighGear(vehicle,1)
            newacc = ratio * acc
            newtopspeedGTA = topspeedGTA / ratio
            newtopspeedms = topspeedms / ratio
            SetVehicleHandbrake(vehicle, false)
            SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce", newacc)
            SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", newtopspeedGTA)
            SetVehicleHandlingFloat(vehicle, "CHandlingData", "fHandBrakeForce", hbrake)
            ModifyVehicleTopSpeed(vehicle,1)
            currspeedlimit = newtopspeedms 
        end
    elseif selectedgear == 0 then
        --SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", 0.0)
    elseif selectedgear == -1 then
        SetVehicleHandbrake(vehicle, false)
        SetVehicleHighGear(vehicle,numgears)    
        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce", acc)
        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", topspeedGTA)
        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fHandBrakeForce", hbrake)
        ModifyVehicleTopSpeed(vehicle,1)
    end
    SetVehicleMod(vehicle,11,engineup,false)
end

CreateThread(function()
    while true do
        Wait(0)
        if manualon == true and vehicle ~= nil then
            if selectedgear == -1 then
                if GetVehicleCurrentGear(vehicle) == 1 then
                    DisableControlAction(0, 71, true)
                end
            elseif selectedgear > 0 then
                if GetEntitySpeedVector(vehicle,true).y < 0.0 then   
                    DisableControlAction(0, 72, true)
                end
            elseif selectedgear == 0 then
                SetVehicleHandbrake(vehicle, true)
                if IsControlPressed(0, 76) == false then
                    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fHandBrakeForce", 0.0)
                else
                    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fHandBrakeForce", hbrake)
                end
            end
        else
            Wait(100) 
        end
    end
end)
    
CreateThread(function()
    while true do
        Wait(0)
        if realistic == true then
            if manualon == true and vehicle ~= nil then
                if selectedgear > 1 then
                    if IsControlPressed(0,71) then
                        local speed = GetEntitySpeed(vehicle) 
                        local minspeed = currspeedlimit / 7 

                        if speed < minspeed then
                            if GetVehicleCurrentRpm(vehicle) < 0.4 then
                                disable = true
                            end
                        end
                    end
                end
            else
                Wait(100) 
            end  
        else
            Wait(100) 
        end
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if disable == true then
            SetVehicleEngineOn(vehicle,false,true,false)
            Wait(1000)
            disable = false
        end   
    end
end)

CreateThread(function()
    while true do    
        Wait(0)
        if vehicle ~= nil and selectedgear ~= 0 then 
            local speed = GetEntitySpeed(vehicle) 
            if currspeedlimit ~= nil then
                if speed >= currspeedlimit then
                    if speed / currspeedlimit > 1.1 then
                        local hhhh = speed / currspeedlimit
                        SetVehicleCurrentRpm(vehicle,hhhh)
                        SetVehicleCheatPowerIncrease(vehicle,-100.0)
                    else
                        SetVehicleCheatPowerIncrease(vehicle,0.0)
                    end
                end
            else 
                if speed >= topspeedms then
                    SetVehicleCheatPowerIncrease(vehicle,0.0)
                end
            end
        end
    end
end)

local function GearUp()
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    if vehicle and GetPedInVehicleSeat(vehicle, 0) and manualon == true then
        local EngineOn = GetIsVehicleEngineRunning(vehicle)
        if EngineOn and ready then
            if selectedgear <= numgears - 1 then 
                DisableControlAction(0, 71, true)
                --Could add a sound here
                selectedgear = selectedgear + 1
                DisableControlAction(0, 71, false)
                SimulateGears()
            end
        end
    end
end
local function GearDown()
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    if vehicle and GetPedInVehicleSeat(vehicle, 0) and manualon == true then
        local EngineOn = GetIsVehicleEngineRunning(vehicle)
        if EngineOn and ready then
            if selectedgear > -1 then
                DisableControlAction(0, 71, true)
                --Could add a sound here
                selectedgear = selectedgear - 1
                DisableControlAction(0, 71, false)
                SimulateGears()
            end
        end
    end
end
lib.addKeybind(
    {
        name = 'gearUp',
        description = '[CAR] Gear Up',
        defaultMapper = 'MOUSE_WHEEL',
        defaultKey = 'IOM_WHEEL_UP',
        onPressed = GearUp
    }
)
lib.addKeybind(
    {
        name = 'gearDown',
        description = '[CAR] Gear Down',
        defaultMapper = 'MOUSE_WHEEL',
        defaultKey = 'IOM_WHEEL_DOWN',
        onPressed = GearDown
    }
)
-- Get Gears
function getSelectedGear()
    return selectedgear
end