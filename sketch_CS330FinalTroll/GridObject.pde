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

	void drawObj()
	{
		pushMatrix();
		translate(position.x * grid.gridSize, position.y * grid.gridSize);
		rotate(radians(imageAngle));
		scale(scaleX, scaleY);
		
		pushStyle();
		
		draw();
		
		popStyle();
		
		popMatrix();
	}
}