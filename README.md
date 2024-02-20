Fusball Game on FPGA card implemented using SystemVerilog on Intel's Quartus Prime Lite. in addition to the FPGA card we are using a mini keyboard with PS2 port and a VGA screen.
The game consists of 6 players for each team with varying levels of the gameplay, starting from level 1 and ending at level 3.
the players are controlled using the Up,Down,Left,Right buttons of the keyboard whereas the ball is kicked with different initial speeds according to the time the Left/Right buttons were pressed(the longer the press the bigger the kicking force is). The opposition team is controlled automatically depending on the current level of the game as follows:
* Level 1: the poles on which the players are hanging move upwards and downwards at a constant speed that can be set before the game starts.
* Level 2: the poles on which the players are hanging move according to where the ball is heading where the field is divided into 3 sections: between the goalkeeper and the defence, between the defence and the attack and infront of the attack. the poled move in an attempt to block the ball and in addition kicking it using the "artificial" Left and Right buttons.
*Level 3: similar to Level 2, but in addition both the opposition and team goals are moving at a constant speed upwards and downwards making it harder for the keeper to block the ball.

to give some spice to the game, I decided that the opposition players would be the lovely character "Towlie" from the famous or infamous cartoon SouthPark whereas the team players are the iconic character "Eric Cartman". 

Hope you enjoy the game and idea :)


<img src="https://github.com/GhanayemMuh/Fusball-Game-on-FPGA/assets/125828484/073a5899-6e5e-48b4-a69d-897ef6c9c67a" width="50%" height="50%">
![Fusball2](https://github.com/GhanayemMuh/Fusball-Game-on-FPGA/assets/125828484/eb57a4a3-f87c-4830-a8bb-f71d7232d428)
![Fusball3](https://github.com/GhanayemMuh/Fusball-Game-on-FPGA/assets/125828484/6aad4220-3bbb-4063-8fa5-a339ece91f72)
