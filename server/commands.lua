QBCore.Commands.Add('admin', 'help text here', {}, false, function(source)
    TriggerClientEvent('qb-admin:client:openmenu', source)
end)

QBCore.Commands.Add('noclip', 'help text here', {}, false, function(source)
    TriggerClientEvent('qb-admin:client:noclip', source)
end)

QBCore.Commands.Add('names', 'help text here', {}, false, function(source)
    TriggerClientEvent('qb-admin:client:names', source)
end)

QBCore.Commands.Add('blips', 'help text here', {}, false, function(source)
    TriggerClientEvent('qb-admin:client:blips', source)
end)

QBCore.Commands.Add('setmodel', 'help text here', {}, true, function(source, args)
    local model = args[1]
    local Target = tonumber(args[2]) or source

    if not QBCore.Functions.GetPlayer(Target) then return end

    TriggerClientEvent('qb-admin:client:setmodel', Target, tostring(model))
end)
