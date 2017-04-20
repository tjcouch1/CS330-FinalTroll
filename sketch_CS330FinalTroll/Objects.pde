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
