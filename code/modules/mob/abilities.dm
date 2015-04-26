/*
Creature-level abilities.
*/

/var/global/list/ability_verbs = list(	)

/mob/living/carbon/human/proc/slimepeople_ventcrawl()  // Slime people ventcrawling commented out
	set category = "Abilities"
	set name = "Ventcrawl (Slime People)"
	set desc = "The ability to crawl through vents if naked and not holding anything."

	if(istype(usr,/mob/living/carbon/human))
		var/mob/living/carbon/human/M = usr
		if(M.get_species() != "Slime People")
			return 0 //no

		// Check if the client has a mob and if the mob is valid and alive.
		if(M.stat==2)
			M << "\red You must be corporeal and alive to do that."
			return 0

		//Handcuff check.
		if(M.restrained())
			M << "\red You cannot do this while restrained."
			return 0

		if(M.handcuffed)
			M << "\red You cannot do this while cuffed."
			return 0

		if(M.contents.len != 0)
			M << "\red You need to be naked and have nothing in your hands to ventcrawl."
			return 0

		M.handle_ventcrawl()
	else
		src << "This should not be happening. At all."

/mob/living/carbon/human/proc/slimecontenthandle()
	set category = "Abilities"
	set name = "Toggle Slime Intent"
	set desc = "Toggles the intent of your slime towards anyone you 'hug'."

	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if(H.get_species() != "Slime People")
			usr << "How the fuck did you get this?"
			return 0 //no

		H.should_absorb = !H.should_absorb

		H << "<span class='[H.should_absorb ? "warning'>You will now break down people you absorb for nutrients.</span>" : "notice'>You will now hold people in your slime harmlessly.</span>"]"
	return 0