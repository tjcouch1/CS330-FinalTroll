//Objects - handles all the object actions and drawings
//Timothy Couch

class Objects
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

	Object remove(int i)
	{
		Object o = objects.remove(i);
		
		return o;
	}

	Object remove(Object o)
	{
		return objects.remove(objects.indexOf(o));
	}
	
	PVector removeGrid(GridObject o)
	{
		remove(o);
		return grid.remove(o);
		
	}

	void step()
	{ 
		for (Object o : objects)
		{
			o.step();
		}
	}

	void KeysDown(Keys keys)
	{
		for (Object o : objects)
		{
			keys.ObjectKeysDown(o);
		}
	}

	void KeyPressed(char key)
	{
		char k = str(key).toUpperCase().charAt(0);
		for (Object o : objects)
		{
			o.KeyPressed(k);
		}
	}

	void KeyReleased(char key)
	{
		char k = str(key).toUpperCase().charAt(0);
		for (Object o : objects)
		{
			o.KeyReleased(k);
		}
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
			o.drawObj();
		}
		
		for (Object o : objects)
		{
			o.drawGUI();
		}
	}
}