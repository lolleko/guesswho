local GWRound = {}

GM.GWRound = GWRound

hook.Add("InitPostEntity", "gw_InitPostEntity", function()
    GAMEMODE.GWRound:UpdateSettings()
    GAMEMODE.GWRound:RoundPreGame()
    GAMEMODE.GWRound.GeneratedSpawnPointCount = 0
end)

function GWRound:RoundPreGame()
    self:SetRoundState(GW_ROUND_PRE_GAME)
    hook.Run("GWPreGame")
    self:SetEndTime(CurTime() + self.PreGameDuration)
    timer.Create("gwPreGameTimer", self.PreGameDuration, 1,
                 function() self:RoundWaitForPlayers() end)
    timer.Simple(1, function() self:MeshController() end)
end

function GWRound:RoundWaitForPlayers()
    -- do not start round without players or at least one player in each team
    if team.NumPlayers(GW_TEAM_HIDING) < self.MinHiding or
        team.NumPlayers(GW_TEAM_SEEKING) < self.MinSeeking then
        -- check again after half a second second
        timer.Simple(0.5, function() self:RoundWaitForPlayers() end)
        -- clear remaning npcs to save recources
        for k, v in pairs(ents.FindByClass(GW_WALKER_CLASS)) do v:Remove() end
        self:SetEndTime(CurTime() + 1)
        self:SetRoundState(GW_ROUND_WAITING_PLAYERS)
        return
    end

    self:RoundCreateWalkers()

end

function GWRound:RoundCreateWalkers()

    self:SetRoundState(GW_ROUND_CREATING_NPCS)
    hook.Run("GWCreating")

    self:UpdateSpawnPoints()

    local wave = 1
    local playerCount = player.GetCount()

    self.WalkerCount = 0
    self.MaxWalkers = self.BaseWalkers + (playerCount * self.WalkerPerPly)

    if #self.SpawnPoints > self.MaxWalkers then
        self:SpawnNPCWave()
        MsgN("GW Spawned ", self.WalkerCount, " NPCs in 1 wave.")
    else
        local wpw
        for w = 0, math.floor(self.MaxWalkers / #self.SpawnPoints) - 1, 1 do
            wave = wave + 1
            timer.Simple(w * 5, function()
                wpw = self.WalkerCount
                self:SpawnNPCWave()
                MsgN("GW Spawned ", self.WalkerCount - wpw, " NPCs in wave ",
                     w + 1, ".")
            end)
        end
        wave = wave - 1
    end

    timer.Simple(5 * wave, function()
        self:SetRoundState(GW_ROUND_HIDE)
        hook.Run("GWHide")
        for _, v in pairs(team.GetPlayers(GW_TEAM_HIDING)) do v:Spawn() end
    end)

    timer.Simple(5 + (5 * wave), function()
        for _, v in pairs(team.GetPlayers(GW_TEAM_SEEKING)) do
            v:Spawn()
            v:SetPos(v:GetPos() + Vector(2, 2, 2)) -- move them a little bit to make avoid players work
            v:Freeze(true)
            v:GodEnable()
            v:SetAvoidPlayers(true)
        end
    end)
    timer.Simple(self.HideDuration + (5 * wave),
                 function() self:RoundStart() end)
    self:SetEndTime(CurTime() + self.HideDuration + (5 * wave))

    PrintMessage(HUD_PRINTTALK,
                 "Map will change in " .. self.MaxRounds -
                     GetGlobalInt("RoundNumber", 0) .. " rounds.")
end

function GWRound:RoundStart()
    for _, v in pairs(team.GetPlayers(GW_TEAM_SEEKING)) do
        v:Freeze(false)
        v:SetAvoidPlayers(false)
        v:GodDisable()
    end

    timer.Create("RoundThink", 1, self.RoundDuration,
                 function() self:RoundThink() end)
    self.RoundTime = 1
    self:SetEndTime(CurTime() + self.RoundDuration)
    SetGlobalInt("RoundNumber", GetGlobalInt("RoundNumber", 0) + 1)

    self:SetRoundState(GW_ROUND_SEEK)
    hook.Run("GWSeek")
end

-- will be called every second
function GWRound:RoundThink()
    -- end conditions
    self.RoundTime = self.RoundTime + 1

    if self.RoundTime == self.RoundDuration then self:RoundEnd(false) end

    if team.NumPlayers(GW_TEAM_HIDING) < self.MinHiding or
        team.NumPlayers(GW_TEAM_SEEKING) < self.MinSeeking then self:RoundEnd() end

    local seekersWin = true
    for k, v in pairs(team.GetPlayers(GW_TEAM_HIDING)) do
        if v:Alive() then seekersWin = false end
    end

    local hidingWin = true
    for k, v in pairs(team.GetPlayers(GW_TEAM_SEEKING)) do
        if v:Alive() then hidingWin = false end
    end

    if seekersWin then self:RoundEnd(true) end

    if hidingWin then self:RoundEnd(false) end
end

function GWRound:RoundEnd(caught)
    hook.Run("GWOnRoundEnd", caught)

    if timer.Exists("RoundThink") then timer.Remove("RoundThink") end
    -- choose winner and stuff

    local postRoundDelay = 8

    if caught then
        GWNotifications:Add("gwVictory" .. team.GetName(GW_TEAM_SEEKING), "<font=gw_font_normal>" .. team.GetName(GW_TEAM_SEEKING) .. " Victory" .. "</font>", "", postRoundDelay)
        for k, v in pairs(team.GetPlayers(GW_TEAM_SEEKING)) do
            v:GWPlayTauntOnClients(ACT_GMOD_TAUNT_CHEER)
        end
        team.AddScore(GW_TEAM_SEEKING, 1)
    else
        GWNotifications:Add("gwVictory" .. team.GetName(GW_TEAM_HIDING), "<font=gw_font_normal>" .. team.GetName(GW_TEAM_HIDING) .. " Victory" .. "</font>", "", postRoundDelay)
        for k, v in pairs(team.GetPlayers(GW_TEAM_HIDING)) do
            v:GWPlayTauntOnClients(ACT_GMOD_TAUNT_CHEER)
            -- reset reroll protections and funcs
            v:SetGWDiedInPrep(false)
            v:SetGWReRolledAbility(false)
            if v:Alive() then v:AddFrags(1) end -- if still alive as hiding after round give them one point (frag)
        end
        team.AddScore(GW_TEAM_HIDING, 1)
    end
    timer.Create("gwPostRoundDelayTimer", postRoundDelay, 1, function() self:PostRound() end)
end

function GWRound:PostRound()

    if GetGlobalInt("RoundNumber", 0) >= self.MaxRounds then
        MsgN("GW Round cap reached changing map..")
        if MapVote then
            MsgN("GW Mapvote detected starting vote!")
            MapVote.Start()
            return
        end
        game.LoadNextMap()
    end

    -- cleanup everythiung except generated spawn points
    game.CleanUpMap(false, {"info_player_start"})

    for _, walker in pairs(ents.FindByClass(GW_WALKER_CLASS)) do walker:Remove() end

    -- Remove some HL2 entities
    local hl2EntClasses = {
        "weapon_357",
        "weapon_pistol",
        "weapon_bugbait",
        "weapon_crossbow",
        "weapon_crowbar",
        "weapon_frag",
        "weapon_physcannon",
        "weapon_ar2",
        "weapon_rpg",
        "weapon_slam",
        "weapon_shotgun",
        "weapon_smg1",
        "weapon_stunstick"
    }

    for _, hl2EntClass in pairs(hl2EntClasses) do
        for _, hl2Ent in pairs(ents.FindByClass(hl2EntClass)) do hl2Ent:Remove() end
    end

    timer.Simple(self.PostRoundDuration,
                 function() self:RoundWaitForPlayers() end)
    self:SetEndTime(CurTime() + self.PostRoundDuration)
    self:SetRoundState(GW_ROUND_POST)
    hook.Run("GWPostRound")

    self:UpdateSettings()

    -- teamswap
    for _, v in pairs(player.GetAll()) do
        if v:Team() == GW_TEAM_SEEKING then
            v:SetTeam(GW_TEAM_HIDING)
        elseif v:Team() == GW_TEAM_HIDING then
            v:SetTeam(GW_TEAM_SEEKING)
        end
        v:KillSilent()
    end

end

function GWRound:SpawnNPCWave()

    for _, v in pairs(self.SpawnPoints) do
        if self.WalkerCount == self.MaxWalkers then break end

        local occupied = false
        for _, ent in pairs(ents.FindInBox(v:GetPos() + Vector(-16, -16, 0),
                                           v:GetPos() + Vector(16, 16, 64))) do
            if ent:GetClass() == GW_WALKER_CLASS then occupied = true end
        end

        if not occupied then
            local walker = ents.Create(GW_WALKER_CLASS)
            if not IsValid(walker) then break end
            walker:SetPos(v:GetPos())
            walker:Spawn()
            walker:Activate()
            self.WalkerCount = self.WalkerCount + 1
        end

    end

end

function GWRound:UpdateSettings()

    self.BaseWalkers = GetConVar("gw_basewalkeramount"):GetInt()
    self.WalkerPerPly = GetConVar("gw_walkerperplayer"):GetInt()
    self.PreGameDuration = GetConVar("gw_pregameduration"):GetInt()
    self.RoundDuration = GetConVar("gw_roundduration"):GetInt()
    self.HideDuration = GetConVar("gw_hideduration"):GetInt()
    self.PostRoundDuration = GetConVar("gw_postroundduration"):GetInt()
    self.MaxRounds = GetConVar("gw_maxrounds"):GetInt()
    self.MinHiding = GetConVar("gw_minhiding"):GetInt()
    self.MinSeeking = GetConVar("gw_minseeking"):GetInt()

end

function GWRound:MeshController()
    if navmesh.IsLoaded() then
        MsgN("GW Navmesh loaded waiting for game to start.")
    else
        timer.Remove("gwPreGameTimer")
        self:SetRoundState(GW_ROUND_NAV_GEN)
        navmesh.BeginGeneration()
        -- force generate
        if not navmesh.IsGenerating() then
            self:UpdateSpawnPoints()

            local tr = util.TraceLine({
                start = self.SpawnPoints[1]:GetPos(),
                endpos = self.SpawnPoints[1]:GetPos() - Vector(0, 0, 100),
                filter = self.SpawnPoints[1]
            })

            local ent = ents.Create("info_player_start")
            ent:SetPos(tr.HitPos)
            ent:Spawn()
            navmesh.BeginGeneration()
        end

        if not navmesh.IsGenerating() then
            PrintMessage(HUD_PRINTCENTER,
                         "Guess Who Navmesh generation failed, try to reload the map a few times.\nIf it still fails try a diffrent map!")
        else
            timer.Create("gwNavmeshGen", 1, 0, function()
                print(self:GetRoundState())
                PrintMessage(HUD_PRINTCENTER,
                             "Generating navmesh, this will take some time!\nUp to 10min (worst case) depending on map size and your system.\nYou will only need to do this once.")
            end)
        end
    end
end

function GWRound:UpdateSpawnPoints()
    if (not self.SpawnPoints or not IsTableOfEntitiesValid(self.SpawnPoints)) then

        self.LastSpawnPoint = 0
        self.SpawnPoints = ents.FindByClass("info_player_start")
        self.SpawnPoints = table.Add(self.SpawnPoints,
                                     ents.FindByClass("info_player_deathmatch"))
        self.SpawnPoints = table.Add(self.SpawnPoints,
                                     ents.FindByClass("info_player_combine"))
        self.SpawnPoints = table.Add(self.SpawnPoints,
                                     ents.FindByClass("info_player_rebel"))

        -- CS Maps
        self.SpawnPoints = table.Add(self.SpawnPoints, ents.FindByClass(
                                         "info_player_counterterrorist"))
        self.SpawnPoints = table.Add(self.SpawnPoints,
                                     ents.FindByClass("info_player_terrorist"))

        -- DOD Maps
        self.SpawnPoints = table.Add(self.SpawnPoints,
                                     ents.FindByClass("info_player_axis"))
        self.SpawnPoints = table.Add(self.SpawnPoints,
                                     ents.FindByClass("info_player_allies"))

        -- (Old) GMod Maps
        self.SpawnPoints = table.Add(self.SpawnPoints,
                                     ents.FindByClass("gmod_player_start"))

        -- TF Maps
        self.SpawnPoints = table.Add(self.SpawnPoints,
                                     ents.FindByClass("info_player_teamspawn"))

        -- INS Maps
        self.SpawnPoints = table.Add(self.SpawnPoints,
                                     ents.FindByClass("ins_spawnpoint"))

        -- AOC Maps
        self.SpawnPoints = table.Add(self.SpawnPoints,
                                     ents.FindByClass("aoc_spawnpoint"))

        -- Dystopia Maps
        self.SpawnPoints = table.Add(self.SpawnPoints,
                                     ents.FindByClass("dys_spawn_point"))

        -- PVKII Maps
        self.SpawnPoints = table.Add(self.SpawnPoints,
                                     ents.FindByClass("info_player_pirate"))
        self.SpawnPoints = table.Add(self.SpawnPoints,
                                     ents.FindByClass("info_player_viking"))
        self.SpawnPoints = table.Add(self.SpawnPoints,
                                     ents.FindByClass("info_player_knight"))

        -- DIPRIP Maps
        self.SpawnPoints = table.Add(self.SpawnPoints,
                                     ents.FindByClass("diprip_start_team_blue"))
        self.SpawnPoints = table.Add(self.SpawnPoints,
                                     ents.FindByClass("diprip_start_team_red"))

        -- OB Maps
        self.SpawnPoints = table.Add(self.SpawnPoints,
                                     ents.FindByClass("info_player_red"))
        self.SpawnPoints = table.Add(self.SpawnPoints,
                                     ents.FindByClass("info_player_blue"))

        -- SYN Maps
        self.SpawnPoints = table.Add(self.SpawnPoints,
                                     ents.FindByClass("info_player_coop"))

        -- ZPS Maps
        self.SpawnPoints = table.Add(self.SpawnPoints,
                                     ents.FindByClass("info_player_human"))
        self.SpawnPoints = table.Add(self.SpawnPoints,
                                     ents.FindByClass("info_player_zombie"))

        -- ZM Maps
        self.SpawnPoints = table.Add(self.SpawnPoints,
                                     ents.FindByClass("info_player_deathmatch"))
        self.SpawnPoints = table.Add(self.SpawnPoints, ents.FindByClass(
                                         "info_player_zombiemaster"))

    end

     -- try to create more spawnpoints if we dont have enough
     if #self.SpawnPoints < 5 then
        local locations = {
            Vector(48, 0, 2),
            Vector(-48, 0, 2),
            Vector(0, 48, 2),
            Vector(0, -48, 2),
            Vector(48, 48, 2),
            Vector(48, -48, 2),
            Vector(-48, 48, 2),
            Vector(-48, -48, 2),
            Vector(96, 0, 2),
            Vector(-96, 0, 2),
            Vector(0, 96, 2),
            Vector(0, -96, 2),
            Vector(96, 96, 2),
            Vector(96, -96, 2),
            Vector(-96, 96, 2),
            Vector(-96, -96, 2),
        }

        for _, spawnPoint in pairs(self.SpawnPoints) do
            for _, locationOffset in pairs(locations) do
                local location = spawnPoint:GetPos() + locationOffset

                local tr = util.TraceHull({
                    start = location,
                    endpos = location,
                    maxs = Vector(16, 16, 70),
                    mins = Vector(-16, -16, 0),
                })

                if self.GeneratedSpawnPointCount < 16 and not tr.Hit then
                    local newSpawnPoint = ents.Create("info_player_start")
                    if not IsValid(newSpawnPoint) then break end
                    newSpawnPoint:SetPos(location)
                    newSpawnPoint:Spawn()
                    newSpawnPoint:Activate()
                    table.insert(self.SpawnPoints, newSpawnPoint)
                    self.GeneratedSpawnPointCount = self.GeneratedSpawnPointCount + 1
                end

            end
        end
    end

    local rand = math.random
    local n = #self.SpawnPoints

    while n > 2 do

        local k = rand(n) -- 1 <= k <= n

        self.SpawnPoints[n], self.SpawnPoints[k] = self.SpawnPoints[k],
                                                   self.SpawnPoints[n]
        n = n - 1
    end
end

function GWRound:SetRoundState(state)

    self.RoundState = state

    self:SendRoundState(state)

end

function GWRound:GetRoundState() return self.RoundState end

function GWRound:IsCurrentState(state) return self.RoundState == state end

function GWRound:SendRoundState(state, ply)

    net.Start("gwRoundState")
    net.WriteUInt(state, 8)
    return ply and net.Send(ply) or net.Broadcast()

end

function GWRound:SetEndTime(time) SetGlobalFloat("gwEndTime", time) end
