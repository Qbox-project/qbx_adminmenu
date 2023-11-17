function CopyToClipboard(dataType)
    if dataType == 'coords2' then
        local coords = GetEntityCoords(cache.ped)
        local x = math.round(coords.x, 2)
        local y = math.round(coords.y, 2)

        local string = string.format('vec2(%s, %s)', x, y)
        lib.setClipboard(string)

        exports.qbx_core:Notify(Lang:t('success.coords_copied'), 'success')
    elseif dataType == 'coords3' then
        local coords = GetEntityCoords(cache.ped)
        local x = math.round(coords.x, 2)
        local y = math.round(coords.y, 2)
        local z = math.round(coords.z, 2)

        local string = string.format('vec3(%s, %s, %s)', x, y, z)
        lib.setClipboard(string)

        exports.qbx_core:Notify(Lang:t('success.coords_copied'), 'success')
    elseif dataType == 'coords4' then
        local coords = GetEntityCoords(cache.ped)
        local x = math.round(coords.x, 2)
        local y = math.round(coords.y, 2)
        local z = math.round(coords.z, 2)
        local heading = GetEntityHeading(cache.ped)
        local h = math.round(heading, 2)

        local string = string.format('vec4(%s, %s, %s, %s)', x, y, z, h)
        lib.setClipboard(string)

        exports.qbx_core:Notify(Lang:t('success.coords_copied'), 'success')
    elseif dataType == 'heading' then
        local heading = GetEntityHeading(cache.ped)
        local h = math.round(heading, 2)

        local string = h
        lib.setClipboard(tostring(string))

        exports.qbx_core:Notify(Lang:t('success.heading_copied'), 'success')
    end
end

RegisterNetEvent('qbx_admin:client:copyToClipboard', function(dataType)
    CopyToClipboard(dataType)
end)
