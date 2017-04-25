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
	
	//status vars (thinking)
	float healthCap = 100;
	float health = healthCap;
	float weaponDamage = 5;
	float attackRange = 1.2;
	boolean returning = false;
	
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
		dest = calcDestination();
		
		path = MakePath();
		
		c = color(#15538c);
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
							sensedObjects.add(o);
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
		if (variation == 0)//think hardcoded for variation 0
		{
			if (sawPlayer && !seesPlayer)
				returning = true;
			if (position.x == origin.x && position.y == origin.y && !seesPlayer)
				returning = false;
			
			pathUpdateTime--;
			if (pathUpdateTime <= 0 || sawPlayer != seesPlayer)
			{
				switch (variation)
				{
					case 0:
						/*if (seesPlayer)
							path = MakePath();
						else
						{
							if (sawPlayer)//path back to origin
								path = MakePath();
							
							if (!path.getLooping() && position.x == origin.x && position.y == origin.y)
								path = MakePath();
						}*/
						if (seesPlayer || sawPlayer || returning || (!returning && position.x == origin.x && position.y == origin.y && !path.getLooping()))
							path = MakePath();
						break;
					
					default:
						path = MakePath();
						break;
				}
				pathUpdateTime = pathUpdateTimeCap;
			}
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
			//case 1:
				//return harry.position;
				//break;
			//case 2:
				//return safeSpace;
				//break;
		}
		return position;
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
			
			for (Object o : sensedObjects)
			{
				switch(o.getClass().getSimpleName())
				{
					case "Player":
						Player p = (Player) o;
						//get attacked
						if (position.dist(p.position) <= attackRange)
						{
							if (p.alive)
								damage(p.weaponDamage);
						}
						break;
				}
			}
			
			if (trackedPlayer != null)//attack tracked player
				if (position.dist(trackedPlayer.position) <= attackRange)
					if (seesPlayer)
						trackedPlayer.damage(weaponDamage);
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
