if SERVER then

hook.Add("EntityTakeDamage", "LibertyForce.AntiFriendlyFire",
	function(ent, dmginfo)
		if IsValid(ent) and ent:IsValid() then
			local att = dmginfo:GetAttacker()
			if IsValid(att) and att:IsValid() then
				if ent:IsNPC() then
					if att:IsPlayer() and AntiFF_plytonpc == 1
					and ( ent:Disposition(att) == 3 or ( ent:Disposition(att) == 4 and AntiFF_neutral == 1 ) )
					then
						dmginfo:SetDamage(0)
					elseif att:IsNPC() and AntiFF_npctonpc == 1
					and ( att:Disposition(ent) == 3 or ( att:Disposition(ent) == 4 and AntiFF_neutral == 1 ) )
					then
						if ent != att or AntiFF_npctoself == 1 then
							dmginfo:SetDamage(0)
						end
					end
				elseif ( AntiFF_prop == 1 or AntiFF_prop == 2 ) and ( att:IsPlayer() or att:IsNPC() ) and not ( ent:IsPlayer() ) then
					dmginfo:SetDamage(0)
					if AntiFF_prop == 2 then dmginfo:SetDamageForce(Vector(0,0,0)) end
				end
			end
		end
	end
)

function AntiFF_Setup()
	AntiFF_plytonpc = GetConVarNumber("npc_antiff_player")
	AntiFF_npctonpc = GetConVarNumber("npc_antiff_npc")
	AntiFF_npctoself = GetConVarNumber("npc_antiff_self")
	AntiFF_neutral = GetConVarNumber("npc_antiff_neutral")
	AntiFF_prop = GetConVarNumber("npc_antiff_prop")
end

CreateConVar( "npc_antiff_player", 1, FCVAR_ARCHIVE )
CreateConVar( "npc_antiff_npc", 1, FCVAR_ARCHIVE )
CreateConVar( "npc_antiff_self", 0, FCVAR_ARCHIVE )
CreateConVar( "npc_antiff_neutral", 1, FCVAR_ARCHIVE )
CreateConVar( "npc_antiff_prop", 0, FCVAR_ARCHIVE )

cvars.AddChangeCallback( "npc_antiff_player", AntiFF_Setup )
cvars.AddChangeCallback( "npc_antiff_npc", AntiFF_Setup )
cvars.AddChangeCallback( "npc_antiff_self", AntiFF_Setup )
cvars.AddChangeCallback( "npc_antiff_neutral", AntiFF_Setup )
cvars.AddChangeCallback( "npc_antiff_prop", AntiFF_Setup )

AntiFF_Setup()

end