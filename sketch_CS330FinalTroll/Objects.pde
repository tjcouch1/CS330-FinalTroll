//Objects - handles all the object actions and drawings
//Timothy Couch

import java.util.Iterator;

class Objects implements Iterable<Object>
{
	ArrayList<Object> objects = new ArrayList<Object>();

	Object add(Object o)
	{
		objects.add(o);
		return o;
	}

	GridObject addGrid(GridObject o)
	{
		add(o);
		return grid.add(o);
	}
	
	//do not use with grid!!
	void clear()
	{
		objects.clear();
	}

	Object remove(int i)
	{
		if (i >= 0 && i < objects.size())
		{
			Object o = objects.remove(i);
			
			return o;
		}
		return null;
	}

	Object remove(Object o)
	{
		return remove(objects.indexOf(o));
	}

	PVector removeGrid(GridObject o)
	{
		remove(o);
		return grid.remove(o);
	}
	
	Object destroy(GridObject o)
	{
		removeGrid(o);
		return o;
	}

	int removeAllGrid()
	{
		int count = 0;
		for (int i = 0; i < grid.gridWidth; i++)
			for (int j = 0; j < grid.gridHeight; j++)
		{
				GridObject removed = grid.removePlace(new PVector(i, j));
				if (removed != null)
				{
					remove(removed);
					count++;
				}
		}
		return count;
	}
	
	Iterator<Object> iterator()
	{
		return new Iterator<Object>(){
			int place = 0;
			
			public boolean hasNext()
			{
				return place < objects.size();
			}
			public Object next()
			{
				Object o = objects.get(place);
				place++;
				return o;
			}
			public void remove()
			{}
		};
	}

	void step()
	{
		//must be cloned so stuff can be deleted
		for (Object o : (ArrayList<Object>) objects.clone())
		{
			if (o.active)
				o.step();
		}
	}

	void KeysDown(Keys keys)
	{
		for (Object o : objects)
		{
			if (o.active)
				keys.ObjectKeysDown(o);
		}
	}

	void KeyPressed(char key)
	{
		char k = str(key).toUpperCase().charAt(0);
		for (Object o : objects)
		{
			if (o.active)
				o.KeyPressed(k);
		}
	}

	void KeyReleased(char key)
	{
		char k = str(key).toUpperCase().charAt(0);
		for (Object o : objects)
		{
			if (o.active)
				o.KeyReleased(k);
		}
	}

	void MousePressed()
	{
		//must be cloned so StartGame() doesn't add stuff to it while MousePressed is going on
		for (Object o : (ArrayList<Object>) objects.clone())
			if (o.active)
					o.MousePressed();
	}

	void draw()
	{
		step();

		background(#73D84C);

		if (gameStart && debug)
			grid.draw();

		drawObjects();
	}

	void drawObjects()
	{
		for (Object o : objects)
		{
			if (o.visible && o.active)
				o.drawObj();
		}

		for (Object o : objects)
		{
			if (o.visible && o.active)
				o.drawGUI();
		}
	}
}
