/obj/machinery/compresser
	name = "Compresser"
	desc = "Compresses things into useable materials."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "grinder-b1"
	layer = MOB_LAYER+1 // Overhead
	anchored = 1
	density = 1
	var/safety_mode = 0 // Temporarily stops the machine if it detects a mob
	var/eatmob = 1 //Basically an admin emag var
	var/grinding = 0 //Is it currently busy?
	var/mob/living/occupant //Person inside.
	var/eat_dir = WEST //Which direction will we accept from?

/obj/item/meatcube //eewww.
	name = "Meatcube"
	desc = "Poor fucker."
	icon = 'icons/obj/larkens/meatcube.dmi'
	icon_state = "meatcube"
	anchored = 0
	layer = MOB_LAYER
	density = 1

/obj/item/slimecube //eeewww?
	name = "Slime Person Cube"
	desc = "Slime-person in a box! Poor thing."
	icon = 'icons/obj/larkens/meatcube.dmi'
	icon_state = "slimecube"
	anchored = 0
	w_class = 3.0

/obj/item/slimecube/relaymove(mob/user as mob)
	if (user.stat)
		return
	user << "<span class='notice'>The box is sealed shut!</span>"

/obj/item/slimecube/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	..()
	if (!istype(W, /obj/item/weapon/crowbar))
		user << "<span class='notice'>You can't pry open \the [src] with that!</span>"
		return

	user << "<span class='notice'>You break open \the [src] with \the [W].</span>"
	for(var/mob/M in src) //Should only be one but whatever.
		M.loc = src.loc
		if (M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE
	qdel(src)

/obj/machinery/compresser/New()
	..()
	update_icon()

/obj/machinery/compresser/power_change()
	..()
	update_icon()

/obj/machinery/compresser/Bump(var/atom/movable/AM) //Bump detectection.
	..()
	if(AM)
		Bumped(AM)

/obj/machinery/compresser/Bumped(var/atom/movable/AM, var/obj/machinery/compresser/slimecube/S) //Bump action.
	if(safety_mode)
		return
	// If we're not already grinding something.
	if(!grinding)
		grinding = 1
		spawn(1)
			grinding = 0
	else
		return

	var/move_dir = get_dir(loc, AM.loc)
	if(move_dir == eat_dir)
		if(ishuman(AM))
			if(eatmob) //Should we eat them?
				eat(AM)
			else
				stop(AM) //Let's stop them.
		else // Can't recycle anything other than humans, too lazy to code.
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
			AM.loc = src.loc


/obj/machinery/compresser/proc/stop(var/mob/living/L)
	playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
	safety_mode = 1
	update_icon()
	L.loc = src.loc

	spawn(SAFETY_COOLDOWN)
		playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
		safety_mode = 0
		update_icon()

/obj/machinery/compresser/proc/eat(var/mob/living/carbon/human/H)
	if(H.abiotic(1))
		H.apply_effect(40, STUN, 0)
		H.anchored = 1
		H.visible_message("<span class='warning'>\The [src] grabs ahold of [H.name]'s arms and legs!</span>","\The [src] grabs ahold of your legs and arms.")
		sleep(10)
		H.visible_message("<span class='warning'>\The [src] starts removing [H.name]'s clothes!</span>","<span class='warning'>\The [src] starts taking off your clothes!")
		for(var/obj/item/W in H)
			if(istype(W,/obj/item/organ))
				continue
			H.unEquip(W)
		sleep(20)
		H.visible_message("<span class='warning'>\The [src] removes [H.name]'s clothes!</span>","<span class='warning'><b>\The [src]</b> takes off your clothes!</span>")
		H.underwear = 7
		H.undershirt = 26
		H.update_body(1)
		sleep(10)
		H.visible_message("<span class='warning'>\The [src] drags [H.name] into it!","<span class='warning'>\The [src] drags you into it!</span>")
		H.loc = src
		src.occupant = H
		update_icon()
		H.SetStunned(0)
		H.anchored = 0
	else
		H.loc = src
		src.occupant = H
		update_icon()

	occupant.show_message("\The [src] takes you in, and closes behind you.")
	sleep(10)
	visible_message("<span class='alert'><B>\The [src]</b> states, 'Engaging compression.</span>'")
	occupant.show_message("<span class='notice'>You hear a faint voice.</span> <span class='alert'><B>\The [src]</b> states, 'Engaging compression.'</span>")
	sleep(20)
	occupant.show_message("<span class='danger'>The walls start closing in on you!</span>")
	sleep(20)
	occupant.show_message("<span class='notice'>You put your hands up to stop the walls,</span> <span class='danger'>but only succeed in getting your hands pushed by the walls!</span>")
	sleep(30)
	occupant.show_message("<span class='userdanger'>The walls are touching your shoulders!</span>")
	sleep(20)

	if(occupant.get_species() == "Slime People")
		occupant.show_message("<span class='userdanger'>The walls are squeezing your gelatineous body!</span>")
		sleep(20)
		occupant.show_message("<span class='danger'>Your body is being squashed.</span> <span class='userdanger'>The pressure is starting to hurt!</span>")
		sleep(20)
		occupant.show_message("<span class='danger'>The walls keep pressing against you from every side, reducing you to a cube!</span>")
		sleep(20)
		occupant.show_message("<span class='userdanger'>The pressure is very painful, your core is having trouble vibrating in the thick slime!</span>")
		sleep(20)
		occupant.show_message("<span class='danger'>The walls close on you, encasing you in a plastic box!</span>")
		sleep(10)
		var/obj/item/slimecube/cube = new /obj/item/slimecube (loc)
		if (occupant.client)
			occupant.client.perspective = EYE_PERSPECTIVE
			occupant.client.eye = cube
		occupant.loc = cube

	else
		occupant.show_message("<span class='userdanger'>Your bones are cracking and your limbs are being crushed together!</span>")
		occupant.apply_damage(20, BRUTE, "l_leg", 0)
		occupant.apply_damage(20, BRUTE, "r_leg", 0)
		occupant.apply_damage(20, BRUTE, "l_arm", 0)
		occupant.apply_damage(20, BRUTE, "r_arm", 0)
		playsound(loc, 'sound/effects/snap.ogg', 50, 0)
		sleep(30)
		occupant.show_message("<span class='userdanger'>Your chest is being crushed!</span>")
		occupant.apply_damage(40, BRUTE, "chest", 0)
		sleep(10)
		playsound(loc, 'sound/effects/squelch1.ogg', 50, 0)
		sleep(20)
		occupant.emote("scream")
		occupant.death(1)
		occupant.ghostize()
		qdel(occupant)
		visible_message("<span class='alert'><b>\The [src]</b> states, 'No usable material harvested. Disposing of unusable material.'</span>")
		new /obj/item/meatcube(loc)