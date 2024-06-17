local config = require 'config.server'.commandPerms

lib.addCommand('report', {
    help = 'Send Report',
    params = {
        {name = 'report', help = 'Your report message', type = 'string'}
    }
}, function(source, args, raw)
    SendReport(source, string.sub(raw, 8))
end)

lib.addCommand('admin', {
    help = 'Opens Admin Menu',
    restricted = config.useMenu,
}, function(source)
    TriggerClientEvent('qbx_admin:client:openMenu', source)
end)

lib.addCommand('noclip', {
    help = 'Toggle NoClip',
    restricted = config.noclip,
}, function(source)
    TriggerClientEvent('qbx_admin:client:ToggleNoClip', source)
end)

lib.addCommand('names', {
    help = 'Toggle Player Names',
    restricted = config.names,
}, function(source)
    TriggerClientEvent('qbx_admin:client:names', source)
end)

lib.addCommand('blips', {
    help = 'Toggle Player Blips',
    restricted = config.blips,
}, function(source)
    TriggerClientEvent('qbx_admin:client:blips', source)
end)

lib.addCommand('admincar', {
    help = 'Buy Vehicle',
    restricted = config.saveVeh,
}, function(source)
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(source), false)
    if vehicle == 0 then
        return exports.qbx_core:Notify(source, 'You have to be in a vehicle, to use this', 'error')
    end

    local vehModel = GetEntityModel(vehicle)

    if not exports.qbx_core:GetVehiclesByHash()[vehModel] then
        return exports.qbx_core:Notify(source, 'Unknown vehicle, please contact your developer to register it.', 'error')
    end

    local playerData = exports.qbx_core:GetPlayer(source).PlayerData
    local vehName, props = lib.callback.await('qbx_admin:client:GetVehicleInfo', source)
    local existingVehicleId = Entity(vehicle).state.vehicleid
    if existingVehicleId then
        local response = lib.callback.await('qbx_admin:client:SaveCarDialog', source)

        if not response then
            return exports.qbx_core:Notify(source, 'Canceled.', 'inform')
        end
        local success, err = exports.qbx_vehicles:SetPlayerVehicleOwner(existingVehicleId, playerData.citizenid)
        if not success then error(err) end
    else
        local vehicleId, err = exports.qbx_vehicles:CreatePlayerVehicle({
            model = vehName,
            citizenid = playerData.citizenid,
            props = props,
        })
        if err then error(err) end
        Entity(vehicle).state:set('vehicleid', vehicleId, true)
    end
    exports.qbx_core:Notify(source, 'This vehicle is now yours.', 'success')
end)

lib.addCommand('setmodel', {
    help = 'Sets your model to the given model',
    restricted = config.setModel,
    params = {
        {name = 'model', help = 'NPC Model', type = 'string'},
        {name = 'id', help = 'Player ID', type = 'number', optional = true},
    }
}, function(source, args)
    local Target = args.id or source

    if not exports.qbx_core:GetPlayer(Target) then return end

    TriggerClientEvent('qbx_admin:client:setModel', Target, args.model)
end)

lib.addCommand('vec2', {
    help = 'Copy vector2 to clipboard (Admin only)',
    restricted = config.dev,
}, function(source)
    TriggerClientEvent('qbx_admin:client:copyToClipboard', source, 'coords2')
end)

lib.addCommand('vec3', {
    help = 'Copy vector3 to clipboard (Admin only)',
    restricted = config.dev,
}, function(source)
    TriggerClientEvent('qbx_admin:client:copyToClipboard', source, 'coords3')
end)

lib.addCommand('vec4', {
    help = 'Copy vector4 to clipboard (Admin only)',
    restricted = config.dev,
}, function(source)
    TriggerClientEvent('qbx_admin:client:copyToClipboard', source, 'coords4')
end)

lib.addCommand('heading', {
    help = 'Copy heading to clipboard (Admin only)',
    restricted = config.dev,
}, function(source)
    TriggerClientEvent('qbx_admin:client:copyToClipboard', source, 'heading')
end)