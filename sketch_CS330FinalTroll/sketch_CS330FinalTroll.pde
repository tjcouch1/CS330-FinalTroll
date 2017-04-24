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
Keys keys = new Keys();

Todd todd;
Player player;
GridObject chest;

PVector safeSpace = new PVector(19, 5);
PVector bridge = new PVector(8, 28);
PVector chestPos = new PVector(5, 31);

void settings()
{
	size(grid.gridWidth * grid.gridSize, grid.gridHeight * grid.gridSize);
}

void setup()
{
	//main menu
	mainMenu.add(new Button(new PVector(3 * grid.gridSize, 1 * grid.gridSize),
		new PVector(5 * grid.gridSize, 1.5 * grid.gridSize), "Debug " + debug){
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
		new PVector(5 * grid.gridSize, 1.5 * grid.gridSize), "Go Back"){
			public void clicked()
			{
				gameMenu.setActive(false);
				mainMenu.setActive(true);
				endGame();
			}
		});
}

void StartGame(int var)
{
	variation = var;
	gameStart = true;

	player = (Player) objects.addGrid(new Player(new PVector(22, 31)));
	todd = (Todd) objects.addGrid(new Todd(bridge));
	
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
	chest.c = color(#816d1b);
	
	//bushes
	PVector bushSize = new PVector(grid.gridSize * 7 / 8, grid.gridSize * 7 / 8);
	Object bush = objects.add(decorations.add(new GridObject(new PVector(8, 28), bushSize)));
	bush.c = color(#0eb547, 170);
	bush = objects.add(decorations.add(new GridObject(new PVector(6, 28), bushSize)));
	bush.c = color(#0eb547, 170);
	bush = objects.add(decorations.add(new GridObject(new PVector(4, 29), bushSize)));
	bush.c = color(#0eb547, 170);
	bush = objects.add(decorations.add(new GridObject(new PVector(3, 31), bushSize)));
	bush.c = color(#0eb547, 170);
	bush = objects.add(decorations.add(new GridObject(new PVector(4, 33), bushSize)));
	bush.c = color(#0eb547, 170);
	bush = objects.add(decorations.add(new GridObject(new PVector(6, 34), bushSize)));
	bush.c = color(#0eb547, 170);
	bush = objects.add(decorations.add(new GridObject(new PVector(8, 34), bushSize)));
	bush.c = color(#0eb547, 170);
}

void endGame()
{
	variation = 0;
	gameStart = false;
	
	objects.removeAllGrid();
	
	for (Object o : decorations)
		objects.remove(o);
	
	decorations = new Objects();
}

void draw()
{
	objects.KeysDown(keys);
	objects.draw();
}

void mousePressed()
{
	objects.MousePressed();
}

void keyPressed()
{
	if (keys.KeyPressed(key))
	{
		objects.KeyPressed(key);
	}
}

void keyReleased()
{
	if (keys.KeyReleased(key))
	{
		objects.KeyReleased(key);
	}
}
