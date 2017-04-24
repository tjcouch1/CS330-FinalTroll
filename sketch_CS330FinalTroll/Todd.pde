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
	boolean fleeing = false;
	boolean healing = false;
	boolean resting = false;
	
	//status vars
	int energyCap = 600;
	int energy = energyCap;
	boolean tired = false;
	
	int health = 100;
	int weaponDamage = 2;
	
	//counter vars
	int stepTimeCap = 5;
	int stepTime = stepTimeCap;
	
	int pathUpdateTimeCap = 10;
	int pathUpdateTime = pathUpdateTimeCap;
	
	//sensing
	float sightRange = 7;
	float sightAngle = 30;
	float hearRange = 2;
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
		if (!tired)
			return origin;
		else
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
	
	void step()
	{
		sawPlayer = seesPlayer;
		//sense for player
		sense();
		
		//think hardcoded for variation 0
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
		
		//act
		int moveDir = -1;
		stepTime--;
		if (stepTime <= 0)
		{
			//step on path
			stepTime = stepTimeCap;
			moveDir = path.step();
			moved = Move(moveDir);
			
			//keep trying on current static path if variation 0
			if (variation == 0 && !moved && moveDir != GridDir.NULL && path.getLooping())
				path.reverseStep();
			
			//rotate with path or toward player
			if (!seesPlayer)
				if (path.getNextMove() != GridDir.NULL)
					rotation = getAngle(GridDir.Move(path.getNextMove()));
		}
		if (seesPlayer)
			rotation = getAngle(PVector.sub(player.position, position));
		
		if (tired)
			c = color(#002020);
		else c = color(#15538c);
		
		fighting = false;
		fleeing = false;
		healing = false;
		resting = false;
		
		if (variation != 0)
		{
			if (!tired)
			{
				if (!moved)
				{
					if ((position.x != dest.x || position.y != dest.y) && moveDir != GridDir.NULL)// && finished)
						path = MakePath();
					energy--;
					if (new PVector(player.position.x - position.x, player.position.y - position.y).mag() < 4)
					{
						energy -= 3;
						fighting = true;
					}
				}
				
				if (energy <= 0)
				{
					tired = true;
					dest = calcDestination();
					path = MakePath();
				}
			}
			else
			{
				if (!moved)
				{
					if ((position.x != dest.x || position.y != dest.y) && finished)
						path = MakePath();
					if (new PVector(dest.x - position.x, dest.y - position.y).mag() <= 1.5)
					{
						if (variation != 1)
						{
							energy += 3;
							resting = true;
						}
						else
						{
							energy += 4;
							healing = true;
						}
					}
				}
				else fleeing = true;
				
				if (energy >= energyCap)
				{
					tired = false;
					dest = calcDestination();
					path = MakePath();
				}
			}
		}
	}
	
	void sense()
	{
		seesPlayer = false;
		//sense the player in visual sight
		if (position.dist(player.position) <= sightRange)
		{
			PVector forward = PVector.fromAngle(radians(rotation));
			float playerAngle = degrees(PVector.angleBetween(forward, PVector.sub(player.position, position)));
			if (playerAngle <= sightAngle)
				seesPlayer = true;
		}
		
		//sense the player in hearing range
		if (position.dist(player.position) <= hearRange)
			seesPlayer = true;
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
			//hearing raidus
			ellipse(0, 0, hearRange * grid.gridSize * 2, hearRange * grid.gridSize * 2);
			
			rotate(-radians(rotation));
			path.draw();
		}
	}
	
	/**
	 * This method is a simple replacement for animation. I could simply call some animator's method to animate, but that is too pseudocode-y.
	 * A good pseudocode replacement would be animate();
	 */
	void drawGUI()
	{
		String printString = "";
		if (fighting)
			printString = "Combat!";
		else if (fleeing)
			printString = "Fleeing!";
		else if (resting)
			printString = "Resting!";
		else if (healing)
			printString = "Healing!";
		
		if (seesPlayer)
			printString = "Sees Player!";
		
		fill(0);
		text(printString, (position.x + 5 / 2) * grid.gridSize - 1, (position.y + 3 / 2) * grid.gridSize - 1);
	}
}
