QBCore = exports['qb-core']:GetCoreObject()
local IsFrozen = {}

function NoPerms(source) QBCore.Functions.Notify(source, Lang:t('error.no_perms'), 'error') end

--- Checks if the source is inside of the target's routingbucket
--- if not set the source's routingbucket to the target's
--- @param source string - The player's ID
--- @param target string - The player's ID
function CheckRoutingbucket(source, target)
    local sourceBucket = GetPlayerRoutingBucket(source)
    local targetBucket = GetPlayerRoutingBucket(target)
    if sourceBucket ~= targetBucket then SetPlayerRoutingBucket(source, targetBucket) end
end

local GeneralOptions = {
        function(SelectedPlayer, _, _) TriggerClientEvent('hospital:client:KillPlayer', SelectedPlayer.id) end,
        function(SelectedPlayer, _, _) TriggerClientEvent('hospital:client:Revive', SelectedPlayer.id) end,
        function(SelectedPlayer, _, _)

        if IsFrozen[SelectedPlayer.id] then
            FreezeEntityPosition(GetPlayerPed(SelectedPlayer.id), false)
            IsFrozen[SelectedPlayer.id] = false
        else
            FreezeEntityPosition(GetPlayerPed(SelectedPlayer.id), true)
            IsFrozen[SelectedPlayer.id] = true
        end
    end,
    function(SelectedPlayer, source, _)
        local Coords = GetEntityCoords(GetPlayerPed(SelectedPlayer.id))
        CheckRoutingbucket(source, SelectedPlayer.id)
        SetEntityCoords(GetPlayerPed(source), Coords.x, Coords.y, Coords.z)
    end,
    function(SelectedPlayer, source, _)
        local Coords = GetEntityCoords(GetPlayerPed(source))
        CheckRoutingbucket(SelectedPlayer.id, source)
        SetEntityCoords(GetPlayerPed(SelectedPlayer.id), Coords.x, Coords.y, Coords.z)
    end,
    function(SelectedPlayer, source, _)
        local Vehicle = GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer.id), false)
        local Seat = -1
        if Vehicle == 0 then return end
        for i = 0, 8, 1 do if GetPedInVehicleSeat(Vehicle, i) == 0 then Seat = i break end end
        if Seat == -1 then return end
        SetPedIntoVehicle(GetPlayerPed(source), Vehicle, Seat)
    end,
    function(SelectedPlayer, _, Input)
        SetPlayerRoutingBucket(SelectedPlayer.id, Input)
    end,
}
RegisterNetEvent('qb-admin:server:playeroptionsgeneral', function(Selected, SelectedPlayer, Input)
    if not QBCore.Functions.HasPermission(source, Config.Events['playeroptionsgeneral']) then NoPerms(source) return end

    GeneralOptions[Selected](SelectedPlayer, source, Input)
end)

local AdministrationOptions = {
    function(Source, SelectedPlayer, Input)
        if not QBCore.Functions.HasPermission(Source, Config.Events['kick']) then NoPerms(Source) return end
        DropPlayer(SelectedPlayer.id, Input)
    end,
    function(Source, SelectedPlayer, Input)
        if not QBCore.Functions.HasPermission(Source, Config.Events['ban']) then NoPerms(Source) return end
        local BanDuration = (Input[2] or 0) * 3600 + (Input[3] or 0) * 86400 + (Input[4] or 0) * 2629743
        DropPlayer(SelectedPlayer.id, Lang:t('player_options.administration.banreason', { reason = Input[1], lenght = os.date('%c', os.time() + BanDuration) }))
        MySQL.Async.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            GetPlayerName(SelectedPlayer.id), QBCore.Functions.GetIdentifier(SelectedPlayer.id, 'license'), QBCore.Functions.GetIdentifier(SelectedPlayer.id, 'discord'),
            QBCore.Functions.GetIdentifier(SelectedPlayer.id, 'ip'), Input[1], os.time() + BanDuration, GetPlayerName(Source)
        })
    end,
    function(Source, SelectedPlayer, Input)
        if not QBCore.Functions.HasPermission(Source, Config.Events['changeperms']) then NoPerms(Source) return end
        if Input == 'remove' then QBCore.Functions.RemovePermission(SelectedPlayer.id) else QBCore.Functions.AddPermission(SelectedPlayer.id, Input) end
    end,
}
RegisterNetEvent('qb-admin:server:playeradministration', function(Selected, SelectedPlayer, Input)
    AdministrationOptions[Selected](source, SelectedPlayer, Input)
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
