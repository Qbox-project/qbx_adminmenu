local config = require 'config.server'
local isFrozen = {}

--- Checks if the source is inside of the target's routingbucket
--- if not set the source's routingbucket to the target's
--- @param source string - The player's ID
--- @param target string - The player's ID
function CheckRoutingbucket(source, target)
    local sourceBucket = GetPlayerRoutingBucket(source)
    local targetBucket = GetPlayerRoutingBucket(target)
    if sourceBucket ~= targetBucket then SetPlayerRoutingBucket(source, targetBucket) end
end

local generalOptions = {
    function(selectedPlayer) TriggerClientEvent('hospital:client:KillPlayer', selectedPlayer.id) end,
    function(selectedPlayer) TriggerClientEvent('hospital:client:Revive', selectedPlayer.id) end,
    function(selectedPlayer)
        if isFrozen[selectedPlayer.id] then
            FreezeEntityPosition(GetPlayerPed(selectedPlayer.id), false)
            isFrozen[selectedPlayer.id] = false
        else
            FreezeEntityPosition(GetPlayerPed(selectedPlayer.id), true)
            isFrozen[selectedPlayer.id] = true
        end
    end,
    function(selectedPlayer, source)
        local coords = GetEntityCoords(GetPlayerPed(selectedPlayer.id))
        CheckRoutingbucket(source, selectedPlayer.id)
        SetEntityCoords(GetPlayerPed(source), coords.x, coords.y, coords.z, false, false, false, false)
    end,
    function(selectedPlayer, source)
        local coords = GetEntityCoords(GetPlayerPed(source))
        CheckRoutingbucket(selectedPlayer.id, source)
        SetEntityCoords(GetPlayerPed(selectedPlayer.id), coords.x, coords.y, coords.z, false, false, false, false)
    end,
    function(selectedPlayer, source)
        local vehicle = GetVehiclePedIsIn(GetPlayerPed(selectedPlayer.id), false)
        local seat = -1
        if vehicle == 0 then return end
        for i = 0, 8, 1 do if GetPedInVehicleSeat(vehicle, i) == 0 then seat = i break end end
        if seat == -1 then return end
        SetPedIntoVehicle(GetPlayerPed(source), vehicle, seat)
    end,
    function(selectedPlayer, _, input)
        SetPlayerRoutingBucket(selectedPlayer.id, input)
    end,
}
RegisterNetEvent('qbx_admin:server:playerOptionsGeneral', function(selected, selectedPlayer, input)
    if not IsPlayerAceAllowed(source, config.eventPerms.playerOptionsGeneral) then exports.qbx_core:Notify(source, locale('error.no_perms'), 'error') return end

    ---@diagnostic disable-next-line: redundant-parameter
    generalOptions[selected](selectedPlayer, source, input)
end)

local administrationOptions = {
    function(source, selectedPlayer, input)
        if not IsPlayerAceAllowed(source, config.eventPerms.kick) then exports.qbx_core:Notify(source, locale('error.no_perms'), 'error') return end
        DropPlayer(selectedPlayer.id, input)
    end,
    function(source, selectedPlayer, input)
        if not IsPlayerAceAllowed(source, config.eventPerms.ban) then exports.qbx_core:Notify(source, locale('error.no_perms'), 'error') return end
        local banDuration = (input[2] or 0) * 3600 + (input[3] or 0) * 86400 + (input[4] or 0) * 2629743
        DropPlayer(selectedPlayer.id, locale('player_options.administration.banreason', input[1], os.date('%c', os.time() + banDuration)))
        MySQL.Async.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            GetPlayerName(selectedPlayer.id), GetPlayerIdentifierByType(selectedPlayer.id, 'license'), GetPlayerIdentifierByType(selectedPlayer.id, 'discord'),
            GetPlayerIdentifierByType(selectedPlayer.id, 'ip'), input[1], os.time() + banDuration, GetPlayerName(source)
        })
    end,
    function(source, selectedPlayer, input)
        if not IsPlayerAceAllowed(source, config.eventPerms.changePerms) then exports.qbx_core:Notify(source, locale('error.no_perms'), 'error') return end
        if input == 'remove' then exports.qbx_core:RemovePermission(selectedPlayer.id) else exports.qbx_core:AddPermission(selectedPlayer.id, input) end
    end,
}
RegisterNetEvent('qbx_admin:server:playerAdministration', function(selected, selectedPlayer, input)
    administrationOptions[selected](source, selectedPlayer, input)
end)

local playerDataOptions = {
    name = function(target, input)
        if input[1] then target.PlayerData.charinfo.firstname = input[1] end
        if input[2] then target.PlayerData.charinfo.lastname = input[2] end
        target.Functions.SetPlayerData('charinfo', target.PlayerData.charinfo)
    end,
    food = function(target, input) target.Functions.SetMetaData('hunger', input[1]) end,
    thirst = function(target, input) target.Functions.SetMetaData('thirst', input[1]) end,
    stress = function(target, input) target.Functions.SetMetaData('stress', input[1]) end,
    armor = function(target, input) target.Functions.SetMetaData('armor', input[1]) SetPedArmour(GetPlayerPed(target.PlayerData.source), input[1]) end,
    phone = function(target, input)
        target.PlayerData.charinfo.phone = input[1]
        target.Functions.SetPlayerData('charinfo', target.PlayerData.charinfo)
    end,
    crafting = function(target, input) target.Functions.SetMetaData('craftingrep', input[1]) end,
    dealer = function(target, input) target.Functions.SetMetaData('dealerrep', input[1]) end,
    cash = function(target, input)
        target.PlayerData.moneycash = input[1]
        target.Functions.SetPlayerData('money', target.PlayerData.money)
    end,
    bank = function(target, input)
        target.PlayerData.moneybank = input[1]
        target.Functions.SetPlayerData('money', target.PlayerData.money)
    end,
    job = function(target, input)
        target.Functions.SetJob(input[1], input[2])
    end,
    gang = function(target, input)
        target.Functions.SetGang(input[1], input[2])
    end,
    radio = function(target, input)
        exports['pma-voice']:setPlayerRadio(target.PlayerData.source, input[1])
    end,
}
RegisterNetEvent('qbx_admin:server:changePlayerData', function(selected, selectedPlayer, input)
    local target = exports.qbx_core:GetPlayer(selectedPlayer.id)

    if not IsPlayerAceAllowed(source, config.eventPerms.changePlayerData) then exports.qbx_core:Notify(source, locale('error.no_perms'), 'error') return end
    if not target then return end

    playerDataOptions[selected](target, input)
end)

RegisterNetEvent('qbx_admin:server:giveAllWeapons', function(weaponType, playerID)
    local src = playerID or source
    local target = exports.qbx_core:GetPlayer(src)

    if not IsPlayerAceAllowed(source, config.eventPerms.giveAllWeapons) then exports.qbx_core:Notify(source, locale('error.no_perms'), 'error') return end

    for i = 1, #config.weaponList[weaponType], 1 do
        if not exports.ox_inventory:Items()[config.weaponList[weaponType][i]] then return end
        target.Functions.AddItem(config.weaponList[weaponType][i], 1)
    end
end)

lib.callback.register('qbx_admin:callback:getradiolist', function(source, frequency)
    local list = exports['pma-voice']:getPlayersInRadioChannel(tonumber(frequency))
    local players = {}

    if not IsPlayerAceAllowed(source, config.eventPerms.getRadioList) then exports.qbx_core:Notify(source, locale('error.no_perms'), 'error') return end

    for targetSource, _ in pairs(list) do -- cheers Knight who shall not be named
        local player = exports.qbx_core:GetPlayer(targetSource)
        players[#players + 1] = {
            id = targetSource,
            name = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname .. ' | (' .. GetPlayerName(targetSource) .. ')'
        }
    end
    return players, frequency
end)

lib.callback.register('qbx_admin:server:getPlayers', function(source)
    if not IsPlayerAceAllowed(source, config.eventPerms.useMenu) then exports.qbx_core:Notify(source, locale('error.no_perms'), 'error') return end

    local players = {}
    for k, v in pairs(exports.qbx_core:GetQBPlayers()) do
        players[#players + 1] = {
            id = k,
            cid = v.PlayerData.citizenid,
            name = v.PlayerData.charinfo.firstname .. ' ' .. v.PlayerData.charinfo.lastname .. ' | (' .. GetPlayerName(k) .. ')',
            food = v.PlayerData.metadata.hunger,
            water = v.PlayerData.metadata.thirst,
            stress = v.PlayerData.metadata.stress,
            armor = v.PlayerData.metadata.armor,
            phone = v.PlayerData.charinfo.phone,
            craftingrep = v.PlayerData.metadata.craftingrep,
            dealerrep = v.PlayerData.metadata.dealerrep,
            cash = v.PlayerData.money.cash,
            bank = v.PlayerData.money.bank,
            job = v.PlayerData.job.label .. ' | ' .. v.PlayerData.job.grade.level,
            gang = v.PlayerData.gang.label,
            license = GetPlayerIdentifierByType(k, 'license') or 'Unknown',
            discord = GetPlayerIdentifierByType(k, 'discord') or 'Not Linked',
            steam = GetPlayerIdentifierByType(k, 'steam') or 'Not Linked',
        }
    end
    table.sort(players, function(a, b) return a.id < b.id end)
    return players
end)

lib.callback.register('qbx_admin:server:getPlayer', function(source, playerToGet)
    if not IsPlayerAceAllowed(source, config.eventPerms.useMenu) then exports.qbx_core:Notify(source, locale('error.no_perms'), 'error') return end

    local playerData = exports.qbx_core:GetPlayer(playerToGet).PlayerData
    local player = {
        id = playerToGet,
        cid = playerData.citizenid,
        name = playerData.charinfo.firstname .. ' ' .. playerData.charinfo.lastname .. ' | (' .. GetPlayerName(playerToGet) .. ')',
        food = playerData.metadata.hunger,
        water = playerData.metadata.thirst,
        stress = playerData.metadata.stress,
        armor = playerData.metadata.armor,
        phone = playerData.charinfo.phone,
        craftingrep = playerData.metadata.craftingrep,
        dealerrep = playerData.metadata.dealerrep,
        cash = playerData.money.cash,
        bank = playerData.money.bank,
        job = playerData.job.label .. ' | ' .. playerData.job.grade.level,
        gang = playerData.gang.label,
        license = GetPlayerIdentifierByType(playerToGet, 'license') or 'Unknown',
        discord = GetPlayerIdentifierByType(playerToGet, 'discord') or 'Not Linked',
        steam = GetPlayerIdentifierByType(playerToGet, 'steam') or 'Not Linked',
    }
    return player
end)

lib.callback.register('qbx_admin:server:clothingMenu', function(source, target)
    if not IsPlayerAceAllowed(source, config.eventPerms.clothingMenu) then
        exports.qbx_core:Notify(source, locale('error.no_perms'), 'error')
        return false
    end

    TriggerClientEvent('qb-clothing:client:openMenu', target)

    return true
end)

lib.callback.register('qbx_admin:server:canUseMenu', function(source)
    if not IsPlayerAceAllowed(source, config.eventPerms.useMenu) then
        exports.qbx_core:Notify(source, locale('error.no_perms'), 'error')
        return false
    end

    return true
end)

lib.callback.register('qbx_admin:server:spawnVehicle', function(source, model)
    local ped = GetPlayerPed(source)
    local netId = qbx.spawnVehicle({
        model = model,
        spawnSource = ped,
        warp = true,
    })

    local plate = qbx.getVehiclePlate(NetworkGetEntityFromNetworkId(netId))

    exports.qbx_vehiclekeys:GiveKeys(source, plate)
    return netId
end)
