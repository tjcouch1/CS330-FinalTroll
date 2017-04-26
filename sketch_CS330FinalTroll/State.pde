//State - holds info for a state for the finite state machine
//Tiomthy Couch

class State
{
  String name = "";
  
  State(String name)
  {
    this.name = name;
  }
  
  void start()//something to do every time this state is set to current
  {
    
  }
  
  void transition()//determines whether to transition and what to transition to
  {
    
  }
  
  void think()//whether or not to create a path
  {
    
  }
  
  void act()//do random stuff every step
  {
    
  }
}
