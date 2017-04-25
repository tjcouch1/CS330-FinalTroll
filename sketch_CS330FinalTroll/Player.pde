//Player - The object that moves around (Using WASD)
//Timothy Couch

class Player extends Movable
{
	int stepTimeCap = 5;
	int stepTime = stepTimeCap;
	
	float healthCap = 100;
	float health = healthCap;
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
	
	void draw()
	{
		super.draw();
		
		//if (debug)
		{
			rotate(-radians(rotation));
			//health
			fill(#f02b08);
			stroke(#000000);
			rect(-grid.gridSize * 3 / 4 - 1, -grid.gridSize - 1, grid.gridSize * 3 / 2 + 2, 2);
			stroke(#2bff09);
			line(-grid.gridSize * 3 / 4, -grid.gridSize, -grid.gridSize * 3 / 4 + health * grid.gridSize * 3 / 2 / healthCap, -grid.gridSize);
		}
	}
}
