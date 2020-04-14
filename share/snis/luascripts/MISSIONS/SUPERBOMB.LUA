--
-- SUPER BOMB
--
-- The fabled Zarkon Doomsday Device is a compatct superbomb that will 
-- extinguish all life, even across whole planets, within its blast radius.
-- Containment is not an option.
-- It has multiple triggers and anti-tampering mechanisms.
-- Disabling is not an option.
-- Alas! One has been detected recently somewhere on board Starbase ICARUS.
-- It must be extracted and transported to a distant empty region of space as
-- quickly as possible. The detonation timer has no more than a few minutes
-- remaining! Help us, Heroes!
-- First the heroes must locate the starbase, NAVIGATE to within range
-- and then assist in locating the bomb within the space station's bowels 
-- via a high resolution scan from SCIENCE. 
-- After COMMS relays the location information to the station,
-- then the bomb will be availble for transfer to the players' ship.
-- Once the bomb is loaded onto the ship, the crew must find a region of
-- space that is far enough away not to kill anyone in the rather large
-- ???-km radius.  Once there, they must eject the cargo and then
-- high-tail it out of there!
--
-- Added tension: after 45 seconds of carrying the device, the warp
-- engine burns out, thanks to the elevated levels of antineutrino
-- emission, a "feature" of the bomb.
--   Repairs must be made immediately!!
--   Cooling levels must also be monitored closely thereafter(accelerated heating)
--   Turns out that NEBULAS have an adverse, bad harmonic effect on the device,
--   if you stay inside, you will either trigger the device or generate even more heat
--   or both. Which may or may not be offset by engineering and/or science...
-- Maybe also SCIENCE can activate the anti-neutrino compensator field
-- but this must be monitored closely and recalibrated as the bomb's
-- Maybe also a minor waylaying by Zarkon Zealot.
-- Maybe also show a small exploration expedition fleet (or maybe
-- "space scout campers") within blast radius at the last minute.
-- Particularly if the bomb is dropped in a safe space with "too much"
-- time to spare.
-- IF COMMS successfully hails the ships
--	AND sends a message containing a key word or phrase like:
--		"evacuate" "leave" "get out of" "egress" "vacate" "exit"
--      AND "here" "area" "region" "sector" "locality" "place",
-- THEN they will warp out and this will count as successfully saving their lives.
-- At first, though, they send garbled message to the effect of: "we did not copy, please repeat, your signal is breaking up"
--   This transmission difficulty can be overcome by closing the distance some 
-- (requiring risky re-approach of the doomsday radius) and/or boosting the signal 
-- with higher COMMS power and/or aiming the transmission antenna
--Extra bonus: shields can provide a small measure of protection, but only at the outer 10% of the blast radius. One last straggler with broken/no-shields is within the blast radius.
--If our heroes can position themselves directly in-line, then with full shields they will survive, and shield/shadow the smaller, weaker craft. Albeit shields will be reduced to 8% and several subsystems will be damaged.
-- TODO: Custom SFX or at least custom VFX (super bright flash and brief console screen shakey-glitchy) would be cool to signify the detonation. Trigger atmospheric light flash, if available.
-- Should/could it be required to eject all other cargo to fit the one bomb in?
-- It would also be cool to replace planets with misshapen, scorched cinders, within the blast radius.
-- TODO: consider some refactoring to make this seamlessly work in a multi-player co-op.


-- First, clear the board
clear_all();

-- Where the player starts
startx = 101000;
starty = 6000;
startz = 0;

-- TimeScale is definitely useful for testing and debugging, maybe useful for a "difficulty setting"
timescale = .85;
-- A difficulty setting might also trigger additional proddings and hints blended in.


-- how many inabitants on the station
survivors = 238; --TODO can we make this all dynamic?

-- how many zarkons to attack
number_of_zarkons = 3;
zarkon_check_interval = 10 * 20; -- check for zarkon attack every 20 seconds

superbomb_disposed = false;
superbomb_container_id = nil;
superbomb_lethal_radius = 120000;
detonation_ogg_filepath = "sounds/big_explosion.ogg";
superbomb_location_directions = "";


-- Interval between distress calls from ICARUS station is 120 seconds
distress_call_interval = 10 * 120;

derelictx = 512070 + math.random(40000) - 20000;
derelicty = -127000 + math.random(40000) - 20000;
derelictz = 257030 + math.random(40000) - 20000;

-- Faction values (must match share/snis/factions.txt)
zarkon = 3;
vekkazi = 4;

-- Ship type values (must match share/snis/ship_types.txt)
disruptor = 12;
skorpio = 11;
dragonhawk = 10;



-- find the player and move him where we want him to start.
player_ids = get_player_ship_ids();
player_name = "Unknown Player"
if (player_ids[1]) then
    move_object(player_ids[1], startx, starty, startz);
    player_name = get_object_name(player_ids[1]);
    reset_player_ship(player_ids[1]);
    set_faction(player_ids[1], 0); -- set player faction to neutral so only zarkons fight
end


x = 2900;
y = 12000;
z = 290000;

-- locations and radii of our planets:

tobbraxx = 250000 + math.random(30000);
tobbraxy = 12000 + math.random(30000);
tobbraxz = 352000 + math.random(30000);
tobbraxr = 5100

scybonx = 22900 + math.random(30000);
scybony = 15000 + math.random(30000);
scybonz = 12000 + math.random(30000);
scybonr = 4900

fralisx = 22000 + math.random(30000);
fralisy = 25000 + math.random(30000);
fralisz = 10000 + math.random(30000);
fralisr = 4000

-- Name and location of station and planets within the DOOMSDAY radius
-- TODO: need a few more here, to increase the stakes. For bonus value: known enemies of Zarkons should be included,
-- and maybe some politically interesting transmissions from one of these planets during exposition.
station = "ICARUS STATION"
bonxname = "BONX"
bonx_starbase_engineering_channel = 10;
bonx_starbase_has_been_selected = false;
bonxx = derelictx + math.random(200000) - 100000;
bonxy = derelicty + math.random(200000) - 100000;
bonxz = derelictz + math.random(200000) - 100000;
bonxr = 6100


function transmission_received(from, channel, message)
	print("Transmission recieved from:'".. from .. "' on channel ".. channel.. ".");
	print("Message: ", message);
	clean_message = string.lower(string.gsub(message, "%s+", ""));
	--TODO: maybe turn this into a "valid player ship name" function
	if channel == bonx_starbase_engineering_channel then
		basename_pattern = "^"..string.gsub(get_object_name(bonx_starbase),"%-","%%-");
		print(".... "..basename_pattern);
		if not string.find(from,basename_pattern) then 
			--What if they split the clue up over several messages? 
			--So to cover satisfaction incrementally, and a chance to normalize a little:
			if string.find(clean_message,"deck") or string.find(clean_message,"level") then
				print("  * got clue 'deck'...");
				superbomb_location_directions = superbomb_location_directions .. " deck";
			end 
			if string.find(clean_message,"seventeen") or string.find(clean_message,"17") then
				print("  * got clue '17'...");
				superbomb_location_directions = superbomb_location_directions .. " 17";
			end
			if string.find(clean_message,"water") or string.find(clean_message,"h2o") or string.find(clean_message,"filteringplant") then
				print("  * got clue 'water'...");
				superbomb_location_directions = superbomb_location_directions .. " water";
			end
			--Now check to see if the normalized, accumulating clue string has everything...
			if string.find(superbomb_location_directions ,"deck") and string.find(superbomb_location_directions,"17") and string.find(superbomb_location_directions,"water") then
				--TODO: add already ejected flag and subcondition.
				comms_channel_transmit("SB-01 ENGINEERING", bonx_starbase_engineering_channel, "THANK YOU, LOCATION RECEIVED! WE'RE SCRAMBLING NOW!"); 
				comms_channel_transmit("SB-01 ENGINEERING", bonx_starbase_engineering_channel, "STAND BY FOR EJECTION."); 
				
				register_timer_callback("engineering_extracting_bomb", 90, 0);
				--To prevent duplication of the mcguffin, could also be handled by aforementioned todo.
				comms_channel_unlisten("SB-01 ENGINEERING", bonx_starbase_engineering_channel)
			end
		else
			print("  (ignoring base transmission in callback)");
		end
	end
end
comms_channel_unlisten("SB-01 ENGINEERING", bonx_starbase_engineering_channel)
--might want to move this further into the process, maybe also during proximity?
comms_channel_listen("SB-01 ENGINEERING", bonx_starbase_engineering_channel, "transmission_received");

function engineering_extracting_bomb()
	--probably this ought to go into a call back for a little delay, maybe some sfx
	play_sound(player_ids[1], "sounds/mining-bot-deployed.ogg");
	superbomb_container_id = eject_superbomb_from_starbase(bonx_starbase);
	comms_channel_transmit("SB-01 ENGINEERING", bonx_starbase_engineering_channel, "WE GOT IT! PACKAGED AND EJECTED!"); 
end

function eject_superbomb_from_starbase(starbase_number)
	--Optional unlock/disengagement something check here? or similar safe-to-receive condition (else boom)
	--TRANSMISSION: WEVE EJECED THAT DAMN THI*NG! GET IT OUTTA HERE!
	--TODO: effect: particles or other for hasty airlock blow (ejecting the bomb)
	text_to_speech(player_ids[1], "Incoming transmission from "..station);
	comms_transmission(starbase_number, "------------------");
	comms_transmission(starbase_number, "DOOMSDAY DEVICE SECURED IN A CARGO CONTAINER FOR SAFER STOWAGE.");
	comms_transmission(starbase_number, "WE HAVE EJECTED THAT DAMN THING! GET IT OUTTA HERE!");
	comms_transmission(starbase_number, "------------------");
	ex,ey,ez = get_object_location(starbase_number);
	ejectedcargocontainer = add_cargo_container(ex + 150, ey + 100, ez + 000, 2, 0, 0);
	set_commodity_contents(ejectedcargocontainer, active_superbomb, 1);
	attach_science_text(ejectedcargocontainer, "COMPOSITION: STANDARD METALLICS, COMPOSITES.\nWARNING: ANTI-NEUTRINO EMITTING MASS DETECTED IN CENTER OF MASS.\nEMISSION AND MASS SIGNATURE MATCHES DOOMSDAY DEVICE ATTRIBUTES.");
	return ejectedcargocontainer;
end

-- Function to create a planet and an accompanying starbase
function add_planet_plus_starbase(name, x, y, z, r, starbase_number)
	sbx = math.random(r / 2) + r;
	sby = math.random(r / 2) + r;
	sbz = math.random(r / 2) + r;
	if math.random(100) < 50 then
		sbx = -sbx;
	end
	if math.random(100) < 50 then
		sby = -sby;
	end
	if math.random(100) < 50 then
		sbz = -sbz;
	end
	sbx = sbx + x;
	sby = sby + y;
	sbz = sbz + z;
	p = add_planet(name, x, y, z, r);
	sb = add_starbase(sbx, sby, sbz, starbase_number);
	return p, sb;
end

-- Create our planets and their starbases
bonx, bonx_starbase = add_planet_plus_starbase(bonxname, bonxx, bonxy, bonxz, bonxr, 1);
scybon, scybon_starbase = add_planet_plus_starbase("SCYBON", scybonx, scybony, scybonz, scybonr, 2);
tobbrax, tobbrax_starbase = add_planet_plus_starbase("TOBBRAX", tobbraxx, tobbraxy, tobbraxz, tobbraxr, 3);
fralis = add_planet("FRALIS", fralisx, fralisy, fralisz, fralisr, 0, 0);
endangered_planets = {bonx,scybon,tobbrax,fralis};
set_planet_description(bonx,"ENORMOUS POPULATION.");
set_planet_description(scybon,"MEDIUM POPULATION.");
set_planet_description(fralis,"SMALL POPULATION.");

-- Add in some nebulas
n1 = add_nebula("INSANITY-MAJORIS", x + 5000, y - 100, z - 1500, 5000);
n2 = add_nebula("INSANITY-MINORIS", x + 500, y - 200, z - 3000, 3000);
n3 = add_nebula("INSANITY", x + 8000, y - 700, z - 2500, 2000);

shipname = { "HEBBO", "AMZAM", "IVIRAM", "CHABBER", "NAKEL" }
zarkon_ship = { -1, -1, -1, -1, -1 }

wormhole1x = derelictx + 1500;
wormhole1y = derelicty + 1000;
wormhole1z = derelictz + 100;

wormhole2x = scybonx + scybonr * 2;
wormhole2y = scybony + 500;
wormhole2z = scybonz + 700;

-- Give the player a wormhole out of a bad situation
-- TODO: ideally put this near an "obvious" ideal disposal sight, AND make that
-- the location that the science/sight-seeing vessel is approaching (which maybe they
-- can then use for escape also)
wormhole1, wormhole2 = add_wormhole_pair(wormhole1x, wormhole1y, wormhole1z, wormhole2x, wormhole2y, wormhole2z);

-- Function to create an asteroid field
function create_asteroid_field(number_of_asteroids, x, y, z, radius)
	for i = 1, number_of_asteroids do
		repeat
			dx = math.random(radius * 2) - radius;
			dy = math.random(radius * 2) - radius;
			dz = math.random(radius * 2) - radius;
			r2 = dx * dx + dy * dy + dz * dz
		until r2 < radius * radius
		add_asteroid(x + dx, y + dy, z + dz);
	end
end




function all_is_lost()
	show_timed_text(player_ids[1], 10, "SUPERBOMB\n" ..
		"ALL LIFEORMS NEAR " .. station .. " ORBITING " .. bonxname .. "\n" ..
		"WERE LOST TO THE EVIL DOOMSDAY SUPERBOMB\n");
	text_to_speech(player_ids[1],
		"All lifeforms near " .. station .. " orbiting " .. bonxname ..
		" were lost to eveil doomsday superbomb.");
end

function you_docked_with_the_bomb()
	text_to_speech(player_ids[1], "Incoming transmission from "..station);
	comms_transmission(bonx_starbase, "------------------");
	comms_transmission(bonx_starbase, "YOU MUST TAKE THAT HORRIBLE THING AWAY FROM HERE!");
	comms_transmission(bonx_starbase, "QUICKLY! TAKE IT OUTSIDE THE DOOMSDAY RADIUS!");
	comms_transmission(bonx_starbase, "------------------");
	--TODO: maybe some variations and conditional messaging based on time.
	--at some point, there won't be time to deliver it AND escape.
end

--TODO: detonation callback and results assessment.

function you_delivered_the_bomb()
	superbomb_disposed = true;
	--TODO: effective doomsday radius check --Actually this needs inverse radius timer check
	if affected_planets >= 0 then
		all_is_lost();
	else
		show_timed_text(player_ids[1], 10, "SUPERBOMB\n" ..
			"YOU HAVE SAVED " .. 100.0 * (survivors / 8.0) .. " PERCENT OF\n" ..
			"THE POPULATION FROM THE UTTER destruction.\n");
		text_to_speech(player_ids[1],
			"You have saved " .. 100.0 * (survivors / 8.0) .. " percent of " ..
			"the population from utter destruction.");
			--TODO: unregister callbacks
	end
end

function wheres_the_bomb()
	text_to_speech(player_ids[1], "Incoming transmission from "..station);
	comms_transmission(bonx_starbase, "------------------");
	comms_transmission(bonx_starbase, "WE MUST FIND THAT SUPERBOMB. WE DON'T KNOW");
	comms_transmission(bonx_starbase, "WHERE IT IS OR HOW MUCH TIME WE HAVE.");
	comms_transmission(bonx_starbase, "ALL AVAILABLE TRAINED STAFF ARE SEARCHING.");
	comms_transmission(bonx_starbase, "PLEASE ASSIST WITH WHATEVER YOU CAN DO.");
	comms_transmission(bonx_starbase, "------------------");
	--if we unload passengers to help search, it helps? Or give more clues about scanning?
end

function bomb_victim_proximity()
	victim_count = 0;

	if player_has_bomb(player_ids[1]) then
		bomb_oid = player_ids[1];
	else
		--TODO: this is gonna have some bugs. not liking the global superbomb_container_id. rethink this some.
		if superbomb_container_id == nil then
			print("uhoh, its STILL on the station (probably)!");
			bomb_oid = bonx_starbase;
		else
			bomb_oid = superbomb_container_id;
		end
	end
	for i, eplanet in ipairs(endangered_planets) do
		print("checking on status of planet "..get_object_name(eplanet));
		if object_distance(bomb_oid, eplanet) < superbomb_lethal_radius then
			victim_count = victim_count + 1; --TODO: how do i get planetary population?
			print("another dead planet...");
		end
	end
	--TODO: check on ancilliary target (sightseer/science vessel)
	--Or maybe rename and return number of vicitims within blast radius? 
	--  therefore 0 is success condition
	print(victim_count);

	return victim_count;
end

-- check if the player has the doomsday superbomb in one of the cargo bays
function player_has_bomb(player)
	ncargo_bays = get_ship_attribute(player, "ncargo_bays");
	print("ncargo bays = " .. ncargo_bays);
	if ncargo_bays == nil then
		return false;
	end
	if ncargo_bays <= 0 then
		return false;
	end
	for i = 0, ncargo_bays - 1, 1 do
		print("getting cargo bay '" .. string.format("cargo[%d[.contents.item", i));
		cargo = get_ship_attribute(player, string.format("cargo[%d].contents.item", i));
		print("cargo[" .. i .. "] = " .. cargo .. " vs. superbomb = " .. active_superbomb);
		if (cargo == active_superbomb) then
			print("MATCH");
			return true;
		end
	end
	return false;
end

-- Function gets called when player docks at a starbase
function player_docked_callback(player_id, station_id)
	print("player docked callback player: " .. player_id .. ", station: " .. station_id .. " vs. " .. bonx_starbase);
	if station_id == bonx_starbase then
		if player_has_bomb(player_ids[1]) then
			print("you have the bomb");
			register_timer_callback("you_docked_with_the_bomb", 50, 0);
		else
			print("you do not have the bomb");
			--might need one more condition for whether we know about and and/or we've already detonated...
			register_timer_callback("wheres_the_bomb", 50, 0);
		end
	 end
end

-- Function to introduce the mission
function intro()
	show_timed_text(player_ids[1], 10,
		"SUPERBOMB\n" ..
		"CAN YOU SAVE THE INHABITANTS OF " .. station .. "\n" ..
		"STATION BEFORE THEY ARE ANNIHILATED\n" ..
		"BY THE DREADED ZARKONIAN DOOMSDAY DEVICE?\n");
end

function anxious_greeting(oid1, oid2, distance)
	text_to_speech(player_ids[1], "Incoming transmission from "..station);
	comms_transmission(bonx_starbase, "------------------");
	comms_transmission(bonx_starbase, "HALEY HERE, VERY GLAD TO SEE YOU, " .. player_name .."!");
	comms_transmission(bonx_starbase, "THERE IS A COMPLICATION. ALTHOUGH WE DID DETECT");
	comms_transmission(bonx_starbase, "THE BOMB'S EMISSION SIGNATURE, WE DO NOT");
	comms_transmission(bonx_starbase, "KNOW WHERE ON THE STATION IT IS LOCATED!");
	comms_transmission(bonx_starbase, "CLEARLY THE ZARKONIANS HID IT CAREFULLY.");
	comms_transmission(bonx_starbase, "OUR TECHNICIANS ARE SCRAMBLING BUT WE JUST DO NOT");
	comms_transmission(bonx_starbase, "HAVE THE RESOURCES TO FIND THIS INFERNAL BOMB!");
	comms_transmission(bonx_starbase, "...");
	register_timer_callback("anxious_greeting2", 30, 0);
end

function anxious_greeting2(oid1, oid2, distance)
	comms_transmission(bonx_starbase, player_name .. " I HAVE AN IDEA!");
	comms_transmission(bonx_starbase, "IF YOU WERE TO USE YOUR HIGH POWERED, HIGH-RESOLUTION SENSORS");
	comms_transmission(bonx_starbase, "FROM OUTSIDE THE BASE, YOU SHOULD BE ABLE TO PIN-POINT");
	comms_transmission(bonx_starbase, "THIS THING! PERFORM YOUR SCAN AND SEND US A MESSAGE");
	comms_transmission(bonx_starbase, "WITH THE LOCATION ON CHANNEL "..bonx_starbase_engineering_channel..", WHICH OUR ENGINEERS ARE MONITORING.");
	comms_transmission(bonx_starbase, "THEY WILL THEN PROCEED TO EXTRACT AND EJECT THE BOMB."); 
	comms_transmission(bonx_starbase, "PLEASE COMPLY, " .. player_name .. " TIME IS SURELY RUNNING SHORT.");
	comms_transmission(bonx_starbase, "ADMIRAL HALEY OUT.");
	comms_transmission(bonx_starbase, "------------------");
	--TODO:register a "thanks a bunch"/"knew we could count on you" reply via comms 
	--  if player sends a roger/wilco message, but haven't taken action yet.

	--comms_channel_listen(name, channel, callback)
	--TODO: register a transmission callback on general channel to exhort comms officer to repeat that message on channel 8
	--   or is that lame? couldn't the base commander just grumble about wasted time and relay the info? maybe channel 8 is actually and automated robot thing, so you are kind of remotely "programming the robot" which cannot be done by a simple verbal relay?
end


function we_have_you_on_visual(oid1, oid2, distance)
	print("getting close to object with proximity callback..");
	text_to_speech(player_ids[1], "Incoming transmission from "..get_object_name(oid2));
	comms_transmission(oid2, "------------------");
	--TODO: could make this function context-aware-ish by having conditional on type of object
	-- then sender ID could include "traffic control" for bases, "flight officer" for ships, etc.
	-- if factions match, they call you by name, if mismatch, they may demand that you identify yourself.
	comms_transmission(oid2, "WE HAVE YOU ON VISUAL, " .. player_name);
	--This is a good opportunity to maybe issue prompts, reminders of need for clearance, etc.
	--Maybe in "easy" mode you get auto-issued clearance, but in hard mode you just get reminded to ask for one? 
	comms_transmission(oid2, "THE BOSS SAYS ITS URGENT. YOU ARE PRE-CLEARED FOR DOCKING.");
	comms_transmission(oid2, "TRANSMITTING DOCUMENT NOW.");
	variety = math.random(100)
	if variety < 25 then
		comms_transmission(oid2, "STEADY AS SHE GOES.");
	elseif variety < 50 then
		comms_transmission(oid2, "RECOMMEND FOR AXIAL APPROACH VECTOR.");
	else
		comms_transmission(oid2, "ALL BERTHINGS CLEAR. COMMAND REQUESTS YOU PROCEED WITH HASTE.");
	end
	comms_transmission(oid2, "------------------");
	issue_docking_clearance(oid2, player_ids[1], get_object_name(bonx_starbase)..":DOCKING_CONTROL", 0);
	register_proximity_callback("anxious_greeting", player_ids[1], bonx_starbase, 1200); 
end

register_proximity_callback("we_have_you_on_visual", player_ids[1], bonx_starbase, 14000); 

-- First distress call from ICARUS station
function distress_call1()
	text_to_speech(player_ids[1], "Incoming transmission from "..station);
	comms_transmission(bonx_starbase, "------------------");
	comms_transmission(bonx_starbase, "THIS IS ADMIRAL ANTON HALEY");
	comms_transmission(bonx_starbase, "ABOARD " .. station .. ", UNIFORM REGISTRATION NAME " .. get_object_name(bonx_starbase));
	comms_transmission(bonx_starbase, "IN STANDARD ORBIT AROUND " .. bonxname);
	comms_transmission(bonx_starbase, "AN URGENT SITUATION HAS DEVELOPED: WE ARE UNDER");
	comms_transmission(bonx_starbase, "THREAT OF AN ARMED SUPERBOMB, PROBABLY OF ");
	comms_transmission(bonx_starbase, "ZARKONIAN ORIGIN. THE BOMB IS STRONG ENOUGH");
	comms_transmission(bonx_starbase, "TO COMPLETELY ANNIHILATE "..bonxname);
	comms_transmission(bonx_starbase, "ALONG WITH THE STATION, POSSIBLY EVEN OTHER");
	comms_transmission(bonx_starbase, "NEARBY PLANETS. WE DO NOT HAVE A SHIP WITH");
	comms_transmission(bonx_starbase, "THE MEANS OR SPEED TO TRANSPORT THE BOMB");
	comms_transmission(bonx_starbase, "TO A SAFE DISTANCE FROM ANY HABITATIONS.");
	comms_transmission(bonx_starbase, "MAKE WAY TO " .. station .. " IMMEDIATELY.");
	comms_transmission(bonx_starbase, "YOU MUST TAKE THIS BOMB ABOARD AND EJECT IT");
	comms_transmission(bonx_starbase, "IN A SAFE, EMPTY REGION OF SPACE OR ELSE");
	comms_transmission(bonx_starbase, "THERE WILL BE TREMENDOUS LOSSES.");
	--comms_transmission(bonx_starbase, "WAS (" ..
	--		derelictx .. ", " .. derelicty .. ", " .. derelictz .. ")");
	--comms_transmission(bonx_starbase, "IN THE MIDDLE OF THE GREATER ZORLACC ASTEROID FIELD");
	--comms_transmission(bonx_starbase, "WE ARE IN DESPERATE NEED OF THAT MEDICINE");
	comms_transmission(bonx_starbase, "ADMIRAL HALEY OUT.");
	comms_transmission(bonx_starbase, "------------------");
	register_timer_callback("distress_call2", distress_call_interval * timescale, 0);
end

-- Subsequent distress calls from ICARUS station
function distress_call2()
	text_to_speech(player_ids[1], "Incoming transmission from "..station);
	comms_transmission(bonx_starbase, "------------------");
	comms_transmission(bonx_starbase, "THIS IS ADMIRAL ANTON HALEY");
	if player_has_bomb(player_ids[1]) then
		comms_transmission(bonx_starbase, "BE CAREFUL OUT THERE. WE WANT YOU TO MAKE");
		comms_transmission(bonx_starbase, "IT BACK HERE SAFELY SO THAT WE CAN SHOW");
		comms_transmission(bonx_starbase, "OUR THANKS PROPERLY.");
		--comms_transmission(bonx_starbase, "SHOULD YOUR SHIP BE CONSUMED IN A BLAZING");
		--comms_transmission(bonx_starbase, "SUBATOMIC INFERNO, PLEASE KNOW THAT YOU HAVE");
		--comms_transmission(bonx_starbase, "OUR GRATTIUDE AND THAT YOUR BRAVERY WILL NOT");
		--comms_transmission(bonx_starbase, "BE FORGOTTEN.");
	else
		comms_transmission(bonx_starbase, "WE ARE DETECTING ELEVATED LEVELS OF");
		comms_transmission(bonx_starbase, "ANTINEUTRINOS, THIS IS A SURE SIGN THAT");
		comms_transmission(bonx_starbase, "THIS IS A ZARKONIAN SUPERBOMB, AND THAT");
		comms_transmission(bonx_starbase, "IT IS NOW FULLY ARMED!");
		comms_transmission(bonx_starbase, "TIME IS SURELY RUNNING OUT, PLEASE SET");
		comms_transmission(bonx_starbase, "A HEADING FOR " .. bonxname .. " IMMEDIATELY!");
		comms_transmission(bonx_starbase, station .. " SHOULD BE ON THE DAY-SIDE BY THE");
		comms_transmission(bonx_starbase, "TIME YOU GET HERE.");
		register_timer_callback("distress_call3", distress_call_interval * timescale, 0);
	--maybe go ahead and unleash the zarkons, player has dawdled too much
	end
	comms_transmission(bonx_starbase, "ADMIRAL HALEY OUT.");
	comms_transmission(bonx_starbase, "------------------");
end

function distress_call3()
	text_to_speech(player_ids[1], "Incoming transmission from "..station);
	comms_transmission(bonx_starbase, "------------------");
	comms_transmission(bonx_starbase, "THIS IS ADMIRAL ANTON HALEY");
	if player_has_bomb(player_ids[1]) then
		comms_transmission(bonx_starbase, "GOOD LUCK, AND COME BACK SAFE.");
		comms_transmission(bonx_starbase, "WE WILL BE MONITORING AND AWAITING");
		comms_transmission(bonx_starbase, "YOUR SAFE RETURN.");
		--Might be a good time for a warning about indications of zarkonian interceptors.
	else
		comms_transmission(bonx_starbase, "THE SITUATION IS DESPARATE. MANY, MANY");
		comms_transmission(bonx_starbase, "LIVES HANG IN THE BALANCE. WE BEG FOR");
		comms_transmission(bonx_starbase, "YOUR ASSISTANCE, " .. player_name .. ".");
	end
	comms_transmission(bonx_starbase, "HALEY OUT.");
	comms_transmission(bonx_starbase, "------------------");
	--register_timer_callback("distress_call4", distress_call_interval, 0);
	--maybe go ahead and start the bomb countdown now, player has dawdled too much
	register_timer_callback("superbomb_detonation", 400 * 10 * timescale, 0);
	demon_print("Superbomb count down has begun!");
end

--TODO: are cargo containers destructuible? if so, call superbomb_detonation if player shoots it.

function bomb_attached_oid()
	--return oid of object that best reflects the location of the bomb
	--because bomb could be:
	--still "hidden" on the base
	--ejected from the base, but floating
	--in the cargo hold of novus
	--re-ejected into space
	--TODO: after writing this, refactor detonation and victim evaluation functions to use it.
end

function superbomb_detonation()
	demon_print("Superbomb DETONATED!");
	print("Detonation now ocurring...");
	if bomb_victim_proximity() then
		print("there were casualties...");
		register_timer_callback("sad_conclusion", 80, 0);
	else
		print("victims saved, heroic!");
	end

	--maybe blow each planet in succession first...
	px,py,pz = get_object_location(player_ids[1]);
	--add_explosion(x, y, z, v, nsparks, 60, OBJTYPE_PLANET, 0);
	if player_has_bomb(player_ids[1]) then
		print("the explosion is starting with the player");
		add_explosion(px, py, pz, player_ids[1], 30, 600, OBJTYPE_BLACK_HOLE, 1);
		move_object(player_ids[1],bonxx,bonxy,bonxz);
	elseif superbomb_container_id then
		print("bomb is just floating in space...");
		cx,cy,cz = get_object_location(superbomb_container_id );
		add_explosion(cx, cy, cz, superbomb_container_id, 30, 600, OBJTYPE_BLACK_HOLE, 1);
		--but make sure it wasn't destroyed or re-stowed or something.
	else
		sbx,sby,sbz = get_object_location(bonx_starbase);
		add_explosion(sbx, sby, sbz, bonx_starbase, 30, 600, OBJTYPE_BLACK_HOLE, 1);
	end
	--add_explosion(0, 0, 0, player_ids[1], 30, 600, OBJTYPE_BLACK_HOLE, 1);
	add_explosion(px, py, pz, player_ids[1], 30, 600, OBJTYPE_BLACK_HOLE, 1);
	-- could have a custom EVERYTHING IS LIT UP skybox--load_skybox(ship_id, filenameprefix);
	play_sound(player_ids[1], detonation_ogg_filepath);
	--set_player_damage(player_ids[1], system, value);
end

function sad_conclusion()
	show_timed_text(player_ids[1], 8, "FAILURE.\n"..
		"THE SUPERBOMB DOOMSDAY DEVICE DETONATED\n"..
		"MANY LIVES WERE WITHIN ITS LETHAL RADIUS.");
end

function maintain_zarkon_focus()
	for i = 1, number_of_zarkons do
		ai_push_attack(zarkon_ship[i], player_ids[1]);
	end
	register_timer_callback("maintain_zarkon_focus", 20, 0);
end

function send_in_the_zarkons()
	print("Sending in the zarkons");
	px,py,pz = get_object_location(player_ids[1]);
	--TODO: maybe instead of random, come from the "far side" of the planet
	zx = px + math.random(4000) - 2000;
	zy = py + math.random(4000) - 2000;
	zz = pz + math.random(4000) - 2000;
	for i = 1, number_of_zarkons do
		zarkon_ship[i] = add_ship(shipname[i], zx, zy, zz, skorpio, zarkon, 0);
		ai_push_attack(zarkon_ship[i], player_ids[1]);
		zy = zy + 250;
	end
	comms_transmission(zarkon_ship[1], "INTERLOPERS! YOU SHALL REGRET YOUR INTERFERENCE!"); 
	comms_transmission(zarkon_ship[1], "WE WILL SHOW NO QUARTER, AND OUR PLAN WILL NOT BE FOILED!"); 
	text_to_speech(player_ids[1], "Warning, Zarkon scanning beam has been detected.");
	-- Mess up the player's warp drive to make it harder to run away
	set_player_damage(player_ids[1], "warp", 255); -- 3 times because of the way
	set_player_damage(player_ids[1], "warp", 255); -- damage is distributed
	set_player_damage(player_ids[1], "warp", 255);
	register_timer_callback("maintain_zarkon_focus", 20, 0);
end

-- Look into reversing this: zarkons attempt to prevent you from obtaining the bomb, but then they are terrified and run away from you once you have it.
-- or maybe even more dramatic, a large, overwhelming squadron threatens, 
-- but then, suddenly /most/ of them chicken out and flee, leaving only one (but big, intimidating) ship behind, 
-- and whose commander we overhear raging and insulting his cowardly, deserting commrades. 
-- then he turns his attention and rage on stopping the heroes.

function check_for_zarkon_attack()
	-- check to see if the space bomb has been acquired and if so send in the zarkons
	print("checking for zarkon attack");
	if not player_has_bomb(player_ids[1]) then
		print("No zarkon attack this time");
		-- player doesn't have bomb, check for zarkon attack again in a little while
		register_timer_callback("check_for_zarkon_attack", zarkon_check_interval, 0);
		return;
	end
	-- player has bomb, send in the zarkons (after a small delay)
	register_timer_callback("send_in_the_zarkons", 10 * 6, 0);
	-- do not register the callback to check for zarkon attack again
end

function add_a_bunch_of_neutral_ships()
	for i = 1, 30 do
		id = add_random_ship();
		set_faction(id, 0);
	end
end

-- Greater Zorlacc asteroid field
create_asteroid_field(200, derelictx + math.random(30000) - 15000,
			derelicty + math.random(30000) - 15000,
			derelictz + math.random(30000) - 15000, 150000);
-- Lesser Zorlacc asteroid field
create_asteroid_field(50, derelictx + 170000, derelicty + 50000, derelictz, 50000);

-- Create a very large, very sparse asteroid "field"
create_asteroid_field(50, scybonx, scybony, scybonz, 500000);


-- Create our macguffin -- a SuberBomb, eventually to be contained in cargocontainer
-- Since the superbomb commodity is carefully hidden on the station, don't add it 
-- to inventory or otherwise spawn YET. First, require the player to be docked/in-proximity 
-- at the station, THEN yield/enable the high-res scan button to SCIENCE
-- and only after the scan, and/or communication thereof add the bomb to the station inventory 
-- or eject it
active_superbomb = add_commodity("ARMED SUPERBOMB", "SEALED UNIT", "RADIOACTIVE COMPOSITE",
					100.0, 02, 1.0, 0.1, 0.1, 0.7, 0.0);

function object_scanned_event_callback(pid,oid)
	if (oid == bonx_starbase) then
		bonx_starbase_has_been_selected = true;
	end
end
register_callback("object-scanned-event", "object_scanned_event_callback");


-- TODO(maybe): another callback for "low-res"/normal scan event: fewer details, and make 
-- the anti-neutrino detection vague (with no location), but offer a "highres scan" 
-- via a custom button. and its that highres scan that reveals the specific location.

function hires_scan_callback(pid,screenid)
	--TODO: conditional on sb-01 is selected, else respond in some other random interesting-ish way
	--TODO: conditional on sensor powerlevel at max, else make a failure-but-try-again apparent somehow
	--todo: some kind of high-energy wind up/signal noise--play_sound(player_ids[1], "sounds/science-data-acquired.ogg");
	--maybeTODO: have an alternate dummy "hi res" scan sci text, if player scans other non-game-important things?
	if get_player_damage(player_ids[1], "sensors") > 50 then
		play_sound(player_ids[1], "sounds/ui9.ogg");
		text_to_speech(player_ids[1], "High resolution scanners non-operational. Repairs required.");
	elseif get_ship_attribute(id, "power_data.sensors.i") < 200 then
		play_sound(player_ids[1], "sounds/ui9.ogg");
		text_to_speech(player_ids[1], "Insufficient power for high resolution scann.");
	else
		--It would be better if we can see what we have selected /right now/. 
		--Rewrite the condition if we find a way.
		--For now, we will just be just be satisfied with "have they every selected it at least temporarily"
		if bonx_starbase_has_been_selected then
			if object_distance(player_ids[1], bonx_starbase) > 2000 then
				play_sound(player_ids[1], "sounds/ui9.ogg");
				text_to_speech(player_ids[1], "Station out of range for high resolution scan.");
			else
				--Might also be nice to throw in some SCI scanning powerlevels checks, and/or SRS/LRS check
				play_sound(player_ids[1], "sounds/ui29.ogg");
				--TODO: experiment with a little loop or chain of callbacks to get bleep-pause-show-bleep-pause-show-etc for each major line item of info.
				-- The text is pretty long, no autowrap. Embedded newlines work though! Still an upward limit on total characters.
				--attach_science_text(bonx_starbase, "COMPOSITION: STANDARD METALLICS, COMPOSITES.\nENERGETICS: NUCLEAR REACTOR CORE DETECTED\n  LOCATION: UPPER CENTER, NOMINAL RADIATION.\n  2 SHUTTLECRAFT DETECTED IN LOWER BAYS.\n  257 LIFEFORMS DETECTED.\nWARNING: ANTI-NEUTRINO EMITTING MASS DETECTED!!\n  LOCATION: DECK 17, WATER TREATMENT PLANT");
				attach_science_text(bonx_starbase, "COMPOSITION: STANDARD METALLICS, COMPOSITES.\n"..
					"ENERGETICS: NUCLEAR REACTOR DETECTED\n"..
					"  LOCATION: UPPER CENTER, NOMINAL RADIATION.\n"..
					"SHUTTLECRAFT DETECTED IN LOWER BAYS.\n\n"..
					"WARNING: ANTI-NEUTRINO EMITTING MASS DETECTED!!\n"..
					"  LOCATION: DECK 17, H2O TREATMENT PLANT");
				play_sound(player_ids[1], "sounds/science-data-acquired.ogg");
			end
		else
			play_sound(player_ids[1], "sounds/ui9.ogg");
		end
		--TODO: add a "burst" of heat to sensors? should have asked for extra cooling from ENGINEERING!
		--and/or disable the sensors temporarily for recharge/refresh, but make it longer if heat is in the orange.
		--disable_custom_button(player_ids[1], 4); --< if we don't use that, we probably need a flag for recharging state
		set_custom_button_label(player_ids[1], 4, "RECHARGING");
		register_timer_callback("hires_scan_recharged_callback", 80, 0);
	end
end

function hires_scan_recharged_callback()
	--TODO: check for sensor energy above 50%
	enable_custom_button(player_ids[1], 4);
	set_custom_button_label(player_ids[1], 4, "HI-RES SCAN");
end

--TODO: consider moving this into docked event call back and/or after the admiral suggests it.
register_timer_callback("hires_scan_recharged_callback", 10, 0);

-- We can leave the derelict out there, but its just flavor text. TODO: put it close to the station, but kinda out of the way, like it was trying not to attract attention. or maybe far away but close the player start place? Lots of "antineutrino damage/residuals".
-- Or maybe we should have the player discover this first? maybe this how they learn of the plot? reading some invocation of the dark powers for the doomsday device to succeed?
-- Make it full of Zarkon Zealots that obviously commited suicide after bomb delivery
-- throw in some religious texts and some so-on.

derelict = add_derelict("ZARKNAX RYTOR", derelictx, derelicty, derelictz, dragonhawk, zarkon);
set_object_velocity(derelict, 0, 0, 0);
attach_science_text(derelict, "HIGH RESIDUAL ANTI-NEUTRINO EMISSIONS\n"..
	"WARP ENGINE: DESTROYED"); --TODO:<< prhase this text better so that it a) sounds cool, and b) leads the players to understand that its the antineutrinos that killed the warp core (so they better be careful when they are the transporters!)


add_a_bunch_of_neutral_ships()

register_callback("player-docked-event", "player_docked_callback");
register_timer_callback("distress_call1", 150, 0);
register_timer_callback("check_for_zarkon_attack", zarkon_check_interval, 0);
register_callback("custom-button-press-event", "hires_scan_callback");

intro();

