var/global/wcBar = pick(list("#0d8395", "#58b5c3", "#58c366", "#90d79a", "#ffffff"))
var/global/wcBrig = pick(list("#aa0808", "#7f0606", "#ff0000"))
var/global/wcCommon = pick(list("#379963", "#0d8395", "#58b5c3", "#49e46e", "#8fcf44", "#ffffff"))

/obj/proc/color_windows(var/obj/W as obj)
	var/list/wcBarAreas = list(/area/crew_quarters/bar)
	var/list/wcBrigAreas = list(/area/security,/area/prison,/area/shuttle/gamma)

	var/newcolor
	var/turf/T = get_turf(W)
	if(!istype(T))	return
	var/area/A = T.loc

	if(is_type_in_list(A,wcBarAreas))
		newcolor = wcBar
	else if(is_type_in_list(A,wcBrigAreas))
		newcolor = wcBrig
	else
		newcolor = wcCommon

	return newcolor

/obj/structure/window
	name = "window"
	desc = "A window."
	icon = 'icons/obj/structures.dmi'
	density = 1
	layer = 3.2//Just above doors
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = 1.0
	flags = ON_BORDER
	var/health = 14.0
	var/ini_dir = null
	var/state = 2
	var/reinf = 0
	var/basestate
	var/shardtype = /obj/item/shard
	var/glasstype = /obj/item/stack/sheet/glass
	var/disassembled = 0
	var/sheets = 1 // Number of sheets needed to build this window (determines how much shit is spawned by destroy())
//	var/silicate = 0 // number of units of silicate
//	var/icon/silicateIcon = null // the silicated icon

/obj/structure/window/bullet_act(var/obj/item/projectile/Proj)
	if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		health -= Proj.damage
		air_update_turf(1)
	..()
	if(health <= 0)
		destroy()
	return

// This should result in the same materials used to make the window.
/obj/structure/window/proc/destroy()
	for(var/i=0;i<sheets;i++)
		new shardtype(loc)

		if(reinf)
			new /obj/item/stack/rods(loc)
	qdel(src)

/obj/structure/window/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			destroy()
			return
		if(3.0)
			if(prob(50))
				destroy()
				return


/obj/structure/window/blob_act()
	destroy()

/obj/structure/window/narsie_act()
	color = "#7D1919"

/obj/structure/window/rpd_act()
	return

/obj/structure/window/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		destroy()

/obj/structure/window/CheckExit(var/atom/movable/O, var/turf/target)
	if(istype(O) && O.checkpass(PASSGLASS))
		return 1
	if(get_dir(O.loc, target) == dir)
		return !density
	return 1

/obj/structure/window/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(dir == SOUTHWEST || dir == SOUTHEAST || dir == NORTHWEST || dir == NORTHEAST)
		return 0	//full tile window, you can't move into it!
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/structure/window/CanAStarPass(ID, to_dir)
	if(!density)
		return 1
	if((dir == SOUTHWEST) || (dir == to_dir))
		return 0

	return 1

/obj/structure/window/hitby(atom/movable/AM)
	..()
	var/tforce = 0
	if(ismob(AM))
		tforce = 10
	else if(isobj(AM))
		var/obj/O = AM
		tforce = O.throwforce
	if(reinf)
		tforce *= 0.25
	playsound(loc, 'sound/effects/Glasshit.ogg', 100, 1)
	health = max(0, health - tforce)
	if(health <= 7 && !reinf)
		anchored = 0
		update_nearby_icons()
		step(src, get_dir(AM, src))
	if(health <= 0)
		destroy()


/obj/structure/window/attack_hand(mob/user as mob)
	if(HULK in user.mutations)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
		user.visible_message("<span class='danger'>[user] smashes through [src]!</span>")
		destroy()
	else if(user.a_intent == INTENT_HARM)
		user.changeNext_move(CLICK_CD_MELEE)
		playsound(get_turf(src), 'sound/effects/glassknock.ogg', 80, 1)
		user.visible_message("<span class='warning'>[user.name] bangs against the [src.name]!</span>", \
							"<span class='warning'>You bang against the [src.name]!</span>", \
							"You hear a banging sound.")
	else
		user.changeNext_move(CLICK_CD_MELEE)
		playsound(src.loc, 'sound/effects/glassknock.ogg', 80, 1)
		user.visible_message("[user.name] knocks on the [src.name].", \
							"You knock on the [src.name].", \
							"You hear a knocking sound.")
	return


/obj/structure/window/attack_generic(mob/living/user, damage = 0)	//used by attack_alien, attack_animal, and attack_slime
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	health -= damage
	if(health <= 0)
		user.visible_message("<span class='danger'>[user] smashes through [src]!</span>")
		destroy()
	else	//for nicer text~
		user.visible_message("<span class='danger'>[user] smashes into [src]!</span>")
		playsound(loc, 'sound/effects/Glasshit.ogg', 100, 1)


/obj/structure/window/attack_alien(mob/living/user as mob)
	if(islarva(user)) return
	attack_generic(user, 15)

/obj/structure/window/attack_animal(mob/living/user as mob)
	if(!isanimal(user)) return
	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0 || (M.melee_damage_type != BRUTE && M.melee_damage_type != BURN))
		return
	attack_generic(M, M.melee_damage_upper)


/obj/structure/window/attack_slime(mob/living/user as mob)
	var/mob/living/carbon/slime/S = user
	if(!S.is_adult)
		return
	attack_generic(user, rand(10, 15))


/obj/structure/window/attackby(obj/item/I as obj, mob/living/user as mob, params)
	if(!istype(I))
		return//I really wish I did not need this
	if(istype(I, /obj/item/grab) && get_dist(src,user)<2)
		var/obj/item/grab/G = I
		if(istype(G.affecting,/mob/living))
			var/mob/living/M = G.affecting
			var/state = G.state
			qdel(I)	//gotta delete it here because if window breaks, it won't get deleted
			switch(state)
				if(1)
					M.visible_message("<span class='warning'>[user] slams [M] against \the [src]!</span>")
					M.apply_damage(7)
					hit(10)
				if(2)
					M.visible_message("<span class='danger'>[user] bashes [M] against \the [src]!</span>")
					if(prob(50))
						M.Weaken(1)
					M.apply_damage(10)
					hit(25)
				if(3)
					M.visible_message("<span class='danger'><big>[user] crushes [M] against \the [src]!</big></span>")
					M.Weaken(5)
					M.apply_damage(20)
					hit(50)
				if(4)
					visible_message("<span class='danger'><big>[user] smashes [M] against \the [src]!</big></span>")
					M.Weaken(5)
					M.apply_damage(30)
					hit(75)
			return
	if(I.flags & NOBLUDGEON)
		return

	if(handle_decon(I, user, is_fulltile()))
		return

	if(I.damtype == BRUTE || I.damtype == BURN)
		user.changeNext_move(CLICK_CD_MELEE)
		hit(I.force)
		if(health <= 7)
			anchored = 0
			update_nearby_icons()
			step(src, get_dir(user, src))
	else
		playsound(loc, 'sound/effects/Glasshit.ogg', 75, 1)
	..()

/obj/structure/window/proc/handle_decon(obj/item/W, mob/user, var/takes_time = FALSE)
	//screwdriver
	if(isscrewdriver(W))
		playsound(loc, W.usesound, 75, 1)
		if(reinf)
			if(state == 0)
				if(takes_time)
					to_chat(user, "<span class='notice'>You begin to [anchored ? "unfasten the frame from" : "fasten the frame to"] the floor.</span>")
					if(!do_after(user, 20 * W.toolspeed, target = src))
						return 1
				anchored = !anchored
				to_chat(user, "<span class='notice'>You have [anchored? "fastened the frame to" : "unfastened the frame from"] the floor.</span>")
			if(state >= 1)
				if(takes_time)
					to_chat(user, "<span class='notice'>You begin to [(state == 1) ? "fasten the window to" : "unfasten the window from"] the frame.</span>")
					if(!do_after(user, 20 * W.toolspeed, target = src))
						return 1
				state = 3 - state
				to_chat(user, "<span class='notice'>You have [(state == 1) ? "unfastened the window from" : "fastened the window to"] the frame.</span>")
		else
			if(takes_time)
				to_chat(user, "<span class='notice'>You begin to [anchored ? "unfasten the frame from" : "fasten the frame to"] the floor.</span>")
				if(!do_after(user, 20 * W.toolspeed, target = src))
					return 1
			anchored = !anchored
			update_nearby_icons()
			to_chat(user, "<span class='notice'>You have [anchored ? "fastened the window to" : "unfastened the window from"] the floor.</span>")
		return 1
	//crowbar
	if(iscrowbar(W))
		if(!reinf || state > 1)
			return 0
		playsound(loc, W.usesound, 75, 1)
		if(takes_time)
			to_chat(user, "<span class='notice'>You begin to pry the window [state ? "out of" : "in to"] the frame.</span>")
			if(!do_after(user, 20 * W.toolspeed, target = src))
				return 1
		state = 1 - state
		to_chat(user, "<span class='notice'>You have pried the window [state ? "into" : "out of"] the frame.</span>")
		return 1
	//wrench
	if(iswrench(W))
		if(anchored)
			return 0
		playsound(loc, W.usesound, 50, 1)
		if(takes_time)
			to_chat(user, "<span class='notice'>You begin to disassemble [src]...</span>")
			if(!do_after(user, 20 * W.toolspeed, target = src))
				return 1
		for(var/i=0; i<sheets; i++)
			var/obj/item/stack/sheet/NS = new glasstype(get_turf(src))	//glass types don't share a base tye of /glass, so this didn't work for plasma glass
			for(var/obj/item/stack/sheet/S in loc) //Stack em up
				if(S == NS)
					continue
				if(S.amount >= S.max_amount)
					continue
				S.attackby(NS, user)

			if(reinf)
				var/obj/item/stack/rods/NR = new (get_turf(src))
				for(var/obj/item/stack/rods/R in loc)
					if(R == NR)
						continue
					if(R.amount >= R.max_amount)
						continue
					R.attackby(NR, user)

		to_chat(user, "<span class='notice'>You have disassembled [src].</span>")
		disassembled = 1
		density = 0
		air_update_turf(1)
		update_nearby_icons()
		qdel(src)
		return 1

/obj/structure/window/mech_melee_attack(obj/mecha/M)
	if(..())
		hit(M.force, 1)

/obj/structure/window/proc/hit(var/damage, var/sound_effect = 1)
	if(reinf) damage *= 0.5
	health = max(0, health - damage)
	if(sound_effect)
		playsound(loc, 'sound/effects/Glasshit.ogg', 75, 1)
	if(health <= 0)
		destroy()
		return


/obj/structure/window/verb/rotate()
	set name = "Rotate Window Counter-Clockwise"
	set category = "Object"
	set src in oview(1)

	if(usr.stat || !usr.canmove || usr.restrained())
		return

	if(anchored)
		to_chat(usr, "<span class='warning'>It is fastened to the floor therefore you can't rotate it!</span>")
		return 0

	dir = turn(dir, 90)
//	updateSilicate()
	air_update_turf(1)
	ini_dir = dir
	add_fingerprint(usr)
	return

/obj/structure/window/verb/revrotate()
	set name = "Rotate Window Clockwise"
	set category = "Object"
	set src in oview(1)

	if(usr.stat || !usr.canmove || usr.restrained())
		return

	if(anchored)
		to_chat(usr, "<span class='warning'>It is fastened to the floor therefore you can't rotate it!</span>")
		return 0

	dir = turn(dir, 270)
//	updateSilicate()
	air_update_turf(1)
	ini_dir = dir
	add_fingerprint(usr)
	return


/obj/structure/window/AltClick(mob/user)
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!Adjacent(user))
		return
	revrotate()

/*
/obj/structure/window/proc/updateSilicate()
	if(silicateIcon && silicate)
		icon = initial(icon)

		var/icon/I = icon(icon,icon_state,dir)

		var/r = (silicate / 100) + 1
		var/g = (silicate / 70) + 1
		var/b = (silicate / 50) + 1
		I.SetIntensity(r,g,b)
		icon = I
		silicateIcon = I
*/

/obj/structure/window/New(Loc,re=0)
	..()
	ini_dir = dir
	if(!color && !istype(src,/obj/structure/window/plasmabasic) && !istype(src,/obj/structure/window/plasmareinforced))
		color = color_windows(src)
	update_nearby_icons()
	return

/obj/structure/window/Initialize()
	air_update_turf(1)
	return ..()

/obj/structure/window/Destroy()
	density = 0
	air_update_turf(1)
	if(loc && !disassembled)
		playsound(get_turf(src), "shatter", 70, 1)
	return ..()


/obj/structure/window/Move()
	var/turf/T = loc
	..()
	dir = ini_dir
	move_update_air(T)

//checks if this window is full-tile one
/obj/structure/window/proc/is_fulltile()
	if(dir & (dir - 1))
		return 1
	return 0

/obj/structure/window/CanAtmosPass(turf/T)
	if(get_dir(loc, T) == dir)
		return !density
	if(dir == SOUTHWEST || dir == SOUTHEAST || dir == NORTHWEST || dir == NORTHEAST)
		return !density
	return 1

//This proc is used to update the icons of nearby windows.
/obj/structure/window/proc/update_nearby_icons()
	if(!loc) return 0
	update_icon()
	for(var/direction in cardinal)
		for(var/obj/structure/window/W in get_step(src,direction) )
			W.update_icon()

/obj/structure/window/update_icon()
	return

/obj/structure/window/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 800)
		hit(round(exposed_volume / 100), 0)
	..()

/obj/structure/window/basic
	icon_state = "window"
	desc = "It looks thin and flimsy. A few knocks with... anything, really should shatter it."
	basestate = "window"

/obj/structure/window/plasmabasic
	name = "plasma window"
	desc = "A plasma-glass alloy window. It looks insanely tough to break. It appears it's also insanely tough to burn through."
	basestate = "plasmawindow"
	icon_state = "plasmawindow"
	shardtype = /obj/item/shard/plasma
	glasstype = /obj/item/stack/sheet/plasmaglass
	health = 120
	armor = list("melee" = 75, "bullet" = 5, "laser" = 0, "energy" = 0, "bomb" = 45, "bio" = 100, "rad" = 100)

/obj/structure/window/plasmabasic/New(Loc,re=0)
	..()
	ini_dir = dir
	update_nearby_icons()
	return

/obj/structure/window/plasmabasic/Initialize()
	..()
	air_update_turf(1)

/obj/structure/window/plasmabasic/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 32000)
		hit(round(exposed_volume / 1000), 0)
	..()

/obj/structure/window/plasmabasic/BlockSuperconductivity()
	return 1

/obj/structure/window/plasmareinforced
	name = "reinforced plasma window"
	desc = "A plasma-glass alloy window, with rods supporting it. It looks hopelessly tough to break. It also looks completely fireproof, considering how basic plasma windows are insanely fireproof."
	basestate = "plasmarwindow"
	icon_state = "plasmarwindow"
	shardtype = /obj/item/shard/plasma
	glasstype = /obj/item/stack/sheet/plasmaglass
	reinf = 1
	health = 160
	armor = list("melee" = 85, "bullet" = 20, "laser" = 0, "energy" = 0, "bomb" = 60, "bio" = 100, "rad" = 100)

/obj/structure/window/plasmareinforced/New(Loc,re=0)
	..()
	ini_dir = dir
	update_nearby_icons()
	return

/obj/structure/window/plasmareinforced/Initialize()
	..()
	air_update_turf(1)

/obj/structure/window/plasmareinforced/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/structure/window/plasmareinforced/BlockSuperconductivity()
	return 1 //okay this SHOULD MAKE THE TOXINS CHAMBER WORK

/obj/structure/window/reinforced
	name = "reinforced window"
	desc = "It looks rather strong. Might take a few good hits to shatter it."
	icon_state = "rwindow"
	reinf = 1
	basestate = "rwindow"
	health = 40
	armor = list("melee" = 50, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 25, "bio" = 100, "rad" = 100)

/obj/structure/window/reinforced/tinted
	name = "tinted window"
	desc = "It looks rather strong and opaque. Might take a few good hits to shatter it."
	icon_state = "twindow"
	basestate = "twindow"
	opacity = 1

/obj/structure/window/reinforced/tinted/frosted
	name = "frosted window"
	desc = "It looks rather strong and frosted over. Looks like it might take a few less hits then a normal reinforced window."
	icon_state = "fwindow"
	basestate = "fwindow"
	health = 30

/obj/structure/window/reinforced/polarized
	name = "electrochromic window"
	desc = "Adjusts its tint with voltage. Might take a few good hits to shatter it."
	var/id

/obj/structure/window/reinforced/polarized/proc/toggle()
	if(opacity)
		animate(src, color="#FFFFFF", time=5)
		set_opacity(0)
	else
		animate(src, color="#222222", time=5)
		set_opacity(1)



/obj/machinery/button/windowtint
	name = "window tint control"
	icon = 'icons/obj/power.dmi'
	icon_state = "light0"
	desc = "A remote control switch for polarized windows."
	var/range = 7
	var/id = 0
	var/active = 0

/obj/machinery/button/windowtint/attack_hand(mob/user as mob)
	if(..())
		return 1

	toggle_tint()

/obj/machinery/button/windowtint/proc/toggle_tint()
	use_power(5)

	active = !active
	update_icon()

	for(var/obj/structure/window/reinforced/polarized/W in range(src,range))
		if(W.id == src.id || !W.id)
			spawn(0)
				W.toggle()
				return

/obj/machinery/button/windowtint/power_change()
	..()
	if(active && !powered(power_channel))
		toggle_tint()

/obj/machinery/button/windowtint/update_icon()
	icon_state = "light[active]"
