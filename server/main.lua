local isFrozen = {}
local sounds = {}

function NoPerms(source)
    exports.qbx_core:Notify(source, Lang:t('error.no_perms'), 'error')
end

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
    function(SelectedPlayer) TriggerClientEvent('hospital:client:KillPlayer', SelectedPlayer.id) end,
    function(SelectedPlayer) TriggerClientEvent('hospital:client:Revive', SelectedPlayer.id) end,
    function(SelectedPlayer)
        if isFrozen[SelectedPlayer.id] then
            FreezeEntityPosition(GetPlayerPed(SelectedPlayer.id), false)
            isFrozen[SelectedPlayer.id] = false
        else
            FreezeEntityPosition(GetPlayerPed(SelectedPlayer.id), true)
            isFrozen[SelectedPlayer.id] = true
        end
    end,
    function(SelectedPlayer, source)
        local Coords = GetEntityCoords(GetPlayerPed(SelectedPlayer.id))
        CheckRoutingbucket(source, SelectedPlayer.id)
        SetEntityCoords(GetPlayerPed(source), Coords.x, Coords.y, Coords.z, false, false, false, false)
    end,
    function(SelectedPlayer, source)
        local Coords = GetEntityCoords(GetPlayerPed(source))
        CheckRoutingbucket(SelectedPlayer.id, source)
        SetEntityCoords(GetPlayerPed(SelectedPlayer.id), Coords.x, Coords.y, Coords.z, false, false, false, false)
    end,
    function(SelectedPlayer, source)
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
    if not exports.qbx_core:HasPermission(source, Config.Events['playeroptionsgeneral']) then NoPerms(source) return end

    ---@diagnostic disable-next-line: redundant-parameter
    GeneralOptions[Selected](SelectedPlayer, source, Input)
end)

local AdministrationOptions = {
    function(Source, SelectedPlayer, Input)
        if not exports.qbx_core:HasPermission(Source, Config.Events['kick']) then NoPerms(Source) return end
        DropPlayer(SelectedPlayer.id, Input)
    end,
    function(Source, SelectedPlayer, Input)
        if not exports.qbx_core:HasPermission(Source, Config.Events['ban']) then NoPerms(Source) return end
        local BanDuration = (Input[2] or 0) * 3600 + (Input[3] or 0) * 86400 + (Input[4] or 0) * 2629743
        DropPlayer(SelectedPlayer.id, Lang:t('player_options.administration.banreason', { reason = Input[1], lenght = os.date('%c', os.time() + BanDuration) }))
        MySQL.Async.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            GetPlayerName(SelectedPlayer.id), exports.qbx_core:GetIdentifier(SelectedPlayer.id, 'license'), exports.qbx_core:GetIdentifier(SelectedPlayer.id, 'discord'),
            exports.qbx_core:GetIdentifier(SelectedPlayer.id, 'ip'), Input[1], os.time() + BanDuration, GetPlayerName(Source)
        })
    end,
    function(Source, SelectedPlayer, Input)
        if not exports.qbx_core:HasPermission(Source, Config.Events['changeperms']) then NoPerms(Source) return end
        if Input == 'remove' then exports.qbx_core:RemovePermission(SelectedPlayer.id) else exports.qbx_core:AddPermission(SelectedPlayer.id, Input) end
    end,
}
RegisterNetEvent('qb-admin:server:playeradministration', function(Selected, SelectedPlayer, Input)
    AdministrationOptions[Selected](source, SelectedPlayer, Input)
end)

local PlayerDataOptions = {
    name = function(Target, Input)
        if Input[1] then Target.PlayerData.charinfo.firstname = Input[1] end
        if Input[2] then Target.PlayerData.charinfo.lastname = Input[2] end
        Target.Functions.SetPlayerData('charinfo', Target.PlayerData.charinfo)
    end,
    food = function(Target, Input) Target.Functions.SetMetaData('hunger', Input[1]) end,
    thirst = function(Target, Input) Target.Functions.SetMetaData('thirst', Input[1]) end,
    stress = function(Target, Input) Target.Functions.SetMetaData('stress', Input[1]) end,
    armor = function(Target, Input) Target.Functions.SetMetaData('armor', Input[1]) SetPedArmour(GetPlayerPed(Target.PlayerData.source), Input[1]) end,
    phone = function(Target, Input)
        Target.PlayerData.charinfo.phone = Input[1]
        Target.Functions.SetPlayerData('charinfo', Target.PlayerData.charinfo)
    end,
    crafting = function(Target, Input) Target.Functions.SetMetaData('craftingrep', Input[1]) end,
    dealer = function(Target, Input) Target.Functions.SetMetaData('dealerrep', Input[1]) end,
    cash = function(Target, Input)
        Target.PlayerData.moneycash = Input[1]
        Target.Functions.SetPlayerData('money', Target.PlayerData.money)
    end,
    bank = function(Target, Input)
        Target.PlayerData.moneybank = Input[1]
        Target.Functions.SetPlayerData('money', Target.PlayerData.money)
    end,
    job = function(Target, Input)
        Target.Functions.SetJob(Input[1], Input[2])
    end,
    gang = function(Target, Input)
        Target.Functions.SetGang(Input[1], Input[2])
    end,
    radio = function(Target, Input)
        exports['pma-voice']:setPlayerRadio(Target.PlayerData.source, Input[1])
    end,
}
RegisterNetEvent('qb-admin:server:changeplayerdata', function(Selected, SelectedPlayer, Input)
    local Target = exports.qbx_core:GetPlayer(SelectedPlayer.id)

    if not exports.qbx_core:HasPermission(source, Config.Events['changeplayerdata']) then NoPerms(source) return end
    if not Target then return end

    PlayerDataOptions[Selected](Target, Input)
end)

RegisterNetEvent('qb-admin:server:SaveCar', function(mods, vehicle, plate)
    local Player = exports.qbx_core:GetPlayer(source)
    local result = MySQL.Sync.fetchAll('SELECT plate FROM player_vehicles WHERE plate = ?', { plate })
    if result[1] ~= nil then
        TriggerClientEvent('ox_lib:notify', source, 'This vehicle is already yours.', 'error', 3000)
        return
    end
    if not exports.qbx_core:HasPermission(source, Config.Events['savecar']) then
        NoPerms(source)
        return
    end
    local playerName = GetPlayerName(source)
    local citizenID = Player.PlayerData.citizenid
    TriggerEvent('qb-log:server:CreateLog', 'admin', 'Admin menu', 'pink', string.format(
        "**%s** (CitizenID: %s | ID: %s) - Saved a car to their garage **%s**",
        playerName, citizenID, source, vehicle.model
    ))
    MySQL.Async.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        Player.PlayerData.license,
        citizenID,
        vehicle.model,
        vehicle.hash,
        json.encode(mods),
        plate,
        0
    })
    TriggerClientEvent('ox_lib:notify', source, 'The vehicle is now yours!', 'success', 5000)
end)
RegisterNetEvent('qb-admin:server:giveallweapons', function(Weapontype, PlayerID)
    local src = PlayerID or source
    local Target = exports.qbx_core:GetPlayer(src)

    if not exports.qbx_core:HasPermission(source, Config.Events['giveallweapons']) then NoPerms(source) return end

    for i = 1, #Config.Weaponlist[Weapontype], 1 do
        if not exports.ox_inventory:Items()[Config.Weaponlist[Weapontype][i]] then return end
        Target.Functions.AddItem(Config.Weaponlist[Weapontype][i], 1)
    end
end)

lib.callback.register('qb-admin:callback:getradiolist', function(source, Frequency)
    local list = exports['pma-voice']:getPlayersInRadioChannel(tonumber(Frequency))
    local Players = {}

    if not exports.qbx_core:HasPermission(source, Config.Events['getradiolist']) then NoPerms(source) return end

    for targetSource, _ in pairs(list) do -- cheers Knight who shall not be named
        local Player = exports.qbx_core:GetPlayer(targetSource)
        Players[#Players + 1] = {
            id = targetSource,
            name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname .. ' | (' .. GetPlayerName(targetSource) .. ')'
        }
    end
    return Players, Frequency
end)

lib.callback.register('qb-admin:server:getplayers', function(source)
    if not exports.qbx_core:HasPermission(source, Config.Events['usemenu']) then NoPerms(source) return end

    local Players = {}
    for k, v in pairs(exports.qbx_core:GetQBPlayers()) do
        Players[#Players + 1] = {
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
            license = exports.qbx_core:GetIdentifier(k, 'license') or 'Unknown',
            discord = exports.qbx_core:GetIdentifier(k, 'discord') or 'Not Linked',
            steam = exports.qbx_core:GetIdentifier(k, 'steam') or 'Not Linked',
        }
    end
    table.sort(Players, function(a, b) return a.id < b.id end)
    return Players
end)

lib.callback.register('qb-admin:server:getplayer', function(source, playerToGet)
    if not exports.qbx_core:HasPermission(source, Config.Events['usemenu']) then NoPerms(source) return end

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
        license = exports.qbx_core:GetIdentifier(playerToGet, 'license') or 'Unknown',
        discord = exports.qbx_core:GetIdentifier(playerToGet, 'discord') or 'Not Linked',
        steam = exports.qbx_core:GetIdentifier(playerToGet, 'steam') or 'Not Linked',
    }
    return player
end)

lib.callback.register('qb-admin:server:clothingMenu', function(source, target)
    if not exports.qbx_core:HasPermission(source, Config.Events['clothing menu']) then
        NoPerms(source)
        return false
    end

    TriggerClientEvent('qb-clothing:client:openMenu', target)

    return true
end)

lib.callback.register('qb-admin:server:getSounds', function(source)
    if not exports.qbx_core:HasPermission(source, Config.Events['play sounds']) then
        NoPerms(source)
        return
    end
    return sounds
end)

lib.callback.register('qb-admin:server:canUseMenu', function(source)
    if not exports.qbx_core:HasPermission(source, Config.Events['usemenu']) then
        NoPerms(source)
        return false
    end

    return true
end)

lib.callback.register('qb-admin:server:spawnVehicle', function(source, model)
    local hash = joaat(model)
    return SpawnVehicle(source, hash, nil, true)
end)

CreateThread(function()
    local path = GetResourcePath(Config.SoundScriptName)
    local directory = ('%s%s'):format(path:gsub('//', '/'), Config.SoundPath)
    if not Config.Linux then
        for filename in io.popen(('dir "%s" /b'):format(directory)):lines() do
            sounds[#sounds + 1] = filename:match('(.+)%..+$')
        end
    else
        for filename in io.popen(('ls "%s" /b'):format(directory)):lines() do
            sounds[#sounds + 1] = filename:match('(.+)%..+$')
        end
    end
end)
