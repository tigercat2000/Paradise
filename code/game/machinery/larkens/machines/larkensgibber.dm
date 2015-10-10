/obj/machinery/larkens/gibber
	name = "gibber"
	desc = "The name isn't descriptive enough?"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	density = 1
	anchored = 1
	var/operating = 0 //Is it on?
	var/dirty = 0 // Does it need cleaning?

	var/gib_throw_dir = WEST // Direction to spit meat and gibs in. Defaults to west.
	var/gibtime = 40 // Time from starting until meat appears

	var/mob/living/carbon/human/occupant // Mob who has been put inside

	var/locked = 0 // Is \The [src] locked shut?
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 500

/obj/machinery/larkens/gibber/bumpgibber
	name = "autogibber-NT"

/obj/machinery/larkens/gibber/bumpgibber/Bumped(var/atom/A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.abiotic(1))
			src.visible_message("<span class='warning'>\The [src] states, 'Subject may not have abiotic items on.'</span>")
			if(H.resting)
				src.visible_message("<span class='warning'>\The [src] states, 'Larkens.Override(Disposals) Detected.'</span>")
				sleep(10)
				H.show_message("<span class='warning'>\The [src] states, 'Stripping Subject.'</span>")
				for(var/obj/item/W in H)
					if(istype(W,/obj/item/organ))
						continue
					H.unEquip(W)
				H.underwear = 7
				H.undershirt = 5
				H.update_body(1)
			else
				return
		else
			if(H.client)
				H.client.perspective = EYE_PERSPECTIVE
				H.client.eye = src
			H.loc = src
			src.occupant = H
			update_icon()
			visible_message("<span class='warning'>\The [src] grabs ahold of [H.name] and drags them in!</span>")
			H.show_message("<span class='warning'>\The [src] grabs ahold of your feet and drags you into it!</span>")
			src.startgibbing(H)

/obj/machinery/larkens/gibber/bumpgibberFull
	name = "autogibber-AI1"

/obj/machinery/larkens/gibber/bumpgibberFull/Bumped(var/atom/A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.abiotic(1))
			src.visible_message("<span class='warning'>\The [src] states, 'Subject may not have abiotic items on.'</span>")
			if(H.resting)
				src.visible_message("<span class='warning'>\The [src] states, 'Larkens.Override(Disposals) Detected.'</span>")
				sleep(10)
				H.show_message("<span class='warning'>\The [src] states, 'Stripping Subject.'</span>")
				for(var/obj/item/W in H)
					if(istype(W,/obj/item/organ))
						continue
					H.unEquip(W)
				H.underwear = 7
				H.undershirt = 5
				H.update_body(1)
				sleep(5)
			else
				return
		else
			if(H.client)
				H.client.perspective = EYE_PERSPECTIVE
				H.client.eye = src
			H.loc = src
			src.occupant = H
			update_icon()
			visible_message("<span class='warning'>\The [src] grabs ahold of [H.name] and drags them in!</span>")
			H.show_message("<span class='warning'>\The [src] grabs ahold of your feet and drags you into it!</span>")
			src.startgibbing(H, "full")

/obj/machinery/larkens/gibber/tenderizer
	name = "tenderizer"

/obj/machinery/larkens/gibber/tenderizer/Bumped(var/atom/A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.abiotic(1))
			src.visible_message("<span class='warning'>\The [src] states, 'Subject may not have abiotic items on.'</span>")
			if(H.resting)
				src.visible_message("<span class='warning'>\The [src] states, 'Larkens.Override(Disposals) Detected.'</span>")
				sleep(10)
				H.show_message("<span class='warning'>\The [src] states, 'Stripping Subject.'</span>")
				for(var/obj/item/W in H)
					if(istype(W,/obj/item/organ))
						continue
					H.unEquip(W)
				H.underwear = 7
				H.undershirt = 5
				H.update_body(1)
			else
				return
		else
			if(H.client)
				H.client.perspective = EYE_PERSPECTIVE
				H.client.eye = src
			H.loc = src
			src.occupant = H
			update_icon()
			visible_message("<span class='warning'>\The [src] grabs ahold of [H.name] and drags them in!</span>")
			H.show_message("<span class='warning'>\The [src] grabs ahold of your feet and drags you into it!</span>")
			src.starttenderizing(H)

/obj/machinery/larkens/gibber/New()
	..()
	src.overlays += image('icons/obj/kitchen.dmi', "grjam")

/obj/machinery/larkens/gibber/update_icon()
	overlays.Cut()
	if (dirty)
		src.overlays += image('icons/obj/kitchen.dmi', "grbloody")
	if(stat & (NOPOWER|BROKEN))
		return
	if (!occupant)
		src.overlays += image('icons/obj/kitchen.dmi', "grjam")
	else if (operating)
		src.overlays += image('icons/obj/kitchen.dmi', "gruse")
	else
		src.overlays += image('icons/obj/kitchen.dmi', "gridle")

/obj/machinery/larkens/gibber/relaymove(mob/user as mob)
	src.go_out()
	return

/obj/machinery/larkens/gibber/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	if(operating)
		user << "<span class='warning'>\The [src] is locked and running.</span>"
		return
	if(src.occupant == user)
		src.occupant.show_message ("<span class='warning'>You hit the internal 'Sweet Relief' button.</span>")
		src.startgibbing(user, "full")

	else
		visible_message("<span class='warning>[user.name] hits the red flashing 'Gib' button on \the [src].</span>", \
						 "<span class='warning'>You hit the big red flashing 'Gib' button.</span>")
		src.occupant.show_message ("<span class='danger'>You hear a beep, and then a hum as \the [src] springs to life around you. This can't be good.</span>")
		src.startgibbing(user, "full")

/obj/machinery/larkens/gibber/tenderizer/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return

	if(operating)
		user << "<span class='warning'>\The [src] is locked and running.</span>"
		return

	if(src.occupant == user)
		src.occupant.show_message ("<span class='danger'>You hit the internal start button.</span>")
		src.starttenderizing(user)

	else
		visible_message("<span class='warning>[user.name] hits the big red flashing 'Start Tenderization' button on \the [src].</span>", \
						 "<span class='warning'>You hit the big red flashing 'Start Tenderization' button.</span>")
		src.occupant.show_message("<span class='danger'>You hear a beep, and then a hum as \the [src] springs to life around you. This can't be good.</span>")
		src.starttenderizing(user)

/obj/machinery/larkens/gibber/attackby(obj/item/weapon/grab/G as obj, mob/user as mob)
	if(src.occupant)
		user << "<span class='warning'>\The [src] is full, empty it first!</span>"
		return
	if (!( istype(G, /obj/item/weapon/grab)) || !(istype(G.affecting, /mob/living/carbon/human)))
		user << "<span class='warning'>This item is not suitable for \The [src]!</span>"
		return
	if(G.affecting.abiotic(1))
		user << "<spawn class='warning'>Subject may not have abiotic items on.</span>"
		return

	user.visible_message("<span class='danger'>[user.name] starts to put [G.affecting] into \the [src]!</span>", \
						  "<span class='warning'>You start to put [G.affecting] into \the [src].</span")
	src.add_fingerprint(user)
	if(do_after(user, 30) && G && G.affecting && !occupant)
		user.visible_message("<span class='danger'>[user] stuffs [G.affecting] into \the [src]!</span>", \
							  "<span class='warning'>You stuff [G.affecting] into \the [src].</span>")
		var/mob/M = G.affecting
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src
		M.loc = src
		src.occupant = M
		del(G)
		update_icon()


/obj/machinery/larkens/gibber/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if(O.loc == user) //no you can't pull things out of your ass
		return
	if(user.restrained() || user.stat || user.weakened || user.stunned || user.paralysis || user.resting) //are you cuffed, dying, lying, stunned or other
		return
	if(O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)) // is the mob anchored, too far away from you, or are you too far away from the source
		return
	if(!ishuman(O)) //humans only
		return
	if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if(!istype(user.loc, /turf) || !istype(O.loc, /turf)) // are you in a container/closet/pod/etc?
		return

	var/mob/living/L = O
	if(L != user)
		return

	if(src.occupant)
		user << "<span class='warning'>\The [src] is full! You can't fit in there!</span>"
		visible_message ("<span class='notice'>\The [src] rejects [user.name].</span>")

	if(!istype(L) || L.buckled)
		return

	if(L.abiotic(1))
		visible_message("<span class='notice'><B>\The [src] states, 'Subject cannot have abiotic items on.'</B></span>")
		return
	if(!L)
		return
	if(L.client)
		L.client.perspective = EYE_PERSPECTIVE
		L.client.eye = src
	L.loc = src
	src.occupant = L
	src.add_fingerprint(user)
	update_icon()


/obj/machinery/larkens/gibber/verb/eject()
	set category = "Object"
	set name = "Empty [src]"
	set src in oview(1)

	if (usr.stat != 0)
		return

	if(operating||locked)
		usr.show_message("<span class='warning'>The hatch is locked.</span>")
		return

	else
		src.go_out()
		add_fingerprint(usr)
		update_icon()
		return

/obj/machinery/larkens/gibber/verb/lock()
	set category = "Object"
	set name = "Lock [src]"
	set src in oview(1)

	if (usr != src.occupant)
		usr.show_message("<span class='warning'>You [locked ? "unlock" : "close"] the hatch and [locked ? "open" : "lock"] it.</span>")
		locked = !locked

	else
		usr.show_message("<span class='warning'>You can't [locked ? "unlock" : "lock"] the hatch from inside!</span>")
		return

/obj/machinery/larkens/gibber/proc/go_out()
	if (!src.occupant)
		return

	if(locked || operating)
		src.occupant.show_message("<span class='warning>The hatch is locked!</span>")
		return

	for(var/obj/O in src)
		O.loc = src.loc

	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE

	src.occupant.loc = src.loc
	src.occupant = null
	update_icon()
	return

/obj/machinery/larkens/gibber/proc/starttenderizing(mob/user as mob)
	var/obj/item/organ/external/LL = src.occupant.get_organ("l_leg")
	var/obj/item/organ/external/RL = src.occupant.get_organ("r_leg")
	if(src.operating)
		return
	if(src.occupant.get_species() == "Slime People")
		src.occupant.show_message("<span class='warning><b>\The [src]</b> scans you, then decides it cannot tenderize your slime.</span>")
		sleep(10)
		src.occupant.show_message("<span class='warning><b>\The [src]</b> ejects you.</span>")
		src.operating = 0
		src.eject()
		visible_message("<span class='warning><b>The Tenderizer</b> states 'Incompatible Meat, ejecting.'</span>")
		return

	use_power(1000)
	src.operating = 1
	update_icon()

	src.occupant.attack_log += "\[[time_stamp()]\] Was tenderized by <b>auto-tender</b>" //One shall not simply gib a mob unnoticed!
	user.attack_log += "\[[time_stamp()]\] Was Tenderized <b>via auto-tender</b>"

	if(src.occupant.ckey)
		msg_admin_attack("[user.name] ([user.ckey]) was tenderized.(<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

	sleep(10)
	visible_message("<span class='warning>The [src]'s panel slides shut and locks.</span>")
	src.occupant.show_message("<span class='warning>The panel slides shut and locks behind you.</span>")
	sleep(20)
	visible_message("<span class='warning'><b>\The [src]</b> states, 'Preparing Subject.'</span>")
	src.occupant.show_message("<span class='notice>You hear a faint voice.</span><span class='warning><b>\The [src]</b> states, 'Preparing Subject.'</span>")
	src.occupant.show_message("<span class='warning'>You feel a panel open underneath you.</span>")
	sleep(30)
	src.occupant.show_message("<span class='danger'>A large blow strikes your back.</span>")
	src.occupant.show_message("<span class='danger'>Oh god, the pain!</span>")
	src.occupant.apply_effect(15, AGONY, 0)
	src.occupant.apply_damage(20, BRUTE, "chest", 0)
	sleep(30)
	src.occupant.show_message("<span class='danger'>A blow strikes your right leg.</span>")
	src.occupant.apply_effect(10, AGONY, 0)
	RL.fracture()
	sleep(10)
	src.occupant.show_message("<span class='danger'>Another blow strikes your left leg.</span>")
	src.occupant.apply_effect(10, AGONY, 0)
	LL.fracture()
	sleep(10)
	src.occupant.show_message("<span class='danger'>A number of blows strike your torso and groin.</span>")
	src.occupant.apply_damage(15, BRUTE, "groin", 0)
	src.occupant.apply_damage(15, BRUTE, "chest", 0)
	sleep(10)
	src.occupant.resting = 1
	src.operating = 0
	src.eject()

/obj/machinery/larkens/gibber/proc/startgibbing(mob/user as mob, var/type="default")
	var/obj/item/organ/external/LL = src.occupant.get_organ("l_leg")
	var/obj/item/organ/external/RL = src.occupant.get_organ("r_leg")
	if(src.operating)
		return

	if(!src.occupant)
		visible_message("<span class='warning'>You hear a loud metallic grinding sound.</span>")
		return

	use_power(1000)
	src.operating = 1
	update_icon()

	var/slab_name = occupant.name
	var/slab_count = 3
	var/slab_type = /obj/item/weapon/reagent_containers/food/snacks/meat/human //gibber can only gib humans on paracode, no need to check meat type
	var/slab_nutrition = src.occupant.nutrition / 15

	slab_nutrition /= slab_count

	for(var/i=1 to slab_count)
		var/obj/item/weapon/reagent_containers/food/snacks/meat/new_meat = new slab_type(src)
		new_meat.name = "[slab_name] [new_meat.name]"
		new_meat.reagents.add_reagent("nutriment",slab_nutrition)

		if(src.occupant.reagents)
			src.occupant.reagents.trans_to(new_meat, round(occupant.reagents.total_volume/slab_count,1))

	new /obj/effect/decal/cleanable/blood/gibs(src)

	src.occupant.attack_log += "\[[time_stamp()]\] Was gibbed by <b>Conveyer Line</b>" //One shall not simply gib a mob unnoticed!
	user.attack_log += "\[[time_stamp()]\] Gibbed <b>[src.occupant]/[src.occupant.ckey]</b>"

	if(src.occupant.ckey)
		msg_admin_attack("[user] ([user.ckey]) gibbed [src.occupant] ([src.occupant.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

	if(!iscarbon(user))
		src.occupant.LAssailant = null
	else
		src.occupant.LAssailant = user

	switch(type)
		if("default")
			sleep(10)
			visible_message("<span class='warning'>\The [src]'s hatch closes and locks.</span>")
			src.occupant.show_message("<span class='warning'>The hatch closes and locks behind you.</span>")
			sleep(20)
			visible_message("<span class='warning'><b>\The [src]</b> states, 'Readying subject.'</span>")
			src.occupant.show_message("<span class='notice'>You hear a faint voice. <span class='warning'><b>\The [src]</b> states 'Readying Subject.'</span>")
			src.occupant.show_message("<span class='warning'>A pair of rollers rolls you onto your back.</span>")
			sleep(20)
			src.occupant.show_message("<span class='warning'>Padded cuffs extend from the sides of <b>\The [src]</b> and take ahold of your arms and legs.</span>")
			sleep(40)
			visible_message("<span class='warning'><b>\The [src]</b> states, 'Subject Ready. Engaging Muzzle.'</span>")
			src.occupant.show_message("<span class='notice'>You hear a faint voice. <span class='warning'><b>\The [src]</b> states 'Subject Ready. Engaging Muzzle.'</span>")
			sleep(30)
			src.occupant.show_message("<span class='warning'>A muzzle extends from above and clamps onto your mouth.</span>")
			src.occupant.sdisabilities |= MUTE
			sleep(30)
			visible_message("<span class='warning'><b>\The [src]</b> states, 'Deploying Grinders.'</span>")
			src.occupant.show_message("<span class='notice'>You hear a faint voice. <span class='warning'><b>\The [src]</b> states 'Deploying Grinders.'</span>")
			sleep(30)
			src.occupant.show_message("<span class='warning'>A number of sharp points dig into your arms, and legs.</span>")
			sleep(20)
			src.occupant.show_message("<span class='warning'>A large clamp seals around your waist. This can't bode well.</span>")
			sleep(30)
			visible_message("<span class='warning'><b>\The [src]</b> states 'Engaging Grinders.'</span>")
			visible_message("<span class='warning'>\The [src] starts rumbling!</span>")
			src.occupant.show_message("<span class='notice'>You hear a faint voice. <span class='warning'><b>\The [src]</b> states 'Engaging Grinders.'</span>")
			sleep(30)
			src.occupant.show_message("<span class='warning'><b>You feel an extreme amount of pain as your hands and feet are seperated from your body. </b></span>")
			src.occupant.apply_effect(40, AGONY, 0)
			visible_message("<span class='warning'>You hear a loud squelchy grinding sound.</span>")
			sleep(20)
			src.occupant.show_message("<span class='warning'><b>You make a loud groan as your knees and elbows are seperated. </b></span>")
			visible_message("<b>[src.occupant]</b> groans loudly.</span>")
			sleep(40)
			src.occupant.show_message("<span class='warning'><b>As a blade saws your remaining limbs off, you attempt to scream out, but only make a little whimper. </b></span>")
			visible_message("<b>[src.occupant]</b> lightly whimpers.</span>")
			sleep(40)
			src.occupant.show_message("<span class='warning'><b>A saw slowly descends towards your neck.</b> </br> <span class='notice'>Your last thoughts are 'Finally, the pain will be over'</span>")
			visible_message("<span class='warning'><b>\The [src]</b> states, 'Gibbing Complete!'</span>")
			sleep(20)

		if("full")
			sleep(10)
			visible_message("<span class='warning'>The hatch closes and locks.</span>")
			src.occupant.show_message("<span class='warning'>The hatch closes and locks behind you.</span>")
			sleep(20)
			visible_message("<span class='warning'><b>\The [src]</b> states, 'Readying subject.'</span>")
			src.occupant.show_message("<span class='notice'>You hear a faint voice. <span class='warning'><b>\The [src]</b> states 'Readying Subject.'</span>")
			src.occupant.show_message("<span class='warning'>A pair of rollers rolls you onto your back.</span>")
			sleep(20)
			src.occupant.show_message("<span class='warning'>Padded cuffs extend from the sides of <b>\The [src]</b> and take ahold of your arms and legs.</span>")
			sleep(40)
			visible_message("<span class='warning'><b>\The [src]</b> states, 'Subject Ready. Engaging Muzzle.'</span>")
			src.occupant.show_message("<span class='notice'>You hear a faint voice. <span class='warning'><b>\The [src]</b> states 'Subject Ready. Engaging Muzzle.'</span>")
			sleep(30)
			src.occupant.show_message("<span class='warning'>A muzzle extends from above and clamps onto your mouth.</span>")
			src.occupant.sdisabilities |= MUTE
			sleep(30)
			visible_message("<span class='warning'><b>\The [src]</b> states 'Deploying Tenderizers.'</span>")
			src.occupant.show_message("<span class='notice'>You hear a faint voice. <span class='warning'><b>\The [src]</b> states 'Deploying Tenderizers..'</span>")
			sleep(20)
			src.occupant.show_message("<span class='warning'>You feel a panel open underneath you.</span>")
			sleep(30)
			src.occupant.show_message("<span class='warning'>A large blow strikes your back.</span>")
			src.occupant.show_message("<span class='warning'><b>Oh god, the pain! </b></span>")
			src.occupant.apply_effect(15, AGONY, 0)
			src.occupant.apply_damage(20, BRUTE, "chest", 0)
			sleep(30)
			src.occupant.show_message("<span class='warning'><b>A blow strikes your right leg.</b></span>")
			src.occupant.apply_effect(10, AGONY, 0)
			RL.fracture()
			sleep(10)
			src.occupant.show_message("<span class='warning'><b>Another blow strikes your left leg.</b></span>")
			src.occupant.apply_effect(10, AGONY, 0)
			LL.fracture()
			sleep(10)
			src.occupant.show_message("<span class='warning'><b>A number of blows strike your torso and groin.</b></span>")
			src.occupant.apply_damage(15, BRUTE, "groin", 0)
			src.occupant.apply_damage(15, BRUTE, "chest", 0)
			sleep(10)
			src.occupant.resting = 1
			sleep(40)
			visible_message("<span class='warning'><b>\The [src]</b> states, 'Deploying Grinders.'</span>")
			src.occupant.show_message("<span class='notice'>You hear a faint voice. <span class='warning'><b>\The [src]</b> states 'Deploying Grinders.'</span>")
			sleep(30)
			src.occupant.show_message("<span class='warning'>A number of sharp points dig into your arms, and legs.</span>")
			sleep(10)
			src.occupant.show_message("<span class='warning'>A large clamp seals around your waist. This can't bode well.</span>")
			sleep(30)
			visible_message("<span class='warning'><b>\The [src]</b> states 'Engaging Grinders.'</span>")
			src.occupant.show_message("<span class='notice'>You hear a faint voice. <span class='warning'><b>\The [src]</b> states 'Engaging Grinders.'</span>")
			sleep(30)
			visible_message("<span class='warning'>\The [src] starts rumbling!</span>")
			src.occupant.show_message("<span class='warning'><b> You feel an extreme amount of pain as your hands and feet are seperated from your body. </b></span>")
			src.occupant.apply_effect(40, AGONY, 0)
			visible_message("<span class='warning'>You hear a loud squelchy grinding sound.</span>")
			sleep(20)
			src.occupant.show_message("<span class='warning'><b>You make a loud groan as your knees and elbows are seperated. </b></span>")
			visible_message("<b>[src.occupant]</b> groans loudly.</span>")
			sleep(40)
			src.occupant.show_message("<span class='warning'><b>As a blade saws your remaining limbs off, you attempt to scream out, but only make a little whimper. </b></span>")
			visible_message("<b>[src.occupant]</b> lightly whimpers.</span>")
			sleep(40)
			src.occupant.show_message("<span class='warning'><b>You feel a serrated blade splitting your torso open! </b></span>")
			src.occupant.apply_effect(20, AGONY, 0)
			sleep(30)
			src.occupant.show_message("<span class='warning'><b>You feel your intense agony coming to an end as your internal organs are ripped out by a claw. </b></span>")
			visible_message("<span class='warning'><b>\The [src]</b> states, 'Gibbing Complete!'</span>")
			sleep(20)

	playsound(src.loc, 'sound/effects/gib.ogg', 50, 1)

	src.occupant.death(1)
	src.occupant.ghostize()

	del(src.occupant)

	spawn(src.gibtime)

		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
		operating = 0

		for (var/obj/item/thing in contents) //Meat is spawned inside the gibber and thrown out afterwards.
			thing.loc = get_turf(thing) // Drop it onto the turf for throwing.
			thing.throw_at(get_edge_target_turf(src,gib_throw_dir),rand(1,5),15) // Being pelted with bits of meat and bone would hurt.

		for (var/obj/effect/gibs in contents) //throw out the gibs too
			gibs.loc = get_turf(gibs) //drop onto turf for throwing
			gibs.throw_at(get_edge_target_turf(src,gib_throw_dir),rand(1,5),15)

		src.operating = 0
		update_icon()