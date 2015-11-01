AddCSLuaFile()

CreateConVar( "npc_antiff_player", 1, { FCVAR_ARCHIVE, FCVAR_REPLICATED } )
CreateConVar( "npc_antiff_npc", 1, { FCVAR_ARCHIVE, FCVAR_REPLICATED } )
CreateConVar( "npc_antiff_npc_selfdmg", 0, { FCVAR_ARCHIVE, FCVAR_REPLICATED } )
CreateConVar( "npc_antiff_rel_neutral", 1, { FCVAR_ARCHIVE, FCVAR_REPLICATED } )
CreateConVar( "npc_antiff_rel_fear", 1, { FCVAR_ARCHIVE, FCVAR_REPLICATED } )
CreateConVar( "npc_antiff_prop", 0, { FCVAR_ARCHIVE, FCVAR_REPLICATED } )
CreateConVar( "npc_antiff_prop_force", 0, { FCVAR_ARCHIVE, FCVAR_REPLICATED } )


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
	
	AntiFF_rel_n = GetConVar("npc_antiff_rel_neutral"):GetBool()
	AntiFF_rel_f = GetConVar("npc_antiff_rel_fear"):GetBool()
	
	AntiFF_prop_d = GetConVar("npc_antiff_prop"):GetBool()
	AntiFF_prop_f = GetConVar("npc_antiff_prop_force"):GetBool()
end

cvars.AddChangeCallback( "npc_antiff_player", AntiFF_Setup )
cvars.AddChangeCallback( "npc_antiff_npc", AntiFF_Setup )
cvars.AddChangeCallback( "npc_antiff_npc_selfdmg", AntiFF_Setup )
cvars.AddChangeCallback( "npc_antiff_rel_neutral", AntiFF_Setup )
cvars.AddChangeCallback( "npc_antiff_rel_fear", AntiFF_Setup )
cvars.AddChangeCallback( "npc_antiff_prop", AntiFF_Setup )
cvars.AddChangeCallback( "npc_antiff_prop_force", AntiFF_Setup )


util.AddNetworkString("npc_antiff_player")
util.AddNetworkString("npc_antiff_npc")
util.AddNetworkString("npc_antiff_npc_selfdmg")
util.AddNetworkString("npc_antiff_rel_neutral")
util.AddNetworkString("npc_antiff_rel_fear")
util.AddNetworkString("npc_antiff_prop")
util.AddNetworkString("npc_antiff_prop_force")

net.Receive("npc_antiff_player", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("npc_antiff_player", net.ReadFloat())
	end
end)
net.Receive("npc_antiff_npc", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("npc_antiff_npc", net.ReadFloat())
	end
end)
net.Receive("npc_antiff_npc_selfdmg", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("npc_antiff_npc_selfdmg", net.ReadFloat())
	end
end)
net.Receive("npc_antiff_rel_neutral", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("npc_antiff_rel_neutral", net.ReadFloat())
	end
end)
net.Receive("npc_antiff_rel_fear", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("npc_antiff_rel_fear", net.ReadFloat())
	end
end)
net.Receive("npc_antiff_prop", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("npc_antiff_prop", net.ReadFloat())
	end
end)
net.Receive("npc_antiff_prop_force", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("npc_antiff_prop_force", net.ReadFloat())
	end
end)


AntiFF_Setup()


end


if CLIENT then


local function LF_AntiFF_Menu( panel )
	if LocalPlayer():IsSuperAdmin() then
		
		panel:AddControl("Label", {Text = "Enable / Disable for yourself and other NPCs:"})
		panel:AddControl("Label", {Text = " "})
		
		local p = panel:AddControl("Checkbox", {Label = "Enable Player -> NPC"})
		p:SetValue( GetConVar("npc_antiff_player"):GetInt() )
		p.OnChange = function(self)
			net.Start("npc_antiff_player")
			net.WriteFloat(self:GetChecked()==true and 1 or 0)
			net.SendToServer()	
		end
		
		panel:AddControl("Label", {Text = "Players can no longer hurt NPCs that are friendly towards them (see additional conditions below)."})
		
		local p = panel:AddControl("Checkbox", {Label = "Enable NPC -> NPC"})
		p:SetValue( GetConVar("npc_antiff_npc"):GetInt() )
		p.OnChange = function(self)
			net.Start("npc_antiff_npc")
			net.WriteFloat(self:GetChecked()==true and 1 or 0)
			net.SendToServer()	
		end
		
		panel:AddControl("Label", {Text = "NPCs can no longer hurt NPCs that are friendly towards them (see additional conditions below)."})
		panel:AddControl("Label", {Text = " "})
		panel:AddControl("Label", {Text = " "})
		panel:AddControl("Label", {Text = "Relationship Options:"})
		panel:AddControl("Label", {Text = "All settings apply to players and NPCs. Please note, that you won't encounter neutral or scared NPCs in GMod by default. However, you may encounter them on maps and there are also addons that allow you to modify relationships."})
		panel:AddControl("Label", {Text = " "})
		
		local p = panel:AddControl("Checkbox", {Label = "No damage to NPCs with neutral relationship"})
		p:SetValue( GetConVar("npc_antiff_rel_neutral"):GetInt() )
		p.OnChange = function(self)
			net.Start("npc_antiff_rel_neutral")
			net.WriteFloat(self:GetChecked()==true and 1 or 0)
			net.SendToServer()	
		end
		
		panel:AddControl("Label", {Text = "\"I don't hurt you, you don't hurt me. Let's just ignore each other.\""})
		
		local p = panel:AddControl("Checkbox", {Label = "No damage to NPCs with fear relationship"})
		p:SetValue( GetConVar("npc_antiff_rel_fear"):GetInt() )
		p.OnChange = function(self)
			net.Start("npc_antiff_rel_fear")
			net.WriteFloat(self:GetChecked()==true and 1 or 0)
			net.SendToServer()	
		end
		
		panel:AddControl("Label", {Text = "\"Let's not hurt that poor guy running away from you, okay?\""})
		panel:AddControl("Label", {Text = " "})
		panel:AddControl("Label", {Text = " "})
		panel:AddControl("Label", {Text = "Additional Options:"})
		panel:AddControl("Label", {Text = "Changing this settings may have unwanted side effects (Zombines not blowing themself up; unable to finish maps that require breaking stuff; etc.)"})
		panel:AddControl("Label", {Text = " "})
		
		local p = panel:AddControl("Checkbox", {Label = "NPCs can't hurt themself"})
		p:SetValue( GetConVar("npc_antiff_npc_selfdmg"):GetInt() )
		p.OnChange = function(self)
			net.Start("npc_antiff_npc_selfdmg")
			net.WriteFloat(self:GetChecked()==true and 1 or 0)
			net.SendToServer()	
		end
		
		panel:AddControl("Label", {Text = "\"Did that Zombine just survived blowing itself up?!\""})
		
		local p = panel:AddControl("Checkbox", {Label = "No damage to props"})
		p:SetValue( GetConVar("npc_antiff_prop"):GetInt() )
		p.OnChange = function(self)
			net.Start("npc_antiff_prop")
			net.WriteFloat(self:GetChecked()==true and 1 or 0)
			net.SendToServer()	
		end
		
		panel:AddControl("Label", {Text = "\"My insurance will terminate my contract, if I break anymore things. Let's be more careful.\""})
		
		local p = panel:AddControl("Checkbox", {Label = "No physical force to props (requires no damage)"})
		p:SetValue( GetConVar("npc_antiff_prop_force"):GetInt() )
		p.OnChange = function(self)
			net.Start("npc_antiff_prop_force")
			net.WriteFloat(self:GetChecked()==true and 1 or 0)
			net.SendToServer()	
		end
		
		panel:AddControl("Label", {Text = "\"Although that crate didn't broke, it was thrown over my neighbor's fence again.\""})
		
	else
	
		panel:AddControl("Label", {Text = " "})
		panel:AddControl("Label", {Text = "Only Super-Admins can change this settings."})
	
	end
end

hook.Add( "PopulateToolMenu", "LF_AntiFF_Menu_Hook", function() spawnmenu.AddToolMenuOption( "Options", "NPCs", "LF_AntiFF_MenuItem", "Anti-FriendlyFire", "", "", LF_AntiFF_Menu, {} ) end )


end