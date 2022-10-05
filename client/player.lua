local SelectedPlayer
local GeneralOptions = {

}
local PlayerOptions = {
    function()
        lib.showMenu('player_general_menu')
    end,
}

function GeneratePlayersMenu()
    lib.callback('qb-admin:server:getplayers', false, function(Players)
        local OptionsList = {}
        for i = 1, #Players do
            OptionsList[#OptionsList + 1] = {label = string.format('ID: %s | Name: %s', Players[i].id, Players[i].name), description = string.format('CID: %s | %s', Players[i].cid, Players[i].license), args = Players[i]}
        end
        lib.registerMenu({
            id = 'players_menu',
            title = Lang:t('title.players_menu'),
            position = 'top-right',
            options = OptionsList
        }, function(_, _, args)
            lib.registerMenu({
                id = 'player_menu',
                title = args.name,
                position = 'top-right',
                options = {
                    {label = Lang:t('player_options.label1'), description = Lang:t('player_options.desc1'), icon = 'fas fa-wrench',},
                    {label = Lang:t('player_options.label2'), description = Lang:t('player_options.desc2'), icon = 'fas fa-file-invoice',},
                    {label = Lang:t('player_options.label3'), description = Lang:t('player_options.desc3'), icon = 'fas fa-gamepad',},
                    {label = string.format('Name: %s', args.name)},
                    {label = string.format('Food: %s', args.food)},
                    {label = string.format('Water: %s', args.water)},
                    {label = string.format('Stress: %s', args.stress)},
                    {label = string.format('Armor: %s', args.armor)},
                    {label = string.format('Phone: %s', args.phone)},
                    {label = string.format('Crafting Rep: %s', args.craftingrep)},
                    {label = string.format('Dealer Rep: %s', args.dealerrep)},
                    {label = string.format('Cash: %s', args.cash)},
                    {label = string.format('Bank: %s', args.bank)},
                    {label = string.format('Job: %s', args.job)},
                    {label = string.format('Gang: %s', args.gang)},
                    {label = string.format('%s', args.license)},
                    {label = string.format('%s', args.discord), description = 'Discord'},
                    {label = string.format('%s', args.steam), description = 'Steam'}
                }
            }, function(selected)
                PlayerOptions[selected]()
            end)
            SelectedPlayer = args
            lib.showMenu('player_menu')
        end)
        lib.showMenu('players_menu')
    end)
end

lib.registerMenu({
    id = 'player_general_menu',
    title = Lang:t('player_options.label1'),
    position = 'top-right',
    options = {
        {label = Lang:t('player_options.general.labelkill'), description = Lang:t('player_options.general.desckill'), icon = 'fas fa-skull', close = false},
        {label = Lang:t('player_options.general.labelrevive'), description = Lang:t('player_options.general.descrevive'), icon = 'fas fa-cross', close = false},
        {label = Lang:t('player_options.general.labelfreeze'), description = Lang:t('player_options.general.descfreeze'), icon = 'fas fa-icicles', close = false},
        {label = Lang:t('player_options.general.labelgoto'), description = Lang:t('player_options.general.descgoto'), icon = 'fas fa-arrow-right-long', close = false},
        {label = Lang:t('player_options.general.labelbring'), description = Lang:t('player_options.general.descbring'), icon = 'fas fa-arrow-left-long', close = false},
        {label = Lang:t('player_options.general.labelsitinveh'), description = Lang:t('player_options.general.descsitinveh'), icon = 'fas fa-chair', close = false},
        {label = Lang:t('player_options.general.labelrouting'), description = Lang:t('player_options.general.descrouting'), icon = 'fas fa-bucket', close = false},
    }
}, function(selected)
    TriggerServerEvent('qb-admin:server:playeroptionsgeneral', selected, SelectedPlayer)
end)
