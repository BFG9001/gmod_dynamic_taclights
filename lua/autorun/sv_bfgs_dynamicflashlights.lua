--Serverside functionality

local FlashEnabled = CreateConVar("flashlight_tactical_on" , "1" , FCVAR_ARCHIVE  , "Set to 1 to enable tactical flashlights on all weapons")

local function CreateProjectedTexture(ply)
		ply.DynaFlashlight = ents.Create("env_projectedtexture")
		ply.DynaFlashlight:SetKeyValue("fov", "45")
		ply.DynaFlashlight:SetKeyValue("nearz", "1")
		ply.DynaFlashlight:SetKeyValue("farz", "750")
		ply.DynaFlashlight:SetKeyValue("enableshadows", "false")	
end

local function CreateNetworkedFlashlight(player)
	player:SetNWBool("BFG_IsCustomFlashlightOn" , false)
/*
	if not player.DynaFlashlight then
		CreateProjectedTexture(player)
	end
	player.DynaFlashlight:Fire("TurnOff")
*/
end
hook.Add("PlayerInitialSpawn", "BFG_FlashlightStart", CreateNetworkedFlashlight)


local function OverrideInternalFlashlight(ply, TurnOn)
	if FlashEnabled:GetBool() then 
		DoCustomFlashlightToggle(ply)
		if TurnOn then return false end
	end
end
hook.Add("PlayerSwitchFlashlight", "Flashlight_Override", OverrideInternalFlashlight)

function DoCustomFlashlightToggle(ply, On)
	ply:EmitSound("Weapon_Shotgun.Empty")
	//print(ply:Nick() .. " called the toggle flashlight func!")
	if ply:GetNWBool("BFG_IsCustomFlashlightOn", true) or (On == false) then
		ply:SetNWBool("BFG_IsCustomFlashlightOn", false)
		SafeRemoveEntity(ply.DynaFlashlight)
	else
		ply:SetNWBool("BFG_IsCustomFlashlightOn", true)
		if ply:IsBot() then return end
		if IsValid(ply.DynaFlashlight) then return end
		CreateProjectedTexture(ply)
		
		ply.DynaFlashlight:SetParent(ply:GetViewModel())
		HandleMuzzleAttachment(ply.DynaFlashlight, ply:GetViewModel())
	end

end

function HandleMuzzleAttachment(flashlight, viewmodel)
	local attachs = viewmodel:GetAttachments()
	local name = HandleMuzzleAttachmentHelper(attachs)

	if not (name == "nil") and viewmodel:GetOwner():Alive() then
		flashlight:SetParent(viewmodel)
		flashlight:Fire("SetParentAttachment", tostring(name) )
	elseif viewmodel:GetOwner():Alive() then
		//local cache = flashlight:GetParent()
		flashlight:SetParent(viewmodel)
		
		timer.Simple(0, function() flashlight:SetPos(viewmodel:GetPos()) flashlight:SetAngles(viewmodel:GetAngles()) flashlight:SetParent(viewmodel) end)
	end
	//print(flashlight:GetAttachment(flashlight:LookupAttachment(name)))
	//print(name)
	timer.Simple(0, function()
		//flashlight:SetLocalAngles(Angle(0,0,0))
		//print(flashlight:GetAttachment(flashlight:LookupAttachment(name)))
		//flashlight:SetLocalAngles(flashlight:WorldToLocalAngles(flashlight:GetOwner():GetAimVector():Angle()))
	end)
	
end

function HandleMuzzleAttachmentHelper(attachs)
	for key, value in pairs(attachs) do
		if value.name == "muzzle" then return value.name end
		if value.name == "spark" then return value.name end --for crossbow and crossbow skins
		if value.name == "laser" then return value.name end --for RPG
		--if value.name == "0" then return value.name end -- for DoD
		if value.name == "1" then return value.name end
		if value.name == "2" then return value.name end
		
		
	end
	return "nil"
end

/* --doesn't work
local function DoCustomFlashlightToggle(ply)
	if ply:GetNWBool("BFG_IsCustomFlashlightOn", true) then
		ply:SetNWBool("BFG_IsCustomFlashlightOn", false)
		ply.DynaFlashlight:Fire("TurnOff")
	else
		ply:SetNWBool("BFG_IsCustomFlashlightOn", true)
		ply.DynaFlashlight:Fire("TurnOn")
	end
end
*/

hook.Add("PlayerSwitchWeapon", "FlashlightUpdateHook", function(ply, old, new)
	if not IsValid(new) then return end
	local vm = ply:GetViewModel()
	if IsValid(ply.DynaFlashlight) and ply:GetNWBool("BFG_IsCustomFlashlightOn", false) then 
		SafeRemoveEntity(ply.DynaFlashlight)
		
		if ply:IsBot() then return end
		CreateProjectedTexture(ply)

		timer.Simple(0, function()
		HandleMuzzleAttachment(ply.DynaFlashlight, vm)
		end)
	end
end)

hook.Add("PlayerDeath", "FlashlightDeathDestroy", function(ply)
	ply:SetNWBool("BFG_IsCustomFlashlightOn", true)
	SafeRemoveEntity(ply.DynaFlashlight)
end)
/*
hook.Add("PlayerSpawn", "WhyDoIevenHavetodothisargggh", function(ply)
	SafeRemoveEntity(ply.DynaFlashlight)
end)
*/

/*
local PlayerMeta = FindMetaTable("Player")
PlayerMeta._BDrawViewModel = PlayerMeta.DrawViewModel
function PlayerMeta:DrawViewModel(draw)
	self:_BDrawViewModel(draw)
	if IsValid(self.DynaFlashlight) then
		HandleMuzzleAttachment(self, self:GetViewModel())
	end
	
end
*/
