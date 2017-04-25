//Grid - handles grid spaces, movement, and drawing
//Timothy Couch

class Grid
{
	int gridWidth;
	int gridHeight;
	
	GridObject[][] gridContents;
	
	int gridSize;
	
	public Grid()
	{
		gridWidth = 16;
		gridHeight = 16;
		
		InitDefault();
	}
	
	public Grid(int gW, int gH)
	{
		this();
		
		gridWidth = gW;
		gridHeight = gH;
		
		InitDefault();
	}
	
	public Grid(int gW, int gH, int gS)
	{
		this(gW, gH);
		
		gridSize = gS;
	}
	
	void InitDefault()
	{
		float squareSizeX = width / gridWidth;
		float squareSizeY = height / gridHeight;
		gridSize = round(min(squareSizeX, squareSizeY));
		
		gridContents = new GridObject[gridWidth][gridHeight];
		
		for (int i = 0; i < gridWidth; i++)
			for (int j = 0; j < gridHeight; j++)
				gridContents[i][j] = null;
	}
	
	GridObject add(GridObject o)
	{
		gridContents[round(o.position.x)][round(o.position.y)] = o;
		return o;
	}
	
	PVector remove(GridObject o)
	{
		for (int i = 0; i < gridWidth; i++)
			for (int j = 0; j < gridHeight; j++)
				if (gridContents[i][j] == o)
				{
					gridContents[i][j] = null;
					return new PVector(i, j);
				}
		return null;
	}
	
	GridObject removePlace(PVector pos)
	{
		GridObject o = gridContents[(int) pos.x][(int) pos.y];
		gridContents[(int) pos.x][(int) pos.y] = null;
		return o;
	}
	
	GridObject getPlace(PVector pos)
	{
		return gridContents[(int) pos.x][(int) pos.y];
	}
	
	GridObject updateGridObject(GridObject o)
	{
		remove(o);
		add(o);
		return o;
	}
	
	boolean spaceOpen(PVector v)
	{
		if (round(v.x) >= 0 && round(v.x) < gridWidth && round(v.y) >= 0 && round(v.y) < gridHeight)
			return gridContents[round(v.x)][round(v.y)] == null;
		return false;
	}
	
	void draw()
	{
		pushStyle();
		
		fill(#ffffff, 128);
		noStroke();
		//tint(255, 100);
		
		for (int i = 0; i < gridWidth; i++)
			for (int j = 0; j < gridHeight; j++)
				if (gridContents[i][j] != null)
					rect(i * gridSize, j * gridSize, gridSize, gridSize);
		
		fill(#00b3b2, 128);
		rect(safeSpace.x * gridSize, safeSpace.y * gridSize, gridSize, gridSize);
		fill(#d96c00, 128);
		rect(bridge.x * gridSize, bridge.y * gridSize, gridSize, gridSize);
		
		popStyle();
		
		fill(0);
		for (int i = 0; i < grid.gridWidth; i++)
		{
			int x = i * grid.gridSize;
			line(x, 0, x, height);
		}
		for (int j = 0; j < grid.gridHeight; j++)
		{
			int y = j * grid.gridSize;
			line(0, y, width, y);
		}
	}
}
