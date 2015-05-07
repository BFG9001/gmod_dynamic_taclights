--Clientside things and world-view
AddCSLuaFile()
if SERVER then return end
local FLASHLIGHT_RANGE = 500

local function LightEffect(ply, pos, ang, brightness, size)
	local light = DynamicLight(ply:EntIndex())
		light.pos = pos
		light.Decay = 1000/(.25)
		light.DieTime = CurTime() + .5
		light.dir = ang:Forward()
		light.brightness = brightness or 5
		light.Size = size
		light.r = 255
		light.g = 255
		light.b = 255
		light.innerangle = 45
		light.outerangle = 50
end

local holdtypeBlacklist = { "melee", "grenade", "knife", "fist", "camera", "normal", "passive" }
local BASE_BRIGHTNESS = 4
local function DoThirdPersonTacLights()
	for k, ply in pairs(player.GetAll()) do
		if (ply ~= LocalPlayer()) and ply:GetNWBool("BFG_IsCustomFlashlightOn", true) then
			local handAtt = ply:GetAttachment(ply:LookupAttachment("anim_attachment_RH")) or {}
			local handPos = handAtt.Pos or ply:GetShootPos()
			local handAng = handAtt.Ang or ply:EyeAngles()

			local AngleOverride
			local wep = ply:GetActiveWeapon()
			if IsValid(wep) then
				if table.HasValue(holdtypeBlacklist, wep:GetHoldType()) then
					AngleOverride = ply:EyeAngles()
				end
			end

			local FinalAngle = AngleOverride or handAng

			local handTrace = util.TraceLine({ start = handPos, endpos = handPos + (FinalAngle:Forward() * FLASHLIGHT_RANGE) })
			local brightness = math.Clamp(BASE_BRIGHTNESS * (1/handTrace.Fraction), 1, BASE_BRIGHTNESS)
			local size = math.Clamp( 100 * (handTrace.Fraction), 40, 100 )
			LightEffect(ply, handTrace.HitPos, FinalAngle, brightness, size)

		end
	end
end
hook.Add("Think", "BFG_DynamicFlashlights_3rdPerson", DoThirdPersonTacLights)

local LightSourceSprite = Material("sprites/glow04_noz.vmt")
local function LightSprite(ply)
	if not (v == LocalPlayer()) and ply:GetNWBool("BFG_IsCustomFlashlightOn", false) then
			local handAtt = ply:GetAttachment(ply:LookupAttachment("anim_attachment_RH")) or {}
			local handPos = handAtt.Pos

			local wep = ply:GetActiveWeapon()
			local muzzlePos
			if IsValid(wep) then
				local muzzle = wep:GetAttachment(1)
				if muzzle then
					muzzlePos = muzzle.Pos + (muzzle.Ang:Forward() * 2)
				end
			end

			render.SetMaterial(LightSourceSprite)
			render.DrawSprite(muzzlePos or handPos or ply:GetShootPos(), 20, 20, Color( 255,255,255 ))
	end
end
hook.Add("PostPlayerDraw", "BFG_DynamicFlashlights_3rdPerson", LightSprite)
