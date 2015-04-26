/obj/machinery/larkens/autostripper
	name = "Stripping Machine"
	desc = "A large frame with robotic arms. It appears to be intended to remove clothes."

	anchored = 1
	density = 0

	icon = 'icons/obj/machines/metal_detector.dmi'
	icon_state = "metaldetector0"

	use_power = 1
	idle_power_usage = 50
	active_power_usage = 300

	layer = MOB_LAYER+0.1

	var/asid
	var/obj/structure/closet/output
	var/useoutput = 1

/obj/machinery/larkens/autostripper/Crossed(AM as mob|obj)
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(H.abiotic(1))
			handle_stripping(H)
			handle_message(H)
	flick("metaldetector1",src)

/obj/machinery/larkens/autostripper/proc/handle_stripping(var/mob/living/carbon/human/H)
	if(!H)	return

	H.apply_effect(40, STUN, 0)
	H.anchored = 1
	H.visible_message("<span class='warning'>\The [src] grabs ahold of \the [H.name] with it's robotic arms!</span>",\
						"<span class='warning'>\The [src] grabs ahold of you with it's robotic arms, preventing you from moving!</span>")
	sleep(5)
	strip(H)
	sleep(20)

/obj/machinery/larkens/autostripper/proc/handle_message(var/mob/living/carbon/human/H)
	if(!H)	return

	H.visible_message("<span class='warning'>\The [src] releases \the [H.name].</span>" ,\
						"<span class='notice'>\The [src] releases you.</span>")
	H.SetStunned(0)
	H.anchored = 0

/obj/machinery/larkens/autostripper/proc/strip(var/mob/living/carbon/human/H)
	H.visible_message("<span class='warning'>\The [src] quickly removes \the [H.name]'s clothing!</span>", \
						"<span class='warning'>\The [src] removes your clothing.</span>")

	for(var/obj/item/I in H)
		if(istype(I,/obj/item/organ))
			continue

		if(!istype(I,/obj/item/clothing))
			H.unEquip(I)
			if(useoutput)
				movetooutput(I)
			sleep(3)

		else if(istype(I,/obj/item/clothing))
			spawn(1)
				H.unEquip(I)
				if(useoutput)
					movetooutput(I)
				sleep(3)
		else
			spawn(2)
				H.unEquip(I)
				if(useoutput)
					movetooutput(I)
				sleep(3)

	if(H.abiotic(1))
		H.visible_message("<span class='notice'>\The [src] removes \the [H.name]'s remaining items.</span>", \
							"<span class='notice'>\The [src] removes your remaining items!</span>")
		for(var/obj/item/W in H)
			if(istype(W,/obj/item/organ))
				continue
			H.unEquip(W)
			if(useoutput)
				movetooutput(W)
			sleep(3)

/obj/machinery/larkens/autostripper/proc/movetooutput(var/obj/item/I)
	if(!src.output)
		for(var/obj/structure/closet/autostripper/out in autostripperoutputs)
			if(out.asid == asid)
				output = out
				break

	var/obj/item/OI = I

	if(src.output)
		OI.loc = src.output
		return

/obj/machinery/larkens/autostripper/restrain
	name = "Advanced Stripping Machine"
	desc = "A large frame with robotic arms. It appears to be intended to remove clothes, and it has a suspicious extra arm."
	icon = 'icons/obj/machines/metal_detector.dmi'
	icon_state = "metaldetector0"

/obj/machinery/larkens/autostripper/restrain/Crossed(AM as mob|obj)
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(H.abiotic(1))
			handle_stripping(H)
			handle_restraints(H)
		handle_message(H)
	flick("metaldetector1",src)

/obj/machinery/larkens/autostripper/restrain/proc/handle_restraints(var/mob/living/carbon/human/H)
	if(!H)	return

	H.handcuffed = new /obj/item/weapon/restraints/handcuffs/pinkcuffs(H)
	H.visible_message("<span class='warning'>\The [src] slaps a pair of handcuffs onto \the [H.name]!</span>", \
						"<span class='warning'>\The [src] quickly handcuffs you!</span>")
	H.update_inv_handcuffed()

	sleep(10)

	H.equip_or_collect(new /obj/item/clothing/mask/muzzle(H), slot_wear_mask)
	H.visible_message("<span class='warning'>\The [src] straps a muzzle to \the [H.name]'s face!</span>", \
						"<span class='warning'>\The [src] muzzles you!</span>")
	H.update_inv_wear_mask()

	sleep(10)

/obj/machinery/larkens/autostripper/dts
	name = "Disposals Transferal System"
	desc = "Moves living things to a different conveyer."
	var/transferdir = NORTH

/obj/machinery/larkens/autostripper/dts/Crossed(AM as mob|obj)
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(H.abiotic(1))
			handle_stripping(H)
			handle_message(H)
		handle_transfer(H)

	flick("metaldetector1",src)

/obj/machinery/larkens/autostripper/dts/proc/handle_transfer(var/mob/living/carbon/human/H)
	if(!H)	return

	sleep(10)
	H.visible_message("<span class='warning'>\The [src] grabs ahold of \the [H] and moves them!</span>", \
						"<span class='warning'>\The [src] grabs ahold of you with it's robotic arms and moves you through the air!</span>")
	H.forceMove(get_step(src,transferdir))
	H.visible_message("<span class='warning'>\The [H] is knocked over as [src] drops them!</span>",\
						"<span class='warning'>\The [src] drops you abruptly, causing you to fall over!</span>")
	H.resting = 1

/obj/machinery/autostripper/dts/slime
	name = "Slime Person Transferal System"
	desc = "Moves slime people to a different conveyer."

/obj/machinery/larkens/autostripper/dts/slime/Crossed(AM as mob|obj)
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(H.species != "Slime People")
			return
		if(H.abiotic(1))
			handle_stripping(H)
			handle_message(H)
		handle_transfer(H)

	flick("metaldetector1",src)

/obj/structure/closet/autostripper
	name = "Auto-Stripper Output Closet"
	desc = "An output for the auto-stripper."
	var/asid = 0

/obj/structure/closet/autostripper/New()
	..()
	autostripperoutputs += src

/obj/structure/closet/autostripper/Destroy()
	..()
	autostripperoutputs -= src