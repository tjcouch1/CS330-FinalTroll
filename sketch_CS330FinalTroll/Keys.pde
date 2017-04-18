//Keys - handles key presses and keys held down
//Timothy Couch

class Keys
{
  ArrayList<String> keys = new ArrayList<String>();
  
  boolean KeyPressed(char key)
  {
    boolean downPrev = IsKeyDown(key);
    
    if (!IsKeyDown(key))
      keys.add(str(key).toUpperCase());
    
    return (IsKeyDown(key) != downPrev);
  }
  
  boolean KeyReleased(char key)
  {
    boolean downPrev = IsKeyDown(key);
    
    if (IsKeyDown(key))
      keys.remove(str(key).toUpperCase());
    
    return (IsKeyDown(key) != downPrev);
  }
  
  boolean IsKeyDown(char key)
  {
    if(keys.indexOf(str(key).toUpperCase()) >= 0)
      return true;
    return false;
  }
  
  void ObjectKeysDown(Object o)
  {
    for (String key : keys)
      o.KeyDown(key.charAt(0));
  }
}