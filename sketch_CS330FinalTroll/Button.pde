//Button - a simple click button
//Timothy Couch

class Button extends Object
{
  color borderColor = color(0);
  color fillColor = color(100);
  color fillColorHi = color(200);
  color textColor = color(0);
  color textColorHi = color(40);
  String displayText = "";

  Button()
  {
    super();
    size = new PVector(grid.gridSize * 6, grid.gridSize * 2);
  }

  Button(PVector pos)
  {
    super(pos);
    size = new PVector(grid.gridSize * 6, grid.gridSize * 2);
  }

  Button(PVector pos, String dText)
  {
    super(pos);
    size = new PVector(grid.gridSize * 6, grid.gridSize * 2);
    displayText = dText;
  }

  Button(PVector pos, PVector size)
  {
    this(pos);

    this.size = size.copy();
  }

  Button(PVector pos, PVector size, String dText)
  {
    this(pos, dText);

    this.size = size.copy();
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

    boolean mouseOver = containsPoint(new PVector(mouseX, mouseY));

    //fill
    if (mouseOver)
      fill(fillColorHi);
    else fill (fillColor);
    rect(-size.x / 2, -size.y / 2, size.x, size.y);

    //border
    fill(borderColor);
    noFill();
    rect(-size.x / 2, -size.y / 2, size.x, size.y);

    //text
    if (displayText != null && !displayText.equals(""))
    {
      if (mouseOver)
        fill(textColorHi);
      else fill(textColor);
      text(displayText, 0, 0);
    }

		popStyle();

		popMatrix();
  }

  void setDisplayText(String t)
  {
    displayText = t;
  }
}
