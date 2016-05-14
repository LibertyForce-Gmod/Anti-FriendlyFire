if SERVER then

AddCSLuaFile()

local AntiFF = {}

local convars = { }
convars["npc_antiff_player"]			= { 1, bit.bor( FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY ) }
convars["npc_antiff_npc"]				= { 1, bit.bor( FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY ) }
convars["npc_antiff_npc_invallies"]		= { 0, bit.bor( FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY ) }
convars["npc_antiff_npc_selfdmg"]		= { 0, bit.bor( FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY ) }
convars["npc_antiff_rel_neutral"]		= { 0, bit.bor( FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY ) }
convars["npc_antiff_rel_fear"]			= { 0, bit.bor( FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY ) }
convars["npc_antiff_prop"]				= { 0, bit.bor( FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY ) }
convars["npc_antiff_prop_force"]		= { 0, bit.bor( FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY ) }
convars["npc_antiff_admins_allowall"]	= { 0, bit.bor( FCVAR_ARCHIVE, FCVAR_REPLICATED ) }

for cvar, v in pairs( convars ) do
	CreateConVar( cvar,	v[1], v[2] )
end


function AntiFF.Main( vic, dmginfo )
	if IsValid(vic) and vic:IsValid() then
		local att = dmginfo:GetAttacker()
		if IsValid(att) and att:IsValid() then
			
			if vic:IsNPC() then
				
				if AntiFF.invallies and vic:Disposition( player.GetHumans()[1] ) == D_LI then
					dmginfo:SetDamage(0)
				else
					
					if att:IsPlayer() and AntiFF.plytonpc and (
						vic:Disposition(att) == D_LI
						or ( vic:Disposition(att) == D_NU and AntiFF.rel_n )
						or ( vic:Disposition(att) == D_FR and AntiFF.rel_f )
					)
					then
						dmginfo:SetDamage(0)
					
					elseif att:IsNPC() and AntiFF.npctonpc and (
						att:Disposition(vic) == D_LI
						or ( att:Disposition(vic) == D_NU and AntiFF.rel_n )
					)
					then
						if vic != att or AntiFF.npctoself then
							dmginfo:SetDamage(0)
						end
					
					end
					
				end
			
			elseif AntiFF.prop_d and ( att:IsPlayer() or att:IsNPC() ) and not ( vic:IsPlayer() ) then
				dmginfo:SetDamage(0)
				if AntiFF.prop_f then dmginfo:SetDamageForce(Vector(0,0,0)) end
			
			end
			
		end
	end
end
hook.Add("EntityTakeDamage", "LF_AntiFF_Hook", AntiFF.Main )



function AntiFF.Setup()
	AntiFF.plytonpc = GetConVar("npc_antiff_player"):GetBool()
	AntiFF.npctonpc = GetConVar("npc_antiff_npc"):GetBool()
	
	AntiFF.invallies = GetConVar("npc_antiff_npc_invallies"):GetBool()
	AntiFF.npctoself = GetConVar("npc_antiff_npc_selfdmg"):GetBool()
	
	AntiFF.rel_n = GetConVar("npc_antiff_rel_neutral"):GetBool()
	AntiFF.rel_f = GetConVar("npc_antiff_rel_fear"):GetBool()
	
	AntiFF.prop_d = GetConVar("npc_antiff_prop"):GetBool()
	AntiFF.prop_f = GetConVar("npc_antiff_prop_force"):GetBool()
end

for cvar in pairs( convars ) do
	cvars.AddChangeCallback( cvar, AntiFF.Setup )
end


util.AddNetworkString("lf_antiff_convar_sync")
util.AddNetworkString("lf_antiff_convar_change")


hook.Add( "PlayerAuthed", "LF_AntiFF_ConVar_Sync", function( ply )
	local tbl = { }
	for cvar in pairs( convars ) do
		tbl[cvar] = GetConVar(cvar):GetInt()
	end
	net.Start("lf_antiff_convar_sync")
	net.WriteTable( tbl )
	net.Send( ply )
end )

net.Receive("lf_antiff_convar_change", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() then
		local cvar = net.ReadString()
		if !convars[cvar] then ply:Kick("Illegal convar change") return end
		if !ply:IsSuperAdmin() and !( GetConVar("npc_antiff_admins_allowall"):GetBool() and ply:IsAdmin() ) then return end
		if !ply:IsSuperAdmin() and cvar == "npc_antiff_admins_allowall" then return end
		RunConsoleCommand( cvar, net.ReadBool() == true and "1" or "0" )
	end
end)


AntiFF.Setup()


end


-----------------------------------------------------------------------------------------------------------------------------------------------------


if CLIENT then


net.Receive("lf_antiff_convar_sync", function()
	local tbl = net.ReadTable()
	for k,v in pairs( tbl ) do
		CreateConVar( k, v, { FCVAR_REPLICATED } )
	end
end)


local Frame


local function Menu( )

	if IsValid( Frame ) then Frame:Close() return end

	Frame = vgui.Create( "DFrame" )
	local fw, fh = 500, 300
	local pw, ph = fw - 10, fh - 62
	Frame:SetSize( fw, fh )
	Frame:SetTitle( "Anti-FriendlyFire" )
	Frame:SetVisible( true )
	Frame:SetDraggable( true )
	Frame:ShowCloseButton( true )
	Frame:Center()
	Frame:MakePopup()
	Frame:SetKeyboardInputEnabled( false )
	
	local function Change( cvar, v )
		net.Start("lf_antiff_convar_change")
		net.WriteString( cvar )
		net.WriteBool( v )
		net.SendToServer()
	end

	local function Checkbox( panel, x, y, cvar, label, tooltip )
		local c = vgui.Create( "DCheckBoxLabel", panel )
		c:SetPos( x, y )
		c:SetValue( GetConVar(cvar):GetBool() )
		c:SetText( label )
		c:SetTooltip( tooltip )
		c:SetDark( true )
		c:SizeToContents()
		function c:OnChange( v ) Change( cvar, v ) end
	end

	local function Text( panel, x, y, text )
		local t = vgui.Create( "DLabel", panel )
		t:SetPos( x, y )
		t:SetAutoStretchVertical( true )
		t:SetSize( pw - 40, 0 )
		t:SetDark( true )
		t:SetText( text )
		t:SetWrap( true )
	end
	
	local Sheet = vgui.Create( "DPropertySheet", Frame )
	Sheet:Dock( FILL )
	
	
	if ( LocalPlayer():IsSuperAdmin() or ( GetConVar("npc_antiff_admins_allowall"):GetBool() and LocalPlayer():IsAdmin() ) ) then
	
	local panel = vgui.Create( "DPanel", Sheet )
	Sheet:AddSheet( "Main Settings", panel, "icon16/script_edit.png" )
	
		Checkbox( panel, 20, 20, "npc_antiff_player", "Enable Player -> NPC" )
		Text( panel, 20, 40, "Players can no longer damage NPCs that are friendly towards them.")
		
		Checkbox( panel, 20, 80, "npc_antiff_npc", "Enable NPC -> NPC" )
		Text( panel, 20, 100, "NPCs can no longer damage allied NPCs." )
		
		Checkbox( panel, 20, 140, "npc_antiff_npc_invallies", "Enable Invincible Allies" )
		Text( panel, 20, 160, "All NPCs that are friendly towards the player*, will be invincible.\n(* In Multiplayer, only the player with the lowest ID is checked.)" )
		
		if LocalPlayer():IsSuperAdmin() then
			Checkbox( panel, 20, 210, "npc_antiff_admins_allowall", "Allow all admins to change these settings." )
		end
	
	
	local panel = vgui.Create( "DPanel", Sheet )
	Sheet:AddSheet( "Relationships", panel, "icon16/group.png" )
		
		Checkbox( panel, 20, 20, "npc_antiff_rel_neutral", "No damage to NPCs with neutral relationship" )
		Text( panel, 20, 40, "\"I don't hurt you, you don't hurt me. Let's just ignore each other.\"" )
		
		Checkbox( panel, 20, 70, "npc_antiff_rel_fear", "Players Only: No damage to NPCs that fear you" )
		Text( panel, 20, 90, "\"Let's not hurt that poor guy running away from you, okay?\"" )
		
		Checkbox( panel, 20, 120, "npc_antiff_npc_selfdmg", "NPC Only: No self damage" )
		Text( panel, 20, 140, "\"Did that Zombine just survived blowing itself up?!\"" )
		
		Text( panel, 20, 180, "Please note, that you won't encounter neutral or scared NPCs in GMod by default. However, you may encounter them on maps and there are also addons that allow you to modify relationships." )
	
	
	local panel = vgui.Create( "DPanel", Sheet )
	Sheet:AddSheet( "Prop Damage", panel, "icon16/box.png" )
		
		Checkbox( panel, 20, 20, "npc_antiff_prop", "No damage to props" )
		Text( panel, 20, 40, "\"My insurance will terminate my contract, if I break anymore things. Let's be more careful.\"" )
		
		Checkbox( panel, 20, 70, "npc_antiff_prop_force", "No physical force to props (requires no damage)" )
		Text( panel, 20, 90, "\"Although that crate didn't broke, it was thrown over my neighbor's fence again.\"" )
		
		Text( panel, 20, 130, "Enabling these settings may cause issues and / or prevent advancing in some maps." )
	
	end
	
	
	local panel = vgui.Create( "DPanel", Sheet )
	Sheet:AddSheet( "About", panel, "icon16/information.png" )
	
		local t = vgui.Create( "DLabel", panel )
		t:SetPos( 20, 20 )
		t:SetText( "Anti-FriendlyFire" )
		t:SetDark( true )
		t:SetFont( "DermaLarge" )
		t:SizeToContents()
		
		local t = vgui.Create( "DLabel", panel )
		t:SetPos( 20, 60 )
		t:SetDark( true )
		t:SetFont( "DermaDefaultBold" )
		t:SetText( "Created by LibertyForce." )
		t:SizeToContents()
		
		if file.Exists( "materials/vgui/entities/npc_may.vmt", "GAME" ) then -- Easter Egg, don't tell anyone.
		
			local pic = vgui.Create( "DImage", panel )
			pic:SetPos( 20, 90 )
			pic:SetSize( 128, 128 )
			pic:SetImage( "vgui/entities/npc_may", "vgui/avatar_default" )
			
			Text( panel, 170, 100, "May approves the use of Anti-FriendlyFire! Thank you!" )
			
			Text( panel, 170, 120, "Got any problems or suggestions? Pleases report them on\nthe addon page. And if you like this mod, please leave\na thumbs up!" )
			
			local b = vgui.Create( "DButton", panel )
			b:SetPos( 170, 180 )
			b:SetSize( 120, 25 )
			b:SetText( "Visit addon page" )
			b.DoClick = function()
				gui.OpenURL( "http://steamcommunity.com/sharedfiles/filedetails/?id=351603470" )
			end
			
			local b = vgui.Create( "DButton", panel )
			b:SetPos( 310, 180 )
			b:SetSize( 120, 25 )
			b:SetText( "Weapon S.T.A.R." )
			b.DoClick = function()
				gui.OpenURL( "http://steamcommunity.com/sharedfiles/filedetails/?id=492765756" )
			end
		
		else
		
			Text( panel, 20, 90, "If you encounter any problems (especially LUA errors!), please report them on the addon page. Got any suggestions? Feel free to write them down. And if you like this mod, please leave a thumbs up!" )
			
			local b = vgui.Create( "DButton", panel )
			b:SetPos( 20, 150 )
			b:SetSize( 120, 25 )
			b:SetText( "Visit addon page" )
			b.DoClick = function()
				gui.OpenURL( "http://steamcommunity.com/sharedfiles/filedetails/?id=351603470" )
			end
			
			local b = vgui.Create( "DButton", panel )
			b:SetPos( 160, 150 )
			b:SetSize( 290, 25 )
			b:SetText( "Weapon S.T.A.R.: Setup, Transfer And Restore" )
			b.DoClick = function()
				gui.OpenURL( "http://steamcommunity.com/sharedfiles/filedetails/?id=492765756" )
			end
		
		end

end


local function SpawnMenu( panel )

	panel:AddControl("Label", {Text = " "})
	local a = panel:AddControl("Button", {Label = "Open Settings Menu", Command = "npc_antiff"})
	a:SetSize(0, 50)
	panel:AddControl("Label", {Text = " "})
	local a = panel:AddControl("Label", {Text = "How to open the Settings Menu on gamemodes without SpawnMenu:"})
	a:SetFont( "DermaDefaultBold" )
	panel:AddControl("Label", {Text = "Open Console and type in:\nnpc_antiff"})

end

hook.Add( "PopulateToolMenu", "LF_AntiFF_Menu_Hook", function() spawnmenu.AddToolMenuOption( "Options", "NPCs", "LF_AntiFF_MenuItem", "Anti-FriendlyFire", "", "", SpawnMenu, {} ) end )


concommand.Add( "npc_antiff", Menu )


end