--
-- FOX HEN CORN
--

-- A classic logic puzzle translated to space nerdery.
-- Instruct player to proceed to erph_starbase to retrieve the exotic hazardous materials, which will then be delivered to DS8
-- After docking, receive materials in inventory, receive explanation that cargo bays 0 and 1 have been enhanced with stabilizers and shielding
-- Receive reminders to proceed to DS8 to deliver the exotic hazardous materials, and to do so safely
-- Huge nebula must be crossed, too dangerous to cross with all cargo at once, since only two cargo bays are shielded. (Bay 0 and Bay 1)
-- at impulse power, it takes 80 seconds to cross the nebula. 
-- mcguffins can remain stable for just over 100 seconds OUTSIDE of nebula with NO resonant objects in proximity . It would take only an 1/8th of that time if an exacerbation is present (high heat, high gravity, resonant matter, detonations, space warping/folding)
-- It would be nice to be able to divert power to the cargo bays from engineering (to power special equipment modules, like refrigerator or magnetic containment module. maybe we could artificially set higher heat than normal on an existing system and just tell user we "rerouted and spliced" the special stabilizing power circuits in temporarily.


-- First, clear the board
clear_all();

startx = 52000;
starty = 6000;



zarkon = 3;
disruptor = 12;


-- find the player and move him where we want him to start.
player_ids = get_player_ship_ids();
player_name = "Unknown Player";
if (player_ids[1]) then
    move_object(player_ids[1], startx, starty, 0);
    player_name = get_object_name(player_ids[1]);
    reset_player_ship(player_ids[1]);
else
    print("PLAYER IDS NOT FOUND!");
end

x = 50000;
y = 12000;
z = 290000;

zarkx = 250000;
zarky = -12000;
zarkz = 52000 ;

erphx = x;
erphy = y - 6000;
erphz = z - 12000;


nowwhat = add_planet("NOWWHAT", 3000, 3000, 2000, 5000);
nowwhat_starbase = add_starbase(8500, 5500, 2200, 1);

erph = add_planet("ERPH", erphx, erphy, erphz, 3000);
erph_starbase = add_starbase(erphx + 500, erphy + 4500, erphz - 1000, 2);

zark = add_planet("ZARK", zarkx, zarky, zarkz, 0); 
zark_starbase = add_starbase(zarkx + 900, zarky - 1200, zarkz + 1700, 3);

n1 = add_nebula("INSANITY-MAJORIS", x + 5000, y - 100, z - 1500, 5000);
n2 = add_nebula("INSANITY-MINORIS", x + 500, y - 200, z - 3000, 3000);
n3 = add_nebula("INSANITY", x + 8000, y - 700, z - 2500, 2000);
n4 = add_nebula("INSANITY II", x + 18000, y - 700, z - 2000, 2000);

--ds8_starbase = add_starbase(erphx + 250000, erphy + 18500, erphz + 1600, 8);
ds8_starbase = add_starbase(erphx + 20000, erphy + 18500, erphz + 1600, 8);
	
--name, unit, base_price, volatility, legality, econ_sensitivity, govt_sensitivity, tech_sensitivity, odds);
xof_mcg = add_commodity("TELLURIUM XOFINATE CRYSTALS", "kilograms", "exotic compound", 8000, 0.2, 0.2, 0.2, 0.2, 0.8, 0.0);
neh_mcg = add_commodity("NEHEMISTATIC CRYSTALS", "kilograms", "exotic crystal", 80000, .1, .1, .1, .2, .8, 0.0);
nroc_mcg = add_commodity("LIQUIFIED NROCHIAN CONCENTRATE", "kilograms", "exotic compound", 9000, .1, .1, .1, .2, .8, 0.0);


shipname = { "KARK", "TROZZMA", "JYRNNY"}
baddy = { -1, -1, -1 }
alive = { 0, 0, 0 }

function add_some_asteroids()
	for i = 1, 200 do
		done = false
		while (not done)
		do
			dx = math.random(40000) - 20000;
			dy = math.random(40000) - 20000;
			dz = math.random(40000) - 20000;
			distance = math.sqrt(dx * dx + dy * dy + dz * dz);
			if distance > 13000 and distance < 20000 then
				done = true;
			end
		end
		add_asteroid(erphx + dx, erphy + dy, erphz + dz);
	end
end

add_some_asteroids();

function add_bad_guys(cookie)

	text_to_speech(player_ids[1], "WARNING: Zarkon disruptors detected in this sector.");
	for i = 1, #shipname do
		print("Adding " .. shipname[i]);
		baddy[i] = add_ship(shipname[i], x, y, z, disruptor, zarkon, 0);
		alive[i] = 1;
		-- ai_push_attack(baddy[i], erph);
		y = y + 250;
	end

	comms_transmission(erph_starbase, "");
	comms_transmission(erph_starbase, "");
	comms_transmission(erph_starbase, "");
	comms_transmission(erph_starbase, "");
	comms_transmission(erph_starbase, "");
	comms_transmission(erph_starbase, " A FLEET OF ZARKON DISRUPTORS HAS WARPED");
	comms_transmission(erph_starbase, " INTO THE AREA.  THEIR INTENTIONS ARE UNKNOWN");
	comms_transmission(erph_starbase, " MIND YOUR CARGO, BATTLE MAY DESTABILIZE");
	comms_transmission(erph_starbase, " POSSIBLY FATALLY!");
end

function exotic_materials_loaded()
	comms_transmission(erph_starbase, "");
	--comms_transmission(erph_starbase, " SPECIAL MODIFICATIONS TO CARGO BAYS 0, 1, and 2");
	comms_transmission(erph_starbase, " AFTER INSPECTION, ALL CARGO BAYS APPEAR TO BE");
	comms_transmission(erph_starbase, " SUITABLE FOR TRANSPORT OF THESE HIGHLY HAZARDOUS MATERIALS.");
	comms_transmission(erph_starbase, " POWERED ACTIVE STABILIZATION AND TEMP. CONTROL IS CRUCIAL. ");
	comms_transmission(erph_starbase, " AS SOON AS THE MATERIALS LEAVE THESE ");
	comms_transmission(erph_starbase, " SPECIALLY EQUIPPED BAYS, THERE WILL BE");
	comms_transmission(erph_starbase, " A SAFE PERIOD OF ABOUT TWO MINUTES BEFORE");
	comms_transmission(erph_starbase, " THEY DESTABILIZE AND EXPLODE! ALL TRANSFERS MUST BE QUICK!");
	comms_transmission(erph_starbase, " PLEASE NOTE: WHILE ALL BAYS MEET POWER AND TEMP REQUIREMENTS,");
	comms_transmission(erph_starbase, " ONLY CARGO BAYS 0 AND 1 HAVE SUFFICIENT SHIELDING TO SAFELY");
	comms_transmission(erph_starbase, " TRANSIT HIGH-ENERGY ENVIRONMENTS SUCH AS NEBULAE.");
	comms_transmission(erph_starbase, " ALSO NOTE: THE TWO CRYSTALLINE MATERIALS ARE HARMONICALLY");
	comms_transmission(erph_starbase, " RESONANT WITH EACH OTHER. ");
	comms_transmission(erph_starbase, " ALSO THE NEHEMISTATIC CRYSTALS ARE HARMONICALLY RESONONANT");
	comms_transmission(erph_starbase, " WITH THE NROCHIAN CONCENTRATE.");
	comms_transmission(erph_starbase, " THIS MEANS THAT IF THEY ARE IN PROXIMITY TO EACH OTHER ");
	comms_transmission(erph_starbase, " WITHOUT THE BENEFIT OF STABILIZATION AND SHIELDING FROM");
	comms_transmission(erph_starbase, " EACH OTHER, THEY WILL EXPLODE CATASTROPHICALLY WITHIN");
	comms_transmission(erph_starbase, " 12 SECONDS AS A CASCADING HARMONIC RESONANCE BUILDS.");

	set_commodity_contents(player_ids[1], xof_mcg, 1.0, 0);
	set_commodity_contents(player_ids[1], neh_mcg, 1.0, 1);
	set_commodity_contents(player_ids[1], nroc_mcg, 1.0, 2);

 
	comms_transmission(erph_starbase, " TELLURIUM XOFINATE CRYSTALS LOADED AND STABILIZED");
	comms_transmission(erph_starbase, " NEHEMISTATIC CRYSTALS LOADED AND STABILIZED");
	comms_transmission(erph_starbase, " LIQUIFIED NROCHIAN CONCENTRATE LOADED AND STABILIZED");
	comms_transmission(erph_starbase, " READY TO SET OUT CAPTAIN. PLEASE INSTRUCT YOUR CREW");
	comms_transmission(erph_starbase, " TO KEEP THE TEMPERATURE UNDER 118 DEGREES KELVIN,");
	comms_transmission(erph_starbase, " ACCELERATIONS BELOW 10m/s/s, AND NO WARP SPEED!");
	
	comms_transmission(erph_starbase, " PLEASE PROCEED, SAFELY, BUT EXPIDITIOUSLY TO DEEPSPACE 8.");
	--give coords right off?

	comms_transmission(erph_starbase, "");
	
end


function final_score()

	text_to_speech(player_ids[1], "All the hazardous exotic materials have been safely delivered.");
	text_to_speech(player_ids[1], "Commendations to the captain and crew.");

	comms_transmission(erph_starbase, "ALL MATERIALS SUCCESSFULLY DELIVERED.");
	comms_transmission(erph_starbase, player_name .. ", THANK YOU FOR YOUR ASSISTANCE");
	comms_transmission(erph_starbase, "IN DELIVERING THESE EXTREMELY IMPORTANT MATERIALS.");
	comms_transmission(erph_starbase, "YOU HAVE SAVED LIVES AS WELL AS THE SCIENTIFIC MISSION.");
	comms_transmission(erph_starbase, "");
end

function object_death_callback(oid)
	dead_count = 0;
	alive_count = 0;
	for i = 1, 5 do
		if oid == baddy[i] then
			alive[i] = 0;
			dead_count = dead_count + 1
		end
		if alive[i] > 0 then
			alive_count = alive_count + 1
		end
	end
	if dead_count > 0 then
		text_to_speech(player_ids[1], "Zarkon ship destroyed.");
		comms_transmission(erph_starbase, "");
		comms_transmission(erph_starbase, player_name .. ", ANOTHER ONE BITES THE DUST");
		if alive_count > 0 then
			comms_transmission(erph_starbase, "ONLY " .. alive_count .. " MORE TO GO");
			text_to_speech(player_ids[1], alive_count .. " Zarkon ships remain.");
		else
			final_score();
		end
	end
end

function first_request_delivery_callback(oid)
    comms_transmission(erph_starbase, player_name .. ", THIS IS "..get_object_name(ds8_starbase)..", JUST TO LET YOU KNOW, WITHOUT THOSE MATERIALS");
    comms_transmission(erph_starbase, "OUR CYCLOTRONIC HYPER-REACTOR WILL GO CRITICAL WITHIN TWO HOURS.");
    comms_transmission(erph_starbase, "NO PRESSURE OR ANYTHING, BUT TIME IS OF THE ESSENCE!");

    register_timer_callback("rerequest_delivery_callback", math.random(20,120) * 20, 0);
end

function rerequest_delivery_callback(oid)
    variety = math.floor(math.random(1,4));
    if variety == 1 then
	    comms_transmission(erph_starbase, player_name .. ", WHERE ARE THOSE SHIPMENTS OF EXOTIC COMPONENTS?!");
    elseif variety == 2 then
	    comms_transmission(erph_starbase, "REALLY NEED THOSE MATERIALS. CAN YOU HURRY IT UP?");
    elseif variety == 3 then
	    comms_transmission(erph_starbase, "BE REALLY CAREFUL WITH THOSE MATERIALS. THEY ARE NOT VERY STABLE.");
    elseif variety == 4 then
	    comms_transmission(erph_starbase, "WHAT EVER YOU DO, DO NOT LET THE MATERIALS GO CRITICAL!");
    end
    --Add variations, reminders of coordinates,  and escalations. maybe even hints?
    -- if check for proximity, stop bugging if close, be encouraging if past the nebula
    register_timer_callback("request_delivery_callback", math.random(20,120) * 20, 0);
end

function player_docked_callback(p_oid, s_oid)
    -- arguments: object id of player, object id of station
	if (s_oid == erph_starbase) then
		exotic_materials_loaded(); 
	elseif s_oid == ds8_starbase then
		--check contents of cargo bays
		cargo = get_ship_attribute(player_ids[1], "cargo[0].contents.item");
		--in list of 3ids xof_mcg neh_mcg nroc_mcg
		--cargo_name = get_commodity_name(cargo);
		--cargo_units = get_commodity_units(cargo);
		    -- else if destinatoin AND ALL exotics on board, unload and declare victory!
		    -- final_score();
	end
end


function hazardous_conditions_callback()
    -- check for all the fail conditions:
    --FOX and HEN outside, and on the same side of the nebula
    --HEN and CORN outside, and on the same side of the nebula
    --ANY of the three in cargo slot > 1 AND player in nebula
    --even ONE of the exotics onboard without a functioning hibbert space modulator

    register_timer_callback("hazardous_conditions_callback", 20);
end



-- Kick everything off now --


show_timed_text(player_ids[1], 15,
    "HAZ-MAT TRANSPORT\n" ..
    "\n" ..
    "EXOTIC HAZARDOUS MATERIALS TRANSPORT\n" ..
    "MISSION ORDERS RECEIVED: \n" ..
    "FLEET COMMAND HAS SENT ORDERS THAT\n" ..
    "THE " .. player_name .. " SHALL\n" ..
    "ASSIST IN THE TRANSPORT OF SOME OF\n" ..
    "THE MOST HAZARDOUS MATERIALS IN THE\n" ..
    "KNOWN GALAXY. THESE RARE MATERIALS\n" ..
    "ARE NEEDED BY "..get_object_name(ds8_starbase).." TO REPLENISH THEIR\n" ..
    "CYCLOTRONIC HYPER-REACTOR. GOOD LUCK.");
 
--register_timer_callback("add_bad_guys", 100, 0);
register_callback("object-death-event", "object_death_callback");

register_callback("player-docked-event", "player_docked_callback"); 
register_timer_callback("first_request_delivery_callback", 10 * 10, 0);
