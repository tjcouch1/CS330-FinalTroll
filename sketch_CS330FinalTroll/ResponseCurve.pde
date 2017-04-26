//ResponseCurve - handles buckets of decisions and making decisions
//Timothy Couch

class ResponseCurve
{
  ArrayList<ResponseBucket> buckets = new ArrayList<ResponseBucket>();
  ResponseBucket currentBucket;
  
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
    return currentBucket;
  }
  
  ResponseBucket getCurrentBucket()
  {
    return currentBucket;
  }
  
  ResponseBucket chooseBucket()//randomly chooses a bucket based on their weights
  {
    ArrayList<Integer> bSizes = new ArrayList<Integer>();
    int sum = 0;
    for (ResponseBucket b : buckets)
    {
      int bSize = b.size();
      bSizes.add(bSize);
      sum += bSize;
    }
    
    float index = random(sum);
    
    int sum = 0;
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
    return currentBucket;
  }
}
