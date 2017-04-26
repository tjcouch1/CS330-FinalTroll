//Todd - The final troll
//Timothy Couch

class Todd extends Movable
{
	//movement path for scenario 1
	int[] pArray = {
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.LEFT,
		GridDir.LEFT,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.DOWN,
		GridDir.DOWN,
		GridDir.DOWN,
		GridDir.DOWN,
		GridDir.DOWN,
		GridDir.DOWN,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.RIGHT,
		GridDir.RIGHT,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.UP,
		GridDir.UP,
		GridDir.UP,
		GridDir.UP,
		GridDir.UP,
		GridDir.UP
		};
	
	//sensing
	float sightRange = 7;
	float sightAngle = 30;
	float hearRange = 2;
	float trollSenseRange = 10;
	Objects sensedObjects = new Objects();
	Player trackedPlayer;
	boolean seesPlayer = false;
	boolean sawPlayer = false;
	int numTrolls = 0;
	
	//status vars (thinking)
	float healthCap = 100;
	float health = healthCap;
	float weaponDamage = 5;
	float attackRange = 1.2;
	boolean returning = false;
	int numTrollsSeePlayers = 0;
	float threat = 0;
	int attentionThreshold = 10;
	int dangerThreshold = 5;//3;
	
	//animation vars (acting)
	boolean fighting = false;
	boolean pursuing = false;
	float hideAngle;
	boolean returned = false;

	Path path;
	PVector dest;
	boolean moved = false;
	
	//counter vars
	int stepTimeCap = 5;
	int stepTime = stepTimeCap;
	
	int pathUpdateTimeCap = 10;
	int pathUpdateTime = pathUpdateTimeCap;
	
	StateMachine sM;
	ResponseCurve rC;
	
	Todd()
	{
		super();
		
		InitDefault();
	}

	Todd(PVector position)
	{
		super(position);
		
		InitDefault();
	}
	
	Todd(PVector position, int var)
	{
		super(position);
		
		InitDefault();
	}
	
	void InitDefault()
	{
		if (variation == 1)
		 	sM = createStateMachine();
		else if (variation == 2)
			rC = createResponseCurve();
		
		dest = calcDestination();
		
		path = MakePath();
		
		c = color(#15538c);
		
		if (variation > 0)
			rotation = getAngle(new PVector(chestPos.x + 2 - position.x, chestPos.y - position.y));
		hideAngle = rotation;
	}
	
	void damage(float d)
	{
		health -= d;
		if (health <= 0)
			objects.destroy(this);
	}
	
	void step()
	{
		//sense the world
		sense();
		
		//think about situation
		think();
		
		//act to show thoughts
		act();
	}
	
	void sense()
	{
		trackedPlayer = null;
		sawPlayer = seesPlayer;
		seesPlayer = false;
		sensedObjects.clear();
		numTrolls = 0;
		for (Object o : objects)
		{
			switch(o.getClass().getSimpleName())
			{
				case "Player":
					Player p = (Player) o;
					if (p.alive)
					{
						//sense the player in visual sight
						if (position.dist(p.position) <= sightRange)
						{
							PVector forward = PVector.fromAngle(radians(rotation));
							float playerAngle = degrees(PVector.angleBetween(forward, PVector.sub(p.position, position)));
							if (playerAngle <= sightAngle)
								seePlayer(p);
						}
						
						//sense the player in hearing range
						if (position.dist(p.position) <= hearRange)
							seePlayer(p);
					}
					break;
				case "Todd":
					if (o != this)
						if (position.dist(o.position) <= trollSenseRange)
						{
							sensedObjects.add(o);
							numTrolls++;
						}
					break;
			}
		}
	}
	
	void seePlayer(Player p)
	{
		if (!seesPlayer)
		{
			seesPlayer = true;
			trackedPlayer = p;
		}
		if (!sensedObjects.contains(p))
			sensedObjects.add(p);
	}
	
	void think()
	{
		switch (variation)
		{
			case 0://think hardcoded for variation 0
				if (sawPlayer && !seesPlayer)
					returning = true;
				if (position.x == origin.x && position.y == origin.y && !seesPlayer)
					returning = false;
					break;
			case 1:
				break;
		}
		
		pathUpdateTime--;
		if (pathUpdateTime <= 0 || sawPlayer != seesPlayer)//figure out how many trolls see players
		{
			numTrollsSeePlayers = 0;
			for (Object o : objects)
			{
				switch(o.getClass().getSimpleName())
				{
					case "Todd":
						Todd t = (Todd) o;
						if (t.seesPlayer)
							numTrollsSeePlayers++;
						break;
				}
			}
			
			threat = calculateNetThreat(sensedObjects);
			
			switch (variation)
			{
				case 0://hardcoded stuffs
					if (seesPlayer || sawPlayer || returning || (!returning && position.x == origin.x && position.y == origin.y && !path.getLooping()))
						path = MakePath();
					break;
				
				case 1://think of current state//determine state
					sM.getCurrentState().transition();
					sM.getCurrentState().think();
					//path = MakePath();
					break;
				
				case 2:
					rC.chooseBucket();
					path = MakePath();
					break;
			}
			pathUpdateTime = pathUpdateTimeCap;
		}
	}
	
	float calculateNetThreat(Objects objects)
	{
		float netPlayerHealth = 0;
		float netPlayerDamage = 0;
		float netTrollHealth = health;
		float netTrollDamage = weaponDamage;
		int numTrollsCounted = 0;
		for (Object o : objects)
		{
			switch(o.getClass().getSimpleName())
			{
				case "Player":
					Player p = (Player) o;
					netPlayerHealth += p.health;
					netPlayerDamage += p.weaponDamage;
					break;
				case "Todd":
					if (numTrollsCounted < 4)//max 4 because only four trolls can attack at once
					{
						Todd t = (Todd) o;
						netTrollHealth += t.health;
						netTrollDamage += t.weaponDamage;
						numTrollsCounted++;
					}
					break;
			}
		}
		
		float timeToKill = netPlayerHealth / netTrollDamage;
		float timeToBeKilled = netTrollHealth / netPlayerDamage - 1;//-1 so they try to survive
		
		return timeToKill - timeToBeKilled;
	}
	
	StateMachine createStateMachine()//variation 1
	{
		StateMachine s = new StateMachine();
		s.add(new State("Hide"){
			public void start()
			{
				returned = false;
			}
			public void transition()
			{
				//if almost dead
				if (health < 4)
				{
					if (sM.printTransitions)
						println("Hide -> Flee from almost dead");
					sM.setCurrentState("Flee");
				}
				else if (seesPlayer)
				{
					//if the enemy will one shot him
					if (health <= trackedPlayer.weaponDamage)
					{
						if (sM.printTransitions)
							println("Hide -> Flee from one shot");
						sM.setCurrentState("Flee");
					}
					
					if (threat > 0)//if the enemy is more powerful
					{
						//if not many trolls are paying attention and the enemy is very dangerous
						if (numTrolls > 0 && (1 - numTrollsSeePlayers / numTrolls) * threat > attentionThreshold)
						{
							if (sM.printTransitions)
								println("Hide -> Flee from not enough paying attention");
							sM.setCurrentState("Flee");
						}
						//if the enemy is very, very dangerous
						else if (threat > dangerThreshold)
						{
							if (sM.printTransitions)
								println("Hide -> Flee from too dangerous");
							sM.setCurrentState("Flee");
						}
					}
					else
					{
						//if many of the other trolls are paying attention
						if (numTrolls > 0 && (numTrollsSeePlayers / numTrolls > .7))
						{
							if (sM.printTransitions)
								println("Hide -> Attack");
							sM.setCurrentState("Attack");
						}
					}
				}
			}
			public void think()
			{
				//always return to origin
				path = MakePath();
			}
			public void act()
			{
				if (!returned && position.x == origin.x && position.y == origin.y)
				{
					returned = true;
					rotation = hideAngle;
				}
			}
		});
		s.setCurrentState("Hide");//hide is default state
		
		s.add(new State("Attack"){
			public void transition()
			{
				//if almost dead
				if (health < 4)
				{
					if (sM.printTransitions)
						println("Attack -> Flee from almost dead");
					sM.setCurrentState("Flee");
				}
				else if (seesPlayer)
				{
					//if the enemy will one shot him
					if (health <= trackedPlayer.weaponDamage)
					{
						if (sM.printTransitions)
							println("Attack -> Flee from one shot");
						sM.setCurrentState("Flee");
					}
					
					if (threat > 0)//if the enemy is more powerful
					{
						//if not many trolls are paying attention and the enemy is very dangerous
						if (numTrolls > 0 && (1 - numTrollsSeePlayers / numTrolls) * threat > attentionThreshold)
						{
							if (sM.printTransitions)
								println("Attack -> Hide from not enough paying attention");
							sM.setCurrentState("Hide");
						}
						//if the enemy is very, very dangerous
						else if (threat > dangerThreshold)
						{
							if (sM.printTransitions)
								println("Attack -> Flee from too dangerous");
							sM.setCurrentState("Flee");
						}
					}
				}
				else
				{
					if (sM.printTransitions)
						println("Attack -> Hide from losing sight");
					sM.setCurrentState("Hide");
				}
			}
			public void think()
			{
				//always pursue player
				path = MakePath();
			}
			public void act()
			{
				
			}
		});
		
		s.add(new State("Flee"){
			public void transition()
			{
				if (position.dist(safeSpace) < 3 && health == healthCap)
				{
					if (sM.printTransitions)
						println("Flee -> Hide from full health");
					sM.setCurrentState("Hide");
				}
			}
			public void think()
			{
				//always run to safe space
				path = MakePath();
			}
			public void act()
			{
				if (position.dist(safeSpace) < 3 && health < healthCap)
					health++;
			}
		});
		
		return s;
	}
	
	ResponseCurve createResponseCurve()//variation 2
	{
		ResponseCurve r = new ResponseCurve();
		r.add(new ResponseBucket("Hide"){
			public void start()
			{
				returned = false;
			}
			public int size()
			{
				float weight = 0;
				if (seesPlayer)
				{
					if (threat > 0)
					{
						float pDist = position.dist(trackedPlayer.position);
						if (pDist < 4)
						{
							//if player is not that close or threatening, medium chance to wait
							weight += pDist * 30 / threat;
						}
						else
						{
							//if player is threatening but not close, high chance to wait
							weight += 50 / threat;
						}
					}
					else
					{
						//if not many other trolls are watching, high chance to wait
						if (numTrolls > 0)
							weight += (1 - numTrollsSeePlayers / numTrolls) * 50 / abs(threat);
					}
				}
				//if can't see player and health high, low chance to wait, high chance if at origin
				else
				{
					weight += health / healthCap * 3;
					if (position.x == origin.x && position.y == origin.y)
						weight += health / healthCap * 60;
					
					//if not many are watching
					if (numTrolls > 0)
						weight += (1 - numTrollsSeePlayers / numTrolls) * 30;
				}
				
				return (int) weight;
			}
			public void act()
			{
				if (!returned && position.x == origin.x && position.y == origin.y)
				{
					returned = true;
					rotation = hideAngle;
				}
			}
		});
		r.setCurrentBucket("Hide");//hide is default state
		
		r.add(new ResponseBucket("Attack"){
			public int size()
			{
				float weight = 0;
				if (seesPlayer)
				{
					if (threat <= 0)
					{
						//if many other trolls are watching, high chance to attack
						if (numTrolls > 0)
							weight += numTrollsSeePlayers / numTrolls * 20 * abs(threat);
						
						//low chance increase the higher the net threat
						weight += abs(threat) * 2;
					}
				}
				
				return (int) weight;
			}
			public void act()
			{
				
			}
		});
		
		r.add(new ResponseBucket("Flee"){
			public int size()
			{
				float weight = 0;
				
				//if he is going for the healing, high chance to keep going for it
				if (rC.getCurrentBucket().name.equals("Flee"))
					if (position.dist(safeSpace) < 3)
					{
						if (health < healthCap)
							weight += 120;
					}
					else if (health < healthCap)
						weight += 150;
				
				if (seesPlayer)
				{
					//if would get one shot, go heal plox
					if (health <= trackedPlayer.weaponDamage)
						weight += 300;
					
					if (threat > 0)
					{
						float pDist = position.dist(trackedPlayer.position);
						if (pDist < 4)
						{
							//if player is not that close or threatening, medium chance to flee
							weight += (4 - pDist) * 30 * threat;
						}
						else
						{
							//if player is threatening but not close, low chance to flee
							weight += 5 * threat;
						}
					}
				}
				//if can't see player and low health, high chance to flee
				else weight += (1 - health / healthCap) * 100;
				
				return (int) weight;
			}
			public void act()
			{
				if (position.dist(safeSpace) < 3 && health < healthCap)
					health++;
			}
		});
		
		return r;
	}
	
	Path MakePath()
	{
		//println("Creating Path");
		switch (variation)
		{
			case 0:
				if (!seesPlayer && !sawPlayer && !returning && position.x == origin.x && position.y == origin.y && (path == null || !path.getLooping()))//normal pathing
				{
					//println("Looped path");
					return new Path(pArray, true);
				}
				else
				{
					//println("Origin");
					return generatePath(calcDestination());//go back to start or puruse player
				}
				//break;
			//case 1:
				//break;
			//case 2:
				//break;
		}
		
		//println("Dum");
		return generatePath(calcDestination());
	}
	
	PVector calcDestination()
	{
		switch (variation)
		{
			case 0:
				if (returning)
					return origin;
				if (seesPlayer)
					return trackedPlayer.position;
				break;
			case 1:
				switch (sM.getCurrentState().name)
				{
					case "Hide":
						return origin;
					case "Attack":
						return trackedPlayer.position;
					case "Flee":
						return safeSpace;
				}
				break;
			case 2:
				switch (rC.getCurrentBucket().name)
				{
					case "Hide":
						return origin;
					case "Attack":
						return trackedPlayer.position;
					case "Flee":
						return safeSpace;
				}
				break;
		}
		return position;
	}
	
	Path generatePath(PVector v)
	{
		pathUpdateTime = pathUpdateTimeCap;
		Path p = pather.GeneratePath(position, v);
		return p;
	}
	
	void act()
	{
		fighting = false;
		pursuing = false;
		
		stepTime--;
		if (stepTime <= 0)
		{
			//step on path
			int moveDir = -1;
			stepTime = stepTimeCap;
			moveDir = path.step();
			moved = Move(moveDir);
			
			//keep trying on current static path if variation 0
			if (!moved && moveDir != GridDir.NULL && path.getLooping())
				path.reverseStep();
			
			//rotate with path
			if (!seesPlayer)
				if (path.getNextMove() != GridDir.NULL)
					rotation = getAngle(GridDir.Move(path.getNextMove()));
			
			Objects attacking = new Objects();//list of players attacking this
			for (Object o : sensedObjects)
			{
				switch(o.getClass().getSimpleName())
				{
					case "Player":
						Player p = (Player) o;
						//get attacked by all players in range
						if (position.dist(p.position) <= attackRange)
						{
							if (p.alive && !p.attacked)
							{
								damage(p.weaponDamage);
								attacking.add(p);
								p.attacked = true;
							}
						}
						break;
				}
			}
			
			if (trackedPlayer != null)//attack tracked player
			{
				if (attacking.size() > 0 && !attacking.contains(trackedPlayer))//change focus to attacking player
					trackedPlayer = (Player) attacking.get(0);
				if (position.dist(trackedPlayer.position) <= attackRange)
					if (seesPlayer)
						trackedPlayer.damage(weaponDamage);
			}
			
			if (variation == 1)
				sM.getCurrentState().act();
			else if (variation == 2)
				rC.getCurrentBucket().act();
		}
		//rotate to player
		if (seesPlayer)
			rotation = getAngle(PVector.sub(trackedPlayer.position, position));
		
		//animate
		if (variation == 0 && seesPlayer)
		{
			if (position.dist(trackedPlayer.position) <= attackRange)
				fighting = true;
			if (moved)
				pursuing = true;
		}
	}
	
	void draw()
	{
		super.draw();
		fill(0);
		line(0, 0, size.x / 2, 0);
		
		if (debug)
		{
			//sight radius
			noFill();
			stroke(#000000, 150);
			arc(0, 0, sightRange * grid.gridSize * 2, sightRange * grid.gridSize * 2, -radians(sightAngle), radians(sightAngle));
			PVector lineVec = new PVector(sightRange * grid.gridSize, 0);
			lineVec.rotate(radians(sightAngle));
			line(0, 0, lineVec.x, lineVec.y);
			lineVec.rotate(-radians(sightAngle * 2));
			line(0, 0, lineVec.x, lineVec.y);
			//hearing radius
			ellipse(0, 0, hearRange * grid.gridSize * 2, hearRange * grid.gridSize * 2);
			//troll sense radius
			ellipse(0, 0, trollSenseRange * grid.gridSize * 2, trollSenseRange * grid.gridSize * 2);
			
			rotate(-radians(rotation));
			
			path.draw();
		}
		else rotate(-radians(rotation));
		
		//health
		fill(#f02b08);
		stroke(#000000);
		rect(-grid.gridSize * 3 / 4 - 1, -grid.gridSize - 1, grid.gridSize * 3 / 2 + 2, 2);
		stroke(#2bff09);
		line(-grid.gridSize * 3 / 4, -grid.gridSize, -grid.gridSize * 3 / 4 + health * grid.gridSize * 3 / 2 / healthCap, -grid.gridSize);
	}
	
	/**
	 * This method is a simple replacement for animation. I could simply call some animator's method to animate, but that is too pseudocode-y.
	 * A good pseudocode replacement would be animate();
	 */
	void drawGUI()
	{
		String printString = "";
		
		switch (variation)
		{
			case 0:
				if (fighting)
					printString = "Fighting!";
				else if (pursuing)
					printString = "Pursuing!";
				break;
			case 1:
				printString = sM.getCurrentState().name;
				break;
			case 2:
				printString = "" + rC;
				//printString = rC.getCurrentBucket().name;
				break;
		}
		
		pushMatrix();
		pushStyle();
		
		textAlign(CENTER);
		
		fill(0);
		text(printString, (position.x /*+ 5 / 2*/) * grid.gridSize - 1, (position.y - 1 /*+ 3*/ / 2) * grid.gridSize - 1);
		
		popStyle();
		popMatrix();
	}
}
