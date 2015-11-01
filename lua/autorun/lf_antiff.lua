if SERVER then


hook.Add("EntityTakeDamage", "LF_AntiFF_Hook",
	function(ent, dmginfo)
		if IsValid(ent) and ent:IsValid() then
			local att = dmginfo:GetAttacker()
			if IsValid(att) and att:IsValid() then
				
				
				if ent:IsNPC() then
					if att:IsPlayer() and AntiFF_plytonpc and (
						ent:Disposition(att) == D_LI
						or ( ent:Disposition(att) == D_NU and AntiFF_rel_n )
						or ( ent:Disposition(att) == D_FR and AntiFF_rel_f )
					)
					then
						dmginfo:SetDamage(0)
					
					elseif att:IsNPC() and AntiFF_npctonpc and (
						att:Disposition(ent) == D_LI
						or ( att:Disposition(ent) == D_NU and AntiFF_rel_n )
						or ( att:Disposition(ent) == D_FR and AntiFF_rel_f )
					)
					then
						if ent != att or AntiFF_npctoself then
							dmginfo:SetDamage(0)
						end
					
					end
				
				
				elseif AntiFF_prop_d and ( att:IsPlayer() or att:IsNPC() ) and not ( ent:IsPlayer() ) then
					dmginfo:SetDamage(0)
					if AntiFF_prop_f then dmginfo:SetDamageForce(Vector(0,0,0)) end
				
				
				end
			end
		end
	end
)

function AntiFF_Setup()
	AntiFF_plytonpc = GetConVar("npc_antiff_player"):GetBool()
	AntiFF_npctonpc = GetConVar("npc_antiff_npc"):GetBool()
	
	AntiFF_npctoself = GetConVar("npc_antiff_npc_selfdmg"):GetBool()
	
	AntiFF_rel_n = GetConVar("npc_antiFF_rel_neutral"):GetBool()
	AntiFF_rel_f = GetConVar("npc_antiFF_rel_fear"):GetBool()
	
	AntiFF_prop_d = GetConVar("npc_antiff_prop"):GetBool()
	AntiFF_prop_f = GetConVar("npc_antiff_prop_force"):GetBool()
end

CreateConVar( "npc_antiff_player", 1, FCVAR_ARCHIVE )
CreateConVar( "npc_antiff_npc", 1, FCVAR_ARCHIVE )
CreateConVar( "npc_antiff_npc_selfdmg", 0, FCVAR_ARCHIVE )
CreateConVar( "npc_antiFF_rel_neutral", 1, FCVAR_ARCHIVE )
CreateConVar( "npc_antiFF_rel_fear", 1, FCVAR_ARCHIVE )
CreateConVar( "npc_antiff_prop", 0, FCVAR_ARCHIVE )
CreateConVar( "npc_antiff_prop_force", 0, FCVAR_ARCHIVE )

cvars.AddChangeCallback( "npc_antiff_player", AntiFF_Setup )
cvars.AddChangeCallback( "npc_antiff_npc", AntiFF_Setup )
cvars.AddChangeCallback( "npc_antiff_npc_selfdmg", AntiFF_Setup )
cvars.AddChangeCallback( "npc_antiFF_rel_neutral", AntiFF_Setup )
cvars.AddChangeCallback( "npc_antiFF_rel_fear", AntiFF_Setup )
cvars.AddChangeCallback( "npc_antiff_prop", AntiFF_Setup )
cvars.AddChangeCallback( "npc_antiff_prop_force", AntiFF_Setup )

AntiFF_Setup()


end


if CLIENT then


local function LF_AntiFF_Menu( panel )
	if LocalPlayer():IsSuperAdmin() then
		
		panel:AddControl("Label", {Text = "Enable / Disable for yourself and other NPCs:"})
		panel:AddControl("Label", {Text = " "})
		panel:AddControl("Checkbox", {Label = "Enable Player -> NPC", Command = "npc_antiff_player"})
		panel:AddControl("Label", {Text = "Players can no longer hurt NPCs that are friendly towards them (see additional conditions below)."})
		panel:AddControl("Checkbox", {Label = "Enable NPC -> NPC", Command = "npc_antiff_npc"})
		panel:AddControl("Label", {Text = "NPCs can no longer hurt NPCs that are friendly towards them (see additional conditions below)."})
		panel:AddControl("Label", {Text = " "})
		panel:AddControl("Label", {Text = " "})
		panel:AddControl("Label", {Text = "Relationship Options:"})
		panel:AddControl("Label", {Text = "All settings apply to players and NPCs. Please note, that you won't encounter neutral or scared NPCs in GMod by default. However, you may encounter them on maps and there are also addons that allow you to modify relationships."})
		panel:AddControl("Label", {Text = " "})
		panel:AddControl("Checkbox", {Label = "No damage to NPCs with neutral relationship", Command = "npc_antiFF_rel_neutral"})
		panel:AddControl("Label", {Text = "\"I don't hurt you, you don't hurt me. Let's just ignore each other.\""})
		panel:AddControl("Checkbox", {Label = "No damage to NPCs with fear relationship", Command = "npc_antiFF_rel_fear"})
		panel:AddControl("Label", {Text = "\"Let's not hurt that poor guy running away from you, okay?\""})
		panel:AddControl("Label", {Text = " "})
		panel:AddControl("Label", {Text = " "})
		panel:AddControl("Label", {Text = "Additional Options:"})
		panel:AddControl("Label", {Text = "Changing this settings may have unwanted side effects (Zombines not blowing themself up; unable to finish maps that require breaking stuff; etc.)"})
		panel:AddControl("Label", {Text = " "})
		panel:AddControl("Checkbox", {Label = "NPCs can't hurt themself", Command = "npc_antiff_npc_selfdmg"})
		panel:AddControl("Label", {Text = "\"Did that Zombine just survived blowing itself up?!\""})
		panel:AddControl("Checkbox", {Label = "No damage to props", Command = "npc_antiff_prop"})
		panel:AddControl("Label", {Text = "\"My insurance will terminate my contract, if I break anymore things. Let's be more careful.\""})
		panel:AddControl("Checkbox", {Label = "No physical force to props (requires no damage)", Command = "npc_antiff_prop_force"})
		panel:AddControl("Label", {Text = "\"Although that crate didn't broke, it was thrown over my neighbor's fence again.\""})
		
	else
	
		panel:AddControl("Label", {Text = " "})
		panel:AddControl("Label", {Text = "Only Super-Admins can change this settings."})
	
	end
end

hook.Add( "PopulateToolMenu", "LF_AntiFF_Menu_Hook", function() spawnmenu.AddToolMenuOption( "Options", "NPCs", "LF_AntiFF_MenuItem", "Anti-FriendlyFire", "", "", LF_AntiFF_Menu, {} ) end )


end