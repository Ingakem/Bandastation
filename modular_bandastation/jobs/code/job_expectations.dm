
/datum/config_entry/flag/show_job_estimation
	default = TRUE

/datum/preference/toggle/ready_job
	savefile_key = "ready_job"
	savefile_identifier = PREFERENCE_PLAYER
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	default_value = TRUE

/datum/preference/toggle/ready_job/apply_to_human(mob/living/carbon/human/target, value, /datum/preferences/preferences)
	return FALSE

/datum/preference/toggle/ready_job/apply_to_client_updated(client/client, value)
	. = ..()
	SSstatpanels.update_job_estimation(ckey = client.ckey)

/datum/controller/subsystem/statpanels
	/// The assoc list of job estimations keyed to player ref
	var/list/player_ready_data = list()
	/// The assoc list of job estimations keyed to player ref (for command players only)
	var/list/command_player_ready_data = list()

/// Returns the list of job estimation strings that get output to the stat panel. First to ready up get listed first. Command roles get displayed before all the rest.
/datum/controller/subsystem/statpanels/proc/get_job_estimation()
	var/list/job_estimation = list(
		"",
		"------------------",
		"Job Estimation:",
		"",
	)

	// Вспомогательный локальный процесс группировки списка
	var/list/grouped_command = list()
	for(var/player_ref in command_player_ready_data)
		var/list/entry = command_player_ready_data[player_ref]
		var/title = entry["title"]
		var/name = entry["name"]
		if(!grouped_command[title])
			grouped_command[title] = list()
		grouped_command[title] += name

	// Добавляем командование/силикнов в вывод
	for(var/title in grouped_command)
		var/list/names = grouped_command[title]
		job_estimation += "* [title] ([length(names)]): [names.Join(", ")]"

	var/list/grouped_crew = list()
	for(var/player_ref in player_ready_data)
		var/list/entry = player_ready_data[player_ref]
		var/title = entry["title"]
		var/name = entry["name"]
		if(!grouped_crew[title])
			grouped_crew[title] = list()
		grouped_crew[title] += name

	// Добавляем остальной персонал в вывод
	for(var/title in grouped_crew)
		var/list/names = grouped_crew[title]
		job_estimation += "* [title] ([length(names)]): [names.Join(", ")]"

	return job_estimation

/// Adds a player to the ready estimation
/datum/controller/subsystem/statpanels/proc/add_job_estimation(mob/dead/new_player/player)
	if(isnull(player.client))
		return
	if(!CONFIG_GET(flag/show_job_estimation))
		return

	var/datum/preferences/prefs = player.client?.prefs
	var/datum/job/player_job = prefs?.get_highest_priority_job()

	if(!player_job)
		return

	var/title = player_job.title
	if(title == JOB_ASSISTANT || title == JOB_PRISONER)
		return

	var/char_real_name = prefs.get_job_assigned_name(player_job)

	var/display_name
	if(!prefs.read_preference(/datum/preference/toggle/ready_job) && !(player_job.departments_bitflags & (DEPARTMENT_BITFLAG_COMMAND)) && title != JOB_AI)
		display_name = "a mysterious person"
	else
		switch(title)
			if(JOB_AI)
				display_name = prefs.read_preference(/datum/preference/name/ai)
			if(JOB_CLOWN)
				display_name = prefs.read_preference(/datum/preference/name/clown)
			if(JOB_CYBORG)
				display_name = prefs.read_preference(/datum/preference/name/cyborg)
			if(JOB_MIME)
				display_name = prefs.read_preference(/datum/preference/name/mime)
			else
				display_name = char_real_name

	var/player_ref = REF(player)
	if(isnull(display_name) || isnull(player_ref))
		return

	// Сохраняем структуру данных вместо готовой строки
	var/list/player_entry = list(
		"title" = title,
		"name" = display_name,
	)

	if(player_job.departments_bitflags & (DEPARTMENT_BITFLAG_COMMAND | DEPARTMENT_BITFLAG_SILICON))
		command_player_ready_data[player_ref] = player_entry
	else
		player_ready_data[player_ref] = player_entry

	RegisterSignal(player, COMSIG_JOB_PREF_UPDATED, PROC_REF(on_client_changes_job))

/// Removes a player from the job estimation.
/datum/controller/subsystem/statpanels/proc/remove_job_estimation(mob/dead/new_player/player)
	if(isnull(player))
		return

	var/player_ref = REF(player)
	player_ready_data -= player_ref

	if(length(command_player_ready_data))
		command_player_ready_data -= player_ref

	UnregisterSignal(player, list(COMSIG_JOB_PREF_UPDATED))

/// Takes a mob or ckey an tries to update the job estimation
/datum/controller/subsystem/statpanels/proc/update_job_estimation(mob/dead/new_player/player, ckey)
	if(SSticker.HasRoundStarted())
		return

	if(player)
		remove_job_estimation(player)
		add_job_estimation(player)

	else if(ckey) // if the player is ready, update their job estimation
		var/mob/dead/new_player/new_player = get_mob_by_ckey(ckey)
		if(new_player?.ready == PLAYER_READY_TO_PLAY)
			remove_job_estimation(new_player)
			add_job_estimation(new_player)

/// Updates the mob's job if they change it through the occupations tab while readied.
/datum/controller/subsystem/statpanels/proc/on_client_changes_job(mob/dead/new_player/source)
	SIGNAL_HANDLER
	update_job_estimation(source)

// When switching character slots in prefs, make sure we update our job if we're readied
/datum/preferences/switch_to_slot(new_slot)
	. = ..()
	SSstatpanels.update_job_estimation(ckey = parent.ckey) // update the job estimations with their new char

// This gets called both when the client disconnects and when the client is shoved into their spawn mob.
/mob/dead/new_player/become_uncliented()
	SSstatpanels.remove_job_estimation(src)
