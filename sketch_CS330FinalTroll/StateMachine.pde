//StateMachine - handles states and swapping between
//Timothy Couch

import java.util.Hashtable;

class StateMachine
{
  Hashtable<String, State> states = new Hashtable<String, State>();
  State currentState;
  
  StateMachine()
  {
    
  }
  
  State add(State s)
  {
    states.put(s.name, s);
    return s;
  }
  
  State get(String key)
  {
    return states.get(key);
  }
  
  void setCurrentState(String key)
  {
    currentState = get(key);
  }
  
  State getCurrentState()
  {
    if (currentState != null)
      return currentState;
    return null;
  }
}
