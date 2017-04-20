//Object - basic object with actions, translation, and stuff
//Timothy Couch

class Object
{
	PVector position;
	PVector size;
	float imageAngle;//in degrees
	float scaleX;
	float scaleY;
	color c;//color

	boolean visible = true;
	boolean active = true;

	Object()
	{
		position = new PVector(0, 0);
		size = new PVector(10, 10);
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

	void MousePressed()
	{
		if (containsPoint(new PVector(mouseX, mouseY)))
				clicked();
	}

  boolean containsPoint(PVector p)
  {
		if (p.x >= position.x - size.x / 2 && p.x < position.x + size.x / 2)
			if (p.y >= position.y - size.y / 2 && p.y < position.y + size.y / 2)
				return true;
		return false;
  }

	void clicked()
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
		rect(size.x * -1 / 2, size.y * -1 / 2, size.x, size.y);
	}
}
