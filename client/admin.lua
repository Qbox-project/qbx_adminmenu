local VEHICLES_HASH = exports.qbx_core:GetVehiclesByHash()
local optionInvisible = false
local godmode = false
local infiniteAmmo = false
local vehicleGodmode = false

local noclipEnabled = false
local ent
local invisible = nil
local noclipCam = nil
local speed = 1.0
local maxSpeed = 32.0
local minY, maxY = -150.0, 160.0
local inputRotEnabled = false
local disableControls = { 32, 33, 34, 35, 36, 12, 13, 14, 15, 16, 17 }

local function toggleNoclip()
    CreateThread(function()
        local inVehicle = false

        if cache.vehicle then
            inVehicle = true
            ent = cache.vehicle
        else
            ent = cache.ped
        end

        local pos = GetEntityCoords(ent)
        local rot = GetEntityRotation(ent)
        noclipCam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pos.x, pos.y, pos.z, 0.0, 0.0, rot.z, 75.0, true, 2)
        AttachCamToEntity(noclipCam, ent, 0.0, 0.0, 0.0, true)
        RenderScriptCams(true, false, 3000, true, false)
        FreezeEntityPosition(ent, true)
        SetEntityCollision(ent, false, false)
        SetEntityAlpha(ent, 0, false)
        SetPedCanRagdoll(cache.ped, false)
        SetEntityVisible(ent, false, false)

        if not inVehicle then
            ClearPedTasksImmediately(cache.ped)
        end

        if inVehicle then
            FreezeEntityPosition(cache.ped, true)
            SetEntityCollision(cache.ped, false, false)
            SetEntityAlpha(cache.ped, 0, false)
            SetEntityVisible(cache.ped, false, false)
        end

        while noclipEnabled do
            Wait(0)
            local _, fv = GetCamMatrix(noclipCam)
            if IsDisabledControlPressed(2, 17) then -- Scroll Wheel Up
                speed = math.min(speed + 0.1, maxSpeed)
            elseif IsDisabledControlPressed(2, 16) then -- Scroll Wheel Down
                speed = math.max(0.1, speed - 0.1)
            end

            local multiplier = 1.0
            if IsDisabledControlPressed(2, 209) then -- Left Shift
                multiplier = 2.0
            elseif IsDisabledControlPressed(2, 19) then -- Left Alt
                multiplier = 4.0
            elseif IsDisabledControlPressed(2, 36) then -- Left CTRL
                multiplier = 0.25
            end

            if IsDisabledControlPressed(2, 32) then -- W
                local setPos = GetEntityCoords(ent) + fv * (speed * multiplier)
                SetEntityCoordsNoOffset(ent, setPos.x, setPos.y, setPos.z, false, false, false)
                if not inVehicle then
                    SetEntityCoordsNoOffset(cache.ped, setPos.x, setPos.y, setPos.z, false, false, false)
                end
            elseif IsDisabledControlPressed(2, 33) then -- S
                local setPos = GetEntityCoords(ent) - fv * (speed * multiplier)
                SetEntityCoordsNoOffset(ent, setPos.x, setPos.y, setPos.z, false, false, false)
                if not inVehicle then
                    SetEntityCoordsNoOffset(cache.ped, setPos.x, setPos.y, setPos.z, false, false, false)
                end
            end

            if IsDisabledControlPressed(2, 34) then -- A
                local setPos = GetOffsetFromEntityInWorldCoords(ent, -speed * multiplier, 0.0, 0.0)
                SetEntityCoordsNoOffset(ent, setPos.x, setPos.y, setPos.z, false, false, false)
                if not inVehicle then
                    SetEntityCoordsNoOffset(cache.ped, setPos.x, setPos.y, setPos.z, false, false, false)
                end
            elseif IsDisabledControlPressed(2, 35) then -- D
                local setPos = GetOffsetFromEntityInWorldCoords(ent, speed * multiplier, 0.0, 0.0)
                SetEntityCoordsNoOffset(ent, setPos.x, setPos.y, setPos.z, false, false, false)
                if not inVehicle then
                    SetEntityCoordsNoOffset(cache.ped, setPos.x, setPos.y, setPos.z, false, false, false)
                end
            end

            if IsDisabledControlPressed(2, 51) then -- E
                local setPos = GetOffsetFromEntityInWorldCoords(ent, 0.0, 0.0, multiplier * speed / 2)
                SetEntityCoordsNoOffset(ent, setPos.x, setPos.y, setPos.z, false, false, false)
                if not inVehicle then
                    SetEntityCoordsNoOffset(cache.ped, setPos.x, setPos.y, setPos.z, false, false, false)
                end
            elseif IsDisabledControlPressed(2, 52) then -- Q
                local setPos = GetOffsetFromEntityInWorldCoords(ent, 0.0, 0.0, multiplier * -speed / 2)
                SetEntityCoordsNoOffset(ent, setPos.x, setPos.y, setPos.z, false, false, false)
                if not inVehicle then
                    SetEntityCoordsNoOffset(cache.ped, setPos.x, setPos.y, setPos.z, false, false, false)
                end
            end

            local camRot = GetCamRot(noclipCam, 2)
            SetEntityHeading(ent, (360 + camRot.z) % 360)
            SetEntityVisible(ent, false, false)

            if inVehicle then
                SetEntityVisible(cache.ped, false, false)
            end

            for i = 1, #disableControls do
                DisableControlAction(2, disableControls[i], true)
            end

            DisablePlayerFiring(cache.playerId, true)
        end

        DestroyCam(noclipCam, false)
        noclipCam = nil
        RenderScriptCams(false, false, 3000, true, false)
        FreezeEntityPosition(ent, false)
        SetEntityCollision(ent, true, true)
        ResetEntityAlpha(ent)
        SetPedCanRagdoll(cache.ped, true)
        SetEntityVisible(ent, not invisible, false)
        ClearPedTasksImmediately(cache.ped)
        if inVehicle then
            FreezeEntityPosition(cache.ped, false)
            SetEntityCollision(cache.ped, true, true)
            ResetEntityAlpha(cache.ped)
            SetEntityVisible(cache.ped, true, false)
            SetPedIntoVehicle(cache.ped, ent, -1)
        end
    end)
end

local function checkInputRotation()
    CreateThread(function()
        while inputRotEnabled do
            while not noclipCam or IsPauseMenuActive() do Wait(0) end
            local axisX = GetDisabledControlNormal(0, 1)
            local axisY = GetDisabledControlNormal(0, 2)
            local sensitivity = GetProfileSetting(14) * 2

            if GetProfileSetting(15) == 0 then -- Invert controls
                sensitivity = -sensitivity
            end

            if math.abs(axisX) > 0 or math.abs(axisY) > 0 then
                local rotation = GetCamRot(noclipCam, 2)
                local rotz = rotation.z + (axisX * sensitivity)
                local yValue = axisY * sensitivity
                local rotx = rotation.x
                if rotx + yValue > minY and rotx + yValue < maxY then
                    rotx = rotation.x + yValue
                end

                SetCamRot(noclipCam, rotx, rotation.y, rotz, 2)
            end
            Wait(0)
        end
    end)
end

local function toggleNoClipMode(forceMode)
    if forceMode ~= nil then
        noclipEnabled = forceMode
        inputRotEnabled = noclipEnabled
    else
        noclipEnabled = not noclipEnabled
        inputRotEnabled = noclipEnabled
    end

    if noclipEnabled and inputRotEnabled then
        toggleNoclip()
        checkInputRotation()
    end
end

local options = {
    function() toggleNoClipMode() end,
    function() TriggerEvent('qbx_medical:client:playerRevived') end,
    function()
        optionInvisible = not optionInvisible
        if not optionInvisible then return end
        while optionInvisible do Wait(0)
            SetEntityVisible(cache.ped, false, false)
        end

        SetEntityVisible(cache.ped, true, false)
    end,
    function()
        godmode = not godmode
        if godmode then SetPlayerInvincible(cache.playerId, true) else SetPlayerInvincible(cache.playerId, false) end
    end,
    function() ExecuteCommand('names') end,
    function() ExecuteCommand('blips') end,
    function()
        vehicleGodmode = not vehicleGodmode
        if vehicleGodmode then
            while vehicleGodmode do
                SetEntityInvincible(cache.vehicle, true)
                SetEntityCanBeDamaged(cache.vehicle, false)
                SetVehicleBodyHealth(cache.vehicle, 1000.0)
                SetVehicleFixed(cache.vehicle)
                SetVehicleEngineHealth(cache.vehicle, 1000.0)
                Wait(250)
            end
        else
            SetEntityInvincible(cache.vehicle, false)
            SetEntityCanBeDamaged(cache.vehicle, true)
        end
    end,
    function(switch)
        if switch == 1 then
            local input = lib.inputDialog(locale('admin_options.value8_1'), {locale('admin_options.input8label')})
            if not input then return end
            ExecuteCommand('setmodel ' .. input)
        else
            ExecuteCommand('refreshskin')
        end
    end,
    function()
        infiniteAmmo = not infiniteAmmo
        local weapon = GetSelectedPedWeapon(cache.ped)
        if infiniteAmmo then
            if GetAmmoInPedWeapon(cache.ped, weapon) < 6 then SetAmmoInClip(cache.ped, weapon, 10) Wait(50) end
            while infiniteAmmo do
                weapon = GetSelectedPedWeapon(cache.ped)
                SetPedInfiniteAmmo(cache.ped, true, weapon)
                RefillAmmoInstantly(cache.ped)
                Wait(250)
            end
        else
            SetPedInfiniteAmmo(cache.ped, false, weapon)
        end
    end,
    function(weaponType) TriggerServerEvent('qbx_admin:server:giveAllWeapons', weaponType) end,
    function() TriggerEvent('police:client:GetCuffed', cache.serverId, true) end,
}

lib.registerMenu({
    id = 'qbx_adminmenu_admin_menu',
    title = locale('title.admin_menu'),
    position = 'top-right',
    onClose = function(keyPressed)
        CloseMenu(false, keyPressed, 'qbx_adminmenu_main_menu')
    end,
    onSelected = function(selected)
        MenuIndexes.qbx_adminmenu_admin_menu = selected
    end,
    options = {
        {label = locale('admin_options.label1'), description = locale('admin_options.desc1'), icon = 'fab fa-fly', close = false},
        {label = locale('admin_options.label2'), description = locale('admin_options.desc2'), icon = 'fas fa-hospital', close = false},
        {label = locale('admin_options.label3'), description = locale('admin_options.desc3'), icon = 'fas fa-ghost', close = false},
        {label = locale('admin_options.label4'), description = locale('admin_options.desc4'), icon = 'fas fa-bolt', close = false},
        {label = locale('admin_options.label5'), description = locale('admin_options.desc5'), icon = 'fas fa-clipboard-list', close = false},
        {label = locale('admin_options.label6'), description = locale('admin_options.desc6'), icon = 'fas fa-map-pin', close = false},
        {label = locale('admin_options.label7'), description = locale('admin_options.desc7'), icon = 'fas fa-car-on', close = false},
        {label = locale('admin_options.label8'), description = locale('admin_options.desc8'), icon = 'fas fa-person-half-dress', values = {locale('admin_options.value8_1'), locale('admin_options.value8_2')}},
        {label = locale('admin_options.label9'), description = locale('admin_options.desc9'), icon = 'fas fa-bullseye', close = false},
        {label = locale('admin_options.label10'), description = locale('admin_options.desc10'), icon = 'fas fa-gun', values = {locale('admin_options.value10_1'), locale('admin_options.value10_2'), locale('admin_options.value10_3'), locale('admin_options.value10_4'), locale('admin_options.value10_5'), locale('admin_options.value10_6'), locale('admin_options.value10_7')}, args = {'pistol', 'smg', 'shotgun', 'assault', 'lmg', 'sniper', 'heavy'}, close = false},
        {label = locale('admin_options.label11'), description = locale('admin_options.desc11'), icon = 'fas fa-handcuffs', close = false},
    }
}, function(selected, scrollIndex, args)
    if selected == 10 then
        ---@diagnostic disable-next-line: redundant-parameter
        options[selected](args[scrollIndex])
    else
        ---@diagnostic disable-next-line: redundant-parameter
        options[selected](scrollIndex)
    end
end)

RegisterNetEvent('qbx_admin:client:ToggleNoClip', function()
    if GetInvokingResource() then return end
    toggleNoClipMode()
end)

local showBlips = false
local showNames = false
local netCheck1 = false
local netCheck2 = false

RegisterNetEvent('qbx_admin:client:blips', function()
    if not showBlips then
        showBlips = true
        netCheck1 = true
        exports.qbx_core:Notify(locale('success.blips_activated'), 'success')
    else
        showBlips = false
        exports.qbx_core:Notify(locale('error.blips_deactivated'), 'error')
    end
end)

RegisterNetEvent('qbx_admin:client:names', function()
    if not showNames then
        showNames = true
        netCheck2 = true
        exports.qbx_core:Notify(locale('success.names_activated'), 'success')
    else
        showNames = false
        exports.qbx_core:Notify(locale('error.names_deactivated'), 'error')
    end
end)

RegisterNetEvent('qbx_admin:client:Show', function()
    local players = lib.callback.await('qbx_admin:server:getPlayers', false)
    for _, player in pairs(players) do
        local playerId = GetPlayerFromServerId(player.id)
        local ped = GetPlayerPed(playerId)
        local blip = GetBlipFromEntity(ped)
        local name = 'ID: '..player.id..' | '..player.name

        local tag = CreateFakeMpGamerTag(ped, name, false, false, '', 0)
        SetMpGamerTagAlpha(tag, 0, 255) -- Sets 'MP_TAG_GAMER_NAME' bar alpha to 100% (not needed just as a fail safe)
        SetMpGamerTagAlpha(tag, 2, 255) -- Sets 'MP_TAG_HEALTH_ARMOUR' bar alpha to 100%
        SetMpGamerTagAlpha(tag, 4, 255) -- Sets 'MP_TAG_AUDIO_ICON' bar alpha to 100%
        SetMpGamerTagAlpha(tag, 6, 255) -- Sets 'MP_TAG_PASSIVE_MODE' bar alpha to 100%
        SetMpGamerTagHealthBarColour(tag, 25)  --https://wiki.rage.mp/index.php?title=Fonts_and_Colors

        if showNames then
            SetMpGamerTagVisibility(tag, 0, true) -- Activates the player ID Char name and FiveM name
            SetMpGamerTagVisibility(tag, 2, true) -- Activates the health (and armor if they have it on) bar below the player names
            if NetworkIsPlayerTalking(playerId) then
                SetMpGamerTagVisibility(tag, 4, true) -- If player is talking a voice icon will show up on the left side of the name
            else
                SetMpGamerTagVisibility(tag, 4, false)
            end
            if GetPlayerInvincible(playerId) then
                SetMpGamerTagVisibility(tag, 6, true) -- If player is in godmode a circle with a line through it will show up
            else
                SetMpGamerTagVisibility(tag, 6, false)
            end
        else
            SetMpGamerTagVisibility(tag, 0, false)
            SetMpGamerTagVisibility(tag, 2, false)
            SetMpGamerTagVisibility(tag, 4, false)
            SetMpGamerTagVisibility(tag, 6, false)
            RemoveMpGamerTag(tag) -- Unloads the tags till you activate it again
            netCheck2 = false
        end

        -- Blips Logic
        if showBlips then
            if not DoesBlipExist(blip) then
                blip = AddBlipForEntity(ped)
                SetBlipSprite(blip, 1)
                ShowHeadingIndicatorOnBlip(blip, true)
            else
                local blipSprite = GetBlipSprite(blip)
                --Payer Death
                if not GetEntityHealth(ped) then
                    if blipSprite ~= 274 then
                        SetBlipSprite(blip, 274)            --Dead icon
                        ShowHeadingIndicatorOnBlip(blip, false)
                    end
                --Player in Vehicle
                elseif cache.vehicle ~= 0 then
                    local classVeh = GetVehicleClass(cache.vehicle)
                    local modelVeh = GetEntityModel(cache.vehicle)
                    --MotorCycles (8) or Cycles (13)
                    if classVeh == 8  or classVeh == 13 then
                        if blipSprite ~= 226 then
                            SetBlipSprite(blip, 226)        --Motorcycle icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --OffRoad (9)
                    elseif classVeh == 9 then
                        if blipSprite ~= 757 then
                            SetBlipSprite(blip, 757)        --OffRoad icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Industrial (10)
                    elseif classVeh == 10 then
                        if blipSprite ~= 477 then
                            SetBlipSprite(blip, 477)        --Truck icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Utility (11)
                    elseif classVeh == 11 then
                        if blipSprite ~= 477 then
                            SetBlipSprite(blip, 477)        --Truck icon despite finding better one
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Vans (12)
                    elseif classVeh == 12 then
                        if blipSprite ~= 67 then
                            SetBlipSprite(blip, 67)         --Van icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Boats (14)
                    elseif classVeh == 14 then
                        if blipSprite ~= 427 then
                            SetBlipSprite(blip, 427)        --Boat icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Helicopters (15)
                    elseif classVeh == 15 then
                        if blipSprite ~= 422 then
                            SetBlipSprite(blip, 422)        --Moving helicopter icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Planes (16)
                    elseif classVeh == 16 then
                        if modelVeh == 'besra' or modelVeh == 'hydra' or modelVeh == 'lazer' then
                            if blipSprite ~= 424 then
                                SetBlipSprite(blip, 424)    --Jet icon
                                ShowHeadingIndicatorOnBlip(blip, false)
                            end
                        elseif blipSprite ~= 423 then
                            SetBlipSprite(blip, 423)        --Plane icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Service (17)
                    elseif classVeh == 17 then
                        if blipSprite ~= 198 then
                            SetBlipSprite(blip, 198)        --Taxi icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Emergency (18)
                    elseif classVeh == 18 then
                        if blipSprite ~= 56 then
                            SetBlipSprite(blip, 56)        --Cop icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Military (19)
                    elseif classVeh == 19 then
                        if modelVeh == 'rhino' then
                            if blipSprite ~= 421 then
                                SetBlipSprite(blip, 421)    --Tank icon
                                ShowHeadingIndicatorOnBlip(blip, false)
                            end
                        elseif blipSprite ~= 750 then
                            SetBlipSprite(blip, 750)        --Military truck icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Commercial (20)
                    elseif classVeh == 20 then
                        if blipSprite ~= 477 then
                            SetBlipSprite(blip, 477)        --Truck icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Every car (0, 1, 2, 3, 4, 5, 6, 7)
                    else
                        if modelVeh == 'insurgent' or modelVeh == 'insurgent2' or modelVeh == 'limo2' then
                            if blipSprite ~= 426 then
                                SetBlipSprite(blip, 426)    --Armed car icon
                                ShowHeadingIndicatorOnBlip(blip, false)
                            end
                        elseif blipSprite ~= 225 then
                            SetBlipSprite(blip, 225)        --Car icon
                            ShowHeadingIndicatorOnBlip(blip, true)
                        end
                    end
                    -- Show number in case of passangers
                    local passengers = GetVehicleNumberOfPassengers(cache.vehicle)
                    if passengers then
                        if not IsVehicleSeatFree(cache.vehicle, -1) then
                            passengers = passengers + 1
                        end
                        ShowNumberOnBlip(blip, passengers)
                    else
                        HideNumberOnBlip(blip)
                    end
                --Player on Foot
                else
                    HideNumberOnBlip(blip)
                    if blipSprite ~= 1 then
                        SetBlipSprite(blip, 1)
                        ShowHeadingIndicatorOnBlip(blip, true)
                    end
                end

                SetBlipRotation(blip, math.ceil(GetEntityHeading(cache.vehicle)))
                SetBlipNameToPlayerName(blip, playerId)
                SetBlipScale(blip, 0.85)

                if IsPauseMenuActive() then
                    SetBlipAlpha(blip, 255)
                else
                    local x1, y1 = table.unpack(GetEntityCoords(cache.ped, true))
                    local x2, y2 = table.unpack(GetEntityCoords(ped, true))
                    local distance = (math.floor(math.abs(math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))) / -1)) + 900
                    distance = distance < 0 and 0 or distance > 255 and 255 or distance
                    SetBlipAlpha(blip, distance)
                end
            end
        else
            RemoveBlip(blip)
            netCheck1 = false
        end
    end
end)

lib.callback.register('qbx_admin:client:SaveCarDialog', function()
    local response = lib.alertDialog({
        header = 'Save Car',
        content = 'This vehicle is already owned, do you want to override the current owner?',
        centered = true,
        cancel = true,
        labels = {
            confirm = 'Yes',
            cancel = 'No'
        }
    })
    return response == 'confirm'
end)

lib.callback.register('qbx_admin:client:GetVehicleInfo', function()
    return VEHICLES_HASH[GetEntityModel(cache.vehicle)].model, lib.getVehicleProperties(cache.vehicle)
end)

CreateThread(function()
    while true do
        Wait(1000)
        if netCheck1 or netCheck2 then
            TriggerEvent('qbx_admin:client:Show')
        end
    end
end)