Config = {}
Config.Locale = 'en' -- Language [en / cs / de]
Config.DrawDistance = 1.5 -- Distance from which will be the point visible
Config.AllowReportInEveryWhere = false -- If players can use /duty command everywhere on the map

Config.Points = { -- Locations where the players will be able to go on/off duty


-- Examples:
    -- {
        -- Loc = vector3(450.1802,-987.6061,30.6896),
        -- Jobs = { -- List of jobs that can use this point
            -- ['police'] = true, -- Police officers can use this point
            -- ['offpolice'] = true -- Police officers off duty can use this point
        -- }
    -- },

    -- {
        -- Loc = vector3(312.3144,-597.6319,43.2842),
        -- Jobs = {
            -- ['ambulance'] = true,
            -- ['offambulance'] = true
        -- }
    -- }

}

Config.TrackedJobs = { -- Time of players with these jobs will be counted to the database + Discord daily report
    ['police'] = true,
    ['ambulance'] = true
}

Config.SpecialJobs = { -- List of jobs that will go to other job
    ['mafia'] = 'ballas' -- For example, if you are mafia, you will go to ballas if this is enabled
}