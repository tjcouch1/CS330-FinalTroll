//Object - basic object with actions, translation, and stuff
//Timothy Couch

class Object
{
	PVector position;
	PVector origin;
	PVector size;
	float rotation;//in degrees
	float scaleX;
	float scaleY;
	color c;//color

	boolean visible = true;
	boolean active = true;

	Object()
	{
		position = new PVector(0, 0);
		origin = position.copy();
		size = new PVector(10, 10);
		rotation = 0;
		scaleX = 1;
		scaleY = 1;
		c = color(0);
	}

	Object(PVector pos)
	{
		this();

		this.position = pos.copy();
		origin = position.copy();
		c = color(200);
	}

	Object(PVector pos, PVector size)
	{
		this(pos);
		this.size = size.copy();
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
	
	float getAngle(PVector v)
	{
		float angle = degrees(PVector.angleBetween(new PVector(1, 0), v));
		if (v.y < 0)
			angle *= -1;
		
		return angle;
	}

	void drawObj()
	{
		pushMatrix();
		translate(position.x, position.y);
		scale(scaleX, scaleY);
		rotate(radians(rotation));

		pushStyle();

		draw();

		popStyle();

		popMatrix();
	}

	void drawGUI()
	{
		pushMatrix();
		translate(position.x, position.y);
		scale(scaleX, scaleY);
		rotate(radians(rotation));
		
		pushStyle();
		textAlign(CENTER);
		
		drawLate();

		popStyle();

		popMatrix();
	}

	void draw()
	{
		fill(c);
		rect(size.x * -1 / 2, size.y * -1 / 2, size.x, size.y);
	}
	
	void drawLate()
	{
		
	}
}
