QBCore = exports['qb-core']:GetCoreObject()

function NoPerms(source) QBCore.Functions.Notify(source, Lang:t('error.no_perms'), 'error') end

RegisterNetEvent('qb-admin:server:playeroptionsgeneral', function(selected, SelectedPlayer)
    
end)

RegisterNetEvent('qb-admin:server:giveallweapons', function(Weapontype, PlayerID)
    local src = PlayerID or source
    local Target = QBCore.Functions.GetPlayer(src)

    if not QBCore.Functions.HasPermission(source, Config.Events['giveallweapons']) then NoPerms(source) return end

    for i = 1, #Config.Weaponlist[Weapontype], 1 do
        if not QBCore.Shared.Items[Config.Weaponlist[Weapontype][i]] then return end
        Target.Functions.AddItem(Config.Weaponlist[Weapontype][i], 1)
    end
end)

lib.callback.register('qb-admin:callback:getradiolist', function(source, Frequency)
    local list = exports['pma-voice']:getPlayersInRadioChannel(tonumber(Frequency))
    local Players = {}

    if not QBCore.Functions.HasPermission(source, Config.Events['getradiolist']) then NoPerms(source) return end

    for targetSource, _ in pairs(list) do -- cheers Knight who shall not be named
        local Player = QBCore.Functions.GetPlayer(targetSource)
        Players[#Players + 1] = {
            id = targetSource,
            name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname .. ' | (' .. GetPlayerName(targetSource) .. ')'
        }
    end
    return Players, Frequency
end)

lib.callback.register('qb-admin:server:getplayers', function(source)
    if not QBCore.Functions.HasPermission(source, Config.Events['usemenu']) then NoPerms(source) return end

    local Players = {}
    for k, v in pairs(QBCore.Functions.GetQBPlayers()) do
        Players[#Players + 1] = {
            id = k,
            cid = v.PlayerData.citizenid,
            name = v.PlayerData.charinfo.firstname .. ' ' .. v.PlayerData.charinfo.lastname .. ' | (' .. GetPlayerName(k) .. ')',
            food = v.PlayerData.metadata['hunger'],
            water = v.PlayerData.metadata['thirst'],
            stress = v.PlayerData.metadata['stress'],
            armor = v.PlayerData.metadata['armor'],
            phone = v.PlayerData.charinfo.phone,
            craftingrep = v.PlayerData.metadata['craftingrep'],
            dealerrep = v.PlayerData.metadata['dealerrep'],
            cash = v.PlayerData.money['cash'],
            bank = v.PlayerData.money['bank'],
            job = v.PlayerData.job.label .. ' | ' .. v.PlayerData.job.grade.level,
            gang = v.PlayerData.gang.label,
            license = QBCore.Functions.GetIdentifier(k, 'license') or 'Unknown',
            discord = QBCore.Functions.GetIdentifier(k, 'discord') or 'Not Linked',
            steam = QBCore.Functions.GetIdentifier(k, 'steam') or 'Not Linked',
        }
    end
    table.sort(Players, function(a, b) return a.id < b.id end)
    return Players
end)
