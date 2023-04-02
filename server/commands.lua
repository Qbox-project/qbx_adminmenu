lib.addCommand('admin', {
    help = 'Opens Adminmenu',
    restricted = 'qbox.admin',
}, function(source)
    TriggerClientEvent('qb-admin:client:openmenu', source)
end)


lib.addCommand('noclip', {
    help = 'Toggle NoClip',
    restricted = 'qbox.admin',
}, function(source)
    TriggerClientEvent('qb-admin:client:noclip', source)
end)

lib.addCommand('names', {
    help = 'Toggle Player Names',
    restricted = 'qbox.admin',
}, function(source)
    TriggerClientEvent('qb-admin:client:names', source)
end)

lib.addCommand('blips', {
    help = 'Toggle Player Blips',
    restricted = 'qbox.admin',
}, function(source)
    TriggerClientEvent('qb-admin:client:blips', source)
end)

lib.addCommand('setmodel', {
    help = 'Sets your model to the given model',
    restricted = 'qbox.admin',
    params = {
        { name = 'model', help = 'NPC Model', type = 'string'},
        { name = 'id', help = 'Player ID', type = 'number', optional = true},
    }
}, function(source, args)
    local Target = args.id or source

    if not QBCore.Functions.GetPlayer(Target) then return end

    TriggerClientEvent('qb-admin:client:setmodel', Target, args.model)
end)
