local reportOptions = {
    function(report)
        lib.alertDialog({
            header = string.format('Report ID: %s | Sender: %s', report.id, report.senderName),
            content = report.message,
            centered = true,
            cancel = false,
            size = 'lg',
            labels = {
                confirm = 'Close'
            }
        })

        lib.showMenu(('qbx_adminmenu_reports_menu_%s'):format(report.id), MenuIndexes[('qbx_adminmenu_reports_menu_%s'):format(report.id)])
    end,
    function(report)
        local input = lib.inputDialog(string.format('Report ID: %s | Sender: %s', report.id, report.senderName), {
            {type = 'input', label = 'Reply'}
        })
        
        if not input then
            exports.qbx_core:Notify(locale('error.no_report_reply'), 'error')
        else
            TriggerServerEvent('qbx_admin:server:sendReply', report, input[1])
        end

        lib.showMenu(('qbx_adminmenu_reports_menu_%s'):format(report.id), MenuIndexes[('qbx_adminmenu_reports_menu_%s'):format(report.id)])
    end,
    function(report)
        TriggerServerEvent('qbx_admin:server:deleteReport', report)

        GenerateReportMenu()
    end
}

function GenerateReportMenu()
    local reports = lib.callback.await('qbx_admin:server:getReports', false)

    if not reports or #reports < 1 then
        lib.showMenu('qbx_adminmenu_main_menu', MenuIndexes.qbx_adminmenu_main_menu)
        return
    end

    local optionsList = {}

    for i = 1, #reports do
        optionsList[#optionsList + 1] = {label = string.format('Report ID: %s | Sender: %s', reports[i].id, reports[i].senderName), description = locale('report_options.desc1'), args = {reports[i]}}
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
        options = optionsList
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
            local reportOption = reportOptions[selected]

            if not reportOption then
                lib.showMenu(('qbx_adminmenu_reports_menu_%s'):format(report.id), MenuIndexes[('qbx_adminmenu_reports_menu_%s'):format(report.id)])
                return
            end

            reportOption(report)
        end)

        lib.showMenu(('qbx_adminmenu_reports_menu_%s'):format(report.id), MenuIndexes[('qbx_adminmenu_reports_menu_%s'):format(report.id)])
    end)

    lib.showMenu('qbx_adminmenu_reports_menu', MenuIndexes.qbx_adminmenu_reports_menu)
end