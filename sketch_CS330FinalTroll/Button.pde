//Button - a simple click button
//Timothy Couch

class Button extends Object
{
  color borderColor;
  color fillColor;
  color textColor;
  String displayText;

  Button()
  {
    super();

    InitDefault();
  }

  Button(PVector pos)
  {
    super(pos);

    InitDefault();
  }

  Button(PVector pos, PVector size)
  {
    super(pos);

    InitDefault();

    this.size = size.copy();
  }

  void InitDefault()
  {
    size = new PVector(16, 16);
    borderColor = color(0);
    fillColor = color(30);
    textColor = color(0);
    displayText = "";
  }

	void MousePressed()
	{
		if (mouseX >= position.x && mouseX < position.x + size.x)
			if (mouseY >= position.y && mouseY < position.y + size.y)
				clicked();
	}

	void clicked()
	{
	}

  void draw()
  {
  }

  void drawGUI()
  {
		pushMatrix();
		translate(position.x, position.y);
		rotate(radians(imageAngle));
		scale(scaleX, scaleY);

    pushStyle();

    textAlign(CENTER);

    fill(fillColor);
    rect(0, 0, size.x, size.y);

    fill(borderColor);
    noFill();
    rect(0, 0, size.x, size.y);

    if (!displayText.equals(""))
    fill(0);
    text(displayText, size.x / 2, size.y / 2);

		popStyle();

		popMatrix();
  }
}
