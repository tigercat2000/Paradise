/*
Creature-level abilities.
*/

/var/global/list/ability_verbs = list(	)

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

/mob/living/carbon/human/proc/slime_release()
	set category = "Abilities"
	set name = "Release 'hugged' people."
	set desc = "Release everyone or anyone in your slime."

	if(slime_contents.len <= 0)
		usr << "<span class='warning'>You don't have anyone in your slime!</span>"
		return

	if(!ishumanslime(usr))
		usr << "How the fuck did you get this?"
		return 0 //no

	var/list/victims = list()
	victims += "Everyone"

	for(var/mob/M in src.slime_contents)
		victims += M

	victims += "--CANCEL--"

	var/chosen = input("Choose who you wish to release, or everyone.","Releasing 'hugged' people","--CANCEL--") in victims

	if(chosen == "Everyone")
		for(var/mob/M in src.slime_contents)
			M.loc = src.loc
			slime_contents.Remove(M)

	if(chosen == "--CANCEL--")
		src << "<span class='notice'>You decide not to release anyone from your hug.</span>"
		return

	if(!(chosen == "Everyone"||chosen == "--CANCEL--"))
		var/mob/mobtorelease = chosen
		mobtorelease.loc = src.loc
		src.slime_contents.Remove(mobtorelease)
		src << "<span class='notice'>You release \the [chosen] from your slime.</span>"
		return

/mob/living/carbon/human/proc/slime_underdoor()
	set category = "Abilities"
	set name = "Slime under a door"
	set desc = "Squish! Infiltrate! Hug! Squish!"

	var/mob/user = usr

	if(!ishumanslime(user))
		usr << "ABUSE"
		return 0 //no

	var/list/nearbydoors = list()

	for(var/cdir in cardinal)
		for(var/obj/machinery/door/D in get_step(src,cdir))
			nearbydoors[D.name] += D

	nearbydoors += "--CANCEL--"

	var/choice = input("Which door would you like to move under?","Doorcrawl","--CANCEL--") in nearbydoors
	if(!choice || choice == "--CANCEL--")	return
	var/obj/machinery/door/crawl_door = nearbydoors[choice]
	if(!istype(crawl_door))	return

	user.visible_message("<span class='warning'>\The [user.name] starts to slime under \the [crawl_door.name]!","<span class='notice'>You start to slime under \the [crawl_door.name]!</span>")

	if(do_after(user, 50, target = crawl_door))
		var/go_dir = get_dir(user,crawl_door)
		user.forceMove(get_turf(crawl_door))
		spawn(1)
			user.forceMove(get_step(crawl_door,go_dir))
			user.visible_message("<span class='warning'>\The [user.name] slimes under \the [crawl_door.name]!","<span class='notice'>You slime under \the [crawl_door.name]!</span>")