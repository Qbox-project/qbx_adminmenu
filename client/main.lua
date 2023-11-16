MenuIndexes = {}

lib.registerMenu({
    id = 'qbx_adminmenu_main_menu',
    title = Lang:t('title.main_menu'),
    position = 'top-right',
    onClose = function()
        CloseMenu(true)
    end,
    onSelected = function(selected)
        MenuIndexes.qbx_adminmenu_main_menu = selected
    end,
    options = {
        {label = Lang:t('main_options.label1'), description = Lang:t('main_options.desc1'), icon = 'fas fa-hammer', args = {'qbx_adminmenu_admin_menu'}},
        {label = Lang:t('main_options.label2'), description = Lang:t('main_options.desc2'), icon = 'fas fa-user', args = {'qbx_adminmenu_players_menu'}},
        {label = Lang:t('main_options.label3'), description = Lang:t('main_options.desc3'), icon = 'fas fa-server', args = {'qbx_adminmenu_server_menu'}},
        {label = Lang:t('main_options.label4'), description = Lang:t('main_options.desc4'), icon = 'fas fa-car', args = {'qbx_adminmenu_vehicles_menu'}},
        {label = Lang:t('main_options.label5'), description = Lang:t('main_options.desc5'), icon = 'fas fa-toolbox', args = {'qbx_adminmenu_dev_menu'}}
    }
}, function(_, _, args)
    if args[1] == 'qbx_adminmenu_players_menu' then
        GeneratePlayersMenu()
    else
        lib.showMenu(args[1], MenuIndexes[args[1]])
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
    BeginTextCommandDisplayText('STRING')
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    AddTextComponentSubstringPlayerName(content)
    EndTextCommandDisplayText(x, y)
end

function CloseMenu(isFullMenuClose, keyPressed, previousMenu)
    if isFullMenuClose or not keyPressed or keyPressed == 'Escape' then
        lib.hideMenu(false)
        return
    end

    lib.showMenu(previousMenu, MenuIndexes[previousMenu])
end

RegisterNetEvent('qbx_admin:client:openMenu', function()
    lib.showMenu('qbx_adminmenu_main_menu', MenuIndexes.qbx_adminmenu_main_menu)
end)

RegisterNetEvent('qbx_admin:client:setModel', function(skin)
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
