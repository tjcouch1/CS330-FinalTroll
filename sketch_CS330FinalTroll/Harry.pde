//Harry - Harry the troll who runs around in a circle in the second demo
//Timothy Couch

class Harry extends Movable
{
	int[] pArray = {GridDir.LEFT, 
					GridDir.LEFT,  
					GridDir.UP,  
					GridDir.LEFT,  
					GridDir.UP,  
					GridDir.UP,  
					GridDir.UP,  
					GridDir.UP,  
					GridDir.RIGHT,  
					GridDir.UP,  
					GridDir.RIGHT, 
					GridDir.RIGHT, 
					GridDir.RIGHT, 
					GridDir.RIGHT, 
					GridDir.DOWN, 
					GridDir.RIGHT, 
					GridDir.DOWN,  
					GridDir.DOWN,  
					GridDir.DOWN,  
					GridDir.DOWN,  
					GridDir.LEFT,
					GridDir.DOWN,
					GridDir.LEFT, 
					GridDir.LEFT};
	Path path;
	
	int stepTimeCap = 5;
	int stepTime = stepTimeCap;
	
	boolean stopped = false;
	
	Harry()
	{
		super();
		
		InitDefault();
	}

	Harry(PVector position)
	{
		super(position);
		
		InitDefault();
	}

	void InitDefault()
	{
		path = new Path(pArray);
		
		c = color(#59b300);
	}
	
	void step()
	{
		if (new PVector(tina.position.x - position.x, tina.position.y - position.y).mag() < 1.5)
			stopped = true;
		else stopped = false;
		if (!stopped)
		{
			stepTime--;
			if (stepTime <= 0)
			{
				stepTime = stepTimeCap;
				Move(path.stepLoop());
			}
		}
}
	
	void draw()
	{
		super.draw();
		
		if (debug)
			path.draw();
	}
	
	/**
	 * This method is a simple replacement for animation. I could simply call some animator's method to animate, but that is too pseudocode-y.
	 * A good pseudocode replacement would be animate();
	 */
	void drawGUI()
	{
		String printString = "";
		if (stopped)
			printString = "Healing!";
		
		fill(0);
		text(printString, (position.x + 5 / 2) * grid.gridSize - 1, (position.y + 3 / 2) * grid.gridSize - 1);
	}
}