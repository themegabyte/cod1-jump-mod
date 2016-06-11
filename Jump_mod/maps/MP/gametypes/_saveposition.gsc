initializate(){
	self.position=0;
	self.loadedpos=undefined;
	self.saves=0;
	self.loads=0;
	self.pers["cj_hudmsg"]=undefined;
	self waittill("welcome");
	self thread jumphud();
}
doHUDMessages(){

	self waittill("welcome");

	if(!isdefined(self.pers["cj_hudmsg"]))
	{
		wait 1;
		self iprintlnbold("Double press '^2BASH^7' to save your position.");
		wait 3;
		self iprintlnbold("Double press '^1[{+activate}]^7' to load your position");
		wait 3;
		self iprintlnbold("If you press '^1[{+activate}]^7' then '^1[{+attack}]^7' you can load one position back");
		self iprintlnbold("If you hold it then it load back another position and so on ... :D ");
		self.pers["cj_hudmsg"] = true;
	}
}

_MeleeKey(){
	self endon("end_saveposition_threads");
	self endon("disconnect");

	for(;;)
	{
		if(self meleeButtonPressed())
		{
			catch_next = false;

			for(i=0; i<=0.30; i+=0.01)
			{
				if(catch_next && self meleeButtonPressed() && self isOnGround() && self.sessionstate =="playing" || catch_next && self meleeButtonPressed() && !self isOnGround() && isOnLadder() && self.sessionstate =="playing" )
				{
					self thread savePos();
					wait 1;
					break;
				}
				else if (!(self meleeButtonPressed()))
					catch_next = true;

				wait 0.01;
			}
		}

		wait 0.05;
	}
}

_UseKey(){

	self endon("end_saveposition_threads");
	self endon("disconnect");

	for(;;)
	{
		if(self useButtonPressed())
		{
			catch_next = false;

			for(i=0; i<=0.30; i+=0.01)
			{
				if(catch_next && self useButtonPressed())
				{
					self thread loadpos();
					wait 1;
					break;
				}
				else if(!(self useButtonPressed()))
					catch_next = true;

				wait 0.01;
			}
		}

		wait 0.05;
	}
}

_UseKey2()
{
	self endon("end_saveposition_threads");
	self endon("disconnect");

	for(;;)
	{
		if(self useButtonPressed())
		{
			catch_next = false;
			self.loadedpos=self.position;
			for(i=0; i<=0.30; i+=0.01)
			{			
				if(catch_next)
				{
					while(self attackButtonPressed())
					{
					if(self.loadedpos>1)
					{
					self.loadedpos--;
					self thread loadPos_prew();
					i-=0.01;
					}
					wait 1;
					}
					
				}
				else if(!(self attackButtonPressed()))
					catch_next = true;
				wait 0.01;
			}
				
		}

		wait 0.05;
	}
}
savePos(){
	self.position++;
	
	self.score++;
	self.saves++;
	self.saved_origin[self.position] = self.origin;
	self.saved_angles[self.position] = self.angles;
//	self iprintln("^2P^7osition saved (^2" + self.position + "^7)");
	self iprintln("^2P^7osition ^3[^1 X : ^2" + (int)self.origin[0] + "^7, ^1Y : ^2" + (int)self.origin[1] + "^7, ^1Z : ^2" + (int)self.origin[2] + "^3 ]^7 saved.");
}
isOnLadder() {
    if ( !isDefined( self ) || !isAlive( self ) || self.sessionstate != "playing" )
        return false;
 
    if ( !self isOnGround() && self getCurrentWeapon() == "none" )
        return true;
 
    return false;
}

loadPos(){

	//thread positions();
	if(!isDefined(self.saved_origin[self.position]))
		{
		self iprintln("^1T^7here is no previous position to load.");
		return;
		}
	else if(self positions(70) && /* added for a test */ self positions2(70) )	{
			self iprintln("^1P^7osition occupied");
			self iprintlnbold("Try again in a few sec.");
			return;
		}
		else
		{
			self.loads++;
			self setPlayerAngles(self.saved_angles[self.position]); 
			self setOrigin(self.saved_origin[self.position]);
			self iprintln("^2P^7osition loaded (^2" + self.position + "^7)");
		}
}

loadPos_prew()
{
	if(!isDefined(self.saved_origin[self.loadedpos]))
		{
		self iprintln("^1T^7here is no previous position to load.");
		return;
		}
	else if(self positions2(70))
		{
			self iprintlnbold("^1P^7osition occupied");
			self iprintlnbold("Try again in a few sec.");
			return;
		}
		else
		{
			self.loads++;
			self setPlayerAngles(self.saved_angles[self.loadedpos]); 
			self setOrigin(self.saved_origin[self.loadedpos]);
			self iprintln("^2P^7osition loaded (^2" + self.loadedpos + "^7)");
			wait 0.1;
		}
}
jumphud(){
	self endon("disconnect");

	while(1){
	if(self.pers["team"] != "spectator")
	{
		if(isdefined(self.hud_save))
			self.hud_save destroy();
		if(isdefined(self.hud_load))
			self.hud_load destroy();

		self.hud_save = newClientHudElem(self);
		self.hud_save.x=10;
		self.hud_save.y=30;
		self.hud_save.fontScale = 0.9;
		self.hud_save.alpha=1;
	//	self.hud_save.color = ( 1, 0.2, 0 );
		self.hud_save.label=&"Saved positions: ";
		self.hud_save setValue(self.saves);

		self.hud_load = newClientHudElem(self);
		self.hud_load.x=10;
		self.hud_load.y=40;
		self.hud_load.fontScale = 0.9;
		self.hud_load.alpha=1;
	//	self.hud_load.color = ( 1, 0.2, 0 );
		self.hud_load.label=&"Loaded positions: ";
		self.hud_load setValue(self.loads);
	}
	else
	{
	if(isdefined(self.hud_save))
		self.hud_save destroy();
	if(isdefined(self.hud_load))
		self.hud_load destroy();
	}
	wait 0.05;
}
}

weaponswitcher()
{
	wait 1;
	tempwep=self getweaponslotweapon("pistol");
	self switchtoweapon(tempwep);
}

positions(range)
{
	if(!range)
		return true;

	// Get all players and pick out the ones that are playing
	allplayers = getentarray("player", "classname");
	players = [];
	for(i = 0; i < allplayers.size; i++)
	{
		if(allplayers[i].sessionstate == "playing")
			players[players.size] = allplayers[i];
	}

	// Get the players that are in range
	sortedplayers = sortByDist(players, self);

	// Need at least 2 players (myself + one team mate)
	if(sortedplayers.size<2)
		return false;

	// First player will be myself so check against second player
	distance = distance(self.saved_origin, sortedplayers[1].origin);
	if( distance <= range )
		return true;
	else
		return false;
}

positions2(range)
{
	if(!range)
		return true;

	// Get all players and pick out the ones that are playing
	allplayers = getentarray("player", "classname");
	players = [];
	for(i = 0; i < allplayers.size; i++)
	{
		if(allplayers[i].sessionstate == "playing")
			players[players.size] = allplayers[i];
	}

	// Get the players that are in range
	sortedplayers = sortByDist(players, self);

	// Need at least 2 players (myself + one team mate)
	if(sortedplayers.size<2)
		return false;

	// First player will be myself so check against second player
	distance = distance(self.saved_origin[self.loadedpos], sortedplayers[1].origin);
	
	if( distance <= range )
		{
		return true;
		}
		else
		{
		return false;
		}
	
}

sortByDist(points, startpoint, maxdist, mindist)
{
	if(!isdefined(points))
		return undefined;
	if(!isdefineD(startpoint))
		return undefined;

	if(!isdefined(mindist))
		mindist = -1000000;
	if(!isdefined(maxdist))
		maxdist = 1000000; // almost 16 miles, should cover everything.

	sortedpoints = [];

	max = points.size-1;
	for(i = 0; i < max; i++)
	{
		nextdist = 1000000;
		next = undefined;

		for(j = 0; j < points.size; j++)
		{
			thisdist = distance(startpoint.origin, points[j].origin);
			if(thisdist <= nextdist && thisdist <= maxdist && thisdist >= mindist)
			{
				next = j;
				nextdist = thisdist;
			}
		}

		if(!isdefined(next))
			break; // didn't find one that fit the range, stop trying

		sortedpoints[i] = points[next];

		// shorten the list, fewer compares
		points[next] = points[points.size-1]; // replace the closest point with the end of the list
		points[points.size-1] = undefined; // cut off the end of the list
	}

	sortedpoints[sortedpoints.size] = points[0]; // the last point in the list

	return sortedpoints;
}