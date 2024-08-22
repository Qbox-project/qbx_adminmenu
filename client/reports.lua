local function reportAction(selected, report)
    if selected == 1 then
        lib.alertDialog({
            header = string.format('Report ID: %s | Sender: %s', report.id, report.senderName),
            content = string.format('message: %s', report.message),
            centered = true,
            cancel = false,
            size = 'lg',
            labels = {
                confirm = 'Close'
            }
        })

        lib.showMenu(('qbx_adminmenu_reports_menu_%s'):format(report.id), MenuIndexes[('qbx_adminmenu_reports_menu_%s'):format(report.id)])
    elseif selected == 2 then
        local input = lib.inputDialog(string.format('Report ID: %s | Sender: %s', report.id, report.senderName), {
            {type = 'input', label = 'Reply'}
        })
        if input[1] == '' then
            exports.qbx_core:Notify(locale('error.no_report_reply'), 'error')
        else
            TriggerServerEvent('qbx_admin:server:sendReply', report, input[1])
        end

        lib.showMenu(('qbx_adminmenu_reports_menu_%s'):format(report.id), MenuIndexes[('qbx_adminmenu_reports_menu_%s'):format(report.id)])
    elseif selected == 3 then
        TriggerServerEvent('qbx_admin:server:deleteReport', report)
        GenerateReportMenu()
    else
        return lib.showMenu(('qbx_adminmenu_reports_menu_%s'):format(report.id), MenuIndexes[('qbx_adminmenu_reports_menu_%s'):format(report.id)])
    end
end

function GenerateReportMenu()
    local reports = lib.callback.await('qbx_admin:server:getReports', false)

    if not reports or #reports < 1 then
        exports.qbx_core:Notify(locale('error.no_reports'), 'error')
        return lib.showMenu('qbx_adminmenu_main_menu', MenuIndexes.qbx_adminmenu_main_menu)
    else
        exports.qbx_core:Notify(string.format(locale('success.report_load'), #reports), 'success')
    end

    local reportsList = {}
    for i = 1, #reports do
        reportsList[i] = {label = string.format(locale('report_options.label1'), reports[i].id, reports[i].senderName), description = locale('report_options.desc1'), args = {reports[i]}}
    end

    lib.registerMenu({
        id = 'qbx_adminmenu_reports_menu',
        title = locale('title.reports_menu'),
        position = 'top-right',
        onClose = function(keyPressed)
            CloseMenu(false, keyPressed, 'qbx_adminmenu_main_menu')
        end,
        onSelected = function(selected)
            MenuIndexes.qbx_adminmenu_reports_menu = selected
        end,
        options = reportsList
    }, function(_, _, args)
        local report = args[1]

        lib.registerMenu({
            id = ('qbx_adminmenu_reports_menu_%s'):format(report.id),
            title = string.format('Report ID: %s | Sender: %s', report.id, report.senderName),
            position = 'top-right',
            onClose = function(keyPressed)
                CloseMenu(false, keyPressed, 'qbx_adminmenu_reports_menu')
            end,
            onSelected = function(selected)
                MenuIndexes[('qbx_adminmenu_reports_menu_%s'):format(report.id)] = selected
            end,
            options = {
                {label = 'View Message', icon = 'fas fa-message'},
                {label = 'Send Message', icon = 'fas fa-reply'},
                {label = 'Close Report', icon = 'fas fa-trash'},
                {label = string.format('Claimed By: %s', report.claimed)},
                {label = string.format('Report ID: %s', report.id)},
                {label = string.format('Sender ID: %s', report.senderId)},
                {label = string.format('Sender Name: %s', report.senderName)}
            }
        }, function(selected)
            reportAction(selected, report)
        end)
        lib.showMenu(('qbx_adminmenu_reports_menu_%s'):format(report.id), MenuIndexes[('qbx_adminmenu_reports_menu_%s'):format(report.id)])
    end)

    lib.showMenu('qbx_adminmenu_reports_menu', MenuIndexes.qbx_adminmenu_reports_menu)
end