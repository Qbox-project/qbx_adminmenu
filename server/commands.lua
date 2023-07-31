lib.addCommand('admin', {
    help = 'Opens Adminmenu',
    restricted = 'admin',
}, function(source)
    TriggerClientEvent('qb-admin:client:openmenu', source)
end)

lib.addCommand('noclip', {
    help = 'Toggle NoClip',
    restricted = 'admin',
}, function(source)
    TriggerClientEvent('qb-admin:client:noclip', source)
end)

lib.addCommand('names', {
    help = 'Toggle Player Names',
    restricted = 'admin',
}, function(source)
    TriggerClientEvent('qb-admin:client:names', source)
end)

lib.addCommand('blips', {
    help = 'Toggle Player Blips',
    restricted = 'admin',
}, function(source)
    TriggerClientEvent('qb-admin:client:blips', source)
end)

lib.addCommand('setmodel', {
    help = 'Sets your model to the given model',
    restricted = 'admin',
    params = {
        { name = 'model', help = 'NPC Model', type = 'string'},
        { name = 'id', help = 'Player ID', type = 'number', optional = true},
    }
}, function(source, args)
    local Target = args.id or source

    if not QBCore.Functions.GetPlayer(Target) then return end

    TriggerClientEvent('qb-admin:client:setmodel', Target, args.model)
end)

lib.addCommand('vec2', {
    help = 'Copy vector2 to clipboard (Admin only)',
    restricted = 'admin',
}, function(source)
    TriggerClientEvent('qb-admin:client:copyToClipboard', source, 'coords2')
end)

lib.addCommand('vec3', {
    help = 'Copy vector3 to clipboard (Admin only)',
    restricted = 'admin',
}, function(source)
    TriggerClientEvent('qb-admin:client:copyToClipboard', source, 'coords3')
end)

lib.addCommand('vec4', {
    help = 'Copy vector4 to clipboard (Admin only)',
    restricted = 'admin',
}, function(source)
    TriggerClientEvent('qb-admin:client:copyToClipboard', source, 'coords4')
end)

lib.addCommand('heading', {
    help = 'Copy heading to clipboard (Admin only)',
    restricted = 'admin',
}, function(source)
    TriggerClientEvent('qb-admin:client:copyToClipboard', source, 'heading')
end)