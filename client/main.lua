QBCore = exports['qb-core']:GetCoreObject()

lib.registerMenu({
    id = 'main_menu',
    title = Lang:t('title.main_menu'),
    position = 'top-right',
    options = {
        {label = Lang:t('main_options.label1'), description = Lang:t('main_options.desc1'), icon = 'fas fa-hammer', args = 'admin_menu'},
        {label = Lang:t('main_options.label2'), description = Lang:t('main_options.desc2'), icon = 'fas fa-user', args = 'players_menu'},
        {label = Lang:t('main_options.label3'), description = Lang:t('main_options.desc3'), icon = 'fas fa-server', args = 'server_menu'},
        {label = Lang:t('main_options.label4'), description = Lang:t('main_options.desc4'), icon = 'fas fa-car', args = 'vehicles_menu'},
        {label = Lang:t('main_options.label5'), description = Lang:t('main_options.desc5'), icon = 'fas fa-toolbox', args = 'dev_menu'}
    }
}, function(_, _, args)
    if args == 'players_menu' then
        GeneratePlayersMenu()
    else
        lib.showMenu(args)
    end
end)

function Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function Draw2DText(content, font, colour, scale, x, y)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(colour[1], colour[2], colour[3], 255)
    BeginTextCommandDisplayText("STRING")
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    AddTextComponentSubstringPlayerName(content)
    EndTextCommandDisplayText(x, y)
end

RegisterNetEvent('qb-admin:client:openmenu', function()
    lib.showMenu('main_menu')
end)

RegisterNetEvent('qb-admin:client:setmodel', function(skin)
    local model = joaat(skin)
    SetEntityInvincible(cache.ped, true)
    if IsModelInCdimage(model) and IsModelValid(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(0) end
        SetPlayerModel(cache.playerId, model)
        SetPedRandomComponentVariation(cache.ped, 1)
		SetModelAsNoLongerNeeded(model)
	end
	SetEntityInvincible(cache.ped, false)
end)
