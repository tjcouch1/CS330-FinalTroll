//ResponseCurve - handles buckets of decisions and making decisions
//Timothy Couch

class ResponseCurve
{
  ArrayList<ResponseBucket> buckets = new ArrayList<ResponseBucket>();
  ResponseBucket currentBucket;
  
  boolean printSizes = false;
  
  ResponseBucket add(ResponseBucket b)
  {
    buckets.add(b);
    return b;
  }
  
  ResponseBucket get(int i)//gets bucket at index
  {
    return buckets.get(i);
  }
  
  ResponseBucket get(String name)//gets bucket by name
  {
    for (ResponseBucket b : buckets)
      if (b.name.equals(name))
        return b;
    return null;
  }
  
  ResponseBucket get(float key)//gets bucket by value between sizes
  {
    int sum = 0;
    for (ResponseBucket b : buckets)
    {
      int bSize = b.size();
      if (key < sum + bSize)
        return b;
      sum += bSize;
    }
    return null;
  }
  
  ResponseBucket setCurrentBucket(String name)
  {
    if (get(name) != null)
      currentBucket = get(name);
    return currentBucket;
  }
  
  ResponseBucket setCurrentBucket(int i)
  {
    if (i < buckets.size())
      currentBucket = get(i);
    currentBucket.start();
    return currentBucket;
  }
  
  ResponseBucket getCurrentBucket()
  {
    return currentBucket;
  }
  
  ResponseBucket chooseBucket()//randomly chooses a bucket based on their weights
  {
    ResponseBucket currBuck = currentBucket;
    ArrayList<Integer> bSizes = new ArrayList<Integer>();
    int sum = 0;
    for (ResponseBucket b : buckets)
    {
      int bSize = b.size();
      bSizes.add(bSize);
      sum += bSize;
    }
    
    float index = random(sum);
    
    sum = 0;
    for (int i = 0; i < buckets.size(); i++)
    {
      ResponseBucket b = buckets.get(i);
      if (index < sum + bSizes.get(i))
      {
        setCurrentBucket(i);
        break;
      }
      sum += bSizes.get(i);
    }
    
    if (printSizes && currBuck != currentBucket)
      println("" + bSizes);
    
    return currentBucket;
  }
  
  public String toString()
  {
    ArrayList<Integer> sizes = new ArrayList<Integer>();
    for (ResponseBucket b : buckets)
      sizes.add(b.size());
    return "" + getCurrentBucket().name + sizes;
  }
}
