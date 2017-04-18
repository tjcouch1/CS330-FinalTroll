//Button - a simple click button
//Timothy Couch

class Button extends Object
{
  PVector size;
  color borderColor;
  color fillColor;
  color textColor;

  Button()
  {
    super();
    size = new PVector(16, 16);
    borderColor = color(0);
    fillColor = color(30);
    textColor = color(0);
  }

  Button(PVector pos)
  {
    super(pos);
  }

  void clicked()
  {

  }

  void draw()
  {
  }

  void drawGUI()
  {
    pushStyle();

    textAlign(CENTER);

    fill(fillColor);
    rect(0, 0, size.x, size.y);

    fill(borderColor);
    noFill();
    rect(0, 0, size.x, size.y);

    fill(0);
    text("Variation 1", width / 2, height / 4);

    popStyle();
  }
}
