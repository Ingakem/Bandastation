/**
 * Pray
 *
 * During the night, revealing someone will announce their role when day comes.
 * This is one time use, we'll delete ourselves once done.
 */
/datum/mafia_ability/seance
	name = "Сеанс"
	ability_action = "общаться с духами"
	use_flags = CAN_USE_ON_OTHERS|CAN_USE_ON_DEAD

/datum/mafia_ability/seance/perform_action_target(datum/mafia_controller/game, datum/mafia_role/day_target)
	. = ..()
	if(!.)
		return FALSE

	host_role.send_message_to_player(span_warning("Вы призвали дух [target_role.body.real_name] и узнали, что его роль была <b>[target_role.name]<b>."))
	return TRUE
