local invisible = false
local godmode = false
local infiniteAmmo = false
local vehicleGodmode = false
local options = {
    function() toggleNoClipMode() end,
    function() TriggerEvent('qbx_medical:client:playerRevived') end,
    function()
        invisible = not invisible
        if not invisible then return end
        while invisible do Wait(0) SetEntityVisible(cache.ped, false, false) end
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
            local input = lib.inputDialog(Lang:t('admin_options.value8_1'), {Lang:t('admin_options.input8label')})
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
    title = Lang:t('title.admin_menu'),
    position = 'top-right',
    onClose = function(keyPressed)
        closeMenu(false, keyPressed, 'qbx_adminmenu_main_menu')
    end,
    onSelected = function(selected)
        MenuIndexes.qbx_adminmenu_admin_menu = selected
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
        options[selected](args[scrollIndex])
    else
        ---@diagnostic disable-next-line: redundant-parameter
        options[selected](scrollIndex)
    end
end)

local noclipEnabled = false
local cam = 0
local ped
local speed = 1
local maxSpeed = 32.0

local function DisabledControls()
    HudWeaponWheelIgnoreSelection()
    DisableAllControlActions(0)
    DisableAllControlActions(1)
    DisableAllControlActions(2)
    EnableControlAction(0, 220, true)
    EnableControlAction(0, 221, true)
    EnableControlAction(0, 245, true)
end

local function SetupCam()
    local rotation = GetEntityRotation(ped)
    local coords = GetEntityCoords(ped)

    cam = CreateCameraWithParams('DEFAULT_SCRIPTED_CAMERA', coords, vector3(0.0, 0.0, rotation.z), 75.0)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 1000, false, false)
    AttachCamToEntity(cam, ped, 0.0, 0.0, 1.0, true)
end

local function DestoryCam()
    Wait(100)
    SetGameplayCamRelativeHeading(0)
    RenderScriptCams(false, true, 1000, true, true)
    DetachEntity(ped, true, true)
    SetCamActive(cam, false)
    DestroyCam(cam, true)
end

local IsControlAlwaysPressed = function(inputGroup, control)
    return IsControlPressed(inputGroup, control) or IsDisabledControlPressed(inputGroup, control)
end

local function UpdateCameraRotation()
    local rightAxisX = GetControlNormal(0, 220)
    local rightAxisY = GetControlNormal(0, 221)
    local rotation = GetCamRot(cam, 2)
    local yValue = rightAxisY * -5
    local newX
    local newZ = rotation.z + (rightAxisX * -10)

    if (rotation.x + yValue > -89.0) and (rotation.x + yValue < 89.0) then
        newX = rotation.x + yValue
    end

    if newX ~= nil and newZ ~= nil then
        SetCamRot(cam, vector3(newX, rotation.y, newZ), 2)
    end

    SetEntityHeading(ped, math.max(0, (rotation.z % 360)))
end

local function TeleportToGround()
    local coords = GetEntityCoords(ped)
    local rayCast = StartShapeTestRay(coords.x, coords.y, coords.z, coords.x, coords.y, -10000.0, 1, 0)
    local _, hit, hitCoords = GetShapeTestResult(rayCast)

    if hit == 1 then
        SetEntityCoords(ped, hitCoords.x, hitCoords.y, hitCoords.z)
    else
        SetEntityCoords(ped, coords.x, coords.y, coords.z)
    end
end

local function ToggleBehavior(bool)
    local coords = GetEntityCoords(ped)

    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    FreezeEntityPosition(ped, bool)
    SetEntityCollision(ped, not bool, not bool)
    SetEntityVisible(ped, not bool, not bool)
    SetEntityInvincible(ped, bool)
    SetEntityAlpha(ped, bool and noclipAlpha or 255, false)
    SetLocalPlayerVisibleLocally(true)
    SetEveryoneIgnorePlayer(ped, bool)
    SetPoliceIgnorePlayer(ped, bool)

    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle ~= 0 then
        SetEntityAlpha(vehicle, bool and noclipAlpha or 255, false)
    end
end

local function StopNoclip()
    DestoryCam()
    TeleportToGround()
    ToggleBehavior(false)
end

local function UpdateSpeed()
    if IsControlAlwaysPressed(2, 14) then
        speed = speed - 0.5
        if speed < 0.5 then
            speed = 0.5
        end
    elseif IsControlAlwaysPressed(2, 15) then
        speed = speed + 0.5
        if speed > maxSpeed then
            speed = maxSpeed
        end
    elseif IsDisabledControlJustReleased(0, 348) then
        speed = 1
    end
end

local function UpdateMovement()
    local multi = 1.0
    if IsControlAlwaysPressed(0, 21) then
        multi = 2
    elseif IsControlAlwaysPressed(0, 19) then
        multi = 4
    elseif IsControlAlwaysPressed(0, 36) then
        multi = 0.25
    end

    if IsControlAlwaysPressed(0, 32) then
        local pitch = GetCamRot(cam, 0)

        if pitch.x >= 0 then
            SetEntityCoordsNoOffset(ped,
                GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.5 * (speed * multi),
                    (pitch.x * ((speed / 2) * multi)) / 89))
        else
            SetEntityCoordsNoOffset(ped,
                GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.5 * (speed * multi),
                    -1 * ((math.abs(pitch.x) * ((speed / 2) * multi)) / 89)))
        end
    elseif IsControlAlwaysPressed(0, 33) then
        local pitch = GetCamRot(cam, 2)

        if pitch.x >= 0 then
            SetEntityCoordsNoOffset(ped,
                GetOffsetFromEntityInWorldCoords(ped, 0.0, -0.5 * (speed * multi),
                    -1 * (pitch.x * ((speed / 2) * multi)) / 89))
        else
            SetEntityCoordsNoOffset(ped,
                GetOffsetFromEntityInWorldCoords(ped, 0.0, -0.5 * (speed * multi),
                    ((math.abs(pitch.x) * ((speed / 2) * multi)) / 89)))
        end
    end

    if IsControlAlwaysPressed(0, 34) then
        SetEntityCoordsNoOffset(ped,
            GetOffsetFromEntityInWorldCoords(ped, -0.5 * (speed * multi), 0.0, 0.0))
    elseif IsControlAlwaysPressed(0, 35) then
        SetEntityCoordsNoOffset(ped,
            GetOffsetFromEntityInWorldCoords(ped, 0.5 * (speed * multi), 0.0, 0.0))
    end

    if IsControlAlwaysPressed(0, 44) then
        SetEntityCoordsNoOffset(ped,
            GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, 0.5 * (speed * multi)))
    elseif IsControlAlwaysPressed(0, 46) then
        SetEntityCoordsNoOffset(ped,
            GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, -0.5 * (speed * multi)))
    end
end

local function toggleNoclip()
    noclipEnabled = not noclipEnabled

    if cache.vehicle then
        ped = cache.vehicle
    else
        ped = cache.ped
    end

    if noclipEnabled then
        SetupCam()
        ToggleBehavior(true)
        while noclipEnabled do
            Wait(0)
            UpdateCameraRotation()
            DisabledControls()
            UpdateSpeed()
            UpdateMovement()
        end
    else
        StopNoclip()
    end
end

RegisterNetEvent('qbx_admin:client:noclip', function()
    if GetInvokingResource() then return end -- Safety to make sure it is only called from the server
    toggleNoclipMode()
end)

function toggleNoclipMode()
    noclipEnabled = not noclipEnabled

    if noclipEnabled then
        toggleNoclip()
end

local showBlips = false
local showNames = false
local netCheck1 = false
local netCheck2 = false

RegisterNetEvent('qbx_admin:client:blips', function()
    if not showBlips then
        showBlips = true
        netCheck1 = true
        exports.qbx_core:Notify(Lang:t('success.blips_activated'), 'success')
    else
        showBlips = false
        exports.qbx_core:Notify(Lang:t('error.blips_deactivated'), 'error')
    end
end)

RegisterNetEvent('qbx_admin:client:names', function()
    if not showNames then
        showNames = true
        netCheck2 = true
        exports.qbx_core:Notify(Lang:t('success.names_activated'), 'success')
    else
        showNames = false
        exports.qbx_core:Notify(Lang:t('error.names_deactivated'), 'error')
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

CreateThread(function()
    while true do
        Wait(1000)
        if netCheck1 or netCheck2 then
            TriggerEvent('qbx_admin:client:Show')
        end
    end
end)
