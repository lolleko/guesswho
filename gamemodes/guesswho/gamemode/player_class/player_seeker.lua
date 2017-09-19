DEFINE_BASECLASS( "player_default" )

local PLAYER = {}

PLAYER.WalkSpeed = GetConVar("gw_seeker_walk_speed"):GetFloat()
PLAYER.RunSpeed = GetConVar("gw_seeker_run_speed"):GetFloat()
PLAYER.JumpPower = 250
PLAYER.CanUseFlashlight = true

function PLAYER:SetModel()

    local model = GAMEMODE.SeekerModel

    if GetConVar( "gw_disguise_seeker" ):GetBool() then
        local models = GAMEMODE.GWConfig.HidingModels

        local rand = math.random(1, #models)

        model = models[rand]
    else

        model = GAMEMODE.GWConfig.SeekerModels[ math.random( 1, #GAMEMODE.GWConfig.SeekerModels ) ]

    end

    util.PrecacheModel( model )
    self.Player:SetModel( model )

end

function PLAYER:Loadout()
    self.Player:Give( "weapon_gw_seeker_crowbar" )
    self.Player:Give( "weapon_smg1" )
    self.Player:GiveAmmo( 200, "smg1", true )
    self.Player:GiveAmmo( 1, "smg1_grenade", true )
end

--Double jump script originally created by Willox (unlicensed) modified by me
--[[local plyMeta = FindMetaTable("Player")


AccessorFunc(plyMeta, "gwDoubleJump", "DoubleJumped", FORCE_BOOL)

local function GetMoveVector( mv )

    local ang = mv:GetAngles()

    local max_speed = mv:GetMaxSpeed() * 2

    local forward = math.Clamp( mv:GetForwardSpeed(), - max_speed, max_speed )
    local side = math.Clamp( mv:GetSideSpeed(), - max_speed, max_speed )

    local abs_xy_move = math.abs( forward ) + math.abs( side )

    if abs_xy_move == 0 then

        return Vector( 0, 0, 0 )

    end

    local mul = max_speed / abs_xy_move

    local vec = Vector()

    vec:Add( ang:Forward() * forward )
    vec:Add( ang:Right() * side )

    vec:Mul( mul )

    return vec

end

function PLAYER:StartMove( mv, cmd )

    if self.Player:OnGround() then

        self.Player:SetDoubleJumped( false )

        return

    end

    if not mv:KeyPressed( IN_JUMP ) then

        return

    end

    if self.Player:GetDoubleJumped() then

        return

    end

    self.Player:SetDoubleJumped( true )

    local vel = GetMoveVector( mv )

    vel.z = self.Player:GetJumpPower()

    mv:SetVelocity( vel )

    self.Player:DoCustomAnimEvent( PLAYERANIMEVENT_JUMP, - 1 )

end--]]

player_manager.RegisterClass( "player_seeker", PLAYER, "player_default" )
