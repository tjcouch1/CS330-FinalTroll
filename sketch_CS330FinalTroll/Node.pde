//Node - holds a vector and a score (distance from destination)
//Timothy Couch

class Node
{
	PVector position;
	float dist;
	
	Node previousNode = null;
	
	Node()
	{
		position = new PVector(0, 0);
		dist = 0f;
	}
	
	Node(PVector p)
	{
		position = p;
		dist = 0f;
	}
	
	Node(PVector p, int numSteps, PVector dest, Node prevNode)
	{
		position = p;
		dist = numSteps + CalculateDist(dest);
		previousNode = prevNode;
	}
	
	float CalculateDist(PVector dest)
	{
		return position.dist(dest);
	}
	
	boolean HasSameVector(PVector v)
	{
		return (position.x == v.x && position.y == v.y);
	}
}