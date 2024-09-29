local options = {
    function(weather) TriggerServerEvent('qb-weathersync:server:setWeather', weather) end,
    function(time) TriggerServerEvent('qb-weathersync:server:setTime', time) end,
    function()
        local input = lib.inputDialog(locale('server_options.label3'), {
            {type = 'number', label = locale('server_options.input3label'), min = 0, max = 1000}
        })
        if not input then return end if not input[1] then return end
        lib.callback('qbx_admin:callback:getradiolist', false, function(players, frequency)
            local optionsList = {}
            for i = 1, #players do optionsList[#optionsList + 1] = {title = players[i].name .. ' | ' .. players[i].id} end
            lib.registerContext({id = 'frequency_list', title = 'Frequency ' .. frequency, options = optionsList })
            lib.showContext('frequency_list')
        end, input[1])
    end,
    function()
        local input = lib.inputDialog(locale('server_options.label4'), {locale('server_options.input4label')})
        if not input then return end if not input[1] then return end
        TriggerServerEvent('inventory:server:OpenInventory', 'stash', input[1])
        TriggerEvent('inventory:client:SetCurrentStash', input[1])
    end,
}

lib.registerMenu({
    id = 'qbx_adminmenu_server_menu',
    title = locale('title.server_menu'),
    position = 'top-right',
    onClose = function(keyPressed)
        CloseMenu(false, keyPressed, 'qbx_adminmenu_main_menu')
    end,
    onSelected = function(selected)
        MenuIndexes.qbx_adminmenu_server_menu = selected
    end,
    options = {
        {label = locale('server_options.label1'), description = locale('server_options.desc1'), icon = 'fas fa-cloud', values = {locale('server_options.value1_1'), locale('server_options.value1_2'), locale('server_options.value1_3'), locale('server_options.value1_4'), locale('server_options.value1_5'), locale('server_options.value1_6'),
        locale('server_options.value1_7'), locale('server_options.value1_8'), locale('server_options.value1_9'), locale('server_options.value1_10'), locale('server_options.value1_11'), locale('server_options.value1_12'), locale('server_options.value1_13'), locale('server_options.value1_14'), locale('server_options.value1_15')},
        args = {'Extrasunny', 'Clear', 'Neutral', 'Smog', 'Foggy', 'Overcast', 'Clouds', 'Clearing', 'Rain', 'Thunder', 'Snow', 'Blizzard', 'Snowlight', 'Xmas', 'Halloween'}, close = false},
        {label = locale('server_options.label2'), description = locale('server_options.desc2'), icon = 'fas fa-clock', values = {'00:00', '01:00', '02:00', '03:00', '04:00', '05:00', '06:00', '07:00', '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00', '23:00'},
        args = {'00', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23'}, close = false},
        {label = locale('server_options.label3'), description = locale('server_options.desc3'), icon = 'fas fa-walkie-talkie'},
        {label = locale('server_options.label4'), description = locale('server_options.desc4'), icon = 'fas fa-box-open'},
    }
}, function(selected, scrollIndex, args)
    if selected == 1 or selected == 2 then
        options[selected](args[scrollIndex])
    else
        options[selected]()
    end
end)
