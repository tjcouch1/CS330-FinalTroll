//ResponseBucket - Holds a decision and a size
//Timothy Couch

class ResponseBucket
{
  String name = "";
  
  ResponseBucket(String name)
  {
    this.name = name;
  }
  
  void start()//something to do every time this state is set to current
  {
    
  }
  
  int size()//kind-of like transition. Determines how likely it is for this to get chosen
  {
    return -1;
  }
  
  void act()//do whatever every path step
  {
    
  }
}
