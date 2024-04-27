local config = require 'config.server'.commandPerms

lib.addCommand('admin', {
    help = 'Abre adminmenu',
    restricted = config.useMenu,
}, function(source)
    TriggerClientEvent('qbx_admin:client:openMenu', source)
end)

lib.addCommand('noclip', {
    help = 'Alternar o noclip',
    restricted = config.noclip,
}, function(source)
    TriggerClientEvent('qbx_admin:client:ToggleNoClip', source)
end)

lib.addCommand('names', {
    help = 'Alternar os nomes dos jogadores',
    restricted = config.names,
}, function(source)
    TriggerClientEvent('qbx_admin:client:names', source)
end)

lib.addCommand('blips', {
    help = 'Alternar os blips do jogador',
    restricted = config.blips,
}, function(source)
    TriggerClientEvent('qbx_admin:client:blips', source)
end)

lib.addCommand('admincar', {
    help = 'Compre veículo',
    restricted = config.saveVeh,
}, function(source)
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(source), false)
    if vehicle == 0 then
        return exports.qbx_core:Notify(source, 'Você precisa estar em um veículo.', 'error')
    end

    local vehModel = GetEntityModel(vehicle)

    if not exports.qbx_core:GetVehiclesByHash()[vehModel] then
        return exports.qbx_core:Notify(source, 'Veículo desconhecido, entre em contato com seu desenvolvedor para registrá -lo.', 'error')
    end

    local playerData = exports.qbx_core:GetPlayer(source).PlayerData
    local vehName, props = lib.callback.await('qbx_admin:client:GetVehicleInfo', source)
    if exports.qbx_vehicles:DoesEntityPlateExist(props.plate) then
        local response = lib.callback.await('qbx_admin:client:SaveCarDialog', source)

        if not response then
            return exports.qbx_core:Notify(source, 'Cancelado.', 'inform')
        end
        exports.qbx_vehicles:SetVehicleEntityOwner({
            citizenId = playerData.citizenid,
            plate = props.plate
        })
    else
        exports.qbx_vehicles:CreateVehicleEntity({
            citizenId = playerData.citizenid,
            model = vehName,
            mods = props,
            plate = props.plate
        })
    end
    exports.qbx_core:Notify(source, 'Este veículo é seu agora.', 'success')
end)

lib.addCommand('setmodel', {
    help = 'Define seu modelo para o modelo especificado',
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
    help = 'Copie o Vector2 para a área de transferência (somente administrador)',
    restricted = config.dev,
}, function(source)
    TriggerClientEvent('qbx_admin:client:copyToClipboard', source, 'coords2')
end)

lib.addCommand('vec3', {
    help = 'Copie o Vector3 para a área de transferência (somente administrador)',
    restricted = config.dev,
}, function(source)
    TriggerClientEvent('qbx_admin:client:copyToClipboard', source, 'coords3')
end)

lib.addCommand('vec4', {
    help = 'Copie o Vector4 para a área de transferência (somente administrador)',
    restricted = config.dev,
}, function(source)
    TriggerClientEvent('qbx_admin:client:copyToClipboard', source, 'coords4')
end)

lib.addCommand('heading', {
    help = 'Copie o caminho para a área de transferência (somente administrador)',
    restricted = config.dev,
}, function(source)
    TriggerClientEvent('qbx_admin:client:copyToClipboard', source, 'heading')
end)