//GridDir - handles directions
//Timothy Couch

static class GridDir
{
	static int NULL = -1;
	static int UP = 0;
	static int DOWN = 1;
	static int LEFT = 2;
	static int RIGHT = 3;
	
	static int KeyDir(char key)
	{
		switch (key)
		{
		case 'W':
			return UP;
		case 'S':
			return DOWN;
		case 'A':
			return LEFT;
		case 'D':
			return RIGHT;
		default:
			return NULL;
		}
	}

	static PVector Move(int dir)
	{
		if (dir == GridDir.UP)
			return new PVector(0, -1);
		if (dir == GridDir.DOWN)
			return new PVector(0, 1);
		if (dir == GridDir.LEFT)
			return new PVector(-1, 0);
		if (dir == GridDir.RIGHT)
			return new PVector(1, 0);
		return new PVector(0, 0);
	}
	
	static int VectorDir(PVector v)
	{
		int dir = -1;
		if (abs(v.x) >= abs(v.y))
		{
			if (v.x >= 0)
				dir = GridDir.RIGHT;
			else dir = GridDir.LEFT;
		}
		else
			if (v.y < 0)
				dir = GridDir.UP;
			else dir = GridDir.DOWN;
		
		return dir;
	}
}