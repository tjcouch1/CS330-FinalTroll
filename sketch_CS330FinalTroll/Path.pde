//Path - holds path instructions
//Timothy Couch

class Path
{
	int[] path;
	int step;
	
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
	
	Path(int[] p)
	{
		this();
		
		path = p;
	}
	
	int step()
	{
		if (path.length > 0 && step < path.length)
		{
			int currStep = step;
			step++;
			return path[currStep];
		}
		return GridDir.NULL;
	}
	
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
		stroke(#ffffff, round(((float) path.length - currStep) / (path.length - step) * 255));
		line((p1.x + .5) * grid.gridSize, (p1.y + .5) * grid.gridSize, (p2.x + .5) * grid.gridSize, (p2.y + .5) * grid.gridSize);
	}
}