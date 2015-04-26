/obj/machinery/larkens
	name = "larkens machine"
	desc = "You shouldn't be seeing this."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "scanner"

/obj/machinery/larkens/var/list/larkenslist = list("Shadow Larkens","Jenny Larkens","Jennifer Larkens","Skye Larkens","Violet Larkens","Gemma Larkens","Bianca Larkens","Mazika Larkens", \
													"Jamie Larkens","Haley Larkens","Squishy Larkens","Monica Larkens","Angeline Larkens")

/obj/machinery/larkens/proc/isLarkens(var/mob/M)
	if(larkenslist.Find(M.real_name))
		return 1
	return 0