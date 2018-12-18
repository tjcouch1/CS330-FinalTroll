# Enemy-Group-AI
AI that weighs party strength against player party strength using multiple methodologies

Todd is a blue troll who guards a brown chest from the player. He hides in green bushes, and he rests to recover health at home in the transparent blue square. Generally, he should attack the player when he gets close to the chest.

Todd runs on a sense-think-act cycle. He receives information from the environment based on specified rules, thinks about the information he received in three different ways based on three scenarios, then acts based on his thoughts.

Todd has a few senses:
* The large circle around Todd represents his troll sense. He sees the other trolls in that circle and whether or not they see the player.
* The triangle in front of Todd represents his sight. When the player is in the triangle, Todd can see him.
* The small circle around Todd represents his hearing. When the player enters that circle, Todd can always see the player regardless of the direction the player faces.
* Todd sees lots of information about the player like how close he is to Todd, his health, and his weapon damage.
* Todd considers factors about himself like his weapon damage and his health.

Todd can think and act in three ways based on three scenarios:
1. Todd is alone. He thinks with a simple state machine. He patrols in a rectangle if he does not see the player, and he attacks the player if he does see the player. Todd is very stupid and easily gets himself killed.
2. Todd is hiding in a bush with several other trolls. He can hide in the bush in waiting, attack the player, or flee to home. Todd thinks with a more complex state machine, considering all listed factors like how many of his friendly trolls see (and therefore are ready to fight) the player. He is perfectly predictable. The same senses produce the same actions every time.
3. Todd is hiding in a bush with several other trolls. He can hide in the bush in waiting, attack the player, or flee to home. Todd thinks with a response curve, considering all listed factors like in scenario 2. This time, however, he builds "buckets" of decisions and acts randomly based on the size of each bucket or the likely success of each action.

Choose a scenario by clicking it.

Move the player with WASD.

Change the player's damage or the trolls' damage by clicking the buttons in the top right. This setting immensely affects how Todd acts in scenarios 2 and 3.

Includes a small game engine for Processing I wrote for this AI. It handles objects, inputs, an optional grid system, and more.

Created for AI class, April 26, 2017.

![](https://github.com/tjcouch1/Enemy-Group-AI/blob/master/enemygroupai.gif)