function Schema:CanDrive(client, entity)
	return false
end

function Schema:DoAnimationEvent(ply, event, data)
	if ( event == PLAYERANIMEVENT_CUSTOM_GESTURE ) then
		ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, data, 0, true)
	end
end