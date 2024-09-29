local coreVehicles = exports.qbx_core:GetVehiclesByName()

function GenerateVehiclesSpawnMenu()
    local canUseMenu = lib.callback.await('qbx_admin:server:canUseMenu', false)
    if not canUseMenu then
        lib.showMenu('qbx_adminmenu_main_menu', MenuIndexes.qbx_adminmenu_main_menu)
        return
    end

    local indexedCategories = {}
    local categories = {}
    local vehs = {}
    for _, v in pairs(coreVehicles) do
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
        lib.setMenuOptions('qbx_adminmenu_spawn_vehicles_menu', {label = qbx.string.capitalize(categories[i]), args = {('qbx_adminmenu_spawn_vehicles_menu_%s'):format(categories[i])}}, i)

        lib.registerMenu({
            id = ('qbx_adminmenu_spawn_vehicles_menu_%s'):format(categories[i]),
            title = categories[i],
            position = 'top-right',
            onClose = function(keyPressed)
                CloseMenu(false, keyPressed, 'qbx_adminmenu_spawn_vehicles_menu')
            end,
            onSelected = function(selected)
                MenuIndexes[('qbx_adminmenu_spawn_vehicles_menu_%s'):format(categories[i])] = selected
            end,
            options = {}
        }, function(_, _, args)
            local vehNetId = lib.callback.await('qbx_admin:server:spawnVehicle', false, args[1])
            if not vehNetId then return end
            local veh
            repeat
                veh = NetToVeh(vehNetId)
                Wait(100)
            until DoesEntityExist(veh)
            TriggerEvent('qb-vehiclekeys:client:AddKeys', qbx.getVehiclePlate(veh))
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

    for k in pairs(coreVehicles) do
        vehs[#vehs + 1] = k
    end

    table.sort(vehs, function(a, b)
        return a < b
    end)

    for i = 1, #vehs do
        local v = coreVehicles[vehs[i]]
        lib.setMenuOptions(('qbx_adminmenu_spawn_vehicles_menu_%s'):format(v.category), {label = v.name, args = {v.model}}, indexedCategories[v.category])
        indexedCategories[v.category] += 1
    end

    lib.showMenu('qbx_adminmenu_spawn_vehicles_menu', MenuIndexes.qbx_adminmenu_spawn_vehicles_menu)
end

lib.registerMenu({
    id = 'qbx_adminmenu_vehicles_menu',
    title = 'Vehicles',
    position = 'top-right',
    onClose = function(keyPressed)
        CloseMenu(false, keyPressed, 'qbx_adminmenu_main_menu')
    end,
    onSelected = function(selected)
        MenuIndexes.qbx_adminmenu_vehicles_menu = selected
    end,
    options = {
        {label = 'Spawn Vehicle'},
        {label = 'Fix Vehicle', close = false},
        {label = 'Buy Vehicle', close = true},
        {label = 'Remove Vehicle', close = false},
        {label = 'Tune Vehicle'},
        {label = 'Change Plate'}
    }
}, function(selected)
    if selected == 1 then
        GenerateVehiclesSpawnMenu()
    elseif selected == 2 then
        ExecuteCommand('fix')
    elseif selected == 3 then
        ExecuteCommand('admincar')
    elseif selected == 4 then
        ExecuteCommand('dv')
    elseif selected == 5 then
        if not cache.vehicle then
            exports.qbx_core:Notify('You have to be in a vehicle, to use this', 'error')
            lib.showMenu('qbx_adminmenu_vehicles_menu', MenuIndexes.qbx_adminmenu_vehicles_menu)
            return
        end
        
        -- New customs needs a way to open it from other resources
        exports.qbx_core:Notify('Currently no support for new customs', 'error')
    elseif selected == 6 then
        if not cache.vehicle then
            exports.qbx_core:Notify('You have to be in a vehicle, to use this', 'error')
            lib.showMenu('qbx_adminmenu_vehicles_menu', MenuIndexes.qbx_adminmenu_vehicles_menu)
            return
        end

        local dialog = lib.inputDialog('Custom License Plate (Max. 8 characters)',  {'License Plate'})

        if not dialog or not dialog[1] or dialog[1] == '' then
            Wait(200)
            lib.showMenu('qbx_adminmenu_vehicles_menu', MenuIndexes.qbx_adminmenu_vehicles_menu)
            return
        end

        if #dialog[1] > 8 then
            Wait(200)
            exports.qbx_core:Notify('You can only enter a maximum of 8 characters', 'error')
            lib.showMenu('qbx_adminmenu_vehicles_menu', MenuIndexes.qbx_adminmenu_vehicles_menu)
            return
        end

        SetVehicleNumberPlateText(cache.vehicle, dialog[1])
        TriggerEvent('qb-vehiclekeys:client:AddKeys', dialog[1])
    end
end)

lib.registerMenu({
    id = 'qbx_adminmenu_spawn_vehicles_menu',
    title = 'Spawn Vehicle',
    position = 'top-right',
    onClose = function(keyPressed)
        CloseMenu(false, keyPressed, 'qbx_adminmenu_main_menu')
    end,
    onSelected = function(selected)
        MenuIndexes.qbx_adminmenu_spawn_vehicles_menu = selected
    end,
    options = {}
}, function(_, _, args)
    lib.showMenu(args[1], MenuIndexes[args[1]])
end)
