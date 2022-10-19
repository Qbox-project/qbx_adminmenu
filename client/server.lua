local Options = {
    function(Weather) TriggerServerEvent('qb-weathersync:server:setWeather', Weather) end,
    function(Time) TriggerServerEvent('qb-weathersync:server:setTime', Time) end,
    function()
        local Input = lib.inputDialog(Lang:t('server_options.label3'), {
            { type = 'number', label = Lang:t('server_options.input3label'), placeholder = '25'}
        })
        if not Input then return end if not Input[1] then return end
        lib.callback('qb-admin:callback:getradiolist', false, function(Players, Frequency)
            local OptionsList = {}
            for i = 1, #Players do OptionsList[#OptionsList + 1] = {title = Players[i].name .. ' | ' .. Players[i].id} end
            lib.registerContext({id = 'frequency_list', title = 'Frequency ' .. Frequency, options = OptionsList })
            lib.showContext('frequency_list')
        end, Input[1])
    end,
    function()
        local Input = lib.inputDialog(Lang:t('server_options.label4'), {Lang:t('server_options.input4label')})
        if not Input then return end if not Input[1] then return end
        TriggerServerEvent('inventory:server:OpenInventory', 'stash', Input[1])
        TriggerEvent('inventory:client:SetCurrentStash', Input[1])
    end,
}

lib.registerMenu({
    id = 'qb_adminmenu_server_menu',
    title = Lang:t('title.server_menu'),
    position = 'top-right',
    onClose = function(keyPressed)
        CloseMenu(false, keyPressed, 'qb_adminmenu_main_menu')
    end,
    onSelected = function(selected)
        MenuIndexes['qb_adminmenu_server_menu'] = selected
    end,
    options = {
        {label = Lang:t('server_options.label1'), description = Lang:t('server_options.desc1'), icon = 'fas fa-cloud', values = {Lang:t('server_options.value1_1'), Lang:t('server_options.value1_2'), Lang:t('server_options.value1_3'), Lang:t('server_options.value1_4'), Lang:t('server_options.value1_5'), Lang:t('server_options.value1_6'),
        Lang:t('server_options.value1_7'), Lang:t('server_options.value1_8'), Lang:t('server_options.value1_9'), Lang:t('server_options.value1_10'), Lang:t('server_options.value1_11'), Lang:t('server_options.value1_12'), Lang:t('server_options.value1_13'), Lang:t('server_options.value1_14'), Lang:t('server_options.value1_15')},
        args = {'Extrasunny', 'Clear', 'Neutral', 'Smog', 'Foggy', 'Overcast', 'Clouds', 'Clearing', 'Rain', 'Thunder', 'Snow', 'Blizzard', 'Snowlight', 'Xmas', 'Halloween'}, close = false},
        {label = Lang:t('server_options.label2'), description = Lang:t('server_options.desc2'), icon = 'fas fa-clock', values = {'00:00', '01:00', '02:00', '03:00', '04:00', '05:00', '06:00', '07:00', '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00', '23:00'},
        args = {'00', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23'}, close = false},
        {label = Lang:t('server_options.label3'), description = Lang:t('server_options.desc3'), icon = 'fas fa-walkie-talkie'},
        {label = Lang:t('server_options.label4'), description = Lang:t('server_options.desc4'), icon = 'fas fa-box-open'},
    }
}, function(selected, scrollIndex, args)
    if selected == 1 or selected == 2 then
        Options[selected](args[scrollIndex])
    else
        Options[selected]()
    end
end)