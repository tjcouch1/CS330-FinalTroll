//GridObject - Object that conforms to the grid
//Timothy Couch

class GridObject extends Object
{
	GridObject()
	{
		super();
	}

	GridObject(PVector position)
	{
		super(position);
	}

	GridObject(PVector position, PVector size)
	{
		super(position, size);
	}

  boolean containsPoint(PVector p)
  {
		if (p.x >= position.x * grid.gridSize + grid.gridSize / 2 - size.x / 2 && p.x < position.x * grid.gridSize + grid.gridSize / 2 + size.x / 2)
			if (p.y >= position.y * grid.gridSize + grid.gridSize / 2 - size.y / 2 && p.y < position.y * grid.gridSize + grid.gridSize / 2 + size.y / 2)
				return true;
		return false;
  }

	void drawObj()
	{
		pushMatrix();
		translate(position.x * grid.gridSize + grid.gridSize / 2, position.y * grid.gridSize + grid.gridSize / 2);
		rotate(radians(rotation));
		scale(scaleX, scaleY);

		pushStyle();

		draw();

		popStyle();

		popMatrix();
	}
}