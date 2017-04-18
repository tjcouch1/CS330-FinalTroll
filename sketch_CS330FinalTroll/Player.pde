//Player - The object that moves around (Using WASD)
//Timothy Couch

class Player extends Movable
{
	int stepTimeCap = 5;
	int stepTime = stepTimeCap;
	
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