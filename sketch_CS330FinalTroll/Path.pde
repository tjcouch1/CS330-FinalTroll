//Path - holds path instructions
//Timothy Couch

class Path
{
	int[] path;
	int step;
	
	boolean loop = false;
	
	Path()
	{
		path = new int[1];
		path[0] = GridDir.NULL;
		/* path = new int[4];
		path[0] = GridDir.UP;
		path[1] = GridDir.RIGHT;
		path[2] = GridDir.DOWN;
		path[3] = GridDir.LEFT;
		 */
		step = 0;
	}
	
	Path(boolean looping)
	{
		this();
		setLooping(looping);
	}
	
	Path(int[] p)
	{
		this();
		path = p;
	}
	
	Path(int[] p, boolean looping)
	{
		this();
		path = p;
		setLooping(looping);
	}
	
	int step()
	{
		if (path.length > 0 && (step < path.length || getLooping()))
		{
			int currStep = step;
			step++;
			if (getLooping())
				step %= path.length;
			return path[currStep];
		}
		return GridDir.NULL;
	}
	
	//DEPRECATED
	int stepLoop()
	{
		if (path.length > 0)
		{
			int currStep = step;
			step++;
			step %= path.length;
			return path[currStep];
		}
		return GridDir.NULL;
	}
	
	boolean finished()
	{
		return step == path.length;
	}
	
	boolean getLooping()
	{
		return loop;
	}
	
	void setLooping(boolean looping)
	{
		loop = looping;
	}
	
	void draw()
	{
		PVector currPos = new PVector(0, 0);
		for (int i = step; i < path.length; i++)
		{
			PVector prevPos = currPos.copy();
			currPos.add(GridDir.Move(path[i]));
			drawSegment(prevPos, currPos, i);
		}
	}
	
	void drawSegment(PVector p1, PVector p2, int currStep)
	{
		float offset = 0;//.5;
		stroke(#ffffff, round(((float) path.length - currStep) / (path.length - step) * 255));
		line((p1.x + offset) * grid.gridSize, (p1.y + offset) * grid.gridSize, (p2.x + offset) * grid.gridSize, (p2.y + offset) * grid.gridSize);
	}
}
