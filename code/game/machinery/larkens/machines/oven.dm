/obj/machinery/larkens/oven
	name = "large oven"
	desc = "An over-sized oven. It smells of a strange meaty smell."

	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "oven_off"

	density = 1
	anchored = 1

	use_power = 1
	idle_power_usage = 2
	active_power_usage = 500

	var/mob/living/occupant = null
	var/mob/living/occupant_2 = null

	var/operating = 0

/obj/machinery/larkens/oven/process()
	if(operating)	use_power = 2
	else			use_power = 1

	..()

/obj/machinery/larkens/oven/MouseDrop_T(var/atom/movable/AM, var/mob/user)
	attempt_enter_oven(AM, user)

/obj/machinery/larkens/oven/attack_hand(var/mob/user)
	if(operating)
		user << "\The [src] is already on!"

	start_cooking()

/obj/machinery/larkens/oven/relaymove(var/mob/user)
	if(!user.stat)

		if(operating)
			user << "<span class='warning'>\The [src] is locked!</span>"
			return 0

		if(user == occupant)
			eject_occupants(1)
		else if(user == occupant_2)
			eject_occupants(2)

/obj/machinery/larkens/oven/update_icon()
	if(stat & (NOPOWER|BROKEN))
		icon_state = "oven_broke"
		return

	if(operating)
		icon_state = "oven_on"
	else
		icon_state = "oven_off"


/obj/machinery/larkens/oven/proc/attempt_enter_oven(var/mob/living/attempted_mob, var/mob/living/user)
	if(!istype(attempted_mob) || !istype(user))	return 0

	user.visible_message("\The [user] starts to [user == attempted_mob ? "crawl" : "feed \the [attempted_mob]"] into \the [src].", \
						 "You start to [user == attempted_mob ? "crawl" : "shove \the [attempted_mob]"] into \the [src].")
	if(do_after(user, 20))
		if(enter_oven(attempted_mob))
			visible_message("\The [user] [user == attempted_mob ? "crawls" : "feeds \the [attempted_mob]"] into \the [src].")
			user << "You [user == attempted_mob ? "crawl" : "shove \the [attempted_mob]"] into \the [src]."
	else
		user.visible_message("\The [user] stops [user == attempted_mob ? "crawling" : "feeding \the [attempted_mob]"] into \the [src].", \
							 "You stop [user == attempted_mob ? "crawling" : "shoving \the [attempted_mob]"] into \the [src].")

/obj/machinery/larkens/oven/proc/enter_oven(var/mob/living/L)
	if(!istype(L))	return 0 //Not a living mob
	if(occupant && occupant_2)	return 0 //All full
	if(operating)	return 0 //Already cooking

	if(occupant == L || occupant_2 == L)	return 1 //Already inside the oven

	L.forceMove(src)

	if(!occupant)	{occupant = L; return 1} //no occupant, make them the occupant
	else if(!occupant_2)	{occupant_2 = L; return 1} //there is an occupant, and no second occupant, make them the second occupant

	else	L.forceMove(get_turf(src)) //couldn't fit, forget it
	return 0

/obj/machinery/larkens/oven/proc/eject_occupants(var/oc)
	switch(oc)
		if(1) //Eject occupant 1
			if(occupant)
				occupant.forceMove(get_turf(src))
				occupant = null

		if(2) //Eject occupant 2
			if(occupant_2)
				occupant_2.forceMove(get_turf(src))
				occupant_2 = null

		if(3) //Eject both occupants
			eject_occupants(1)
			eject_occupants(2)


/obj/machinery/larkens/oven/proc/message_occupants(var/msg)
	if(occupant)	occupant.show_message(msg)
	if(occupant_2)	occupant_2.show_message(msg)

/obj/machinery/larkens/oven/proc/force_occupant_emote(var/emote)
	if(occupant)	occupant.emote(emote)
	if(occupant_2)	occupant_2.emote(emote)

/obj/machinery/larkens/oven/proc/damage_occupants(var/damage = 0,var/damagetype = BRUTE, var/def_zone = null)
	if(occupant)	occupant.apply_damage(damage, damagetype, def_zone)
	if(occupant_2)	occupant_2.apply_damage(damage, damagetype, def_zone)

/obj/machinery/larkens/oven/proc/start_cooking()
	use_power(1000) //Starting power usage
	operating = 1 //used to track if the oven is on

	if(!occupant && !occupant_2)	{operating = 0; return 0}

	update_icon()

	message_occupants("\The [src] makes a clicking noise.")
	visible_message("<b>\The [src]</b> beeps, then states, \"Attempting to start primary heating element.\"")

	sleep(60)

	message_occupants("\The [src] stops clicking, as the air around you starts to <font color='red'>heat up.</font>")
	visible_message("<b>\The [src]</b> pings, and states, \"Heating element engaged.\"")

	sleep(40)
	message_occupants("<span class='alert'>The air around you starts getting painfully hot.</span>")

	for(var/mob/M in range(1, src))
		if(M.loc == src)	continue
		M.show_message("<span class='alert'>\The [src] is starting to leak warm air.</span>")

	sleep(30)

	message_occupants("<span class='danger'>The metal walls of \the [src] start to get very hot to the touch.</span>")

	sleep(40)

	message_occupants("<span class='danger'>The air is starting to burn!</span>")
	damage_occupants(5, BURN, "head")

	visible_message("<b>\The [src]</b> states, \"Slow-cook temperature reached. Elevating to <span class='danger'>high-cook.</span>\"")

	sleep(20)

	message_occupants("<span class='danger'>\The [src] makes a violent firey noise, and the walls start to get burning hot.</span>")

	damage_occupants(10, BURN, "r_hand")
	damage_occupants(10, BURN, "l_hand")
	damage_occupants(10, BURN, "head")

	sleep(30)

	message_occupants("<span class='danger'>The air in \the [src] is starting to get extremely hot.</span>")

	for(var/mob/M in range(2, src))
		if(M.loc == src)	continue
		M.show_message("<span class='alert'>\The [src] is giving off a pleasent warmth.</span>")

	sleep(30)

	damage_occupants(20, BURN, "chest")
	damage_occupants(20, BURN, "head")

	message_occupants("<span class='userdanger'>The air burns like fuck, and \the [src]'s walls are singeing your flesh!</span>")
	force_occupant_emote("scream")

	sleep(20)

	damage_occupants(40, BURN, "chest")
	damage_occupants(10, BURN, "r_leg")
	damage_occupants(10, BURN, "l_leg")

	message_occupants("<span class='userdanger'>\The [src] is roasting you!</span>")

	visible_message("<b>\The [src]</b> states, \"High-cook temperature reached.\"")

	sleep(30)

	damage_occupants(20, BURN, "chest")
	damage_occupants(20, BURN, "r_leg")
	damage_occupants(20, BURN, "l_leg")
	damage_occupants(20, BURN, "r_arm")
	damage_occupants(20, BURN, "l_arm")

	message_occupants("<span class='userdanger'>Your flesh is cooking!</span>")

	sleep(10)

	damage_occupants(20, BURN, "chest")
	damage_occupants(20, BURN, "r_leg")
	damage_occupants(20, BURN, "l_leg")
	damage_occupants(20, BURN, "r_arm")
	damage_occupants(20, BURN, "l_arm")

	sleep(10)

	visible_message("<b>\The [src]</b> pings, and states, \"Cooking complete!\"")

	sleep(10)
	visible_message("<span class='alert'>\The [src] throws out [occupant && occupant_2 ? "two charred bodies" : "a charred corpse"].</span>")

	eject_occupants(3)
	operating = 0

	update_icon()

	return 1