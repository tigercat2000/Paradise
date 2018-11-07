//Strained Muscles: Temporary speed boost at the cost of rapid damage
//Limited because of hardsuits and such; ideally, used for a quick getaway

/obj/effect/proc_holder/changeling/strained_muscles
	name = "Strained Muscles"
	desc = "We evolve the ability to reduce the acid buildup in our muscles, allowing us to move much faster."
	helptext = "The strain will make us tired, and we will rapidly become fatigued. Standard weight restrictions, like hardsuits, still apply. Cannot be used in lesser form."
	chemical_cost = 0
	dna_cost = 1
	req_human = 1
	var/stacks = 0 //Increments every 5 seconds; damage increases over time
	var/enabled = 0 //Whether or not you are a hedgehog

/obj/effect/proc_holder/changeling/strained_muscles/sting_action(var/mob/living/carbon/user)
	enabled = !enabled
	if(enabled)
		to_chat(user, "<span class='notice'>Our muscles tense and strengthen.</span>")
	else
		user.status_flags &= ~GOTTAGOFAST
		to_chat(user, "<span class='notice'>Our muscles relax.</span>")
		if(stacks >= 10)
			to_chat(user, "<span class='danger'>We collapse in exhaustion.</span>")
			user.Weaken(3)
			user.emote("gasp")

	while(enabled)
		user.status_flags |= GOTTAGOFAST
		if(user.stat || user.staminaloss >= 90)
			enabled = 0 //Let's use something exact instead of !enabled where we can.
			to_chat(user, "<span class='notice'>Our muscles relax without the energy to strengthen them.</span>")
			user.status_flags &= ~GOTTAGOFAST
			user.Weaken(2)
			user.emote("gasp")
			break

		stacks++
		//user.take_organ_damage(stacks * 0.03, 0)
		user.staminaloss += stacks * 1.3 //At first the changeling may regenerate stamina fast enough to nullify fatigue, but it will stack

		if(stacks == 11) //Warning message that the stacks are getting too high
			to_chat(user, "<span class='warning'>Our legs are really starting to hurt...</span>")

		sleep(40)

	while(!enabled) //Damage stacks decrease fairly rapidly while not in sanic mode
		if(stacks >= 1)
			stacks--
		sleep(20)

	SSblackbox.add_details("changeling_powers","SANIC")
	return 1
