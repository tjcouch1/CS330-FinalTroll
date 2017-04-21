//Menu - holds menu objects
//Timothy Couch

class Menu
{
  ArrayList<Button> items = new ArrayList<Button>();

  boolean active = true;

  public Menu()
  {
    
  }
  
  public Menu(boolean a)
  {
    active = a;
  }

  public Button add(Button b)
  {
    b.active = active;
    items.add(b);
    objects.add(b);
    return b;
  }

  public void setActive(boolean a)
  {
    for (Button b : items)
      b.active = a;
    active = a;
  }
}