lib.versionCheck('Qbox-project/qbx_adminmenu')

local config = require 'config.server'
local isFrozen = {}
local reportsCount = 0

REPORTS = {}

--- Trigger something on players who have the passed permission
--- @param permission string - The required permission
--- @param cb function - The function, will return player object as parameter
function OnAdmin(permission, cb)
    for k, v in pairs(exports.qbx_core:GetQBPlayers()) do
        if IsPlayerAceAllowed(k, permission) then
            if exports.qbx_core:IsOptin(k) then
                cb(v)
            end
        end
    end
end

--- Sends a report to online staff members
--- @param source string - The player's ID
--- @param message string - Message for the report
function SendReport(source, message)
    local reportId = #REPORTS + 1
    reportsCount += 1

    REPORTS[reportId] = {
        id = reportsCount,
        senderId = source,
        senderName = GetPlayerName(source),
        message = message,
        claimed = 'Nobody'
    }

    table.sort(REPORTS, function(a, b) return a.id < b.id end)

    exports.qbx_core:Notify(source, locale('success.report_sent'), 'success')

    OnAdmin(config.commandPerms.reportReply, function(target)
        exports.qbx_core:Notify(target.PlayerData.source, locale('success.new_report'), 'success')
    end)
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

RegisterNetEvent('qbx_admin:server:sendReply', function(report, message)
    if not IsPlayerAceAllowed(source, config.commandPerms.reportReply) then exports.qbx_core:Notify(source, locale('error.no_perms'), 'error') return end
    if not exports.qbx_core:IsOptin(source) then exports.qbx_core:Notify(source, locale('error.not_optin'), 'error') return end
    if type(report) ~= 'table' or type(report.id) ~= 'number' or type(message) ~= 'string' then return end

    message = message:sub(1, 500)
    if message == '' then return end

    for k, v in pairs(REPORTS) do
        if v.id == report.id then
            local name = GetPlayerName(source)

            TriggerClientEvent('chatMessage', v.senderId, '', {255, 0, 0}, string.format('[REPORT #%s] [%s] ^7%s', v.id, name, message))

            exports.qbx_core:Notify(source, locale('success.sent_report_reply'), 'success')
            if REPORTS[k].claimed == 'Nobody' then
                REPORTS[k].claimed = name
                OnAdmin(config.commandPerms.reportReply, function(target)
                    exports.qbx_core:Notify(target.PlayerData.source, string.format(locale('success.report_claimed_by'), report.id, name), 'success')
                end)
            end
            return
        end
    end
end)

RegisterNetEvent('qbx_admin:server:deleteReport', function(report)
    if not IsPlayerAceAllowed(source, config.commandPerms.reportReply) then exports.qbx_core:Notify(source, locale('error.no_perms'), 'error') return end
    if not exports.qbx_core:IsOptin(source) then exports.qbx_core:Notify(source, locale('error.not_optin'), 'error') return end
    if type(report) ~= 'table' or type(report.id) ~= 'number' then return end

    for k, v in pairs(REPORTS) do
        if v.id == report.id then
            return table.remove(REPORTS, k)
        end
    end
end)

local generalOptions = {
    function(selectedPlayer) TriggerClientEvent('qbx_admin:client:killPlayer', selectedPlayer.id) end,
    function(selectedPlayer) TriggerClientEvent('qbx_medical:client:playerRevived', selectedPlayer.id) end,
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
        exports.qbx_core:SetPlayerBucket(selectedPlayer.id, input)
    end,
}
RegisterNetEvent('qbx_admin:server:playerOptionsGeneral', function(selected, selectedPlayer, input)
    if not IsPlayerAceAllowed(source, config.eventPerms.playerOptionsGeneral) then exports.qbx_core:Notify(source, locale('error.no_perms'), 'error') return end
    if not exports.qbx_core:IsOptin(source) then exports.qbx_core:Notify(source, locale('error.not_optin'), 'error') return end

    selected = tonumber(selected)
    local option = selected and generalOptions[selected]
    local targetId = type(selectedPlayer) == 'table' and tonumber(selectedPlayer.id)
    if not option or not targetId or not GetPlayerName(targetId) then return end
    if selected == 7 then
        input = tonumber(input)
        if not input or input < 0 or input % 1 ~= 0 then return end
    end

    ---@diagnostic disable-next-line: redundant-parameter
    option({id = targetId}, source, input)
end)

local administrationOptions = {
    function(source, selectedPlayer, input)
        if not IsPlayerAceAllowed(source, config.eventPerms.kick) then exports.qbx_core:Notify(source, locale('error.no_perms'), 'error') return end
        if not exports.qbx_core:IsOptin(source) then exports.qbx_core:Notify(source, locale('error.not_optin'), 'error') return end
        if type(input) ~= 'string' or input == '' then return end

        DropPlayer(selectedPlayer.id, input:sub(1, 500))
    end,
    function(source, selectedPlayer, input)
        if not IsPlayerAceAllowed(source, config.eventPerms.ban) then exports.qbx_core:Notify(source, locale('error.no_perms'), 'error') return end
        if not exports.qbx_core:IsOptin(source) then exports.qbx_core:Notify(source, locale('error.not_optin'), 'error') return end
        if type(input) ~= 'table' or type(input[1]) ~= 'string' or input[1] == '' then return end

        local hours = tonumber(input[2]) or 0
        local days = tonumber(input[3]) or 0
        local months = tonumber(input[4]) or 0
        if hours < 0 or days < 0 or months < 0 then return end

        local reason = input[1]:sub(1, 500)
        local banDuration = hours * 3600 + days * 86400 + months * 2629743
        DropPlayer(selectedPlayer.id, locale('player_options.administration.banreason', reason, os.date('%c', os.time() + banDuration)))
        MySQL.Async.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            GetPlayerName(selectedPlayer.id), GetPlayerIdentifierByType(selectedPlayer.id, 'license'), GetPlayerIdentifierByType(selectedPlayer.id, 'discord'),
            GetPlayerIdentifierByType(selectedPlayer.id, 'ip'), reason, os.time() + banDuration, GetPlayerName(source)
        })
    end,
    function(source, selectedPlayer, input)
        if not IsPlayerAceAllowed(source, config.eventPerms.changePerms) then exports.qbx_core:Notify(source, locale('error.no_perms'), 'error') return end
        if not exports.qbx_core:IsOptin(source) then exports.qbx_core:Notify(source, locale('error.not_optin'), 'error') return end

        local allowedPermissions = {remove = true, mod = true, admin = true, god = true}
        if not allowedPermissions[input] then return end

        if input == 'remove' then exports.qbx_core:RemovePermission(selectedPlayer.id) else exports.qbx_core:AddPermission(selectedPlayer.id, input) end
    end,
}
RegisterNetEvent('qbx_admin:server:playerAdministration', function(selected, selectedPlayer, input)
    selected = tonumber(selected)
    local option = selected and administrationOptions[selected]
    local targetId = type(selectedPlayer) == 'table' and tonumber(selectedPlayer.id)
    if not option or not targetId or not GetPlayerName(targetId) then return end

    option(source, {id = targetId}, input)
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
        target.Functions.SetMoney('cash', input[1], 'qbx_adminmenu')
    end,
    bank = function(target, input)
        target.Functions.SetMoney('bank', input[1], 'qbx_adminmenu')
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
    if not IsPlayerAceAllowed(source, config.eventPerms.changePlayerData) then exports.qbx_core:Notify(source, locale('error.no_perms'), 'error') return end
    if not exports.qbx_core:IsOptin(source) then exports.qbx_core:Notify(source, locale('error.not_optin'), 'error') return end

    local option = type(selected) == 'string' and playerDataOptions[selected]
    local targetId = type(selectedPlayer) == 'table' and tonumber(selectedPlayer.id)
    if not option or not targetId or type(input) ~= 'table' then return end

    local target = exports.qbx_core:GetPlayer(targetId)
    if not target then return end

    option(target, input)
end)

RegisterNetEvent('qbx_admin:server:giveAllWeapons', function(weaponType, playerID)
    if not IsPlayerAceAllowed(source, config.eventPerms.giveAllWeapons) then exports.qbx_core:Notify(source, locale('error.no_perms'), 'error') return end
    if not exports.qbx_core:IsOptin(source) then exports.qbx_core:Notify(source, locale('error.not_optin'), 'error') return end

    local weapons = type(weaponType) == 'string' and config.weaponList[weaponType]
    local target = exports.qbx_core:GetPlayer(tonumber(playerID) or source)
    if not weapons or not target then return end

    for i = 1, #weapons, 1 do
        target.Functions.AddItem(weapons[i], 1)
    end
end)

lib.callback.register('qbx_admin:callback:getradiolist', function(source, frequency)
    if not IsPlayerAceAllowed(source, config.eventPerms.getRadioList) then exports.qbx_core:Notify(source, locale('error.no_perms'), 'error') return end
    if not exports.qbx_core:IsOptin(source) then exports.qbx_core:Notify(source, locale('error.not_optin'), 'error') return end

    frequency = tonumber(frequency)
    if not frequency or frequency < 0 or frequency > 1000 then return end

    local list = exports['pma-voice']:getPlayersInRadioChannel(frequency)
    local players = {}

    for targetSource, _ in pairs(list) do -- cheers Knight who shall not be named
        local player = exports.qbx_core:GetPlayer(targetSource)
        if player then
            players[#players + 1] = {
                id = targetSource,
                name = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname .. ' | (' .. GetPlayerName(targetSource) .. ')'
            }
        end
    end
    return players, frequency
end)

lib.callback.register('qbx_admin:server:getPlayers', function(source)
    if not IsPlayerAceAllowed(source, config.eventPerms.useMenu) then exports.qbx_core:Notify(source, locale('error.no_perms'), 'error') return end
    if not exports.qbx_core:IsOptin(source) then exports.qbx_core:Notify(source, locale('error.not_optin'), 'error') return end

    local players = {}
    for k, v in pairs(exports.qbx_core:GetQBPlayers()) do
        players[#players + 1] = {
            id = k,
            cid = v.PlayerData.citizenid,
            name = v.PlayerData.charinfo.firstname .. ' ' .. v.PlayerData.charinfo.lastname .. ' | (' .. GetPlayerName(k) .. ')',
            food = Player(v.PlayerData.source).state.hunger,
            water = Player(v.PlayerData.source).state.thirst,
            stress = Player(v.PlayerData.source).state.stress,
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
    if not exports.qbx_core:IsOptin(source) then exports.qbx_core:Notify(source, locale('error.not_optin'), 'error') return end

    local target = exports.qbx_core:GetPlayer(tonumber(playerToGet))
    if not target then return end

    local playerData = target.PlayerData
    local player = {
        id = playerToGet,
        cid = playerData.citizenid,
        name = playerData.charinfo.firstname .. ' ' .. playerData.charinfo.lastname .. ' | (' .. GetPlayerName(playerToGet) .. ')',
        food = Player(playerData.source).state.hunger,
        water = Player(playerData.source).state.thirst,
        stress = Player(playerData.source).state.stress,
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
    if not IsPlayerAceAllowed(source, config.eventPerms.clothingMenu) then  exports.qbx_core:Notify(source, locale('error.no_perms'), 'error') return false end
    if not exports.qbx_core:IsOptin(source) then exports.qbx_core:Notify(source, locale('error.not_optin'), 'error') return false end

    TriggerClientEvent('qb-clothing:client:openMenu', target)

    return true
end)

lib.callback.register('qbx_admin:server:canUseMenu', function(source)
    if not IsPlayerAceAllowed(source, config.eventPerms.useMenu) then exports.qbx_core:Notify(source, locale('error.no_perms'), 'error') return false end
    if not exports.qbx_core:IsOptin(source) then exports.qbx_core:Notify(source, locale('error.not_optin'), 'error') return false end

    return true
end)

lib.callback.register('qbx_admin:server:spawnVehicle', function(source, model)
    if not IsPlayerAceAllowed(source, config.commandPerms.spawnVehicle) then exports.qbx_core:Notify(source, locale('error.no_perms'), 'error') return end
    if not exports.qbx_core:IsOptin(source) then exports.qbx_core:Notify(source, locale('error.not_optin'), 'error') return end

    local ped = GetPlayerPed(source)
    local netId, vehicle = qbx.spawnVehicle({
        model = model,
        spawnSource = ped,
        warp = true,
    })

    exports.qbx_vehiclekeys:GiveKeys(source, vehicle)
    return netId
end)

lib.callback.register('qbx_admin:server:getReports', function(source)
    if not IsPlayerAceAllowed(source, config.commandPerms.reportReply) then exports.qbx_core:Notify(source, locale('error.no_perms'), 'error') return end
    if not exports.qbx_core:IsOptin(source) then exports.qbx_core:Notify(source, locale('error.not_optin'), 'error') return end
    return REPORTS
end)
