local selectedPlayer
local playerOptions = {
    function()
        lib.showMenu('qb_adminmenu_player_general_menu', MenuIndexes['qb_adminmenu_player_general_menu'])
    end,
    function()
        lib.showMenu('qb_adminmenu_player_administration_menu', MenuIndexes['qb_adminmenu_player_administration_menu'])
    end,
    function()
        lib.showMenu('qb_adminmenu_player_extra_menu', MenuIndexes['qb_adminmenu_player_extra_menu'])
    end,
}

function GeneratePlayersMenu()
    local players = lib.callback.await('qb-admin:server:getplayers', false)
    if not players then
        Wait(200)
        lib.showMenu('qb_adminmenu_main_menu', MenuIndexes['qb_adminmenu_main_menu'])
        return
    end
    local optionsList = {}
    for i = 1, #players do
        optionsList[#optionsList + 1] = {label = string.format('ID: %s | Name: %s', players[i].id, players[i].name), description = string.format('CID: %s | %s', players[i].cid, players[i].license), args = players[i]}
    end
    lib.registerMenu({
        id = 'qb_adminmenu_players_menu',
        title = Lang:t('title.players_menu'),
        position = 'top-right',
        onClose = function(keyPressed)
            CloseMenu(false, keyPressed, 'qb_adminmenu_main_menu')
        end,
        onSelected = function(selected)
            MenuIndexes['qb_adminmenu_players_menu'] = selected
        end,
        options = optionsList
    }, function(_, _, args)
        local player = lib.callback.await('qb-admin:server:getplayer', false, args.id)
        if not player then
            Wait(200)
            lib.showMenu('qb_adminmenu_main_menu', MenuIndexes['qb_adminmenu_main_menu'])
            return
        end
        lib.registerMenu({
            id = ('qb_adminmenu_player_menu_%s'):format(args.id),
            title = player.name,
            position = 'top-right',
            onClose = function(keyPressed)
                CloseMenu(false, keyPressed, 'qb_adminmenu_players_menu')
            end,
            onSelected = function(selected)
                MenuIndexes[('qb_adminmenu_player_menu_%s'):format(args.id)] = selected
            end,
            options = {
                {label = Lang:t('player_options.label1'), description = Lang:t('player_options.desc1'), icon = 'fas fa-wrench'},
                {label = Lang:t('player_options.label2'), description = Lang:t('player_options.desc2'), icon = 'fas fa-file-invoice'},
                {label = Lang:t('player_options.label3'), description = Lang:t('player_options.desc3'), icon = 'fas fa-gamepad'},
                {label = string.format('Name: %s', player.name), close = false},
                {label = string.format('Food: %s', player.food), close = false},
                {label = string.format('Water: %s', player.water), close = false},
                {label = string.format('Stress: %s', player.stress), close = false},
                {label = string.format('Armor: %s', player.armor), close = false},
                {label = string.format('Phone: %s', player.phone), close = false},
                {label = string.format('Crafting Rep: %s', player.craftingrep), close = false},
                {label = string.format('Dealer Rep: %s', player.dealerrep), close = false},
                {label = string.format('Cash: %s', player.cash), close = false},
                {label = string.format('Bank: %s', player.bank), close = false},
                {label = string.format('Job: %s', player.job), close = false},
                {label = string.format('Gang: %s', player.gang), close = false},
                {label = string.format('%s', player.license), close = false},
                {label = string.format('%s', player.discord), description = 'Discord', close = false},
                {label = string.format('%s', player.steam), description = 'Steam', close = false}
            }
        }, function(selected)
            if not playerOptions[selected] then return end
            playerOptions[selected]()
        end)
        selectedPlayer = player
        lib.showMenu(('qb_adminmenu_player_menu_%s'):format(args.id), MenuIndexes[('qb_adminmenu_player_menu_%s'):format(args.id)])
    end)
    lib.showMenu('qb_adminmenu_players_menu', MenuIndexes['qb_adminmenu_players_menu'])
end

lib.registerMenu({
    id = 'qb_adminmenu_player_general_menu',
    title = Lang:t('player_options.label1'),
    position = 'top-right',
    onClose = function(keyPressed)
        CloseMenu(false, keyPressed, ('qb_adminmenu_player_menu_%s'):format(selectedPlayer?.id))
    end,
    onSelected = function(selected)
        MenuIndexes['qb_adminmenu_player_general_menu'] = selected
    end,
    options = {
        {label = Lang:t('player_options.general.labelkill'), description = Lang:t('player_options.general.desckill'), icon = 'fas fa-skull', close = false},
        {label = Lang:t('player_options.general.labelrevive'), description = Lang:t('player_options.general.descrevive'), icon = 'fas fa-cross', close = false},
        {label = Lang:t('player_options.general.labelfreeze'), description = Lang:t('player_options.general.descfreeze'), icon = 'fas fa-icicles', close = false},
        {label = Lang:t('player_options.general.labelgoto'), description = Lang:t('player_options.general.descgoto'), icon = 'fas fa-arrow-right-long', close = false},
        {label = Lang:t('player_options.general.labelbring'), description = Lang:t('player_options.general.descbring'), icon = 'fas fa-arrow-left-long', close = false},
        {label = Lang:t('player_options.general.labelsitinveh'), description = Lang:t('player_options.general.descsitinveh'), icon = 'fas fa-chair', close = false},
        {label = Lang:t('player_options.general.labelrouting'), description = Lang:t('player_options.general.descrouting'), icon = 'fas fa-bucket'},
    }
}, function(selected)
    if selected == 7 then
        local Input = lib.inputDialog(selectedPlayer.name, {
            { type = 'number', label = Lang:t('player_options.general.labelrouting'), placeholder = '25'}
        })
        if not Input then return end if not Input[1] then return end
        TriggerServerEvent('qb-admin:server:playeroptionsgeneral', selected, selectedPlayer, Input[1])
        lib.showMenu(('qb_adminmenu_player_menu_%s'):format(selectedPlayer?.id), MenuIndexes[('qb_adminmenu_player_menu_%s'):format(selectedPlayer?.id)])
    else
        TriggerServerEvent('qb-admin:server:playeroptionsgeneral', selected, selectedPlayer)
    end
end)

lib.registerMenu({
    id = 'qb_adminmenu_player_administration_menu',
    title = Lang:t('player_options.label2'),
    position = 'top-right',
    onClose = function(keyPressed)
        CloseMenu(false, keyPressed, ('qb_adminmenu_player_menu_%s'):format(selectedPlayer?.id))
    end,
    onSelected = function(selected)
        MenuIndexes['qb_adminmenu_player_administration_menu'] = selected
    end,
    options = {
        {label = Lang:t('player_options.administration.labelkick'), description = Lang:t('player_options.administration.desckick'), icon = 'fas fa-plane-departure'},
        {label = Lang:t('player_options.administration.labelban'), description = Lang:t('player_options.administration.descban'), icon = 'fas fa-gavel'},
        {label = Lang:t('player_options.administration.labelperm'), description = Lang:t('player_options.administration.descperm'), values = {Lang:t('player_options.administration.permvalue1'),
        Lang:t('player_options.administration.permvalue2'), Lang:t('player_options.administration.permvalue3'), Lang:t('player_options.administration.permvalue4')}, args = {'remove', 'mod', 'admin', 'god'}, icon = 'fas fa-book-bookmark'},
    }
}, function(selected, scrollIndex, args)
    if selected == 1 then
        local Input = lib.inputDialog(selectedPlayer.name, {Lang:t('player_options.administration.inputkick')})
        if not Input then lib.showMenu('qb_adminmenu_player_administration_menu', MenuIndexes['qb_adminmenu_player_administration_menu']) return end if not Input[1] then return end
        TriggerServerEvent('qb-admin:server:playeradministration', selected, selectedPlayer, Input[1])
        lib.showMenu('qb_adminmenu_player_administration_menu', MenuIndexes['qb_adminmenu_player_administration_menu'])
    elseif selected == 2 then
        local Input = lib.inputDialog(selectedPlayer.name, {
            { type = 'input', label = Lang:t('player_options.administration.inputkick'), placeholder = 'VDM'},
            { type = 'number', label = Lang:t('player_options.administration.input1ban')},
            { type = 'number', label = Lang:t('player_options.administration.input2ban')},
            { type = 'number', label = Lang:t('player_options.administration.input3ban')}
        })
        if not Input then lib.showMenu('qb_adminmenu_player_administration_menu', MenuIndexes['qb_adminmenu_player_general_menu']) return end if not Input[1] or not Input[2] and not Input[3] and not Input[4] then return end
        TriggerServerEvent('qb-admin:server:playeradministration', selected, selectedPlayer, Input)
        lib.showMenu('qb_adminmenu_player_administration_menu', MenuIndexes['qb_adminmenu_player_administration_menu'])
    else
        TriggerServerEvent('qb-admin:server:playeradministration', selected, selectedPlayer, args[scrollIndex])
        lib.showMenu('qb_adminmenu_player_administration_menu', MenuIndexes['qb_adminmenu_player_administration_menu'])
    end
end)

lib.registerMenu({
    id = 'qb_adminmenu_player_extra_menu',
    title = Lang:t('player_options.label2'),
    position = 'top-right',
    onClose = function(keyPressed)
        CloseMenu(false, keyPressed, ('qb_adminmenu_player_menu_%s'):format(selectedPlayer?.id))
    end,
    onSelected = function(selected)
        MenuIndexes['qb_adminmenu_player_extra_menu'] = selected
    end,
    options = {

    }
}, function(selected, scrollIndex, args)

end)