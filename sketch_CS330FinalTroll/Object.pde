//Object - basic object with actions, translation, and stuff
//Timothy Couch

class Object
{
	PVector position;
	float imageAngle;//in degrees
	float scaleX;
	float scaleY;
	color c;//color

	Object()
	{
		position = new PVector(0, 0);
		imageAngle = 0;
		scaleX = 1;
		scaleY = 1;
		c = color(0);
	}

	Object(PVector pos)
	{
		this();
		
		this.position = pos.copy();
		c = color(200);
	}

	void step()
	{
		
	}

	void KeyPressed(char key)
	{
	}

	void KeyReleased(char key)
	{
	}

	void KeyDown(char key)
	{
	}

	void drawObj()
	{
		pushMatrix();
		translate(position.x, position.y);
		rotate(radians(imageAngle));
		scale(scaleX, scaleY);
		
		pushStyle();
		
		draw();
		
		popStyle();
		
		popMatrix();
	}

	void drawGUI()
	{
		
	}

	void draw()
	{
		fill(c);
		rect(-5, -5, 10, 10);
	}
}