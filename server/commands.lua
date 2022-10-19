QBCore.Commands.Add('admin', 'Pog menu', {}, false, function(source)
    TriggerClientEvent('qb-admin:client:openmenu', source)
end, Config.Commands['usemenu'])

QBCore.Commands.Add('noclip', 'Zoom', {}, false, function(source)
    TriggerClientEvent('qb-admin:client:noclip', source)
end, Config.Commands['noclip'])

QBCore.Commands.Add('names', 'Awesome names', {}, false, function(source)
    TriggerClientEvent('qb-admin:client:names', source)
end, Config.Commands['noclip'])

QBCore.Commands.Add('blips', 'Basically UAV', {}, false, function(source)
    TriggerClientEvent('qb-admin:client:blips', source)
end, Config.Commands['blips'])

QBCore.Commands.Add('setmodel', 'NPC', {}, false, function(source, args)
    local model = args[1]
    local Target = tonumber(args[2]) or source

    if not QBCore.Functions.GetPlayer(Target) then return end

    TriggerClientEvent('qb-admin:client:setmodel', Target, tostring(model))
end, Config.Commands['setmodel'])
