local PLUGIN = PLUGIN

// Credits: https://github.com/TankNut/helix-plugins/blob/master/turning.lua

PLUGIN.name = "Turning"
PLUGIN.description = "Adds support for playermodels playing turning animations."
PLUGIN.author = "TankNut"

local support = {
	metrocop = true,
	overwatch = true,
	citizen_male = true,
	citizen_female = true
}

local whitelist = {
	[ACT_MP_STAND_IDLE] = true,
	[ACT_MP_CROUCH_IDLE] = true
}

function PLUGIN:TranslateActivity(client, act)
	local modelClass = client.ixAnimModelClass or "player"

	if not support[modelClass] or not whitelist[act] then
		return
	end

	client.NextTurn = client.NextTurn or 0

	local diff = math.NormalizeAngle(client:GetRenderAngles().y - client:EyeAngles().y)

	if math.abs(diff) >= 45 and client.NextTurn <= CurTime() then
		local gesture = diff > 0 and ACT_GESTURE_TURN_RIGHT90 or ACT_GESTURE_TURN_LEFT90

		if client:IsWepRaised() and gesture == ACT_GESTURE_TURN_LEFT90 then
			gesture = ACT_GESTURE_TURN_LEFT45
		end

		client:AnimRestartGesture(GESTURE_SLOT_CUSTOM, gesture, true)
		client.NextTurn = CurTime() + client:SequenceDuration(client:SelectWeightedSequence(gesture))
	end
end