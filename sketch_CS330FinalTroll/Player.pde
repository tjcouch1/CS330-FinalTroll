//Player - The object that moves around (Using WASD)
//Timothy Couch

class Player extends Movable
{
	int stepTimeCap = 5;
	int stepTime = stepTimeCap;
	
	float health = 100;
	float weaponDamage = 4;
	boolean alive = true;
	
	Player()
	{
		super();
		
		InitDefault();
	}

	Player(PVector position)
	{
		super(position);
		
		InitDefault();
	}

	void InitDefault()
	{
		c = color(#d93600);
	}
	
	void damage(float d)
	{
		health -= d;
		if (health <= 0)
		{
			alive = false;
			objects.destroy(this);
		}
	}
	
	void KeyPressed(char key)
	{
		super.KeyPressed(key);
		
		stepTime = stepTimeCap;
		Move(GridDir.KeyDir(key));
	}
	
	void KeyDown(char key)
	{
		super.KeyDown(key);
		
		stepTime--;
		if (stepTime <= 0)
		{
			stepTime = stepTimeCap;
			Move(GridDir.KeyDir(key));
		}
		
	}
}
