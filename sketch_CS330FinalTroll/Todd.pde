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

	Path path;
	PVector dest;
	boolean moved = false;
	
	//animation vars
	boolean fighting = false;
	boolean pursuing = false;
	
	//status vars
	float healthCap = 100;
	float health = healthCap;
	float weaponDamage = 5;
	float attackRange = 1.2;
	
	//counter vars
	int stepTimeCap = 5;
	int stepTime = stepTimeCap;
	
	int pathUpdateTimeCap = 10;
	int pathUpdateTime = pathUpdateTimeCap;
	
	//sensing
	float sightRange = 7;
	float sightAngle = 30;
	float hearRange = 2;
	Objects seenObjects = new Objects();
	boolean seesPlayer = false;
	boolean sawPlayer = false;
	
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
	
	PVector calcDestination()
	{
		//f (!tired)
			//return origin;
		//else
			switch (variation)
			{
			case 0:
				return safeSpace;
			//case 1:
				//return harry.position;
			case 2:
				return safeSpace;
			default:
				return position;
			}
	}
	
	void damage(float d)
	{
		health -= d;
		if (health <= 0)
			objects.destroy(this);
	}
	
	void step()
	{
		sawPlayer = seesPlayer;
		//sense the world
		sense();
		
		//think about situation
		think();
		
		//act to show thoughts
		act();
	}
	
	void sense()
	{
		seesPlayer = false;
		seenObjects.clear();
		for (Object o : objects)
		{
			//println(o.getClass().getSimpleName());
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
								seesPlayer = true;
						}
						
						//sense the player in hearing range
						if (position.dist(o.position) <= hearRange)
							seesPlayer = true;
					}
					
					if (seesPlayer)
						seenObjects.add(o);
					break;
				case "Todd":
					//if (o != this)
					break;
			}
			
		}
	}
	
	void think()
	{
		if (variation == 0)//think hardcoded for variation 0
		{
			pathUpdateTime--;
			if (pathUpdateTime <= 0 || sawPlayer != seesPlayer)
			{
				switch (variation)
				{
					case 0:
						if (seesPlayer)
							path = MakePath();
						else
						{
							if (sawPlayer)//path back to origin
								path = MakePath();
							
							if (!path.getLooping() && position.x == origin.x && position.y == origin.y)
								path = MakePath();
						}
						break;
					
					case 1:
						dest = calcDestination();
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
			
			//attack player (and get attacked)
			if (position.dist(player.position) <= attackRange)
			{
				if (player.alive)
					damage(player.weaponDamage);
				if (seesPlayer)
					player.damage(weaponDamage);
			}
		}
		//rotate to player
		if (seesPlayer)
			rotation = getAngle(PVector.sub(player.position, position));
		
		//animate
		if (seesPlayer)
		{
			if (position.dist(player.position) <= attackRange)
				fighting = true;
			if (moved)
				pursuing = true;
		}
	}
	
	Path MakePath()
	{
		//println("Creating Path");
		if (variation == 0)
			if (!seesPlayer)
			{
				if (!sawPlayer)//normal pathing
				{
					//println("Looped path");
					return new Path(pArray, true);
				}
				else
				{
					//println("Origin");
					return GeneratePath(origin);//go back to start
				}
			}
			else
			{
				//println("Path to player");
				return GeneratePath(player.position);
			}
		
		//println("Dum");
		return GeneratePath(dest);
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
			arc(0, 0, sightRange * grid.gridSize * 2, sightRange * grid.gridSize * 2, -radians(sightAngle), radians(sightAngle));
			PVector lineVec = new PVector(sightRange * grid.gridSize, 0);
			lineVec.rotate(radians(sightAngle));
			line(0, 0, lineVec.x, lineVec.y);
			lineVec.rotate(-radians(sightAngle * 2));
			line(0, 0, lineVec.x, lineVec.y);
			//hearing raidus
			ellipse(0, 0, hearRange * grid.gridSize * 2, hearRange * grid.gridSize * 2);
			
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
