//These are all minor mutations that affect your speech somehow.
//Individual ones aren't commented since their functions should be evident at a glance
// no they arent bro


/datum/mutation/nervousness
	name = "Nervousness"
	desc = "Обладатель данного генома заикается."
	instability = NEGATIVE_STABILITY_MINI
	quality = MINOR_NEGATIVE
	text_gain_indication = span_danger("Ты нервничаешь.")

/datum/mutation/nervousness/on_life(seconds_per_tick, times_fired)
	if(SPT_PROB(5, seconds_per_tick))
		owner.set_stutter_if_lower(20 SECONDS)

/datum/mutation/wacky
	name = "Wacky"
	desc = "Ты не клоун. Ты целый цирк."
	instability = NEGATIVE_STABILITY_MINI
	quality = MINOR_NEGATIVE
	text_gain_indication = span_sans(span_notice("Ты чувствуешь странности в своих голосовых связках."))
	text_lose_indication = span_notice("Странное ощущение проходит.")

/datum/mutation/wacky/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/wacky/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/wacky/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	speech_args[SPEECH_SPANS] |= SPAN_SANS

/datum/mutation/heckacious
	name = "heckacious larincks"
	desc = "чел что ЖЕЛАЮТ твои слова чувак..........."
	quality = MINOR_NEGATIVE
	text_gain_indication = span_sans("ЧЁРТ, чувак. твоё горло как ДЕРЬМО.")
	text_lose_indication = span_notice("Демоническое существо, овладевшее твоей гортанью, наконец-то ослабило свою хватку.")
	locked = TRUE

/datum/mutation/heckacious/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_LIVING_TREAT_MESSAGE, PROC_REF(handle_caps))
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/heckacious/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	UnregisterSignal(owner, list(COMSIG_LIVING_TREAT_MESSAGE, COMSIG_MOB_SAY))

/datum/mutation/heckacious/proc/handle_caps(atom/movable/source, list/message_args)
	SIGNAL_HANDLER
	message_args[TREAT_CAPITALIZE_MESSAGE] = FALSE

/datum/mutation/heckacious/proc/handle_speech(datum/source, list/speech_args)

	var/message = speech_args[SPEECH_MESSAGE]
	if(!message)
		return
	// Split for swapping purposes
	message = " [message] "

	// Splitting up each word in the text to manually apply our intended changes
	var/list/message_words = splittext(message, " ")
	// What we use in the end
	var/list/edited_message_words

	for(var/editing_word in message_words)
		if(editing_word == " " || editing_word == "" )
			continue
		// Used to replace the original later
		var/og_word = editing_word
		// Iterating through each replaceable-string in the .json
		var/static/list/super_wacky_words = strings("heckacious.json", "heckacious")

		// If the word doesn't get replaced we might do something with it later
		var/word_edited
		for(var/key in super_wacky_words)
			var/value = super_wacky_words[key]
			// If list, pick one value from said list
			if(islist(value))
				value = pick(value)
			editing_word = replacetextEx(editing_word, "[uppertext(key)]", "[uppertext(value)]")
			editing_word = replacetextEx(editing_word, "[capitalize(key)]", "[capitalize(value)]")
			editing_word = replacetextEx(editing_word, "[key]", "[value]")
			// Enable if we actually found something to change
			if(editing_word != og_word)
				word_edited = TRUE

		// Random caps
		if(prob(10))
			editing_word = prob(85) ? uppertext(editing_word) : LOWER_TEXT(editing_word)
		// some times....... we add DOTS...
		if(prob(10))
			for(var/dotnum in 1 to rand(2, 8))
				editing_word += "."
		// change for bold/italics/underline as well!
		if(prob(10))
			var/extra_emphasis = pick("+", "_", "|")
			editing_word = extra_emphasis + editing_word + extra_emphasis

		// If no replacement we do it manually
		if(!word_edited)
			if(prob(65))
				editing_word = replacetext(editing_word, pick(VOWELS), pick(VOWELS))
			// Many more consonants, double it!
			for(var/i in 1 to rand(1, 2))
				editing_word = replacetext(editing_word, pick(CONSONANTS), pick(CONSONANTS))
			// rarely, lettter is DOUBBLED...
			var/patchword = ""
			for(var/letter in 1 to length(editing_word))
				if(prob(92))
					patchword += editing_word[letter]
					continue
				patchword += replacetext(editing_word[letter], "", editing_word[letter] + editing_word[letter])
			editing_word = patchword

		LAZYADD(edited_message_words, editing_word)

	var/edited_message = jointext(edited_message_words, " ")

	message = trim(edited_message)

	speech_args[SPEECH_MESSAGE] = message

/datum/mutation/mute
	name = "Mute"
	desc = "Геном полностью подавляет отдел головного мозга, отвечающий за речевой аппарат."
	instability = NEGATIVE_STABILITY_MAJOR
	quality = NEGATIVE
	text_gain_indication = span_danger("Ты чувствуешь себя неспособным выражать свои мысли.")
	text_lose_indication = span_danger("Ты чувствуешь, что снова можешь говорить.")

/datum/mutation/mute/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_MUTE, GENETIC_MUTATION)

/datum/mutation/mute/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_MUTE, GENETIC_MUTATION)

/datum/mutation/unintelligible
	name = "Unintelligible"
	desc = "Геном частично подавляет отдел головного мозга, отвечающий за речевой аппарат, сильно искажая речь."
	instability = NEGATIVE_STABILITY_MODERATE
	quality = NEGATIVE
	text_gain_indication = span_danger("Ты чувствуешь себя неспособным сформировать предложение!")
	text_lose_indication = span_danger("Твой ум, кажется более ясным.")

/datum/mutation/unintelligible/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_UNINTELLIGIBLE_SPEECH, GENETIC_MUTATION)

/datum/mutation/unintelligible/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_UNINTELLIGIBLE_SPEECH, GENETIC_MUTATION)

/datum/mutation/swedish
	name = "Swedish"
	desc = "Ужасающая мутация, котороя происходит из далёкого прошлого. Считается, что она была полностью искоренена после 2037."
	instability = NEGATIVE_STABILITY_MINI
	quality = MINOR_NEGATIVE
	text_gain_indication = span_notice("Ты ощущаешь себя шведом, что бы это ни значило.")
	text_lose_indication = span_notice("Ты перестаешь ощущать себя шведом.")
	var/static/list/language_mutilation = list("w" = "v", "j" = "y", "bo" = "bjo", "a" = list("å","ä","æ","a"), "o" = list("ö","ø","o"))

/datum/mutation/swedish/New(datum/mutation/copymut)
	. = ..()
	AddComponent(/datum/component/speechmod, replacements = language_mutilation, end_string = list("",", bork",", bork, bork"), end_string_chance = 30)

/datum/mutation/chav
	name = "Chav"
	desc = "Неизвестно."
	instability = NEGATIVE_STABILITY_MINI
	quality = MINOR_NEGATIVE
	text_gain_indication = span_notice("Ты ощущаешь себя мудаком, не так ли?")
	text_lose_indication = span_notice("Ты перестаешь ощущать себя грубым и нахальным.")

/datum/mutation/chav/New(datum/mutation/copymut)
	. = ..()
	AddComponent(/datum/component/speechmod, replacements = strings("chav_replacement.json", "chav"), end_string = ", mate", end_string_chance = 30)

/datum/mutation/elvis
	name = "Elvis"
	desc = "Ужасающая мутация, названная в честь нулевого пациента."
	instability = NEGATIVE_STABILITY_MINI
	quality = MINOR_NEGATIVE
	text_gain_indication = span_notice("Ты хорошо себя чувствуешь, куколка.")
	text_lose_indication = span_notice("Ты чувствуешь, что немного меньше разговоров не помешало бы.")

/datum/mutation/human/chav/New(class, timer, datum/mutation/human/copymut)
	. = ..()
	AddComponent(/datum/component/speechmod, replacements = strings("elvis_replacement.json", "elvis"))

/datum/mutation/chav/New(datum/mutation/copymut)
	. = ..()
	AddComponent(/datum/component/speechmod, replacements = strings("elvis_replacement.json", "elvis"))

/datum/mutation/elvis/on_life(seconds_per_tick, times_fired)
	switch(pick(1,2))
		if(1)
			if(SPT_PROB(7.5, seconds_per_tick))
				var/list/dancetypes = list("swinging", "fancy", "stylish", "20'th century", "jivin'", "rock and roller", "cool", "salacious", "bashing", "smashing")
				var/dancemoves = pick(dancetypes)
				owner.visible_message("<b>[owner]</b> busts out some [dancemoves] moves!")
		if(2)
			if(SPT_PROB(7.5, seconds_per_tick))
				owner.visible_message("<b>[owner]</b> [pick("jiggles their hips", "rotates their hips", "gyrates their hips", "taps their foot", "dances to an imaginary song", "jiggles their legs", "snaps their fingers")]!")

/datum/mutation/stoner
	name = "Stoner"
	desc = "Обычная мутация, которая сильно понижает интеллект."
	quality = NEGATIVE
	text_gain_indication = span_notice("Ты чувствуешь себя...максимально расслабленным, чувак!")
	text_lose_indication = span_notice("Ты чувствуешь, что твоё восприятие времени стало лучше.")

/datum/mutation/stoner/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	owner.grant_language(/datum/language/beachbum, source = LANGUAGE_STONER)
	owner.add_blocked_language(subtypesof(/datum/language) - /datum/language/beachbum, source = LANGUAGE_STONER)

/datum/mutation/stoner/on_losing(mob/living/carbon/human/owner)
	..()
	owner.remove_language(/datum/language/beachbum, source = LANGUAGE_STONER)
	owner.remove_blocked_language(subtypesof(/datum/language) - /datum/language/beachbum, source = LANGUAGE_STONER)

/datum/mutation/medieval
	name = "Medieval"
	desc = "Ужасная мутация, происходящая из далёкого прошлого, считается, что была распространённым геномом во всей старой Европе."
	instability = NEGATIVE_STABILITY_MINI
	quality = MINOR_NEGATIVE
	text_gain_indication = span_notice("Ты чувствуешь себя стремящимся к Святому Граали!")
	text_lose_indication = span_notice("Ты больше не стремишься к чему-либо.")

/datum/mutation/medieval/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/medieval/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/medieval/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		message = " [message] "
		var/list/medieval_words = strings("medieval_replacement.json", "medieval")
		var/list/startings = strings("medieval_replacement.json", "startings")
		for(var/key in medieval_words)
			var/value = medieval_words[key]
			if(islist(value))
				value = pick(value)
			if(uppertext(key) == key)
				value = uppertext(value)
			if(capitalize(key) == key)
				value = capitalize(value)
			message = replacetextEx(message,regex("\b[REGEX_QUOTE(key)]\b","ig"), value)
		message = trim(message)
		var/chosen_starting = pick(startings)
		message = "[chosen_starting] [message]"

		speech_args[SPEECH_MESSAGE] = message

/datum/mutation/piglatin
	name = "Pig Latin"
	desc = "Историки говорят, что в 2020 году человечество полностью говорило на этом мистическом языке."
	instability = NEGATIVE_STABILITY_MINI
	quality = MINOR_NEGATIVE
	text_gain_indication = span_notice("Ты ощущаешь себя мамонтом.")
	text_lose_indication = span_notice("Кажется, это прошло.")

/datum/mutation/piglatin/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/piglatin/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/piglatin/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/spoken_message = speech_args[SPEECH_MESSAGE]
	spoken_message = piglatin_sentence(spoken_message)
	speech_args[SPEECH_MESSAGE] = spoken_message
