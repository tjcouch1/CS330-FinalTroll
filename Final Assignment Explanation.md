Timothy Couch

Dr. Rochowiak

CS 330

26 April 2017

Final Assignment Explanation

*Scenarios and Todd’s Sense-Think-Act*
	For my final assignment, I created a troll named Todd who interacts with other trolls and the player. He senses, thinks, and acts in three different ways, and he can be placed in three different scenarios as the assignment requires.
	The three scenarios Todd can be placed in are quite different from one another. In the first scenario, Todd is alone, hiding in a bush, and there is a single player. In the second scenario, Todd and six of his troll friends are all hiding in bushes, and there is a single player. In the third scenario, Todd and his six troll friends are hiding in bushes, and there are four players in a group. The idea around them is that Todd waits for the player to approach a chest, then attacks the player. Todd is supposed to be baiting the player in with the chest.
	Todd senses the same way for all scenarios. He has a triangle that points in front of him that is his visual sense. He has a small circle around him which is his auditory sense (trolls don’t have good hearing). He has a large circle around him which is his troll sense (trolls can sense other trolls in the area). He gathers all objects he senses into a group together that serves as his memory.

	Todd thinks in three different ways as requested, and I matched each thinking style with the three scenarios to show how he thinks in each way and each scenario. In his first thinking style, his sensing and his acting are hard-coded (choice 1). This means there is not much thinking. If he sees the player, he paths to attack him. Otherwise, he walks on a pre-made path between some bushes. In his second thinking style, he thinks with a finite state machine (choice 2). He decides between hiding, attacking, and fleeing to regain health based on current stats such as the health and damage of all his teammates compared to that of the player. Based on which state he chooses, he paths to the appropriate place. In the third thinking style, he uses a response curve (choice 6). He decides between hiding, attacking, and fleeing to regain health based on sizes of buckets of these choices. The bucket sizes are determined by seeing the player, the health and damage of teammates and players, number of teammates who see a player, and the proximity of players. Based on which state he chooses, he paths to the appropriate place.
	Todd acts in nearly the same way in all scenarios. He paths to his destination set premade or based on his current state or bucket and attacks the player if in range. In accordance with his thinking patterns 2 and 3, he heals when he is in a safe place.
	These sum up to the following: In the first scenario, Todd paths between bushes, then attacks the player on sight. In the second scenario, many trolls hide in bushes, then ambush the player and surround him or run away based on his threat. In the third scenario, the trolls work together much less, not all quite committing to attacking the players or running away since they have semi-random decisions.

*How It Could Have Been Different*
	When the player has low health and weapon damage, Todd attacks him. If the player has high health and weapon damage, Todd stays hidden. If the player has extremely high health and weapon damage, Todd runs away. I could have made Todd always run away or always stay put. I could have made the Todds stick out for one another when they get singled off by the player. I could have made the Todds attack the player more commonly, risking death.

*How to Play the Simulation*
	Upon launching the game, you can do a number of things. You can enable or disable Debug information by clicking the button in the top left. You can click a scenario button to load that scenario along with Todd’s according thinking. To see the scenarios play out, you can use WASD to control the red player. All the trolls are blue, and they start in green transparent bushes. There is an orange chest in the middle of the ring of bushes. This is what Todd is “guarding.” 

	To make Todd do things, enter his visual or auditory sense areas, which are in front of him and around him. They are drawn to the screen in debug mode to make this simpler. Todd will indicate what he is doing with text drawn above his head. This replaces an animation system, so it displays in and out of debug mode. Click the Go Back button in the top left to return to the scenario screen and to respawn the player if he dies.

	Since Todd weighs the player’s and his own weapon’s strength, you can change the values for them with the buttons to the top left. Click them to change their values and see the difference they make.
