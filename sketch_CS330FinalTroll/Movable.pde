//Movable - GridObject that has moving functionality
//Timothy Couch

class Movable extends GridObject
{
	Movable()
	{
		super();
		
		InitDefault();
	}

	Movable(PVector position)
	{
		super(position);
		
		InitDefault();
	}

	void InitDefault()
	{
		c = color(#00d9a3);
	}

	void step()
	{
		super.step();
	}

	boolean CanMove(int dir, int spaces)
	{
		if (dir == GridDir.UP)
		{
			if (grid.spaceOpen(new PVector(position.x, position.y - spaces)))
				return true;
		}
		else if (dir == GridDir.DOWN)
		{
			if (grid.spaceOpen(new PVector(position.x, position.y + spaces)))
				return true;
		}
		else if (dir == GridDir.LEFT)
		{
			if (grid.spaceOpen(new PVector(position.x - spaces, position.y)))
				return true;
		}
		else if (dir == GridDir.RIGHT)
		{
			if (grid.spaceOpen(new PVector(position.x + spaces, position.y)))
				return true;
		}
		return false;
	}
	
	boolean CanMove(int dir)
	{
		return CanMove(dir, 1);
	}

	boolean Move(int dir, int spaces)
	{
		boolean move = false;
		if (dir == GridDir.UP)
		{
			if (grid.spaceOpen(new PVector(position.x, position.y - spaces)))
			{
				position = new PVector(position.x, position.y - spaces);
				// position.y -= spaces;
				move = true;
			}
		}
		else if (dir == GridDir.DOWN)
		{
			if (grid.spaceOpen(new PVector(position.x, position.y + spaces)))
			{
				position = new PVector(position.x, position.y + spaces);
				// position.y += spaces;
				move = true;
			}
		}
		else if (dir == GridDir.LEFT)
		{
			if (grid.spaceOpen(new PVector(position.x - spaces, position.y)))
			{
				position = new PVector(position.x - spaces, position.y);
				// position.x -= spaces;
				move = true;
			}
		}
		else if (dir == GridDir.RIGHT)
		{
			if (grid.spaceOpen(new PVector(position.x + spaces, position.y)))
			{
				position = new PVector(position.x + spaces, position.y);
				// position.x += spaces;
				move = true;
			}
		}
		
		if (move)
			grid.updateGridObject(this);
		
		return move;
	}
	
	boolean Move(int dir)
	{
		return Move(dir, 1);
	}

	void draw()
	{
		fill(c);
		ellipse(grid.gridSize / 2, grid.gridSize / 2, round(grid.gridSize * 5 / 8), round(grid.gridSize * 5 / 8));
	}
}