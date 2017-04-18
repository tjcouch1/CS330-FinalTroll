//Block - a simple path obstructor
//Timothy Couch

class Block extends GridObject
{
	Block()
	{
		super();
		
		InitDefault();
	}

	Block(PVector position)
	{
		super(position);
		
		InitDefault();
	}

	//replacement for default constructor
	void InitDefault()
	{
		c = color(50);
	}

	void draw()
	{
		fill(c);
		noStroke();
		rect(0, 0, grid.gridSize, grid.gridSize);
	}
}