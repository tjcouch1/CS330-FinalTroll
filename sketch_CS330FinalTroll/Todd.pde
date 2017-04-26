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
	
	//animation vars (acting)
	boolean fighting = false;
	boolean pursuing = false;

	Path path;
	PVector dest;
	boolean moved = false;
	
	//counter vars
	int stepTimeCap = 5;
	int stepTime = stepTimeCap;
	
	int pathUpdateTimeCap = 10;
	int pathUpdateTime = pathUpdateTimeCap;
	
	StateMachine sM;
	
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
		
		dest = calcDestination();
		
		path = MakePath();
		
		c = color(#15538c);
		
		if (variation > 0)
			rotation = getAngle(chestPos.x + 2 - position.x, chestPos.y - position.y);
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
			case 1://determine state
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
				sM.getCurrentState().transition();
				break;
		}
		
		pathUpdateTime--;
		if (pathUpdateTime <= 0 || sawPlayer != seesPlayer)
		{
			switch (variation)
			{
				case 0://hardcoded stuffs
					if (seesPlayer || sawPlayer || returning || (!returning && position.x == origin.x && position.y == origin.y && !path.getLooping()))
						path = MakePath();
					break;
				
				case 1://think of current state
					sM.getCurrentState().think();
					//path = MakePath();
					break;
				
				case 2:
					path = MakePath();
					break;
			}
			pathUpdateTime = pathUpdateTimeCap;
		}
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
		}
		return position;
	}
	
	float calculateNetThreat(Objects objects)
	{
		float netPlayerHealth = 0;
		float netPlayerDamage = 0;
		float netTrollHealth = 0;
		float netTrollDamage = 0;
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
					Todd t = (Todd) o;
					netTrollHealth += t.health;
					netTrollDamage += t.weaponDamage;
					break;
			}
		}
		
		float timeToKill = netPlayerHealth / netTrollDamage;
		float timeToBeKilled = netTrollHealth / netPlayerDamage;
		
		return timeToBeKilled - timeToKill;
	}
	
	StateMachine createStateMachine()
	{
		StateMachine s = new StateMachine();
		s.add(new State("Hide"){
			public void transition()
			{
				if (threat > 0)//if the enemy is more powerful
				{
					//if not many trolls are paying attention and the enemy is very dangerous
					if (numTrolls > 0 && (1 - numTrollsSeePlayers / numTrolls) * threat > 10)
					{
						println("Fleeing from not enough paying attention");
						sM.setCurrentState("Flee");
					}
					//if the enemy is very, very dangerous
					else if (threat > 20)
					{
						println("Fleeing from too dangerous");
						sm.stcurrentState("Flee");
					}
				}
				else
				{
					//if many of the other trolls are paying attention
					if (numTrolls > 0 && (numTrollsSeePlayers / numTrolls > .7))
						sM.setCurrentState("Attack");
				}
				
			}
			public void think()
			{
				
			}
			public void act()
			{
				
			}
		});
		s.setCurrentState("Hide");//hide is default state
		
		s.add(new State("Attack"){
			public void transition()
			{
				
			}
			public void think()
			{
				
			}
			public void act()
			{
				
			}
		});
		
		s.add(new State("Flee"){
			public void transition()
			{
				
			}
			public void think()
			{
				
			}
			public void act()
			{
				
			}
		});
		
		return s;
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
							if (p.alive)
							{
								damage(p.weaponDamage);
								attacking.add(p);
							}
						}
						break;
				}
			}
			
			if (trackedPlayer != null)//attack tracked player
			{
				if (attacking.size() > 0 && !attacking.contains(trackedPlayer))//change trackedPlayer to attacking player
					trackedPlayer = (Player) attacking.get(0);
				if (position.dist(trackedPlayer.position) <= attackRange)
					if (seesPlayer)
						trackedPlayer.damage(weaponDamage);
			}
		}
		//rotate to player
		if (seesPlayer)
			rotation = getAngle(PVector.sub(trackedPlayer.position, position));
		
		//animate
		if (seesPlayer)
		{
			if (position.dist(trackedPlayer.position) <= attackRange)
				fighting = true;
			if (moved)
				pursuing = true;
		}
	}
	
	Path MakePath()
	{
		//println("Creating Path");
		if (variation == 0)
		{
			if (!seesPlayer && !sawPlayer && !returning && position.x == origin.x && position.y == origin.y && (path == null || !path.getLooping()))//normal pathing
			{
				//println("Looped path");
				return new Path(pArray, true);
			}
			else
			{
				//println("Origin");
				return GeneratePath(calcDestination());//go back to start or puruse player
			}
		}
		
		//println("Dum");
		return GeneratePath(calcDestination());
	}
	
	Path GeneratePath(PVector v)
	{
		pathUpdateTime = pathUpdateTimeCap;
		Path p = pather.GeneratePath(position, v);
		return p;
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
		if (fighting)
			printString = "Fighting!";
		else if (pursuing)
			printString = "Pursuing!";
		
		fill(0);
		text(printString, (position.x + 5 / 2) * grid.gridSize - 1, (position.y + 3 / 2) * grid.gridSize - 1);
	}
}
