import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.Iterator; 
import java.util.Hashtable; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class sketch_CS330FinalTroll extends PApplet {

//sketch_CS330TinaPathfinding - runs the game, adds stuff to the map, etc.
//Timothy Couch

/**
 * Change this to enable/disable grid drawing and stuff
 **/
boolean debug = true;

/**
 * This variable controls the demo instance
 * 0 - Scenario 1:
 * 						Todd moves around and looks for the player. When the player
 * 					enters his line of sight, he attacks immediately and until he loses
 * 					the player, kills the player, or dies.
 * 			Uses Thinking Pattern 1 (Hard Code)
 * 1 - Scenario 2:
 * 						Todd waits in a bush for the player. He will attack, flee, or stay
 * 					hidden based on the player's stats. If he is attacking and his
 * 					health gets too low, he flees.
 * 			Uses Thinking Pattern 2 (Finite State Machine)
 * 2 - Scenario 3:
 * 						Todd waits in a bush for the player. He will attack, flee, or stay
 * 					hidden based on his own and the player's stats. He continually makes
 * 					decisions on what to do based on his response curves.
 * 			Uses Thinking Pattern 6 (Probability of Actions - Implemented with a
 * 														Response Curve)
 **/
int variation = 0;

Menu mainMenu = new Menu();
Menu gameMenu = new Menu(false);

boolean gameStart = false;

Grid grid = new Grid(29, 38, 16);
Pather pather = new Pather();

Objects objects = new Objects();
Objects decorations = new Objects();
Objects players = new Objects();
Objects trolls = new Objects();
Keys keys = new Keys();

Todd todd;
Player player;
float wDamage = 4;
float weaponDamageCap = 100;
float trollDamage = 5;
float trollWeaponDamageCap = 10;
GridObject chest;

PVector safeSpace = new PVector(19, 5);
PVector bridge = new PVector(8, 28);
PVector chestPos = new PVector(5, 31);

public void settings()
{
	size(grid.gridWidth * grid.gridSize, grid.gridHeight * grid.gridSize);
}

public void setup()
{
	//main menu
	mainMenu.add(new Button(new PVector(3 * grid.gridSize, 1 * grid.gridSize),
		new PVector(5 * grid.gridSize, 1.5f * grid.gridSize), "Debug " + debug){
			public void clicked()
			{
				debug = !debug;
				displayText = "Debug " + debug;
			}
		});
	mainMenu.add(new Button(new PVector(width / 2, height / 4), "Scenario 1"){
		public void clicked()
		{
			StartGame(0);
			mainMenu.setActive(false);
			gameMenu.setActive(true);
		}
	});
	mainMenu.add(new Button(new PVector(width / 2, height * 2 / 4), "Scenario 2"){
		public void clicked()
		{
			StartGame(1);
			mainMenu.setActive(false);
			gameMenu.setActive(true);
		}
	});
	mainMenu.add(new Button(new PVector(width / 2, height * 3 / 4), "Scenario 3"){
		public void clicked()
		{
			StartGame(2);
			mainMenu.setActive(false);
			gameMenu.setActive(true);
		}
	});
	
	//game menu
	gameMenu.add(new Button(new PVector(3 * grid.gridSize, 1 * grid.gridSize),
			new PVector(5 * grid.gridSize, 1.5f * grid.gridSize), "Go Back"){
		public void clicked()
		{
			gameMenu.setActive(false);
			mainMenu.setActive(true);
			endGame();
		}
	});
	gameMenu.add(new Button(new PVector(width - 4.5f * grid.gridSize, 1 * grid.gridSize),
			new PVector(8 * grid.gridSize, 1.5f * grid.gridSize), "Player Damage: " + wDamage){
		public void clicked()
		{
			wDamage += 10;
			if (wDamage > weaponDamageCap)
				wDamage = 0;
			for (Object o : players)
			{
				Player p = (Player) o;
				p.weaponDamage = wDamage;
			}
			displayText = "Player Damage: " + wDamage;
		}
	});
	gameMenu.add(new Button(new PVector(width - 4.5f * grid.gridSize, 3 * grid.gridSize),
			new PVector(8 * grid.gridSize, 1.5f * grid.gridSize), "Troll Damage: " + trollDamage){
		public void clicked()
		{
			trollDamage += 1;
			if (trollDamage > trollWeaponDamageCap)
				trollDamage = 0;
			for (Object o : trolls)
			{
				Todd t = (Todd) o;
				t.weaponDamage = trollDamage;
			}
			displayText = "Troll Damage: " + trollDamage;
		}
	});
}

public void StartGame(int var)
{
	variation = var;
	gameStart = true;

	player = (Player) players.add(objects.addGrid(new Player(new PVector(22, 31))));
	todd = (Todd) trolls.add(objects.addGrid(new Todd(bridge)));
	
	if (variation > 0)
	{
		trolls.add(objects.addGrid(new Todd(new PVector(6, 28))));
		trolls.add(objects.addGrid(new Todd(new PVector(4, 29))));
		trolls.add(objects.addGrid(new Todd(new PVector(3, 31))));
		trolls.add(objects.addGrid(new Todd(new PVector(4, 33))));
		trolls.add(objects.addGrid(new Todd(new PVector(6, 34))));
		trolls.add(objects.addGrid(new Todd(new PVector(8, 34))));
		
		if (variation == 2)
		{
			players.add(objects.addGrid(new Player(new PVector(24, 31))));
			players.add(objects.addGrid(new Player(new PVector(23, 30))));
			players.add(objects.addGrid(new Player(new PVector(23, 32))));
		}
	}
	
	/*
	objects.addGrid(new Block(new PVector(17, 10)));
	objects.addGrid(new Block(new PVector(18, 11)));
	objects.addGrid(new Block(new PVector(19, 12)));
	objects.addGrid(new Block(new PVector(20, 12)));
	objects.addGrid(new Block(new PVector(21, 12)));
	objects.addGrid(new Block(new PVector(22, 12)));
	objects.addGrid(new Block(new PVector(23, 12)));
	objects.addGrid(new Block(new PVector(23, 11)));
	objects.addGrid(new Block(new PVector(23, 10)));
	objects.addGrid(new Block(new PVector(23, 9)));
	objects.addGrid(new Block(new PVector(23, 8)));
	objects.addGrid(new Block(new PVector(23, 7)));
	objects.addGrid(new Block(new PVector(23, 6)));
	objects.addGrid(new Block(new PVector(23, 5)));
	objects.addGrid(new Block(new PVector(23, 4)));
	objects.addGrid(new Block(new PVector(23, 3)));
	objects.addGrid(new Block(new PVector(22, 3)));
	objects.addGrid(new Block(new PVector(21, 3)));
	objects.addGrid(new Block(new PVector(20, 3)));
	objects.addGrid(new Block(new PVector(19, 3)));
	objects.addGrid(new Block(new PVector(18, 3)));
	objects.addGrid(new Block(new PVector(17, 3)));
	objects.addGrid(new Block(new PVector(16, 3)));
	objects.addGrid(new Block(new PVector(15, 3)));
	objects.addGrid(new Block(new PVector(14, 3)));
	objects.addGrid(new Block(new PVector(13, 3)));
	objects.addGrid(new Block(new PVector(12, 3)));
	objects.addGrid(new Block(new PVector(12, 4)));
	objects.addGrid(new Block(new PVector(12, 5)));
	objects.addGrid(new Block(new PVector(12, 6)));
	objects.addGrid(new Block(new PVector(12, 7)));
	objects.addGrid(new Block(new PVector(12, 8)));
	objects.addGrid(new Block(new PVector(12, 9)));
	objects.addGrid(new Block(new PVector(12, 10)));
	objects.addGrid(new Block(new PVector(13, 11)));

	objects.addGrid(new Block(new PVector(7, 15)));
	objects.addGrid(new Block(new PVector(8, 15)));
	objects.addGrid(new Block(new PVector(9, 15)));
	objects.addGrid(new Block(new PVector(10, 15)));
	objects.addGrid(new Block(new PVector(11, 15)));
	objects.addGrid(new Block(new PVector(12, 15)));
	objects.addGrid(new Block(new PVector(13, 15)));
	objects.addGrid(new Block(new PVector(14, 15)));
	objects.addGrid(new Block(new PVector(15, 16)));
	objects.addGrid(new Block(new PVector(15, 17)));
	objects.addGrid(new Block(new PVector(16, 18)));
	objects.addGrid(new Block(new PVector(17, 19)));
	objects.addGrid(new Block(new PVector(17, 20)));
	*/
	
	Object chest = objects.addGrid(new GridObject(chestPos));
	chest.c = color(0xff816d1b);
	
	//bushes
	PVector bushSize = new PVector(grid.gridSize * 7 / 8, grid.gridSize * 7 / 8);
	Object bush = objects.add(decorations.add(new GridObject(new PVector(8, 28), bushSize)));
	bush.c = color(0xff0eb547, 170);
	bush = objects.add(decorations.add(new GridObject(new PVector(6, 28), bushSize)));
	bush.c = color(0xff0eb547, 170);
	bush = objects.add(decorations.add(new GridObject(new PVector(4, 29), bushSize)));
	bush.c = color(0xff0eb547, 170);
	bush = objects.add(decorations.add(new GridObject(new PVector(3, 31), bushSize)));
	bush.c = color(0xff0eb547, 170);
	bush = objects.add(decorations.add(new GridObject(new PVector(4, 33), bushSize)));
	bush.c = color(0xff0eb547, 170);
	bush = objects.add(decorations.add(new GridObject(new PVector(6, 34), bushSize)));
	bush.c = color(0xff0eb547, 170);
	bush = objects.add(decorations.add(new GridObject(new PVector(8, 34), bushSize)));
	bush.c = color(0xff0eb547, 170);
}

public void endGame()
{
	variation = 0;
	gameStart = false;
	
	objects.removeAllGrid();
	
	for (Object o : decorations)
		objects.remove(o);
	
	players.clear();
	decorations.clear();
}

public void draw()
{
	objects.KeysDown(keys);
	objects.draw();
}

public void mousePressed()
{
	objects.MousePressed();
}

public void keyPressed()
{
	if (key == ESC && gameMenu.active)
	{
		gameMenu.setActive(false);
		mainMenu.setActive(true);
		endGame();
		key = 0;
	}
	if (key == 49 && mainMenu.active)//1
	{
		StartGame(0);
		mainMenu.setActive(false);
		gameMenu.setActive(true);
	}
	if (key == 50 && mainMenu.active)//2
	{
		StartGame(1);
		mainMenu.setActive(false);
		gameMenu.setActive(true);
	}
	if (key == 51 && mainMenu.active)//3
	{
		StartGame(2);
		mainMenu.setActive(false);
		gameMenu.setActive(true);
	}
	
	if (keys.KeyPressed(key))
	{
		objects.KeyPressed(key);
	}
}

public void keyReleased()
{
	if (keys.KeyReleased(key))
	{
		objects.KeyReleased(key);
	}
}
//Block - a simple path obstructor
//Timothy Couch

class Block extends GridObject
{
	Block()
	{
		super();
		
		InitDefault();
	}

	Block(PVector position)
	{
		super(position);
		
		InitDefault();
	}

	//replacement for default constructor
	public void InitDefault()
	{
		c = color(50);
		size = new PVector(grid.gridSize, grid.gridSize);
	}

	/*void draw()
	{
		fill(c);
		noStroke();
		rect(0, 0, grid.gridSize, grid.gridSize);
	}*/
}
//Button - a simple click button
//Timothy Couch

class Button extends Object
{
  int borderColor = color(0);
  int fillColor = color(100);
  int fillColorHi = color(200);
  int textColor = color(0);
  int textColorHi = color(40);
  String displayText = "";

  Button()
  {
    super();
    size = new PVector(grid.gridSize * 6, grid.gridSize * 2);
  }

  Button(PVector pos)
  {
    super(pos);
    size = new PVector(grid.gridSize * 6, grid.gridSize * 2);
  }

  Button(PVector pos, String dText)
  {
    super(pos);
    size = new PVector(grid.gridSize * 6, grid.gridSize * 2);
    displayText = dText;
  }

  Button(PVector pos, PVector size)
  {
    this(pos);

    this.size = size.copy();
  }

  Button(PVector pos, PVector size, String dText)
  {
    this(pos, dText);

    this.size = size.copy();
  }

  public void draw()
  {
  }

  public void drawLate()
  {
		boolean mouseOver = containsPoint(new PVector(mouseX, mouseY));

    //fill
    if (mouseOver)
      fill(fillColorHi);
    else fill (fillColor);
    rect(-size.x / 2, -size.y / 2, size.x, size.y);

    //border
    fill(borderColor);
    noFill();
    rect(-size.x / 2, -size.y / 2, size.x, size.y);

    //text
    if (displayText != null && !displayText.equals(""))
    {
      if (mouseOver)
        fill(textColorHi);
      else fill(textColor);
      text(displayText, 0, 0);
    }
  }

  public void setDisplayText(String t)
  {
    displayText = t;
  }
}
//Grid - handles grid spaces, movement, and drawing
//Timothy Couch

class Grid
{
	int gridWidth;
	int gridHeight;
	
	GridObject[][] gridContents;
	
	int gridSize;
	
	public Grid()
	{
		gridWidth = 16;
		gridHeight = 16;
		
		InitDefault();
	}
	
	public Grid(int gW, int gH)
	{
		this();
		
		gridWidth = gW;
		gridHeight = gH;
		
		InitDefault();
	}
	
	public Grid(int gW, int gH, int gS)
	{
		this(gW, gH);
		
		gridSize = gS;
	}
	
	public void InitDefault()
	{
		float squareSizeX = width / gridWidth;
		float squareSizeY = height / gridHeight;
		gridSize = round(min(squareSizeX, squareSizeY));
		
		gridContents = new GridObject[gridWidth][gridHeight];
		
		for (int i = 0; i < gridWidth; i++)
			for (int j = 0; j < gridHeight; j++)
				gridContents[i][j] = null;
	}
	
	public GridObject add(GridObject o)
	{
		gridContents[round(o.position.x)][round(o.position.y)] = o;
		return o;
	}
	
	public PVector remove(GridObject o)
	{
		for (int i = 0; i < gridWidth; i++)
			for (int j = 0; j < gridHeight; j++)
				if (gridContents[i][j] == o)
				{
					gridContents[i][j] = null;
					return new PVector(i, j);
				}
		return null;
	}
	
	public GridObject removePlace(PVector pos)
	{
		GridObject o = gridContents[(int) pos.x][(int) pos.y];
		gridContents[(int) pos.x][(int) pos.y] = null;
		return o;
	}
	
	public GridObject getPlace(PVector pos)
	{
		return gridContents[(int) pos.x][(int) pos.y];
	}
	
	public GridObject updateGridObject(GridObject o)
	{
		remove(o);
		add(o);
		return o;
	}
	
	public boolean spaceOpen(PVector v)
	{
		if (round(v.x) >= 0 && round(v.x) < gridWidth && round(v.y) >= 0 && round(v.y) < gridHeight)
			return gridContents[round(v.x)][round(v.y)] == null;
		return false;
	}
	
	public void draw()
	{
		pushStyle();
		
		fill(0xffffffff, 128);
		noStroke();
		//tint(255, 100);
		
		for (int i = 0; i < gridWidth; i++)
			for (int j = 0; j < gridHeight; j++)
				if (gridContents[i][j] != null)
					rect(i * gridSize, j * gridSize, gridSize, gridSize);
		
		fill(0xff00b3b2, 128);
		rect(safeSpace.x * gridSize, safeSpace.y * gridSize, gridSize, gridSize);
		fill(0xffd96c00, 128);
		rect(bridge.x * gridSize, bridge.y * gridSize, gridSize, gridSize);
		
		popStyle();
		
		fill(0);
		for (int i = 0; i < grid.gridWidth; i++)
		{
			int x = i * grid.gridSize;
			line(x, 0, x, height);
		}
		for (int j = 0; j < grid.gridHeight; j++)
		{
			int y = j * grid.gridSize;
			line(0, y, width, y);
		}
	}
}
//GridDir - handles directions
//Timothy Couch

static class GridDir
{
	static int NULL = -1;
	static int UP = 0;
	static int DOWN = 1;
	static int LEFT = 2;
	static int RIGHT = 3;
	
	public static int KeyDir(char key)
	{
		switch (key)
		{
		case 'W':
			return UP;
		case 'S':
			return DOWN;
		case 'A':
			return LEFT;
		case 'D':
			return RIGHT;
		default:
			return NULL;
		}
	}

	public static PVector Move(int dir)
	{
		if (dir == GridDir.UP)
			return new PVector(0, -1);
		if (dir == GridDir.DOWN)
			return new PVector(0, 1);
		if (dir == GridDir.LEFT)
			return new PVector(-1, 0);
		if (dir == GridDir.RIGHT)
			return new PVector(1, 0);
		return new PVector(0, 0);
	}
	
	public static int VectorDir(PVector v)
	{
		int dir = -1;
		if (abs(v.x) >= abs(v.y))
		{
			if (v.x >= 0)
				dir = GridDir.RIGHT;
			else dir = GridDir.LEFT;
		}
		else
			if (v.y < 0)
				dir = GridDir.UP;
			else dir = GridDir.DOWN;
		
		return dir;
	}
}
//GridObject - Object that conforms to the grid
//Timothy Couch

class GridObject extends Object
{
	GridObject()
	{
		super();
	}

	GridObject(PVector position)
	{
		super(position);
	}

	GridObject(PVector position, PVector size)
	{
		super(position, size);
	}

  public boolean containsPoint(PVector p)
  {
		if (p.x >= position.x * grid.gridSize + grid.gridSize / 2 - size.x / 2 && p.x < position.x * grid.gridSize + grid.gridSize / 2 + size.x / 2)
			if (p.y >= position.y * grid.gridSize + grid.gridSize / 2 - size.y / 2 && p.y < position.y * grid.gridSize + grid.gridSize / 2 + size.y / 2)
				return true;
		return false;
  }

	public void drawObj()
	{
		pushMatrix();
		translate(position.x * grid.gridSize + grid.gridSize / 2, position.y * grid.gridSize + grid.gridSize / 2);
		rotate(radians(rotation));
		scale(scaleX, scaleY);

		pushStyle();

		draw();

		popStyle();

		popMatrix();
	}
}
//Keys - handles key presses and keys held down
//Timothy Couch

class Keys
{
  ArrayList<String> keys = new ArrayList<String>();
  
  public boolean KeyPressed(char key)
  {
    boolean downPrev = IsKeyDown(key);
    
    if (!IsKeyDown(key))
      keys.add(str(key).toUpperCase());
    
    return (IsKeyDown(key) != downPrev);
  }
  
  public boolean KeyReleased(char key)
  {
    boolean downPrev = IsKeyDown(key);
    
    if (IsKeyDown(key))
      keys.remove(str(key).toUpperCase());
    
    return (IsKeyDown(key) != downPrev);
  }
  
  public boolean IsKeyDown(char key)
  {
    if(keys.indexOf(str(key).toUpperCase()) >= 0)
      return true;
    return false;
  }
  
  public void ObjectKeysDown(Object o)
  {
    for (String key : keys)
      o.KeyDown(key.charAt(0));
  }
}
//Menu - holds menu objects
//Timothy Couch

class Menu
{
  ArrayList<Button> items = new ArrayList<Button>();

  boolean active = true;

  public Menu()
  {
    
  }
  
  public Menu(boolean a)
  {
    active = a;
  }

  public Button add(Button b)
  {
    b.active = active;
    items.add(b);
    objects.add(b);
    return b;
  }

  public void setActive(boolean a)
  {
    for (Button b : items)
      b.active = a;
    active = a;
  }
}
//Movable - GridObject that has moving functionality
//Timothy Couch

class Movable extends GridObject
{
	Movable()
	{
		super();

		InitDefault();
	}

	Movable(PVector position)
	{
		super(position);

		InitDefault();
	}

	public void InitDefault()
	{
		c = color(0xff00d9a3);
		size = new PVector(round(grid.gridSize * 5 / 8), round(grid.gridSize * 5 / 8));
	}

	public void step()
	{
		super.step();
	}

	public boolean CanMove(int dir, int spaces)
	{
		if (dir == GridDir.UP)
		{
			if (grid.spaceOpen(new PVector(position.x, position.y - spaces)))
				return true;
		}
		else if (dir == GridDir.DOWN)
		{
			if (grid.spaceOpen(new PVector(position.x, position.y + spaces)))
				return true;
		}
		else if (dir == GridDir.LEFT)
		{
			if (grid.spaceOpen(new PVector(position.x - spaces, position.y)))
				return true;
		}
		else if (dir == GridDir.RIGHT)
		{
			if (grid.spaceOpen(new PVector(position.x + spaces, position.y)))
				return true;
		}
		return false;
	}

	public boolean CanMove(int dir)
	{
		return CanMove(dir, 1);
	}

	public boolean Move(int dir, int spaces)
	{
		boolean move = false;
		if (dir == GridDir.UP)
		{
			if (grid.spaceOpen(new PVector(position.x, position.y - spaces)))
			{
				position = new PVector(position.x, position.y - spaces);
				// position.y -= spaces;
				move = true;
			}
		}
		else if (dir == GridDir.DOWN)
		{
			if (grid.spaceOpen(new PVector(position.x, position.y + spaces)))
			{
				position = new PVector(position.x, position.y + spaces);
				// position.y += spaces;
				move = true;
			}
		}
		else if (dir == GridDir.LEFT)
		{
			if (grid.spaceOpen(new PVector(position.x - spaces, position.y)))
			{
				position = new PVector(position.x - spaces, position.y);
				// position.x -= spaces;
				move = true;
			}
		}
		else if (dir == GridDir.RIGHT)
		{
			if (grid.spaceOpen(new PVector(position.x + spaces, position.y)))
			{
				position = new PVector(position.x + spaces, position.y);
				// position.x += spaces;
				move = true;
			}
		}

		if (move)
			grid.updateGridObject(this);

		return move;
	}

	public boolean Move(int dir)
	{
		return Move(dir, 1);
	}

	public void draw()
	{
		fill(c);
		ellipse(0, 0, size.x, size.y);
	}
}
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
	
	public float CalculateDist(PVector dest)
	{
		return position.dist(dest);
	}
	
	public boolean HasSameVector(PVector v)
	{
		return (position.x == v.x && position.y == v.y);
	}
}
//Object - basic object with actions, translation, and stuff
//Timothy Couch

class Object
{
	PVector position;
	PVector origin;
	PVector size;
	float rotation;//in degrees
	float scaleX;
	float scaleY;
	int c;//color

	boolean visible = true;
	boolean active = true;

	Object()
	{
		position = new PVector(0, 0);
		origin = position.copy();
		size = new PVector(10, 10);
		rotation = 0;
		scaleX = 1;
		scaleY = 1;
		c = color(0);
	}

	Object(PVector pos)
	{
		this();

		this.position = pos.copy();
		origin = position.copy();
		c = color(200);
	}

	Object(PVector pos, PVector size)
	{
		this(pos);
		this.size = size.copy();
	}

	public void step()
	{

	}

	public void KeyPressed(char key)
	{
	}

	public void KeyReleased(char key)
	{
	}

	public void KeyDown(char key)
	{
	}

	public void MousePressed()
	{
		if (containsPoint(new PVector(mouseX, mouseY)))
				clicked();
	}

  public boolean containsPoint(PVector p)
  {
		if (p.x >= position.x - size.x / 2 && p.x < position.x + size.x / 2)
			if (p.y >= position.y - size.y / 2 && p.y < position.y + size.y / 2)
				return true;
		return false;
  }

	public void clicked()
	{
	}
	
	public float getAngle(PVector v)
	{
		float angle = degrees(PVector.angleBetween(new PVector(1, 0), v));
		if (v.y < 0)
			angle *= -1;
		
		return angle;
	}

	public void drawObj()
	{
		pushMatrix();
		translate(position.x, position.y);
		scale(scaleX, scaleY);
		rotate(radians(rotation));

		pushStyle();

		draw();

		popStyle();

		popMatrix();
	}

	public void drawGUI()
	{
		pushMatrix();
		translate(position.x, position.y);
		scale(scaleX, scaleY);
		rotate(radians(rotation));
		
		pushStyle();
		textAlign(CENTER);
		
		drawLate();

		popStyle();

		popMatrix();
	}

	public void draw()
	{
		fill(c);
		rect(size.x * -1 / 2, size.y * -1 / 2, size.x, size.y);
	}
	
	public void drawLate()
	{
		
	}
}
//Objects - handles all the object actions and drawings
//Timothy Couch



class Objects implements Iterable<Object>
{
	ArrayList<Object> objects = new ArrayList<Object>();

	public Object add(Object o)
	{
		objects.add(o);
		return o;
	}

	public GridObject addGrid(GridObject o)
	{
		add(o);
		return grid.add(o);
	}
	
	public Object get(int i)
	{
		return objects.get(i);
	}
	
	public int size()
	{
		return objects.size();
	}
	
	//do not use with grid!!
	public void clear()
	{
		objects.clear();
	}
	
	public boolean contains(Object o)
	{
		return objects.contains(o);
	}

	public Object remove(int i)
	{
		if (i >= 0 && i < objects.size())
		{
			Object o = objects.remove(i);
			
			return o;
		}
		return null;
	}

	public Object remove(Object o)
	{
		return remove(objects.indexOf(o));
	}

	public PVector removeGrid(GridObject o)
	{
		remove(o);
		return grid.remove(o);
	}
	
	public Object destroy(GridObject o)
	{
		removeGrid(o);
		return o;
	}

	public int removeAllGrid()
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
	
	public Iterator<Object> iterator()
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

	public void step()
	{
		//must be cloned so stuff can be deleted
		for (Object o : (ArrayList<Object>) objects.clone())
		{
			if (o.active)
				o.step();
		}
	}

	public void KeysDown(Keys keys)
	{
		for (Object o : objects)
		{
			if (o.active)
				keys.ObjectKeysDown(o);
		}
	}

	public void KeyPressed(char key)
	{
		char k = str(key).toUpperCase().charAt(0);
		for (Object o : objects)
		{
			if (o.active)
				o.KeyPressed(k);
		}
	}

	public void KeyReleased(char key)
	{
		char k = str(key).toUpperCase().charAt(0);
		for (Object o : objects)
		{
			if (o.active)
				o.KeyReleased(k);
		}
	}

	public void MousePressed()
	{
		//must be cloned so StartGame() doesn't add stuff to it while MousePressed is going on
		for (Object o : (ArrayList<Object>) objects.clone())
			if (o.active)
					o.MousePressed();
	}

	public void draw()
	{
		step();

		background(0xff73D84C);

		if (gameStart && debug)
			grid.draw();

		drawObjects();
	}

	public void drawObjects()
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
//Path - holds path instructions
//Timothy Couch

class Path
{
	int[] path;
	int step;
	
	boolean loop = false;
	
	Path()
	{
		path = new int[1];
		path[0] = GridDir.NULL;
		/* path = new int[4];
		path[0] = GridDir.UP;
		path[1] = GridDir.RIGHT;
		path[2] = GridDir.DOWN;
		path[3] = GridDir.LEFT;
		 */
		step = 0;
	}
	
	Path(boolean looping)
	{
		this();
		setLooping(looping);
	}
	
	Path(int[] p)
	{
		this();
		path = p;
	}
	
	Path(int[] p, boolean looping)
	{
		this();
		path = p;
		setLooping(looping);
	}
	
	public int step()
	{
		if (path.length > 0 || (step < path.length || getLooping()))
		{
			int currStep = step;
			if (step < path.length)
				step++;
			if (getLooping())
				step %= path.length;
			if (currStep < path.length)
				return path[currStep];
		}
		return GridDir.NULL;
	}
	
	public int getNextStep()
	{
		return path[step];
	}
	
	public int getNextMove()
	{
		if (path.length <= 0 || step >= path.length)
			return GridDir.NULL;
		if (path[step] != GridDir.NULL)
			return path[step];
		int currStep = step + 1;
		while (currStep < path.length && currStep != step && path[currStep] == GridDir.NULL)
		{
			currStep++;
			if (getLooping())
				currStep %= path.length;
		}
		return path[currStep];
	}
	
	public int reverseStep()
	{
		if (getLooping() || step > 0)
			step--;
		if (getLooping())
			if (step < 0)
				step += path.length;
		
		return path[step];
	}
	
	//DEPRECATED
	public int stepLoop()
	{
		if (path.length > 0)
		{
			int currStep = step;
			step++;
			step %= path.length;
			return path[currStep];
		}
		return GridDir.NULL;
	}
	
	public boolean finished()
	{
		return step == path.length;
	}
	
	public boolean getLooping()
	{
		return loop;
	}
	
	public void setLooping(boolean looping)
	{
		loop = looping;
	}
	
	public void draw()
	{
		PVector currPos = new PVector(0, 0);
		for (int i = step; i < path.length; i++)
		{
			PVector prevPos = currPos.copy();
			currPos.add(GridDir.Move(path[i]));
			drawSegment(prevPos, currPos, i);
		}
	}
	
	public void drawSegment(PVector p1, PVector p2, int currStep)
	{
		float offset = 0;//.5;
		stroke(0xffffffff, round(((float) path.length - currStep) / (path.length - step) * 255));
		line((p1.x + offset) * grid.gridSize, (p1.y + offset) * grid.gridSize, (p2.x + offset) * grid.gridSize, (p2.y + offset) * grid.gridSize);
	}
}
//Pather - creates a path
//Timothy Couch

class Pather
{
	public Path GeneratePath(PVector source, PVector dest)
	{
		if (source.x == dest.x && source.y == dest.y)
		{
			int[] path = new int[1];
			path[0] = GridDir.NULL;
			return new Path(path);
		}
		return GenerateAStarPath(source, dest);
	}
	
	public Path GenerateAStarPath(PVector source, PVector dest)
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
	
	public Path GenerateLinePath(PVector source, PVector dest)
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
//Player - The object that moves around (Using WASD)
//Timothy Couch

class Player extends Movable
{
	int stepTimeCap = 5;
	int stepTime = stepTimeCap;
	
	float healthCap = 100;
	float health = healthCap;
	float weaponDamage = wDamage;
	boolean alive = true;
	boolean attacked = false;
	
	Player()
	{
		super();
		
		InitDefault();
	}

	Player(PVector position)
	{
		super(position);
		
		InitDefault();
	}

	public void InitDefault()
	{
		c = color(0xffd93600);
	}
	
	public void step()
	{
		attacked = false;
	}
	
	public void damage(float d)
	{
		health -= d;
		if (health <= 0)
		{
			alive = false;
			objects.destroy(this);
		}
	}
	
	public void KeyPressed(char key)
	{
		super.KeyPressed(key);
		
		stepTime = stepTimeCap;
		Move(GridDir.KeyDir(key));
	}
	
	public void KeyDown(char key)
	{
		super.KeyDown(key);
		
		stepTime--;
		if (stepTime <= 0)
		{
			stepTime = stepTimeCap;
			Move(GridDir.KeyDir(key));
		}
		
	}
	
	public void draw()
	{
		super.draw();
		
		//if (debug)
		{
			rotate(-radians(rotation));
			//health
			fill(0xfff02b08);
			stroke(0xff000000);
			rect(-grid.gridSize * 3 / 4 - 1, -grid.gridSize - 1, grid.gridSize * 3 / 2 + 2, 2);
			stroke(0xff2bff09);
			line(-grid.gridSize * 3 / 4, -grid.gridSize, -grid.gridSize * 3 / 4 + health * grid.gridSize * 3 / 2 / healthCap, -grid.gridSize);
		}
	}
}
//ResponseBucket - Holds a decision and a size
//Timothy Couch

class ResponseBucket
{
  String name = "";
  
  ResponseBucket(String name)
  {
    this.name = name;
  }
  
  public void start()//something to do every time this state is set to current
  {
    
  }
  
  public int size()//kind-of like transition. Determines how likely it is for this to get chosen
  {
    return -1;
  }
  
  public void act()//do whatever every path step
  {
    
  }
}
//ResponseCurve - handles buckets of decisions and making decisions
//Timothy Couch

class ResponseCurve
{
  ArrayList<ResponseBucket> buckets = new ArrayList<ResponseBucket>();
  ResponseBucket currentBucket;
  
  boolean printSizes = false;
  
  public ResponseBucket add(ResponseBucket b)
  {
    buckets.add(b);
    return b;
  }
  
  public ResponseBucket get(int i)//gets bucket at index
  {
    return buckets.get(i);
  }
  
  public ResponseBucket get(String name)//gets bucket by name
  {
    for (ResponseBucket b : buckets)
      if (b.name.equals(name))
        return b;
    return null;
  }
  
  public ResponseBucket get(float key)//gets bucket by value between sizes
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
  
  public ResponseBucket setCurrentBucket(String name)
  {
    if (get(name) != null)
      currentBucket = get(name);
    return currentBucket;
  }
  
  public ResponseBucket setCurrentBucket(int i)
  {
    if (i < buckets.size())
      currentBucket = get(i);
    currentBucket.start();
    return currentBucket;
  }
  
  public ResponseBucket getCurrentBucket()
  {
    return currentBucket;
  }
  
  public ResponseBucket chooseBucket()//randomly chooses a bucket based on their weights
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
//State - holds info for a state for the finite state machine
//Tiomthy Couch

class State
{
  String name = "";
  
  State(String name)
  {
    this.name = name;
  }
  
  public void start()//something to do every time this state is set to current
  {
    
  }
  
  public void transition()//determines whether to transition and what to transition to
  {
    
  }
  
  public void think()//whether or not to create a path
  {
    
  }
  
  public void act()//do random stuff every step
  {
    
  }
}
//StateMachine - handles states and swapping between
//Timothy Couch



class StateMachine
{
  Hashtable<String, State> states = new Hashtable<String, State>();
  State currentState;
  
  boolean printTransitions = false;
  
  StateMachine()
  {
    
  }
  
  public State add(State s)
  {
    states.put(s.name, s);
    return s;
  }
  
  public State get(String key)
  {
    return states.get(key);
  }
  
  public void setCurrentState(String key)
  {
    currentState = get(key);
    currentState.start();
  }
  
  public State getCurrentState()
  {
    if (currentState != null)
      return currentState;
    return null;
  }
}
//Tina - TINAAAA!!!!!!!
//Timothy Couch

class Tina extends Movable
{
	Path path;
	PVector dest;
	boolean moved = false;
	
	boolean fighting = false;
	boolean fleeing = false;
	boolean healing = false;
	boolean resting = false;
	
	int energyCap = 600;
	int energy = energyCap;
	boolean tired = false;
	
	int harryDist = 10;
	Object harry;
	
	int stepTimeCap = 5;
	int stepTime = stepTimeCap;
	
	int pathUpdateTimeCap = 60;
	int pathUpdateTime = pathUpdateTimeCap;
	
	Tina()
	{
		super();
		
		InitDefault();
	}

	Tina(PVector position)
	{
		super(position);
		
		InitDefault();
	}
	
	Tina(PVector position, int var)
	{
		super(position);
		
		InitDefault();
	}

	public void InitDefault()
	{
		dest = calcDestination();
		
		path = MakePath();
		
		c = color(0xff73ffdc);
	}
	
	public PVector calcDestination()
	{
		if (!tired)
			return bridge;
		else
			switch (variation)
			{
			case 0:
				return safeSpace;
			case 1:
				return harry.position;
			case 2:
				return safeSpace;
			default:
				return position;
			}
	}
	
	public void step()
	{
		stepTime--;
		if (stepTime <= 0)
		{
			stepTime = stepTimeCap;
			moved = Move(path.step());
		}
		
		if (tired)
			c = color(0xff004040);
		else c = color(0xff73ffdc);
		
		fighting = false;
		fleeing = false;
		healing = false;
		resting = false;
		
		if (!tired)
		{
			if (!moved)
			{
				if ((position.x != dest.x || position.y != dest.y) && finished)
					path = MakePath();
				energy--;
				if (new PVector(player.position.x - position.x, player.position.y - position.y).mag() < 4)
				{
					energy -= 3;
					fighting = true;
				}
			}
			
			if (energy <= 0)
			{
				tired = true;
				dest = calcDestination();
				path = MakePath();
			}
		}
		else
		{
			if (!moved)
			{
				if ((position.x != dest.x || position.y != dest.y) && finished && (variation != 1 || new PVector(harry.position.x - position.x, harry.position.y - position.y).mag() > harryDist))
					path = MakePath();
				if (new PVector(dest.x - position.x, dest.y - position.y).mag() <= 1.5f)
				{
					if (variation != 1)
					{
						energy += 3;
						resting = true;
					}
					else
					{
						energy += 4;
						healing = true;
					}
				}
			}
			else fleeing = true;
			
			if (energy >= energyCap)
			{
				tired = false;
				dest = calcDestination();
				path = MakePath();
			}
		}
		
		pathUpdateTime--;
		if (pathUpdateTime <= 0 && (variation != 1 || new PVector(harry.position.x - position.x, harry.position.y - position.y).mag() > harryDist))
		{
			if (variation == 1)
				dest = calcDestination();
			
			path = MakePath();
		}
}
	
	public Path MakePath()
	{
		pathUpdateTime = pathUpdateTimeCap;
		Path p = pather.GeneratePath(position, dest);
		return p;
	}
	
	public void draw()
	{
		super.draw();
		
		if (debug)
			path.draw();
	}
	
	/**
	 * This method is a simple replacement for animation. I could simply call some animator's method to animate, but that is too pseudocode-y.
	 * A good pseudocode replacement would be animate();
	 */
	public void drawGUI()
	{
		String printString = "";
		if (fighting)
			printString = "Combat!";
		else if (fleeing)
			printString = "Fleeing!";
		else if (resting)
			printString = "Resting!";
		else if (healing)
			printString = "Healing!";
		
		fill(0);
		text(printString, (position.x + 5 / 2) * grid.gridSize - 1, (position.y + 3 / 2) * grid.gridSize - 1);
	}
}
//Todd - The final troll
//Timothy Couch

class Todd extends Movable
{
	//movement path for scenario 1
	int[] pArray = {
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.LEFT,
		GridDir.LEFT,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.DOWN,
		GridDir.DOWN,
		GridDir.DOWN,
		GridDir.DOWN,
		GridDir.DOWN,
		GridDir.DOWN,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.RIGHT,
		GridDir.RIGHT,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.NULL,
		GridDir.UP,
		GridDir.UP,
		GridDir.UP,
		GridDir.UP,
		GridDir.UP,
		GridDir.UP
		};
	
	//sensing
	float sightRange = 7;
	float sightAngle = 30;
	float hearRange = 2;
	float trollSenseRange = 10;
	Objects sensedObjects = new Objects();
	Player trackedPlayer;
	boolean seesPlayer = false;
	boolean sawPlayer = false;
	int numTrolls = 0;
	
	//status vars (thinking)
	float healthCap = 100;
	float health = healthCap;
	float weaponDamage = 5;
	float attackRange = 1.2f;
	boolean returning = false;
	int numTrollsSeePlayers = 0;
	float threat = 0;
	int attentionThreshold = 10;
	int dangerThreshold = 5;//3;
	
	//animation vars (acting)
	boolean fighting = false;
	boolean pursuing = false;
	float hideAngle;
	boolean returned = false;

	Path path;
	PVector dest;
	boolean moved = false;
	
	//counter vars
	int stepTimeCap = 5;
	int stepTime = stepTimeCap;
	
	int pathUpdateTimeCap = 10;
	int pathUpdateTime = pathUpdateTimeCap;
	
	StateMachine sM;
	ResponseCurve rC;
	
	Todd()
	{
		super();
		
		InitDefault();
	}

	Todd(PVector position)
	{
		super(position);
		
		InitDefault();
	}
	
	Todd(PVector position, int var)
	{
		super(position);
		
		InitDefault();
	}
	
	public void InitDefault()
	{
		if (variation == 1)
		 	sM = createStateMachine();
		else if (variation == 2)
			rC = createResponseCurve();
		
		dest = calcDestination();
		
		path = MakePath();
		
		c = color(0xff15538c);
		
		if (variation > 0)
			rotation = getAngle(new PVector(chestPos.x + 2 - position.x, chestPos.y - position.y));
		hideAngle = rotation;
	}
	
	public void damage(float d)
	{
		health -= d;
		if (health <= 0)
			objects.destroy(this);
	}
	
	public void step()
	{
		//sense the world
		sense();
		
		//think about situation
		think();
		
		//act to show thoughts
		act();
	}
	
	public void sense()
	{
		trackedPlayer = null;
		sawPlayer = seesPlayer;
		seesPlayer = false;
		sensedObjects.clear();
		numTrolls = 0;
		for (Object o : objects)
		{
			switch(o.getClass().getSimpleName())
			{
				case "Player":
					Player p = (Player) o;
					if (p.alive)
					{
						//sense the player in visual sight
						if (position.dist(p.position) <= sightRange)
						{
							PVector forward = PVector.fromAngle(radians(rotation));
							float playerAngle = degrees(PVector.angleBetween(forward, PVector.sub(p.position, position)));
							if (playerAngle <= sightAngle)
								seePlayer(p);
						}
						
						//sense the player in hearing range
						if (position.dist(p.position) <= hearRange)
							seePlayer(p);
					}
					break;
				case "Todd":
					if (o != this)
						if (position.dist(o.position) <= trollSenseRange)
						{
							sensedObjects.add(o);
							numTrolls++;
						}
					break;
			}
		}
	}
	
	public void seePlayer(Player p)
	{
		if (!seesPlayer)
		{
			seesPlayer = true;
			trackedPlayer = p;
		}
		if (!sensedObjects.contains(p))
			sensedObjects.add(p);
	}
	
	public void think()
	{
		switch (variation)
		{
			case 0://think hardcoded for variation 0
				if (sawPlayer && !seesPlayer)
					returning = true;
				if (position.x == origin.x && position.y == origin.y && !seesPlayer)
					returning = false;
					break;
			case 1:
				break;
		}
		
		pathUpdateTime--;
		if (pathUpdateTime <= 0 || sawPlayer != seesPlayer)//figure out how many trolls see players
		{
			numTrollsSeePlayers = 0;
			for (Object o : objects)
			{
				switch(o.getClass().getSimpleName())
				{
					case "Todd":
						Todd t = (Todd) o;
						if (t.seesPlayer)
							numTrollsSeePlayers++;
						break;
				}
			}
			
			threat = calculateNetThreat(sensedObjects);
			
			switch (variation)
			{
				case 0://hardcoded stuffs
					if (seesPlayer || sawPlayer || returning || (!returning && position.x == origin.x && position.y == origin.y && !path.getLooping()))
						path = MakePath();
					break;
				
				case 1://think of current state//determine state
					sM.getCurrentState().transition();
					sM.getCurrentState().think();
					//path = MakePath();
					break;
				
				case 2:
					rC.chooseBucket();
					path = MakePath();
					break;
			}
			pathUpdateTime = pathUpdateTimeCap;
		}
	}
	
	public float calculateNetThreat(Objects objects)
	{
		float netPlayerHealth = 0;
		float netPlayerDamage = 0;
		float netTrollHealth = health;
		float netTrollDamage = weaponDamage;
		int numTrollsCounted = 0;
		for (Object o : objects)
		{
			switch(o.getClass().getSimpleName())
			{
				case "Player":
					Player p = (Player) o;
					netPlayerHealth += p.health;
					netPlayerDamage += p.weaponDamage;
					break;
				case "Todd":
					if (numTrollsCounted < 4)//max 4 because only four trolls can attack at once
					{
						Todd t = (Todd) o;
						netTrollHealth += t.health;
						netTrollDamage += t.weaponDamage;
						numTrollsCounted++;
					}
					break;
			}
		}
		
		float timeToKill = netPlayerHealth / netTrollDamage;
		float timeToBeKilled = netTrollHealth / netPlayerDamage - 1;//-1 so they try to survive
		
		return timeToKill - timeToBeKilled;
	}
	
	public StateMachine createStateMachine()//variation 1
	{
		StateMachine s = new StateMachine();
		s.add(new State("Hide"){
			public void start()
			{
				returned = false;
			}
			public void transition()
			{
				//if almost dead
				if (health < 4)
				{
					if (sM.printTransitions)
						println("Hide -> Flee from almost dead");
					sM.setCurrentState("Flee");
				}
				else if (seesPlayer)
				{
					//if the enemy will one shot him
					if (health <= trackedPlayer.weaponDamage)
					{
						if (sM.printTransitions)
							println("Hide -> Flee from one shot");
						sM.setCurrentState("Flee");
					}
					
					if (threat > 0)//if the enemy is more powerful
					{
						//if not many trolls are paying attention and the enemy is very dangerous
						if (numTrolls > 0 && (1 - numTrollsSeePlayers / numTrolls) * threat > attentionThreshold)
						{
							if (sM.printTransitions)
								println("Hide -> Flee from not enough paying attention");
							sM.setCurrentState("Flee");
						}
						//if the enemy is very, very dangerous
						else if (threat > dangerThreshold)
						{
							if (sM.printTransitions)
								println("Hide -> Flee from too dangerous");
							sM.setCurrentState("Flee");
						}
					}
					else
					{
						//if many of the other trolls are paying attention
						if (numTrolls > 0 && (numTrollsSeePlayers / numTrolls > .7f))
						{
							if (sM.printTransitions)
								println("Hide -> Attack");
							sM.setCurrentState("Attack");
						}
					}
				}
			}
			public void think()
			{
				//always return to origin
				path = MakePath();
			}
			public void act()
			{
				if (!returned && position.x == origin.x && position.y == origin.y)
				{
					returned = true;
					rotation = hideAngle;
				}
			}
		});
		s.setCurrentState("Hide");//hide is default state
		
		s.add(new State("Attack"){
			public void transition()
			{
				//if almost dead
				if (health < 4)
				{
					if (sM.printTransitions)
						println("Attack -> Flee from almost dead");
					sM.setCurrentState("Flee");
				}
				else if (seesPlayer)
				{
					//if the enemy will one shot him
					if (health <= trackedPlayer.weaponDamage)
					{
						if (sM.printTransitions)
							println("Attack -> Flee from one shot");
						sM.setCurrentState("Flee");
					}
					
					if (threat > 0)//if the enemy is more powerful
					{
						//if not many trolls are paying attention and the enemy is very dangerous
						if (numTrolls > 0 && (1 - numTrollsSeePlayers / numTrolls) * threat > attentionThreshold)
						{
							if (sM.printTransitions)
								println("Attack -> Hide from not enough paying attention");
							sM.setCurrentState("Hide");
						}
						//if the enemy is very, very dangerous
						else if (threat > dangerThreshold)
						{
							if (sM.printTransitions)
								println("Attack -> Flee from too dangerous");
							sM.setCurrentState("Flee");
						}
					}
				}
				else
				{
					if (sM.printTransitions)
						println("Attack -> Hide from losing sight");
					sM.setCurrentState("Hide");
				}
			}
			public void think()
			{
				//always pursue player
				path = MakePath();
			}
			public void act()
			{
				
			}
		});
		
		s.add(new State("Flee"){
			public void transition()
			{
				if (position.dist(safeSpace) < 3 && health == healthCap)
				{
					if (sM.printTransitions)
						println("Flee -> Hide from full health");
					sM.setCurrentState("Hide");
				}
			}
			public void think()
			{
				//always run to safe space
				path = MakePath();
			}
			public void act()
			{
				if (position.dist(safeSpace) < 3 && health < healthCap)
					health++;
			}
		});
		
		return s;
	}
	
	public ResponseCurve createResponseCurve()//variation 2
	{
		ResponseCurve r = new ResponseCurve();
		r.add(new ResponseBucket("Hide"){
			public void start()
			{
				returned = false;
			}
			public int size()
			{
				float weight = 0;
				if (seesPlayer)
				{
					if (threat > 0)
					{
						float pDist = position.dist(trackedPlayer.position);
						if (pDist < 4)
						{
							//if player is not that close or threatening, medium chance to wait
							weight += pDist * 30 / threat;
						}
						else
						{
							//if player is threatening but not close, high chance to wait
							weight += 50 / threat;
						}
					}
					else
					{
						//if not many other trolls are watching, high chance to wait
						if (numTrolls > 0)
							weight += (1 - numTrollsSeePlayers / numTrolls) * 50 / abs(threat);
					}
				}
				//if can't see player and health high, low chance to wait, high chance if at origin
				else
				{
					weight += health / healthCap * 3;
					if (position.x == origin.x && position.y == origin.y)
						weight += health / healthCap * 60;
					
					//if not many are watching
					if (numTrolls > 0)
						weight += (1 - numTrollsSeePlayers / numTrolls) * 30;
				}
				
				return (int) weight;
			}
			public void act()
			{
				if (!returned && position.x == origin.x && position.y == origin.y)
				{
					returned = true;
					rotation = hideAngle;
				}
			}
		});
		r.setCurrentBucket("Hide");//hide is default state
		
		r.add(new ResponseBucket("Attack"){
			public int size()
			{
				float weight = 0;
				if (seesPlayer)
				{
					if (threat <= 0)
					{
						//if many other trolls are watching, high chance to attack
						if (numTrolls > 0)
							weight += numTrollsSeePlayers / numTrolls * 20 * abs(threat);
						
						//low chance increase the higher the net threat
						weight += abs(threat) * 2;
					}
				}
				
				return (int) weight;
			}
			public void act()
			{
				
			}
		});
		
		r.add(new ResponseBucket("Flee"){
			public int size()
			{
				float weight = 0;
				
				//if he is going for the healing, high chance to keep going for it
				if (rC.getCurrentBucket().name.equals("Flee"))
					if (position.dist(safeSpace) < 3)
					{
						if (health < healthCap)
							weight += 120;
					}
					else if (health < healthCap)
						weight += 150;
				
				if (seesPlayer)
				{
					//if would get one shot, go heal plox
					if (health <= trackedPlayer.weaponDamage)
						weight += 300;
					
					if (threat > 0)
					{
						float pDist = position.dist(trackedPlayer.position);
						if (pDist < 4)
						{
							//if player is not that close or threatening, medium chance to flee
							weight += (4 - pDist) * 30 * threat;
						}
						else
						{
							//if player is threatening but not close, low chance to flee
							weight += 5 * threat;
						}
					}
				}
				//if can't see player and low health, high chance to flee
				else weight += (1 - health / healthCap) * 100;
				
				return (int) weight;
			}
			public void act()
			{
				if (position.dist(safeSpace) < 3 && health < healthCap)
					health++;
			}
		});
		
		return r;
	}
	
	public Path MakePath()
	{
		//println("Creating Path");
		switch (variation)
		{
			case 0:
				if (!seesPlayer && !sawPlayer && !returning && position.x == origin.x && position.y == origin.y && (path == null || !path.getLooping()))//normal pathing
				{
					//println("Looped path");
					return new Path(pArray, true);
				}
				else
				{
					//println("Origin");
					return generatePath(calcDestination());//go back to start or puruse player
				}
				//break;
			//case 1:
				//break;
			//case 2:
				//break;
		}
		
		//println("Dum");
		return generatePath(calcDestination());
	}
	
	public PVector calcDestination()
	{
		switch (variation)
		{
			case 0:
				if (returning)
					return origin;
				if (seesPlayer)
					return trackedPlayer.position;
				break;
			case 1:
				switch (sM.getCurrentState().name)
				{
					case "Hide":
						return origin;
					case "Attack":
						return trackedPlayer.position;
					case "Flee":
						return safeSpace;
				}
				break;
			case 2:
				switch (rC.getCurrentBucket().name)
				{
					case "Hide":
						return origin;
					case "Attack":
						return trackedPlayer.position;
					case "Flee":
						return safeSpace;
				}
				break;
		}
		return position;
	}
	
	public Path generatePath(PVector v)
	{
		pathUpdateTime = pathUpdateTimeCap;
		Path p = pather.GeneratePath(position, v);
		return p;
	}
	
	public void act()
	{
		fighting = false;
		pursuing = false;
		
		stepTime--;
		if (stepTime <= 0)
		{
			//step on path
			int moveDir = -1;
			stepTime = stepTimeCap;
			moveDir = path.step();
			moved = Move(moveDir);
			
			//keep trying on current static path if variation 0
			if (!moved && moveDir != GridDir.NULL && path.getLooping())
				path.reverseStep();
			
			//rotate with path
			if (!seesPlayer)
				if (path.getNextMove() != GridDir.NULL)
					rotation = getAngle(GridDir.Move(path.getNextMove()));
			
			Objects attacking = new Objects();//list of players attacking this
			for (Object o : sensedObjects)
			{
				switch(o.getClass().getSimpleName())
				{
					case "Player":
						Player p = (Player) o;
						//get attacked by all players in range
						if (position.dist(p.position) <= attackRange)
						{
							if (p.alive && !p.attacked)
							{
								damage(p.weaponDamage);
								attacking.add(p);
								p.attacked = true;
							}
						}
						break;
				}
			}
			
			if (trackedPlayer != null)//attack tracked player
			{
				if (attacking.size() > 0 && !attacking.contains(trackedPlayer))//change focus to attacking player
					trackedPlayer = (Player) attacking.get(0);
				if (position.dist(trackedPlayer.position) <= attackRange)
					if (seesPlayer)
						trackedPlayer.damage(weaponDamage);
			}
			
			if (variation == 1)
				sM.getCurrentState().act();
			else if (variation == 2)
				rC.getCurrentBucket().act();
		}
		//rotate to player
		if (seesPlayer)
			rotation = getAngle(PVector.sub(trackedPlayer.position, position));
		
		//animate
		if (variation == 0 && seesPlayer)
		{
			if (position.dist(trackedPlayer.position) <= attackRange)
				fighting = true;
			if (moved)
				pursuing = true;
		}
	}
	
	public void draw()
	{
		super.draw();
		fill(0);
		line(0, 0, size.x / 2, 0);
		
		if (debug)
		{
			//sight radius
			noFill();
			stroke(0xff000000, 150);
			arc(0, 0, sightRange * grid.gridSize * 2, sightRange * grid.gridSize * 2, -radians(sightAngle), radians(sightAngle));
			PVector lineVec = new PVector(sightRange * grid.gridSize, 0);
			lineVec.rotate(radians(sightAngle));
			line(0, 0, lineVec.x, lineVec.y);
			lineVec.rotate(-radians(sightAngle * 2));
			line(0, 0, lineVec.x, lineVec.y);
			//hearing radius
			ellipse(0, 0, hearRange * grid.gridSize * 2, hearRange * grid.gridSize * 2);
			//troll sense radius
			ellipse(0, 0, trollSenseRange * grid.gridSize * 2, trollSenseRange * grid.gridSize * 2);
			
			rotate(-radians(rotation));
			
			path.draw();
		}
		else rotate(-radians(rotation));
		
		//health
		fill(0xfff02b08);
		stroke(0xff000000);
		rect(-grid.gridSize * 3 / 4 - 1, -grid.gridSize - 1, grid.gridSize * 3 / 2 + 2, 2);
		stroke(0xff2bff09);
		line(-grid.gridSize * 3 / 4, -grid.gridSize, -grid.gridSize * 3 / 4 + health * grid.gridSize * 3 / 2 / healthCap, -grid.gridSize);
	}
	
	/**
	 * This method is a simple replacement for animation. I could simply call some animator's method to animate, but that is too pseudocode-y.
	 * A good pseudocode replacement would be animate();
	 */
	public void drawGUI()
	{
		String printString = "";
		
		switch (variation)
		{
			case 0:
				if (fighting)
					printString = "Fighting!";
				else if (pursuing)
					printString = "Pursuing!";
				break;
			case 1:
				printString = sM.getCurrentState().name;
				break;
			case 2:
				printString = "" + rC;
				//printString = rC.getCurrentBucket().name;
				break;
		}
		
		pushMatrix();
		pushStyle();
		
		textAlign(CENTER);
		
		fill(0);
		text(printString, (position.x /*+ 5 / 2*/) * grid.gridSize - 1, (position.y - 1 /*+ 3*/ / 2) * grid.gridSize - 1);
		
		popStyle();
		popMatrix();
	}
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "sketch_CS330FinalTroll" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
