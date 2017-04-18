//Pather - creates a path
//Timothy Couch

class Pather
{
	Path GeneratePath(PVector source, PVector dest)
	{
		if (source.x == dest.x && source.y == dest.y)
		{
			int[] path = new int[1];
			path[0] = GridDir.NULL;
			return new Path(path);
		}
		return GenerateAStarPath(source, dest);
	}
	
	Path GenerateAStarPath(PVector source, PVector dest)
	{
		ArrayList<Node> openList = new ArrayList<Node>();
		ArrayList<Node> closedList = new ArrayList<Node>();
		
		openList.add(new Node(source, 0, dest, null));
		
		int numSteps = 1;
		
		boolean foundPath = false;
		
		while (openList.size() > 0)
		{
			Node lowNode = openList.get(0);
			if (lowNode.position.x == dest.x && lowNode.position.y == dest.y)
			{
				foundPath = true;
				break;
			}
			else
			{
				openList.remove(lowNode);
				closedList.add(lowNode);
				
				ArrayList<PVector> adjacentList = new ArrayList<PVector>();
				
				PVector adjPos = new PVector(lowNode.position.x - 1, lowNode.position.y);
				if (grid.spaceOpen(adjPos) || (adjPos.x == dest.x && adjPos.y == dest.y))
					adjacentList.add(adjPos);
				adjPos = new PVector(lowNode.position.x + 1, lowNode.position.y);
				if (grid.spaceOpen(adjPos) || (adjPos.x == dest.x && adjPos.y == dest.y))
					adjacentList.add(adjPos);
				adjPos = new PVector(lowNode.position.x, lowNode.position.y - 1);
				if (grid.spaceOpen(adjPos) || (adjPos.x == dest.x && adjPos.y == dest.y))
					adjacentList.add(adjPos);
				adjPos = new PVector(lowNode.position.x, lowNode.position.y + 1);
				if (grid.spaceOpen(adjPos) || (adjPos.x == dest.x && adjPos.y == dest.y))
					adjacentList.add(adjPos);
				
				for (PVector p : adjacentList)
				{
					boolean isOn = false;
					for (Node n : openList)
						if (n.HasSameVector(p))
						{
							isOn = true;
							break;
						}
					if (!isOn)
						for (Node n : closedList)
							if (n.HasSameVector(p))
							{
								isOn = true;
								break;
							}
					if (!isOn)
					{
						Node newNode = new Node(p, numSteps, dest, lowNode);
						
						boolean added = false;
						for (int i = 0; i < openList.size(); i++)
						{
							if (newNode.dist < openList.get(i).dist)
							{
								openList.add(i, newNode);
								added = true;
								break;
							}
						}
						if (!added)
							openList.add(newNode);
					}
				}
				
			}
			
			numSteps++;
		}
		
		if (foundPath)
		{
			IntList pathList = new IntList();
			Node currentNode = openList.get(0);
			
			while (currentNode.previousNode != null)
			{
				pathList.append(GridDir.VectorDir(currentNode.position.sub(currentNode.previousNode.position)));
				currentNode = currentNode.previousNode;
			}
			
			pathList.reverse();
			return new Path(pathList.array());
		}
		return new Path();
	}
	
	Path GenerateLinePath(PVector source, PVector dest)
	{
		PVector pos = source.copy();
		IntList dirs = new IntList();
		
		int times = 0;
		
		while (pos.x != dest.x || pos.y != dest.y)
		{
			PVector between = new PVector(dest.x - pos.x, dest.y - pos.y);
			
			int dir = -1;
			if (abs(between.x) >= abs(between.y))
			{
				if (between.x >= 0)
					dir = GridDir.RIGHT;
				else dir = GridDir.LEFT;
			}
			else
				if (between.y < 0)
					dir = GridDir.UP;
				else dir = GridDir.DOWN;
			
			dirs.append(dir);
			pos.add(GridDir.Move(dir));
			
			times++;
			if (times > 200)
				break;
		}
		
		return new Path(dirs.array());
	}
}