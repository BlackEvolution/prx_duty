CreateThread( function()
	if GetCurrentResourceName() == 'prx_duty' then     
		print(' ██████╗ ██████╗ ██╗  ██╗    ██████╗ ███████╗██╗   ██╗███████╗██╗      ██████╗ ██████╗ ███╗   ███╗███████╗███╗   ██╗████████╗ ')
		print(' ██╔══██╗██╔══██╗╚██╗██╔╝    ██╔══██╗██╔════╝██║   ██║██╔════╝██║     ██╔═══██╗██╔══██╗████╗ ████║██╔════╝████╗  ██║╚══██╔══╝ ')
		print(' ██████╔╝██████╔╝ ╚███╔╝     ██║  ██║█████╗  ██║   ██║█████╗  ██║     ██║   ██║██████╔╝██╔████╔██║█████╗  ██╔██╗ ██║   ██║    ')
		print(' ██╔═══╝ ██╔══██╗ ██╔██╗     ██║  ██║██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║     ██║   ██║██╔═══╝ ██║╚██╔╝██║██╔══╝  ██║╚██╗██║   ██║    ')
		print(' ██║     ██║  ██║██╔╝ ██╗    ██████╔╝███████╗ ╚████╔╝ ███████╗███████╗╚██████╔╝██║     ██║ ╚═╝ ██║███████╗██║ ╚████║   ██║    ')
		print(' ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝    ╚═════╝ ╚══════╝  ╚═══╝  ╚══════╝╚══════╝ ╚═════╝ ╚═╝     ╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝    ')
    else
		print('\t|\t^8             CONFIGURATION ERROR                 ^7|')
		print('\t|^8 INVALID RESOURCE NAME. PLEASE VERIFY RESOURCE FOLDER   ^7|')
		print('\t|^8        NAME READS \'^3prx_duty^8\'. THIS IS REQUIRED         ^7|')
	end
end)

local ESXJobs = {}

MySQL.ready(function()
	local result = MySQL.Sync.fetchAll('SELECT * FROM jobs', {})

	for i=1, #result do
		ESXJobs[result[i].name] = result[i]
		ESXJobs[result[i].name].grades = {}
	end

	local result2 = MySQL.Sync.fetchAll('SELECT * FROM job_grades', {})

	for i=1, #result2 do
		if ESXJobs[result2[i].job_name] then
			ESXJobs[result2[i].job_name].grades[tostring(result2[i].grade)] = result2[i]
		end
	end

end)

local playerDuty = {}

RegisterNetEvent('prx_duty:ChangeJob')
AddEventHandler('prx_duty:ChangeJob', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not Config.SpecialJobs[xPlayer.job.name] then
        if string.find(xPlayer.job.name, "off") then
            local jobData = xPlayer.getJob()
            jobData.name = string.gsub(jobData.name, "off", "")
            xPlayer.showNotification(_U('in_duty'))
            xPlayer.setJob(jobData.name, jobData.grade)
        else
            local jobData = xPlayer.getJob()
            xPlayer.showNotification(_U('logged_off_duty'))
            xPlayer.setJob('off'..jobData.name, jobData.grade)
        end
    else
        local jobData = xPlayer.getJob()
        xPlayer.setJob(Config.SpecialJobs[xPlayer.job.name], jobData.grade)
    end
    CheckForItems(ESX.GetPlayerFromId(_source))
end)

function CheckForItems(xPlayer)
    if Config.Items[xPlayer.job.name] then
        for k, v in pairs(Config.Items[xPlayer.job.name].Add) do
            if xPlayer.canCarryItem(v, 1) then
                xPlayer.addInventoryItem(v, 1)
            end
        end
        for k, v in pairs(Config.Items[xPlayer.job.name].Remove) do
            local count = xPlayer.getInventoryItem(v).count
            if count and count > 0 then
                xPlayer.removeInventoryItem(v, count)
            end
        end
    end
end

RegisterNetEvent('prx_duty:DutyCheck')
AddEventHandler('prx_duty:DutyCheck', function(job, new)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not playerDuty[xPlayer.identifier] then
        playerDuty[xPlayer.identifier] = {}
    end
    if new then
            playerDuty[xPlayer.identifier][job] = {
                    active = true,
                    pauzes = {},
                    totalTime = 0,
                    startTime = os.date("%Y/%m/%d %X"),
                    endTime = nil,
                    job = {
                        label = xPlayer.job.label,
                        grade = xPlayer.job.grade_label,
                        name = xPlayer.job.name,
                        gradeRank = xPlayer.job.grade
                    }
                }
    else

        if playerDuty[xPlayer.identifier] and playerDuty[xPlayer.identifier][job] and playerDuty[xPlayer.identifier][job].active then
            playerDuty[xPlayer.identifier][job].active = false
            table.insert(playerDuty[xPlayer.identifier][job].pauzes, {
                startTime = os.date("%Y/%m/%d %X"),
                endTime = 'changeMe'
            })
            playerDuty[xPlayer.identifier][job].endTime = os.date("%Y/%m/%d %X")
        end

        if playerDuty[xPlayer.identifier] and playerDuty[xPlayer.identifier][xPlayer.job.name] then

            playerDuty[xPlayer.identifier][xPlayer.job.name].job.label = xPlayer.job.label
            playerDuty[xPlayer.identifier][xPlayer.job.name].job.grade = xPlayer.job.grade_label
            playerDuty[xPlayer.identifier][xPlayer.job.name].job.name = xPlayer.job.name
            playerDuty[xPlayer.identifier][xPlayer.job.name].job.gradeRank = xPlayer.job.grade

            playerDuty[xPlayer.identifier][xPlayer.job.name].active = true
            playerDuty[xPlayer.identifier][xPlayer.job.name].endTime = 'changeMe'

            for k, v in pairs(playerDuty[xPlayer.identifier][xPlayer.job.name].pauzes) do
                if v.endTime == 'changeMe' then
                    v.endTime = os.date("%Y/%m/%d %X")
                end
            end
        elseif playerDuty[xPlayer.identifier] then
            playerDuty[xPlayer.identifier][xPlayer.job.name] = {
                    active = true,
                    pauzes = {},
                    totalTime = 0,
                    startTime = os.date("%Y/%m/%d %X"),
                    endTime = nil,
                    job = {
                        label = xPlayer.job.label,
                        grade = xPlayer.job.grade_label,
                        name = xPlayer.job.name,
                        gradeRank = xPlayer.job.grade
                    }
                }
        else
            playerDuty[xPlayer.identifier][xPlayer.job.name] = {
                    active = true,
                    pauzes = {},
                    totalTime = 0,
                    startTime = os.date("%Y/%m/%d %X"),
                    endTime = nil,
                    job = {
                        label = xPlayer.job.label,
                        grade = xPlayer.job.grade_label,
                        name = xPlayer.job.name,
                        gradeRank = xPlayer.job.grade
                    }
                }
        end
    end
    playerDuty[xPlayer.identifier].identifier = xPlayer.identifier
end)

RegisterNetEvent('prx_duty:DutyTimeUpdate')
AddEventHandler('prx_duty:DutyTimeUpdate', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if playerDuty[xPlayer.identifier] and playerDuty[xPlayer.identifier][xPlayer.job.name] then
        playerDuty[xPlayer.identifier][xPlayer.job.name].totalTime = playerDuty[xPlayer.identifier][xPlayer.job.name].totalTime + 1
    end
end)

RegisterNetEvent('prx_duty:GetEmployes')
AddEventHandler('prx_duty:GetEmployes', function(job)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.job.name == job and xPlayer.job.grade_name == 'boss' then
        local dutyData = MySQL.Sync.fetchAll('SELECT * FROM `prx_duty` WHERE job = @job', {
            ['@job'] = job
        })

        while not dutyData do
            Wait(100)
        end

        local rows = {}

        for k, v in pairs(dutyData) do

            table.insert(rows, {
                data = v,
                cols = {
                    v.rpName,
                    ESXJobs[tostring(v.job)].label .. ' - ' .. ESXJobs[tostring(v.job)].grades[tostring(v.jobGrade)].label,
                    timeToDisp(v.dutyTime),
                    v.lastDuty,
                    '{{' .. _U('reset_time') .. '|resetTime}}',
                },
                grade = v.jobGrade
            })

        end

        TriggerClientEvent('prx_duty:returnEmployes', _source, rows)

    else
        DropPlayer(_source, 'We do not support any cheaters')
    end

end)


RegisterNetEvent('prx_duty:ResetTime')
AddEventHandler('prx_duty:ResetTime', function(identifier, job)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer.job.name == job and xPlayer.job.grade_name == 'boss' then

        MySQL.Async.execute('DELETE FROM `prx_duty` WHERE identifier = @identifier and job = @job', {
            ['@identifier'] = identifier,
            ['@job'] = job,
            }
        )

        local dutyData = MySQL.Sync.fetchAll('SELECT * FROM `prx_duty` WHERE job = @job', {
            ['@job'] = job
        })

        while not dutyData do
            Wait(100)
        end

        local rows = {}

        for k, v in pairs(dutyData) do

            table.insert(rows, {
                data = v,
                cols = {
                    v.rpName,
                    ESXJobs[tostring(v.job)].label .. ' - ' .. ESXJobs[tostring(v.job)].grades[tostring(v.jobGrade)].label,
                    timeToDisp(v.dutyTime),
                    v.lastDuty,
                    '{{' .. _U('reset_time') .. '|resetTime}}',
                },
                grade = v.jobGrade
            })

        end

        TriggerClientEvent('prx_duty:returnEmployes', _source, rows)

    else
        DropPlayer(_source, 'We do not support any cheaters')
    end

end)

if SConfig.UsetxAdmin then

    AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
        if eventData.secondsRemaining == 60 then
            CreateThread(function()
                Wait(45000)
                TriggerEvent('prx_duty:saveEmployes')
            end)
        end
    end)

else

    Citizen.CreateThread(function()
    
        while true do
            Wait(6 * 60 * 60 * 1000) -- 6 hours
            TriggerEvent('prx_duty:saveEmployes')
        end
    end)

end

function timeToDisp(m)
	return string.format("%02dh %02dm",math.floor(m/60),math.floor(m%60))
end

function updatePlayer(playerId, time, job, rpName, lastDutyTime)

    if playerDuty[playerId] then
        local identifier = playerDuty[playerId].identifier

        local dutyTime = MySQL.Sync.fetchAll('SELECT dutyTime FROM `prx_duty` WHERE `identifier` = @identifier and job = @job', {
            ['@identifier'] = identifier,
            ['@job'] = job.name
        })

        if dutyTime and dutyTime[1] then
            dutyTime = dutyTime[1].dutyTime

            dutyTime = dutyTime + time

            MySQL.Async.execute('UPDATE `prx_duty` SET dutyTime = @dutyTime, jobGrade = @jobGrade, lastDuty = @lastDuty WHERE identifier = @identifier and job = @job', {
                    ['@identifier'] = identifier,
                    ['@dutyTime'] = dutyTime,
                    ['@job'] = job.name,
                    ['@jobGrade'] = job.gradeRank,
                    ['@lastDuty'] = lastDutyTime
                }
            )

        else

            MySQL.Async.execute('INSERT INTO prx_duty (identifier, dutyTime, job, jobGrade, rpName, lastDuty) VALUES (@identifier, @dutyTime, @job, @jobGrade, @rpName, @lastDuty)', {
                ['@identifier'] = identifier,
                ['@dutyTime'] = time,
                ['@job'] = job.name,
                ['jobGrade'] = job.gradeRank,
                ['@rpName'] = rpName,
                ['@lastDuty'] = lastDutyTime
                }
            )

        end
    end

end

AddEventHandler('prx_duty:saveEmployes', function()
    for l, m in pairs(playerDuty) do
        if playerDuty[l] then
            local name = MySQL.Sync.fetchAll('SELECT firstname, lastname FROM `users` WHERE `identifier` = @identifier', {
                ['@identifier'] = playerDuty[l].identifier
            })

            while not name do
                Wait(10)
            end

            for k, v in pairs(playerDuty[l]) do
                if k ~= 'identifier' then
                    if not v.endTime then
                        v.endTime = os.date("%Y/%m/%d %X")
                    end

                    updatePlayer(l, v.totalTime, v.job, name[1].firstname..' '..name[1].lastname, v.endTime)

                    if SConfig.Webhooks[k] then

                        local report = _U('loyalEmployee')

                        if #v.pauzes > 0 then
                            report = ''
                            for i=1, #v.pauzes do
                                if v.pauzes[i].endTime == 'changeMe' then
                                    v.pauzes[i].endTime = os.date("%Y/%m/%d %X")
                                end
                                report = _U('report', report, i, v.pauzes[i].startTime, v.pauzes[i].endTime)
                            end
                        end

                        local embed = {
                            {
                                ["color"] = 3066993,
                                ["title"] = _U('embedTitle', v.job.label),
                                ["description"] = _U('embedDescription', name[1].firstname..' '..name[1].lastname, report, timeToDisp(v.totalTime), v.startTime..' | '..v.endTime, v.job.label..' - '..v.job.grade),
                                ["footer"] = {
                                    ["text"] = 'Prx Duty System by Proxys',
                                },
                            }
                        }
                        PerformHttpRequest(SConfig.Webhooks[k], function(err, text, headers) end, 'POST', json.encode({username = 'Prx Duty Bot', embeds = embed}), { ['Content-Type'] = 'application/json' })

                    end
                end
            end
        
        end

    end
end)

AddEventHandler('playerDropped', function (reason)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer and playerDuty[xPlayer.identifier] then
        for k, v in pairs(playerDuty[xPlayer.identifier]) do
            if k ~= 'identifier' then
                if not v.endTime then
                    v.endTime = os.date("%Y/%m/%d %X")
                end

                if #v.pauzes > 0 then
                    for i=1, #v.pauzes do
                        if v.pauzes[i].endTime == 'changeMe' then
                            v.pauzes[i].endTime = os.date("%Y/%m/%d %X")
                        end
                    end
                end
            end
        end
    end
end)
