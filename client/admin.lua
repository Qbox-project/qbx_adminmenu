local Invisible = false
local Godmode = false
local InfiniteAmmo = false
local VehicleGodmode = false
local Options = {
    function() toggleNoClipMode() end,
    function() TriggerEvent('hospital:client:Revive') end,
    function()
        Invisible = not Invisible
        if not Invisible then return end
        while Invisible do Wait(0) SetEntityVisible(cache.ped, false, false) end
        SetEntityVisible(cache.ped, true, false)
    end,
    function()
        Godmode = not Godmode
        if Godmode then SetPlayerInvincible(cache.playerId, true) else SetPlayerInvincible(cache.playerId, false) end
    end,
    function() TriggerServerEvent('QBCore:CallCommand', 'names') end,
    function() TriggerServerEvent('QBCore:CallCommand', 'blips') end,
    function()
        VehicleGodmode = not VehicleGodmode
        if VehicleGodmode then
            while VehicleGodmode do
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
    function(Switch)
        if Switch == 1 then
            local Input = lib.inputDialog(Lang:t('admin_options.value8_1'), {Lang:t('admin_options.input8label')})
            if not Input then return end
            TriggerServerEvent('QBCore:CallCommand', 'setmodel', Input)
        else
            ExecuteCommand('refreshskin')
        end
    end,
    function()
        InfiniteAmmo = not InfiniteAmmo
        local weapon = GetSelectedPedWeapon(cache.ped)
        if InfiniteAmmo then
            if GetAmmoInPedWeapon(cache.ped, weapon) < 6 then SetAmmoInClip(cache.ped, weapon, 10) Wait(50) end
            while InfiniteAmmo do
                weapon = GetSelectedPedWeapon(cache.ped)
                SetPedInfiniteAmmo(cache.ped, true, weapon)
                RefillAmmoInstantly(cache.ped)
                Wait(250)
            end
        else
            SetPedInfiniteAmmo(cache.ped, false, weapon)
        end
    end,
    function(WeaponType) TriggerServerEvent('qb-admin:server:giveallweapons', WeaponType) end,
    function() TriggerEvent('police:client:GetCuffed', cache.serverId, true) end,
}

lib.registerMenu({
    id = 'qb_adminmenu_admin_menu',
    title = Lang:t('title.admin_menu'),
    position = 'top-right',
    onClose = function(keyPressed)
        CloseMenu(false, keyPressed, 'qb_adminmenu_main_menu')
    end,
    onSelected = function(selected)
        MenuIndexes['qb_adminmenu_admin_menu'] = selected
    end,
    options = {
        {label = Lang:t('admin_options.label1'), description = Lang:t('admin_options.desc1'), icon = 'fab fa-fly', close = false},
        {label = Lang:t('admin_options.label2'), description = Lang:t('admin_options.desc2'), icon = 'fas fa-hospital', close = false},
        {label = Lang:t('admin_options.label3'), description = Lang:t('admin_options.desc3'), icon = 'fas fa-ghost', close = false},
        {label = Lang:t('admin_options.label4'), description = Lang:t('admin_options.desc4'), icon = 'fas fa-bolt', close = false},
        {label = Lang:t('admin_options.label5'), description = Lang:t('admin_options.desc5'), icon = 'fas fa-clipboard-list', close = false},
        {label = Lang:t('admin_options.label6'), description = Lang:t('admin_options.desc6'), icon = 'fas fa-map-pin', close = false},
        {label = Lang:t('admin_options.label7'), description = Lang:t('admin_options.desc7'), icon = 'fas fa-car-on', close = false},
        {label = Lang:t('admin_options.label8'), description = Lang:t('admin_options.desc8'), icon = 'fas fa-person-half-dress', values = {Lang:t('admin_options.value8_1'), Lang:t('admin_options.value8_2')}},
        {label = Lang:t('admin_options.label9'), description = Lang:t('admin_options.desc9'), icon = 'fas fa-bullseye', close = false},
        {label = Lang:t('admin_options.label10'), description = Lang:t('admin_options.desc10'), icon = 'fas fa-gun', values = {Lang:t('admin_options.value10_1'), Lang:t('admin_options.value10_2'), Lang:t('admin_options.value10_3'), Lang:t('admin_options.value10_4'), Lang:t('admin_options.value10_5'), Lang:t('admin_options.value10_6'), Lang:t('admin_options.value10_7')}, args = {'pistol', 'smg', 'shotgun', 'assault', 'lmg', 'sniper', 'heavy'}, close = false},
        {label = Lang:t('admin_options.label11'), description = Lang:t('admin_options.desc11'), icon = 'fas fa-handcuffs', close = false},
    }
}, function(selected, scrollIndex, args)
    if selected == 10 then
        ---@diagnostic disable-next-line: redundant-parameter
        Options[selected](args[scrollIndex])
    else
        ---@diagnostic disable-next-line: redundant-parameter
        Options[selected](scrollIndex)
    end
end)



--- Needs cleanup
local noClipEnabled = false
local ent
local noClipCam = nil
local speed = 1.0
local maxSpeed = 32.0
local minY, maxY = -150.0, 160.0
local inputRotEnabled = false

function toggleNoclip()
    CreateThread(function()
        local ped = cache.ped
        local veh = GetVehiclePedIsIn(ped, false)
        local inVehicle = false

        if veh ~= 0 then
            inVehicle = true
            ent = veh
        else
            ent = ped
        end

        local pos = GetEntityCoords(ent)
        local rot = GetEntityRotation(ent)

        noClipCam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pos.x, pos.y, pos.z, 0.0, 0.0, rot.z, 75.0, true, 2)
        AttachCamToEntity(noClipCam, ent, 0.0, 0.0, 0.0, true)
        RenderScriptCams(true, false, 3000, true, false)

        FreezeEntityPosition(ent, true)
        SetEntityCollision(ent, false, false)
        SetEntityAlpha(ent, 0, false)
        SetPedCanRagdoll(ped, false)
        SetEntityVisible(ent, false, false)
        if not inVehicle then
            ClearPedTasksImmediately(ped)
        end

        if inVehicle then
            FreezeEntityPosition(ped, true)
            SetEntityCollision(ped, false, false)
            SetEntityAlpha(ped, 0, false)
            SetEntityVisible(ped, false, false)
        end

        while noClipEnabled do
            local _, fv, _, _ = GetCamMatrix(noClipCam)

            if IsDisabledControlPressed(2, 17) then -- MWheelUp
                speed = math.min(speed + 0.1, maxSpeed)
            elseif IsDisabledControlPressed(2, 16) then -- MWheelDown
                speed = math.max(0.1, speed - 0.1)
            end

            local multiplier = 1.0;

            if IsDisabledControlPressed(2, 209) then
                multiplier = 2.0
            elseif IsDisabledControlPressed(2, 19) then
                multiplier = 4.0
            elseif IsDisabledControlPressed(2, 36) then
                multiplier = 0.25
            end

            -- Forward and Backward
            if IsDisabledControlPressed(2, 32) then -- W
                local setpos = GetEntityCoords(ent) + fv * (speed * multiplier)
                SetEntityCoordsNoOffset(ent, setpos.x, setpos.y, setpos.z, false, false, false)
                if not inVehicle then
                SetEntityCoordsNoOffset(ped, setpos.x, setpos.y, setpos.z, false, false, false)
                end
            elseif IsDisabledControlPressed(2, 33) then -- S
                local setpos = GetEntityCoords(ent) - fv * (speed * multiplier)
                SetEntityCoordsNoOffset(ent, setpos.x, setpos.y, setpos.z, false, false, false)
                if not inVehicle then
                SetEntityCoordsNoOffset(ped, setpos.x, setpos.y, setpos.z, false, false, false)
                end
            end

            -- Left and Right
            if IsDisabledControlPressed(2, 34) then -- A
                local setpos = GetOffsetFromEntityInWorldCoords(ent, -speed * multiplier, 0.0, 0.0)
                SetEntityCoordsNoOffset(ent, setpos.x, setpos.y, GetEntityCoords(ent).z, false, false, false)
                if not inVehicle then
                SetEntityCoordsNoOffset(ped, setpos.x, setpos.y, GetEntityCoords(ent).z, false, false, false)
                end
            elseif IsDisabledControlPressed(2, 35) then -- D
                local setpos = GetOffsetFromEntityInWorldCoords(ent, speed * multiplier, 0.0, 0.0)
                SetEntityCoordsNoOffset(ent, setpos.x, setpos.y, GetEntityCoords(ent).z, false, false, false)
                if not inVehicle then
                SetEntityCoordsNoOffset(ped, setpos.x, setpos.y, GetEntityCoords(ent).z, false, false, false)
                end
            end

            -- Up and Down
            if IsDisabledControlPressed(2, 22) then -- E
                local setpos = GetOffsetFromEntityInWorldCoords(ent, 0.0, 0.0, multiplier * speed / 2)
                SetEntityCoordsNoOffset(ent, setpos.x, setpos.y, setpos.z, false, false, false)
                if not inVehicle then
                SetEntityCoordsNoOffset(ped, setpos.x, setpos.y, setpos.z, false, false, false)
                end
            elseif IsDisabledControlPressed(2, 52) then
                local setpos = GetOffsetFromEntityInWorldCoords(ent, 0.0, 0.0, multiplier * -speed / 2) -- Q
                SetEntityCoordsNoOffset(ent, setpos.x, setpos.y, setpos.z, false, false, false)
                if not inVehicle then
                SetEntityCoordsNoOffset(ped, setpos.x, setpos.y, setpos.z, false, false, false)
                end
            end

            local camrot = GetCamRot(noClipCam, 2)
            SetEntityHeading(ent, (360 + camrot.z) % 360.0)
            SetEntityVisible(ent, false, false)
            if inVehicle then
                SetEntityVisible(ped, false, false)
            end

            DisableControlAction(2, 32, true)
            DisableControlAction(2, 33, true)
            DisableControlAction(2, 34, true)
            DisableControlAction(2, 35, true)
            DisableControlAction(2, 36, true)
            DisableControlAction(2, 12, true)
            DisableControlAction(2, 13, true)
            DisableControlAction(2, 14, true)
            DisableControlAction(2, 15, true)
            DisableControlAction(2, 16, true)
            DisableControlAction(2, 17, true)
            DisablePlayerFiring(cache.playerId, true)
            Wait(0)
        end

        DestroyCam(noClipCam, false)
        noClipCam = nil
        RenderScriptCams(false, false, 3000, true, false)
        FreezeEntityPosition(ent, false)
        SetEntityCollision(ent, true, true)
        ResetEntityAlpha(ent)
        SetPedCanRagdoll(ped, true)
        SetEntityVisible(ent, not Invisible, false)
        ClearPedTasksImmediately(ped)

        if inVehicle then
        FreezeEntityPosition(ped, false)
        SetEntityCollision(ped, true, true)
        ResetEntityAlpha(ped)
        SetEntityVisible(ped, true, false)
        SetPedIntoVehicle(ped, ent, -1)
        end
    end)
end

function checkInputRotation()
    CreateThread(function()
        while inputRotEnabled do
            while noClipCam == nil do Wait(0) end
            while IsPauseMenuActive() do Wait(0) end
            local axisX = GetDisabledControlNormal(0, 1)
            local axisY = GetDisabledControlNormal(0, 2)
            local sensitivity = GetProfileSetting(14) * 2
            if GetProfileSetting(15) == 0 --[[ Invert ]] then
                -- this is default inverse
                sensitivity = -sensitivity
            end
            if (math.abs(axisX) > 0) or (math.abs(axisY) > 0) then
                local rotation = GetCamRot(noClipCam, 2)
                local rotz = rotation.z + (axisX * sensitivity)
                local yValue = (axisY * sensitivity)
                local rotx = rotation.x
                if rotx + yValue > minY and rotx + yValue < maxY then
                    rotx = rotation.x + yValue
                end
                SetCamRot(noClipCam, rotx, rotation.y, rotz, 2)
            end
            Wait(0)
        end
    end)
end

RegisterNetEvent('qb-admin:client:noclip', function()
    toggleNoClipMode()
end)

function toggleNoClipMode()
    noClipEnabled = not noClipEnabled
    inputRotEnabled = noClipEnabled
    if noClipEnabled and inputRotEnabled then
        toggleNoclip()
        checkInputRotation()
    end
end





local ShowBlips = false
local ShowNames = false
local NetCheck1 = false
local NetCheck2 = false

CreateThread(function()
    while true do
        Wait(1000)
        if NetCheck1 or NetCheck2 then
            TriggerServerEvent('qb-admin:server:GetPlayersForBlips')
        end
    end
end)

RegisterNetEvent('qb-admin:client:blips', function()
    if not ShowBlips then
        ShowBlips = true
        NetCheck1 = true
        lib.notify({ description = Lang:t('success.blips_activated'), type = 'success' })
    else
        ShowBlips = false
        lib.notify({ description = Lang:t('error.blips_deactivated'), type = 'error' })
    end
end)

RegisterNetEvent('qb-admin:client:names', function()
    if not ShowNames then
        ShowNames = true
        NetCheck2 = true
        lib.notify({ description = Lang:t('success.names_activated'), type = 'success' })
    else
        ShowNames = false
        lib.notify({ description = Lang:t('error.names_deactivated'), type = 'error' })
    end
end)

RegisterNetEvent('qb-admin:client:Show', function(players)
    for _, player in pairs(players) do
        local playeridx = GetPlayerFromServerId(player.id)
        local ped = GetPlayerPed(playeridx)
        local blip = GetBlipFromEntity(ped)
        local name = 'ID: '..player.id..' | '..player.name

        local Tag = CreateFakeMpGamerTag(ped, name, false, false, '', 0)
        SetMpGamerTagAlpha(Tag, 0, 255) -- Sets 'MP_TAG_GAMER_NAME' bar alpha to 100% (not needed just as a fail safe)
        SetMpGamerTagAlpha(Tag, 2, 255) -- Sets 'MP_TAG_HEALTH_ARMOUR' bar alpha to 100%
        SetMpGamerTagAlpha(Tag, 4, 255) -- Sets 'MP_TAG_AUDIO_ICON' bar alpha to 100%
        SetMpGamerTagAlpha(Tag, 6, 255) -- Sets 'MP_TAG_PASSIVE_MODE' bar alpha to 100%
        SetMpGamerTagHealthBarColour(Tag, 25)  --https://wiki.rage.mp/index.php?title=Fonts_and_Colors

        if ShowNames then
            SetMpGamerTagVisibility(Tag, 0, true) -- Activates the player ID Char name and FiveM name
            SetMpGamerTagVisibility(Tag, 2, true) -- Activates the health (and armor if they have it on) bar below the player names
            if NetworkIsPlayerTalking(playeridx) then
                SetMpGamerTagVisibility(Tag, 4, true) -- If player is talking a voice icon will show up on the left side of the name
            else
                SetMpGamerTagVisibility(Tag, 4, false)
            end
            if GetPlayerInvincible(playeridx) then
                SetMpGamerTagVisibility(Tag, 6, true) -- If player is in godmode a circle with a line through it will show up
            else
                SetMpGamerTagVisibility(Tag, 6, false)
            end
        else
            SetMpGamerTagVisibility(Tag, 0, false)
            SetMpGamerTagVisibility(Tag, 2, false)
            SetMpGamerTagVisibility(Tag, 4, false)
            SetMpGamerTagVisibility(Tag, 6, false)
            RemoveMpGamerTag(Tag) -- Unloads the tags till you activate it again
            NetCheck2 = false
        end

        -- Blips Logic
        if ShowBlips then
            if not DoesBlipExist(blip) then
                blip = AddBlipForEntity(ped)
                SetBlipSprite(blip, 1)
                ShowHeadingIndicatorOnBlip(blip, true)
            else
                local veh = GetVehiclePedIsIn(ped, false)
                local blipSprite = GetBlipSprite(blip)
                --Payer Death
                if not GetEntityHealth(ped) then
                    if blipSprite ~= 274 then
                        SetBlipSprite(blip, 274)            --Dead icon
                        ShowHeadingIndicatorOnBlip(blip, false)
                    end
                --Player in Vehicle
                elseif veh ~= 0 then
                    local classveh = GetVehicleClass(veh)
                    local modelveh = GetEntityModel(veh)
                    --MotorCycles (8) or Cycles (13)
                    if classveh == 8  or classveh == 13 then
                        if blipSprite ~= 226 then
                            SetBlipSprite(blip, 226)        --Motorcycle icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --OffRoad (9)
                    elseif classveh == 9 then
                        if blipSprite ~= 757 then
                            SetBlipSprite(blip, 757)        --OffRoad icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Industrial (10)
                    elseif classveh == 10 then
                        if blipSprite ~= 477 then
                            SetBlipSprite(blip, 477)        --Truck icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Utility (11)
                    elseif classveh == 11 then
                        if blipSprite ~= 477 then
                            SetBlipSprite(blip, 477)        --Truck icon despite finding better one
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Vans (12)
                    elseif classveh == 12 then
                        if blipSprite ~= 67 then
                            SetBlipSprite(blip, 67)         --Van icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Boats (14)
                    elseif classveh == 14 then
                        if blipSprite ~= 427 then
                            SetBlipSprite(blip, 427)        --Boat icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Helicopters (15)
                    elseif classveh == 15 then
                        if blipSprite ~= 422 then
                            SetBlipSprite(blip, 422)        --Moving helicopter icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Planes (16)
                    elseif classveh == 16 then
                        if modelveh == 'besra' or modelveh == 'hydra' or modelveh == 'lazer' then
                            if blipSprite ~= 424 then
                                SetBlipSprite(blip, 424)    --Jet icon
                                ShowHeadingIndicatorOnBlip(blip, false)
                            end
                        elseif blipSprite ~= 423 then
                            SetBlipSprite(blip, 423)        --Plane icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Service (17)
                    elseif classveh == 17 then
                        if blipSprite ~= 198 then
                            SetBlipSprite(blip, 198)        --Taxi icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Emergency (18)
                    elseif classveh == 18 then
                        if blipSprite ~= 56 then
                            SetBlipSprite(blip, 56)        --Cop icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Military (19)
                    elseif classveh == 19 then
                        if modelveh == 'rhino' then
                            if blipSprite ~= 421 then
                                SetBlipSprite(blip, 421)    --Tank icon
                                ShowHeadingIndicatorOnBlip(blip, false)
                            end
                        elseif blipSprite ~= 750 then
                            SetBlipSprite(blip, 750)        --Military truck icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Commercial (20)
                    elseif classveh == 20 then
                        if blipSprite ~= 477 then
                            SetBlipSprite(blip, 477)        --Truck icon
                            ShowHeadingIndicatorOnBlip(blip, false)
                        end
                    --Every car (0, 1, 2, 3, 4, 5, 6, 7)
                    else
                        if modelveh == 'insurgent' or modelveh == 'insurgent2' or modelveh == 'limo2' then
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
                    local passengers = GetVehicleNumberOfPassengers(veh)
                    if passengers then
                        if not IsVehicleSeatFree(veh, -1) then
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

                SetBlipRotation(blip, math.ceil(GetEntityHeading(veh)))
                SetBlipNameToPlayerName(blip, playeridx)
                SetBlipScale(blip, 0.85)

                if IsPauseMenuActive() then
                    SetBlipAlpha(blip, 255)
                else
                    local x1, y1 = table.unpack(GetEntityCoords(PlayerPedId(), true))
                    local x2, y2 = table.unpack(GetEntityCoords(GetPlayerPed(playeridx), true))
                    local distance = (math.floor(math.abs(math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))) / -1)) + 900
                    if distance < 0 then
                        distance = 0
                    elseif distance > 255 then
                        distance = 255
                    end
                    SetBlipAlpha(blip, distance)
                end
            end
        else
            RemoveBlip(blip)
            NetCheck1 = false
        end
    end
end)