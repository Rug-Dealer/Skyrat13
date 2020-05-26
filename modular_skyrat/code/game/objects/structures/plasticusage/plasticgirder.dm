/obj/structure/girder/plastic
	name = "plastic girder"
	desc = "A girder made out of 'sturdy' plastic."
	icon = 'modular_skyrat/code/game/objects/structures/plasticusage/plasticstructures.dmi'
	icon_state = "girder"
	max_integrity = 30

/obj/structure/girder/plastic/displaced
	name = "displaced plastic girder"
	icon_state = "displaced"
	max_integrity = 20
	anchored = FALSE
	state = GIRDER_DISPLACED
	girderpasschance = 25

/obj/structure/girder/plastic/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/remains = pick(/obj/item/stack/rods/plastic, /obj/item/stack/sheet/plastic)
		new remains(loc)
	qdel(src)

/obj/structure/girder/plastic/attackby(obj/item/W, mob/living/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/weldingtool) || istype(W, /obj/item/gun/energy/plasmacutter))
		if(!W.tool_start_check(user, amount = 0))
			return
		to_chat(user, "<span class='notice'>You start slicing apart [src]...</span>")
		if(W.use_tool(src, user, 40, volume=50))
			to_chat(user, "<span class='notice'>You slice apart [src].</span>")
			var/obj/item/stack/sheet/plastic/P = new(drop_location(), 2)
			transfer_fingerprints_to(P)
			qdel(src)

	else if(istype(W, /obj/item/pickaxe/drill/jackhammer))
		to_chat(user, "<span class='notice'>Your jackhammer smashes through the girder!</span>")
		var/obj/item/stack/sheet/plastic/P = new(drop_location(), 2)
		transfer_fingerprints_to(P)
		W.play_tool_sound(src)
		qdel(src)

	else if(istype(W, /obj/item/stack/sheet/plastic))
		var/obj/item/stack/sheet/plastic/P = W
		if(state == GIRDER_DISPLACED)
			if(P.get_amount() < 2)
				to_chat(user, "<span class='warning'>You need two sheets of plastic to create a false wall!</span>")
				return
			to_chat(user, "<span class='notice'>You start building a false wall...</span>")
			if(do_after(user, 20, target = src))
				if(P.get_amount() < 2)
					return
				P.use(2)
				to_chat(user, "<span class='notice'>You create a false wall. Push on it to open or close the passage.</span>")
				var/obj/structure/falsewall/plastic/F = new (loc)
				transfer_fingerprints_to(F)
				qdel(src)
		else
			if(P.get_amount() < 2)
				to_chat(user, "<span class='warning'>You need two sheets of plastic to finish a wall!</span>")
				return
			to_chat(user, "<span class='notice'>You start adding plating...</span>")
			if (do_after(user, 40, target = src))
				if(P.get_amount() < 2)
					return
				P.use(2)
				to_chat(user, "<span class='notice'>You add the plating.</span>")
				var/turf/T = get_turf(src)
				T.PlaceOnTop(/turf/closed/wall/plastic)
				transfer_fingerprints_to(T)
				qdel(src)
			return
	else if(istype(W, /obj/item/stack/rods))
		return
	else
		return ..()

// Wrench Act
/obj/structure/girder/plastic/wrench_act(mob/user, obj/item/tool)
	. = FALSE
	if(state == GIRDER_DISPLACED)
		if(!isfloorturf(loc))
			to_chat(user, "<span class='warning'>A floor must be present to secure the girder!</span>")

		to_chat(user, "<span class='notice'>You start securing the girder...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You secure the girder.</span>")
			var/obj/structure/girder/plastic/G = new (loc)
			transfer_fingerprints_to(G)
			qdel(src)
		return TRUE
	else if(state == GIRDER_NORMAL && can_displace)
		to_chat(user, "<span class='notice'>You start unsecuring the girder...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You unsecure the girder.</span>")
			var/obj/structure/girder/plastic/displaced/D = new (loc)
			transfer_fingerprints_to(D)
			qdel(src)
		return TRUE

// Screwdriver Act
/obj/structure/girder/plastic/screwdriver_act(mob/user, obj/item/tool)
	. = FALSE
	if(state == GIRDER_DISPLACED)
		user.visible_message("<span class='warning'>[user] disassembles the girder.</span>",
							 "<span class='notice'>You start to disassemble the girder...</span>",
							 "You hear clanking and banging noises.")
		if(tool.use_tool(src, user, 40, volume=100))
			if(state != GIRDER_DISPLACED)
				return
			state = GIRDER_DISASSEMBLED
			to_chat(user, "<span class='notice'>You disassemble the girder.</span>")
			var/obj/item/stack/sheet/plastic/P = new (loc, 2)
			P.add_fingerprint(user)
			qdel(src)
		return TRUE