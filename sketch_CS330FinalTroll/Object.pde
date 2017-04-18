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
		if (mouseX >= position.x - size.x / 2 && mouseX < position.x + size.x / 2)
			if (mouseY >= position.y - size.y / 2 && mouseY < position.y + size.y / 2)
				clicked();
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
