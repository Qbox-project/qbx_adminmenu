local vehicles = {}
function GenerateVehiclesSpawnMenu()
    local canUseMenu = lib.callback.await('qb-admin:server:canUseMenu', false)
    if not canUseMenu then
        lib.showMenu('qb_adminmenu_main_menu', MenuIndexes['qb_adminmenu_main_menu'])
        return
    end

    local indexedCategories = {}
    local categories = {}
    local vehs = {}
    for _, v in pairs(QBCore.Shared.Vehicles) do
        categories[v.category] = true
    end

    local categoryIndex = 1
    local newCategories = {}
    for k in pairs(categories) do
        newCategories[categoryIndex] = k
        categoryIndex += 1
    end

    categories = newCategories

    table.sort(categories, function(a, b)
        return a < b
    end)

    for i = 1, #categories do
        vehicles[categories[i]] = {}
        lib.setMenuOptions('qb_adminmenu_spawn_vehicles_menu', {label = categories[i], args = {('qb_adminmenu_spawn_vehicles_menu_%s'):format(categories[i])}}, i)

        lib.registerMenu({
            id = ('qb_adminmenu_spawn_vehicles_menu_%s'):format(categories[i]),
            title = categories[i],
            position = 'top-right',
            onClose = function(keyPressed)
                CloseMenu(false, keyPressed, 'qb_adminmenu_spawn_vehicles_menu')
            end,
            onSelected = function(selected)
                MenuIndexes[('qb_adminmenu_spawn_vehicles_menu_%s'):format(categories[i])] = selected
            end,
            options = {}
        }, function(_, _, args)
            local veh = lib.callback.await('qb-admin:server:spawnVehicle', false, args[1])
            if not veh then return end
            while not DoesEntityExist(NetToVeh(veh)) do Wait(100) end
            veh = NetToVeh(veh)
            TriggerEvent('qb-vehiclekeys:client:AddKeys', QBCore.Functions.GetPlate(veh))
            SetVehicleNeedsToBeHotwired(veh, false)
            SetVehicleHasBeenOwnedByPlayer(veh, true)
            SetEntityAsMissionEntity(veh, true, false)
            SetVehicleIsStolen(veh, false)
            SetVehicleIsWanted(veh, false)
            SetVehicleEngineOn(veh, true, true, true)
            SetPedIntoVehicle(cache.ped, veh, -1)
            SetVehicleOnGroundProperly(veh)
            SetVehicleRadioEnabled(veh, true)
            SetVehRadioStation(veh, 'OFF')
        end)
        indexedCategories[categories[i]] = 1
    end

    for k in pairs(QBCore.Shared.Vehicles) do
        vehs[#vehs + 1] = k
    end

    table.sort(vehs, function(a, b)
        return a < b
    end)

    for i = 1, #vehs do
        local v = QBCore.Shared.Vehicles[vehs[i]]
        vehicles[v.category][vehs[i]] = v
        lib.setMenuOptions(('qb_adminmenu_spawn_vehicles_menu_%s'):format(v.category), {label = v.name, args = {v.model}}, indexedCategories[v.category])
        indexedCategories[v.category] += 1
    end

    lib.showMenu('qb_adminmenu_spawn_vehicles_menu', MenuIndexes['qb_adminmenu_spawn_vehicles_menu'])
end

lib.registerMenu({
    id = 'qb_adminmenu_vehicles_menu',
    title = 'Vehicles',
    position = 'top-right',
    onClose = function(keyPressed)
        CloseMenu(false, keyPressed, 'qb_adminmenu_main_menu')
    end,
    onSelected = function(selected)
        MenuIndexes['qb_adminmenu_vehicles_menu'] = selected
    end,
    options = {
        {label = 'Spawn Vehicle'},
        {label = 'Fix Vehicle', close = false},
        {label = 'Buy Vehicle', close = false},
        {label = 'Remove Vehicle', close = false},
        {label = 'Tune Vehicle'},
        {label = 'Change Plate'}
    }
}, function(selected)
    if selected == 1 then
        GenerateVehiclesSpawnMenu()
    elseif selected == 2 then
        TriggerServerEvent('QBCore:CallCommand', "fix", {})
    elseif selected == 3 then
        TriggerServerEvent('QBCore:CallCommand', "admincar", {})
    elseif selected == 4 then
        TriggerServerEvent('QBCore:CallCommand', "dv", {})
    elseif selected == 5 then
        if not cache.vehicle then
            lib.notify({ description = 'You have to be in a vehicle, to use this', type = 'error' })
            lib.showMenu('qb_adminmenu_vehicles_menu', MenuIndexes['qb_adminmenu_vehicles_menu'])
            return
        end
        local override = {
            coords = GetEntityCoords(cache.ped),
            heading = GetEntityHeading(cache.ped),
            categories = {
                mods = true,
                repair = true,
                armor = true,
                respray = true,
                liveries = true,
                wheels = true,
                tint = true,
                plate = true,
                extras = true,
                neons = true,
                xenons = true,
                horn = true,
                turbo = true,
                cosmetics = true,
            },
        }
        TriggerEvent('qb-customs:client:EnterCustoms', override)
    elseif selected == 6 then
        if not cache.vehicle then
            lib.notify({ description = 'You have to be in a vehicle, to use this', type = 'error' })
            lib.showMenu('qb_adminmenu_vehicles_menu', MenuIndexes['qb_adminmenu_vehicles_menu'])
            return
        end
        local dialog = lib.inputDialog('Custom License Plate (Max. 8 characters)',  {'License Plate'})

        if not dialog or not dialog[1] or dialog[1] == '' then
            Wait(200)
            lib.showMenu('qb_adminmenu_vehicles_menu', MenuIndexes['qb_adminmenu_vehicles_menu'])
            return
        end

        if #dialog[1] > 8 then
            Wait(200)
            lib.notify({ description = 'You can only enter a maximum of 8 characters', type = 'error' })
            lib.showMenu('qb_adminmenu_vehicles_menu', MenuIndexes['qb_adminmenu_vehicles_menu'])
            return
        end

        SetVehicleNumberPlateText(cache.vehicle, dialog[1])
    end
end)

lib.registerMenu({
    id = 'qb_adminmenu_spawn_vehicles_menu',
    title = 'Spawn Vehicle',
    position = 'top-right',
    onClose = function(keyPressed)
        CloseMenu(false, keyPressed, 'qb_adminmenu_main_menu')
    end,
    onSelected = function(selected)
        MenuIndexes['qb_adminmenu_spawn_vehicles_menu'] = selected
    end,
    options = {}
}, function(_, _, args)
    lib.showMenu(args[1], MenuIndexes[args[1]])
end)
