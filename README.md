# CPE 487 Final Project: Crossy Road
**Arden Sentak and Kyra Fischer**

*We pledge our honor that we have abided by the Stevens Honor System.*

A 2D game created using VHDL inspired by the game "Crossy Road" 
![CrossyRoadImage](images/CrossyRoadBaseImage.jpg)

--- 

## Project Overview 
This project aims to mimic the functionality of Crossy Road: a game where a character jumps across grass and roads and avoids obstacles like cars, trees, rocks, and water. The objective is to make it safely across the screen by avoiding obstacles and collect coins on the way to maximize your score. 

### Expected Behavior
- When the game loads in, the monitor will display the Crossy-Road game map which consists of grass, roads, moving cars, coins, and obstacles. In addition the game character will be loaded in at the bottom center of the screen
- Using switches 0-4 on the Nexys board, the player can flip a switch upwards to select their game character 
- The character can be moved around the screen using the following buttons (BTNU, BTND, BTNL, BTNR) to move forward, backward, left, and right, respectively
- At any time the player can press the BTNC button to reset the game and start over
- Each time the character moves forward to a new position the game score will increase by 1
- When the character collects a coin, the game score will increase by 10
- If the character collides with a car or a puddle, the game will be over and the character will disappear. The game can be restarted by pressing BTNC
- If the character collides with a rock or a tree, they will bounce of the obstacle and be sent back to their previous position
- Once the character reaches the top of the screen, the character will disappear and the Nexys board will display a "good job" message & a green LED will light up to indicate the player won the game

### Game Functionality Block Diagram 
![Game Functionality Block Diagram](https://github.com/asentak/tester/blob/main/Frogger%20System%20Diagram.jpg)

### Our Game
![VHDL Crossy Road Image](https://github.com/asentak/CPE487Project/blob/main/images/VHDLCrossyRoad.jpg)
### Demo Videos
- [Character Switching](https://youtube.com/shorts/Pp7JuwL5YC4?feature=share)
- [Gameplay Win + Screen Wrap Around Feature](https://youtube.com/shorts/CF8CdyUG-Aw?feature=share)
- [Car Collision](https://youtube.com/shorts/PBwyS4DZcIo?feature=share)
- [Puddle Collision + Reset Gameplay](https://youtube.com/shorts/j9jCg9TkhcI?feature=share)
- [Obstacle Bounce Off (Trees and Rocks) + Showing Score Only Increases For New Forward Progress](https://youtube.com/shorts/9dyAyl_ouWI?feature=share)

## Required Equipment
(INCLUDE PICTURES ON ACTUAL GITHUB) 
1. Nexys A7 Board
![NexyA7 Board Image](https://github.com/asentak/CPE487Project/images/NexyA7Board.png)
3. VGA to HDML Cable
![Cable Image](https://github.com/asentak/CPE487Project/images/Cable.png)
5. Micro USB Cable
6. Monitor
![Monitor Image](https://github.com/asentak/CPE487Project/images/monitor)


## Project Setup Steps
1. Download the following files from the project code folder on our GitHub: vga_top.vhd, frog.vhd, vga_sync.vhd, leddec.vhd and frogger.xdc
2. Create a new RTL project called CrossyRoad in Vivado Quick Start
	- In the "add sources" section upload the four .vhd files you downloaded 
	- In the "add constraints" section upload the .xdc file you downloaded
	- In the "Default Part" section, click on "Boards" and select the Neyxs A7-100T board
	- Click 'Finish'
3. Plug in the HDMI part of cable into monitor and VGA side into the board as well as the audio plug and usb plug
4. Plug in Nexys A7 micro-usb cable into the board and the computer to create connection
5. Ensure that the Nexys board in turned on
6. Run synthesis
7. Run implementation
8. Generate bitstream, open hardware manager, and program device
	- Click 'Generate Bitstream'
	- Click 'Open Hardware Manager' and click 'Open Target' then 'Auto Connect'
	- Click 'Program Device' then xc7a100t_0 to download vga_top.bit to the Nexys A7 board
9. Once the device is programmed, the project will appear on the screen

## Inputs and Ouputs 
- Most inputs and outputs included in our project files were taken from the starter code. However we added the inputs/outputs regarding the LED, switches (sw), and the win flag.
	- The win flag was added to tell our program when the game was won so that it could display a win message on the board
 	- The switches (switched 0-5) were added as a new input from the board to our program. We set up these switches so that the game character could be changed based on which switch the player had turned on.
  	- The LED (located at the bottom right of the board) was added as a new output from our program to the board. We set up our program so that when the game was won we would signify our board to light up the LED as a win indicator.
- Note while we show the inputs and outputs for our files here, we don't show full modifications of our new input & output from the constraints file to the entities, components, and port maps. The full integration of these new components is shown in our code blocks for their respective modifications (7 for output LED; 12 for input switches)

#### vga_top.vhd
```
ENTITY vga_top IS
	PORT (
		clk_in : IN STD_LOGIC;
		vga_red : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		vga_green : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		vga_blue : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		vga_hsync : OUT STD_LOGIC;
		vga_vsync : OUT STD_LOGIC;
		b_left : IN STD_LOGIC;
		b_right : IN STD_LOGIC;
		b_up : IN STD_LOGIC;
		b_down : IN STD_LOGIC;
		b_reset : IN STD_LOGIC;
		AN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		LED: out std_logic; --added for new led output (bottom right led lights up green when win)
		sw : IN STD_LOGIC_VECTOR(4 DOWNTO 0) -- added for new input: switches 0-4 allow user to switch characters
	);
END vga_top;
```

INPUTS: 
- clk_in: system clock for the Nexys board (from board)
- b_left: button to move character left (from board)
- b_right: button to move character right (from board)
- b_up: button to move character forward (from board)
- b_down: button to move character backward (from board)
- b_reset: button to reset the game (from board)
- sw: controls character selection for switches 0-4 (from board)

<br>OUTPUTS: 
- vga_red: 4 bit red color value (to monitor)
- vga_green: 4 bit green color value (to monitor)
- vga_blue: 4 bit blue color value (to monitor)
- vga_hsync: horizontal sync timining signal (to monitor)
- vga_vsync: vertical sync timining signal (to monitor)
- AN: controls which annode to light up (to board)
- seg: controls what segment pattern to display on Nexys display (to board)
- LED: bottom right led will be lit up upon a win (to board)


#### vga_sync.vhd
```
ENTITY vga_sync IS
	PORT (
		pixel_clk : IN STD_LOGIC;
		red_in    : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		green_in  : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		blue_in   : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		red_out   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		green_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		blue_out  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		hsync     : OUT STD_LOGIC;
		vsync     : OUT STD_LOGIC;
		pixel_row : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
		pixel_col : OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
	);
END vga_sync;
```

INPUTS:
- pixel_clk: clock timing for pixel drawing (from vga_top)
- red_in: red color value (from frog.vhd via vga_top)
- green_in: green color value (from frog via vga_top)
- blue_in: blue color value (from frog via vga_top)

<br>OUTPUTS:
- red_out: red color value sent to VGA monitor (to vga_top then to monitor)
- green_out: green color value sent to VGA monitor (to vga_top then to monitor)
- blue_out: blue color value sent to VGA monitor (to vga_top then to monitor)
- hsync: horizontal sync timing signal (to vga_top then to monitor)
- vsync: vertical sync timing signal (to vga_top then to monitor and frog)
- pixel_row: current pixel y position (to frog via vga_top)
- pixel_col: current pixel x position (to frog via vga_top)


### frog.vhd
```
ENTITY frog IS
	PORT (
		v_sync    : IN STD_LOGIC; 
		pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0); 
		pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0); 
		
		-- used for pixel colors 
		red       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); 
		green     : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		blue      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		
		--for movement buttons & reset
		up        : IN STD_LOGIC; 
		down      : IN STD_LOGIC; 
	   	left      : IN STD_LOGIC; 
	 	right     : IN STD_LOGIC; 
        reset     : IN STD_LOGIC; 
		
		score 	  : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); --changed from 1 downto 0 to 7 downto 0 to ensure high enough scoring could be stored
		win_out   : OUT STD_LOGIC; -- added to track a win
		LED: out std_logic; --added for our new output from board to code (bottom right led turns green when win)
		sw : IN std_logic_vector(4 downto 0) --added as our new input from board to code (switches for changing character)
	);
END frog;
```

INPUTS:
- v_sync: vertical sync timing signal (from vga_sync via vga_top)
- pixel_row: current pixel y position (from vga_sync via vga_top)
- pixel_col: current pixel x position (from vga_sync via vga_top)
- up: button to move character forward (from vga_top)
- down: button to move character backward (from vga_top)
- left: button to move character left (from vga_top)
- right: button to move character right (from vga_top)
- reset: button to reset the game (from vga_top)
- sw: controls character selection based on switches 0-4 (from vga_top)
  
<br> OUTPUTS:
- red: red color value for current pixel (to vga_sync via vga_top)
- green: green color value for current pixel (to vga_sync via vga_top)
- blue: blue color value for current pixel (to vga_sync via vga_top)
- score: current game score (to leddec via vga_top)
- win_out: flag to indicate if the game was won (to leddec via vga_top)
- LED: bottom right led will be lit up upon a win (to vga_top then board)
  
### leddec.vhd
```
ENTITY leddec IS
    PORT (
        dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0); --changed from 1 downto 0 to 2 downto 0 to make it 8 bits so could expand display to say good job when win 
        f_data : IN STD_LOGIC_VECTOR (7 DOWNTO 0); --changed from 1 downto 0 to 7 downto 0 (to match the size of score)
        win : IN STD_LOGIC; --added to track win 
        anode : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
    );
END leddec;
```

INPUTS:
- dig: selects which of the 8 displays on the Nexys board to light up (from vga_top)
- f_data: game score value (from frog via vga_top)
- win: value of win flag (from frog via vga_top)

<br> OUTPUTS:
- anode: controls which display is activated (to vga_top then board)
- seg: controls which segments of the display light up (to vga_top then board)

## Module Hierarchy & File Description
![Module Hierarchy Diagram](https://github.com/asentak/CPE487Project/blob/main/images/CPE487%20Project%20Module%20Hierarchy.jpg)

## Modifications
We used the following [2025 Spring Frogger project](https://github.com/UsuarioDelNet/487FinalProject) as the starting point for our project. Our starter code consisted of the following files from this project: 
- [frog.vhd](https://github.com/asentak/CPE487Project/blob/main/starterCode/frog.vhd): main file to hold all of the game logic
- [leddec.vhd](https://github.com/asentak/CPE487Project/blob/main/starterCode/leddec.vhd): file to control the 8 digit 7-segment display on the Nexys board
- [vga_sync.vhd](https://github.com/asentak/CPE487Project/blob/main/starterCode/vga_syncProject.vhd): generates VGA timing signals and pixel coordinates for graphics display.
- [vga_top.vhd](https://github.com/asentak/CPE487Project/blob/main/starterCode/vga_topProject.vhd): top level file to integrate the game logic, display, and VGA
- [frogger.xdc](https://github.com/asentak/CPE487Project/blob/main/starterCode/frogger.xdc): constraints file to define Nexys hardware inputs/outputs & their connection to the code
 <br>
A few other files were included in the starter code project that we did not use since they weren't fully integrated into the starter project yet and we did not need those aspects for our crossy road game anyway. <br>


<br> We made the following modifications to our code: 
<br>

**1. Replaced Gliding Character Movement With Hopping**
- From the starter code the moving mechanism for the frog was a glide. When you held down any button the character would move continually in that direction. We didn’t love this movement because it didn't match the classic frogger and crossy road game. Therefore we updated the code to introduce a hopping movement mechanic by adding rising-edge detection and a fixed hop distance to replace the previous continuous gliding behavior. Instead of moving every clock cycle while a button is held, the code now checks for the moment a button transitions from unpressed to pressed, allowing the game character to move only once per button press. This is achieved using new signals for each direction and a defined frog_hop value that sets the exact pixel distance of each jump. Together, these changes create precise, discrete hops that better match the intended gameplay style, making the game character’s movement feel more consistent with classic arcade mechanics.
#### Frog.vhd
```
-- current frog position (initialized towards bottom center of the screen) 
	SIGNAL frog_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00110010000"; -- 400
	SIGNAL frog_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "01001000100"; -- 580

	-- added this signal to store the distance the character hops for each button press
	SIGNAL frog_hop : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000010100"; -- 20 pixels
	
	-- added in these button edge detection signals so the character can only move once per button press (hopping effect)
	SIGNAL up_last : STD_LOGIC := '0';
	SIGNAL down_last : STD_LOGIC := '0';
	SIGNAL left_last : STD_LOGIC := '0';
	SIGNAL right_last : STD_LOGIC := '0';
---------------------------------------------------------------------------------------------------------------------
-- Inside mfrog process
--added these lines to update prev_frog positions everytime the character moves
	       prev_frog_x <= frog_x;
	       prev_frog_y <= frog_y;

	       -- Edge detection: added to move once  per button press
	       IF up = '1' AND up_last = '0' THEN
	           frog_y <= frog_y - frog_hop; --hop forward
	           -- Add a point to the score for moving forward to a new y position
	           IF (frog_y - frog_hop) < max_forward_y AND s_score < "11111111" THEN
	               s_score <= s_score + 1;
	               max_forward_y <= frog_y - frog_hop;  --updates max forward y to new furthest y position
	           END IF;
	       ELSIF down = '1' AND down_last = '0' THEN
	           frog_y <= frog_y + frog_hop; --hop backward
	       ELSIF left = '1' AND left_last = '0' THEN
	           frog_x <= frog_x - frog_hop; --hop left
	       ELSIF right = '1' AND right_last = '0' THEN
	           frog_x <= frog_x + frog_hop; --hop right
	       END IF;
	       
	       -- Store status of recent buttn press so can track if its a new click or if just holding down the button
	       up_last <= up;
	       down_last <= down;
	       left_last <= left;
	       right_last <= right;
```

**2. Scoring Changed To +1 For Each New Hop Forward & +10 For Each Coin Collected**
- The starter code used a scoring system that only had +1 for coins picked up. We wanted to follow a similar method to the crossy road game where for each forward movement you gain a point. We updated the code so the score signal was expanded from 2 bits to 8 bits, allowing values up to 255 so the player’s progress could be tracked without overflow. A forward hop now adds 1 point by checking if the frog reaches a new minimum y-position, encouraging players to move upward toward the goal. Additionally, each coin collected awards 10 points. The starter code included a function that when the coin was picked up it would disappear from the gameplay screen indicating it was picked up and not creating an endless loop of getting points so we didn’t have to edit this part. In the display module, the score is converted from binary to decimal by breaking it into hundreds, tens, and ones digits so it can be shown correctly on the seven-segment displays. We also didn’t need to edit the code that showed the current score on the board because that function was working correctly. All together our changes created a more engaging scoring mechanic that rewards the player to progress towards the end goal and collect coins along the way.
#### Frog.vhd
```
score : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); --changed from 1 downto 0 to 7 downto 0 to ensure high enough scoring could be stored

SIGNAL s_score : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000"; --changed from 1 downto 0 to 7 downto 0 to ensure high enough scoring could be stored

score <= s_score;
---------------------------------------------------------------------------------------------------------------------------------

-- Add a point to the score for moving forward to a new y position
 IF (frog_y - frog_hop) < max_forward_y AND s_score < "11111111" THEN
	s_score <= s_score + 1;
------------------------------------------------------------------------------------------------------------------------------
-- Coin collection logic (took ideas from starter code and just changed a bit to fit our project)

			-- if the coin is not yet collected.....   
	       IF coin1_collected = '0' THEN
			   --if character touches coin....flag that the coin is collected
	           IF (frog_x + size >= coin1_x - coin_size) AND (frog_x <= coin1_x + coin_size + size) AND
	              (frog_y + size >= coin1_y - coin_size) AND (frog_y <= coin1_y + coin_size + size) THEN
	               coin1_collected <= '1';
			   		--safety check to make sure score isnt over 8 bit limit (255) before adding--> we ended up switching score so it never passes this anyway but just kept the check in
	               IF s_score <= "11110101" THEN -- <= 245
					   --add 10 to score when coin is collected
	                   s_score <= s_score + 10;
	               END IF;
	           END IF;
	       END IF;

-- Repeated this logic for all three coins
```
#### Leddec.vhd
```
USE IEEE.STD_LOGIC_UNSIGNED.ALL; --added this library so could do math with the score

-- signals created to help calculate the score as an integer 
SIGNAL temp_score : INTEGER RANGE 0 TO 255;
SIGNAL hundreds : INTEGER RANGE 0 TO 9;
SIGNAL tens : INTEGER RANGE 0 TO 9;
SIGNAL ones : INTEGER RANGE 0 TO 9;

-- converts the binary score to decimal numbers and store the digit of each tens place so it can be displayed 
temp_score <= CONV_INTEGER(f_data);
hundreds <= temp_score / 100;
tens <= (temp_score / 10) MOD 10;
ones <= temp_score MOD 10;
--------------------------------------------------------------------------------------------------------------------------------
- Select what number will be displayed 

    data4 <= 
             -- Score digits
            -- ones place score digits
             "0000" WHEN (win = '0' AND dig = "000" AND ones = 0) ELSE --0 
             "0001" WHEN (win = '0' AND dig = "000" AND ones = 1) ELSE --1
             "0010" WHEN (win = '0' AND dig = "000" AND ones = 2) ELSE --2 
             "0011" WHEN (win = '0' AND dig = "000" AND ones = 3) ELSE --3
             "0100" WHEN (win = '0' AND dig = "000" AND ones = 4) ELSE --4
             "0101" WHEN (win = '0' AND dig = "000" AND ones = 5) ELSE --5
             "0110" WHEN (win = '0' AND dig = "000" AND ones = 6) ELSE --6
             "0111" WHEN (win = '0' AND dig = "000" AND ones = 7) ELSE --7
             "1000" WHEN (win = '0' AND dig = "000" AND ones = 8) ELSE --8 
             "1001" WHEN (win = '0' AND dig = "000" AND ones = 9) ELSE -- 9

            -- tens place score digits
             "0000" WHEN (win = '0' AND dig = "001" AND tens = 0) ELSE --00
             "0001" WHEN (win = '0' AND dig = "001" AND tens = 1) ELSE --10
             "0010" WHEN (win = '0' AND dig = "001" AND tens = 2) ELSE --20
             "0011" WHEN (win = '0' AND dig = "001" AND tens = 3) ELSE --30
             "0100" WHEN (win = '0' AND dig = "001" AND tens = 4) ELSE --40
             "0101" WHEN (win = '0' AND dig = "001" AND tens = 5) ELSE --50
             "0110" WHEN (win = '0' AND dig = "001" AND tens = 6) ELSE --60
             "0111" WHEN (win = '0' AND dig = "001" AND tens = 7) ELSE --70
             "1000" WHEN (win = '0' AND dig = "001" AND tens = 8) ELSE --80
             "1001" WHEN (win = '0' AND dig = "001" AND tens = 9) ELSE --90

            --hundreds place score digits (didnt end up needing these because we changed our scoring process to be lower)
             "0000" WHEN (win = '0' AND dig = "010" AND hundreds = 0) ELSE --000
             "0001" WHEN (win = '0' AND dig = "010" AND hundreds = 1) ELSE --100
             "0010" WHEN (win = '0' AND dig = "010" AND hundreds = 2) ELSE --200
             "1111";
```

**3. Created Wrap Around Feature When Character Reaches A Screen Edge**
- The starter code didn’t account for when the player reached the edge of the screen. Your character could move indefinitely to the left and right off the screen and either come all the way back or reset to get your character back visually on the screen. We updated the code to include a horizontal wrap-around feature that prevents the character from disappearing off the edges of the screen. This was done by adding boundary checks for the frog’s x-position: if the frog moves past the right edge, its position is immediately reset to the left side of the screen, and if it moves past the left edge, it reappears at the right side. By replacing the previous hard boundaries with this wrap-around logic, the gameplay becomes smoother and more dynamic, allowing continuous movement across the screen without losing the character. This also enhances playability by ensuring the frog remains visible and follows similar game mechanics to arcade style games.
#### Frog.vhd
```
-- added screen wrapping for left/right boundaries so character cant disappear off sides of screen
IF frog_x > "01110000100" THEN -- > 900 --edge of right side of screen
	frog_x <= "00000001010"; -- wrap to 10 (wrap to edge of left side of screen)
 END IF;
IF frog_x < "00000001010" THEN -- < 10 (edge of left side of screen)
	frog_x <= "01110000100"; -- wrap to 900 (wrap to edge of right side of screen)
END IF;
```

**4. Car Speed Varies (not every object moves at same speed)**
- To make the game more challenging one of our goals was to have multiple cars as obstacles and specifically make them different speeds. This made timing crucial for the player as well as creating some easier and harder parts of the game. The starter code had five cars as obstacles but had all of them moving at the same speed. The previous code included the position and size of each car, set the constant car_size corresponding to the car’s width/height to 12 pixels. Also it created the signals car1_x and car1_y to store the car’s starting position on the screen and the signal car1_on to be used to indicate whether the current pixel being drawn falls within the car’s rectangular area these values tell the screen which pixels to light up as the car moves. We could keep this previous code because it functioned properly. We changed the car_x_motion for each car which allowed us to control how many pixels per frame they move and we made these different for each car therefore changing their speeds.
#### Frog.vhd
```
CONSTANT car_size  : INTEGER := 12;
SIGNAL car1_on : STD_LOGIC; -- indicates whether car1 is over current pixel position 
SIGNAL car1_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000001010"; -- (10) x position on screen
SIGNAL car1_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00100101100"; -- (300) y position on screen
SIGNAL car1_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000011"; -- (3) speed car moves per frame
SIGNAL car2_on : STD_LOGIC;
SIGNAL car2_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000001010"; -- 10
SIGNAL car2_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00101011110"; -- 350
SIGNAL car2_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000100"; -- 4	
SIGNAL car3_on : STD_LOGIC;
SIGNAL car3_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000001010"; -- 10
SIGNAL car3_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00110010000"; -- 400
SIGNAL car3_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000101"; -- 5
SIGNAL car4_on : STD_LOGIC;
SIGNAL car4_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000010100"; -- 20
SIGNAL car4_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00010010110"; -- 150
SIGNAL car4_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000110"; -- 6	
SIGNAL car5_on : STD_LOGIC;
SIGNAL car5_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000011110"; -- 30
SIGNAL car5_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00011001000"; -- 200
SIGNAL car5_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000111"; -- 7
```

**5. Added Functionality to Track if Player Won the Game**
- While it was implied in the starter code that a player won the game once they reached the top of the screen, that code never actually indicated when a win occured and you could continue to move back down the screen and continue playing, essentially making it a game with no true way to win. To fix this, and make it so the player couldn't keep playing aimlessly after they won we added in functionality to track if a player won. To do this, we hierarchically mapped a win signal throughout our program through frog.vhd, leddec.vhd and up to  vga_top.vhd so the signal could be accessed at all levels of our project. A 1 meant the player won the game while a 0 meant that the game was still being played. Once a player got very close to the top of the screen we set the win flag to win to indicate a win. Furthermore, in the character drawing process we added an if statement to only draw the character when win was 0, so that the character would disappear once the game was won, which would signify to the player that the game was over. 

#### frog.vhd
```
-- IN FROG ENTITY
win_out   : OUT STD_LOGIC; -- added to track a win


SIGNAL win : STD_LOGIC := '0'; -- (1 = win 0 = no win)

-- added to assign signals to entity outputs
win_out <= win;

-- added to check for win condition
IF frog_y <= "00000011110" THEN -- <= 30 (top of screen reached)
	win <= '1'; -- set win flag to 1
END IF;

--in fdraw process win is used so character no longer appears once the game is won
IF (frog_dead = '0' AND win = '0') THEN -- only draw character when alive and game not won 
```

#### vga_top.vhd
```
SIGNAL S_win : STD_LOGIC; --added to track win

-- IN FROG COMPONENT
win_out: OUT STD_LOGIC; --added to track win

-- IN LEDDEC COMPONENT
 win : IN STD_LOGIC; --added to detect win (1 = win, 0 = no win)

-- IN PORT MAP FOR INSTANCE OF FROG
win_out => S_win, --added for win tracking

-- IN PORT MAP FOR INSTANCE OF LEDDEC
win => S_win,	--added for win tracking
```
#### leddec.vhd
```
-- IN LEDDEC ENTITY
win : IN STD_LOGIC; --added to track win

-- note within the LEDDEC file we used to win signal to determine whether to display the score (code shown in modification 2) or whether to display a win message (code shown in modification 6)
```

**6. GOOD JOB Lights Up On Nexys 7-Segment Display When Player Wins**
- A winning feedback feature was added to enhance the player’s experience by displaying a celebratory “GOOD JOB” message on the seven-segment displays when the win condition is met. In Leddec.vhd, the logic checks whether the win signal is active and then outputs specific 4-bit codes to the display driver based on the current digit being updated. Each digit corresponds to a segment pattern that forms the letters G-O-O-D-J-O-B across the available display positions. By assigning these coded values only when win = '1', the hardware automatically switches from showing the score to showing the message as soon as the player reaches the goal. This addition provides immediate visual feedback, making the game feel more complete.
#### Leddec.vhd
```
 dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0); --changed from 1 downto 0 to 2 downto 0 to make it 8 bits so could expand display to say good job when win

	data4 <= "1010" WHEN (win = '1' AND dig = "000") ELSE -- b 
		"0000" WHEN (win = '1' AND dig = "001") ELSE -- O
		"1101" WHEN (win = '1' AND dig = "010") ELSE -- J 
        "1011" WHEN (win = '1' AND dig = "011") ELSE -- d
        "0000" WHEN (win = '1' AND dig = "100") ELSE -- O
        "0000" WHEN (win = '1' AND dig = "101") ELSE -- O
        "1100" WHEN (win = '1' AND dig = "110") ELSE -- G

-- 7-segment decoder shows which part of the board digit to light up (0 = on, 1 = off)
                 --key for the bits: top, right top, right bottom, bottom, bottom-left, top-left, middle
    seg <= "0000001" WHEN data4 = "0000" ELSE -- 0
           "1001111" WHEN data4 = "0001" ELSE -- 1
           "0010010" WHEN data4 = "0010" ELSE -- 2
           "0000110" WHEN data4 = "0011" ELSE -- 3
           "1001100" WHEN data4 = "0100" ELSE -- 4
           "0100100" WHEN data4 = "0101" ELSE -- 5
           "0100000" WHEN data4 = "0110" ELSE -- 6
           "0001111" WHEN data4 = "0111" ELSE -- 7
           "0000000" WHEN data4 = "1000" ELSE -- 8
           "0000100" WHEN data4 = "1001" ELSE -- 9
           "1100000" WHEN data4 = "1010" ELSE -- b
           "1000010" WHEN data4 = "1011" ELSE -- D
           "0100001" WHEN data4 = "1100" ELSE -- G
           "1000111" WHEN data4 = "1101" ELSE -- J 
           "1111111";

- Digit enable (active low) (letting 7 of the digits light up) --> tells which digits to light up
    anode <= "11111110" WHEN dig = "000" ELSE --rightmost position
             "11111101" WHEN dig = "001" ELSE
             "11111011" WHEN dig = "010" ELSE
             "11110111" WHEN dig = "011" ELSE
             "11101111" WHEN dig = "100" ELSE
             "11011111" WHEN dig = "101" ELSE
             "10111111" WHEN dig = "110" ELSE --leftmost position (where the G is for good job)
             "11111111";
```

**7. Bottom Right Nexys Board LED Lights Up Green When Player Wins**
- A visual win indicator was added by connecting the board’s bottom-right green LED to the game’s win signal, providing an additional celebratory indicator when the player reaches the top of the screen. In frog.vhd, the LED output was created and directly assigned to the win flag, which becomes ‘1’ when the frog’s y-position reaches the top boundary. This output was then routed through the project hierarchy, first declared in the vga_topProject.vhd entity, then included in the FROG component, and mapped appropriately in the port connections. This way the win signal can be driven all the way out to the board hardware. The corresponding pin assignment was added in frogger.xdc to set LED signal to the correct physical pin. With this update, the LED lights up green as soon as the player wins, creating a simple but effective indictor of vicotory in addition to the "Good Job".
#### Frog.vhd
```
IN FROG ENTITY
LED: out std_logic; --added for our new output from board to code (bottom right led turns green when win)
---------------------------------------------------------------------------------------------------------

LED <= win; --added for green led when win

 IF frog_y <= "00000011110" THEN -- <= 30 (top of screen reached)
 	win <= '1'; -- set win flag to 1
END IF;
```

#### Frogger.xdc
```
#led (in bottom right of board) --> output
set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { LED }]; #IO_L18P_T2_A24_15 Sch=led[0] --> changed name to just LED since only using 1 dont need a vector
```

#### vga_top.vhd 
```
-- IN vga_top ENTITY 
LED: out std_logic; --added for new led output (bottom right led lights up green when win)

-- IN COMPONENT FROG 
LED: out std_logic; --added for led output (bottom right led lights up when win)

-- IN PORT MAP FOR FROG INSTANCE
LED => LED, --added for win game led
```

**8. Background Set Up To Resemble Roads And Grass**
- The starter code featured a simple black background for the game. To make the game better resemble crossy road we used stripes of green and dark gray to make the game background look like grass and roads. To achieve this, we created 5 new signals, each to represent a portion of our background. From bottom to top, we pictured the game being created with grass, road, grass, road, grass so we named the signals accordingly. Then we wrote a process to indicate for which rows of the screen each signal should be turned on for drawing. Note that the actual drawing and color process for all our graphics is mentioned in modification 12 below. The general positioning we chose is: 
- Grass: y < 100
- Grasss y > 480
- Grass: 220 < y < 280
- Road: 130 < y < 210
- Road: 290 < y < 420

Some gaps were left between the grass and roads because we were initially thinking about keeping rivers included in our background. However, we decided not to, so to resolve the positioning gaps easily we just assigned the default background to the same color as the grass in our color assignment process. 
#### Frog.vhd
```
-- added background signals to add different colors to different parts of background
	SIGNAL grass_top_on : STD_LOGIC; --grass on top of screen
	SIGNAL grass_bottom_on : STD_LOGIC; -- grass on bottom of screen
	SIGNAL grass_middle_on : STD_LOGIC; -- grass in the middle of the roads
	SIGNAL road1_on : STD_LOGIC;
	SIGNAL road2_on : STD_LOGIC;

----------------------------------------------------------------------------------------
-- Background detection processes
	PROCESS (pixel_row) IS
	BEGIN
		-- draw grass at top of screen
		IF pixel_row < "00001100100" THEN -- y < 100
			grass_top_on <= '1';
		ELSE
			grass_top_on <= '0';
		END IF;
		
		-- draw grass at bottom of screen
		IF pixel_row > "00111100000" THEN -- y > 480
			grass_bottom_on <= '1';
		ELSE
			grass_bottom_on <= '0';
		END IF;
		
		-- draw grass in middle of road
		IF pixel_row >= "00011011100" AND pixel_row <= "00100011000" THEN -- 220 < y < 280
			grass_middle_on <= '1';
		ELSE
			grass_middle_on <= '0';
		END IF;
		
		-- draw top road (y between 130 and 210)
		IF pixel_row >= "00010000010" AND pixel_row <= "00011010010" THEN -- 130 < y < 210
			road1_on <= '1';
		ELSE
			road1_on <= '0';
		END IF;
		
		-- draw bottom road
		IF pixel_row >= "00100100010" AND pixel_row <= "00110100100" THEN -- 290 < y < 420
			road2_on <= '1';
		ELSE
			road2_on <= '0';
		END IF;
	END PROCESS;
-------------------------------------------------------------------------------------------
-- in color assignment process
BEGIN
		-- Default background -> grass (green)
		red <= "0000";
		green <= "1000";
		blue <= "0000";
```

**9. Puddles Objects Created In Place of the River (Game Ends if Character Jumps in a Puddle)**
- Instead of keeping the river from our starter code in the game, we removed it and implemented a water feature to our game by creating 5 puddles. For each puddle we created a set of signals to represent the puddle width & height from the center of the puddle, the puddle location, and when the puddle should be drawn.
- Since we wanted the game to end when the character jumped in a puddle, we implemented collision logic that was similar to the starter code collision logic for the car objects. Essentially, we checked from each side (left, right, top, and bottom) whether or not the character was within the area of any puddle. If the character was inside the puddle area, the character was marked as dead so that the game ends.
- We created a process to draw the puddles into the game using an ellipse shape. To do this we tracked the current pixel row and column position as well as the center point of the puddle (x, y position) in our sensitivity list. We set our variables dx and dy equal to the current pixel's horizontal & vertical distance from the center of the puddle, respectively. Then we used the following ellipse equation: dx^2 * h^2 + dy^2 *w ^2 <= w^2 * h^2 to determine when the puddle should be drawn. Anytime the left hand side of the equation was less than or equal to the right hand side of the equation we set the puddle_on signal to 1 to signify the puddle should be drawn since the current pixel was within the shape of the puddle. Furthermore, when the left hand side was greater than the right hand side we set the puddle_on signal to 0 so that the puddle would not be drawn. Note that the color process for the puddles is mentioned in modification 12

#### Frog.vhd
```
-- Puddle signals (new addition --> 5 total) 
	CONSTANT puddle1_w : INTEGER := 40; -- puddle width
    CONSTANT puddle1_h : INTEGER := 30; -- puddle height
	SIGNAL puddle1_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00010011000"; -- (152) x position
	SIGNAL puddle1_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000110010"; -- (50) y position
	SIGNAL puddle1_on : STD_LOGIC; -- indicates whether puddle1 is over current pixel position
	
	CONSTANT puddle2_w : INTEGER := 35;
    CONSTANT puddle2_h : INTEGER := 28;
    SIGNAL puddle2_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "01010110000"; -- 688
	SIGNAL puddle2_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000111101"; -- 61
    SIGNAL puddle2_on : STD_LOGIC;
    
    CONSTANT puddle3_w : INTEGER := 42;
    CONSTANT puddle3_h : INTEGER := 32;
    SIGNAL puddle3_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00110010000"; -- 400
	SIGNAL puddle3_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00011110100"; -- 244
    SIGNAL puddle3_on : STD_LOGIC;
    
    CONSTANT puddle4_w : INTEGER := 38;
    CONSTANT puddle4_h : INTEGER := 29;
    SIGNAL puddle4_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "01010000000"; -- 640
	SIGNAL puddle4_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "01000001101"; -- 525
    SIGNAL puddle4_on : STD_LOGIC;
    
    CONSTANT puddle5_w : INTEGER := 40;
    CONSTANT puddle5_h : INTEGER := 31;
    SIGNAL puddle5_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00011001000"; -- 200
	SIGNAL puddle5_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "01000010110"; -- 534
    SIGNAL puddle5_on : STD_LOGIC;
--------------------------------------------------------------------------------------------------------------
 -- Collision detection for puddles (checks character collisions from right, left, bottom, and top edges)
 IF ((frog_x >= puddle1_x - puddle1_w) AND (frog_x <= puddle1_x + puddle1_w) AND
	(frog_y >= puddle1_y - puddle1_h) AND (frog_y <= puddle1_y + puddle1_h)) OR
	((frog_x >= puddle2_x - puddle2_w) AND (frog_x <= puddle2_x + puddle2_w) AND
	(frog_y >= puddle2_y - puddle2_h) AND (frog_y <= puddle2_y + puddle2_h)) OR
	((frog_x >= puddle3_x - puddle3_w) AND (frog_x <= puddle3_x + puddle3_w) AND
	(frog_y >= puddle3_y - puddle3_h) AND (frog_y <= puddle3_y + puddle3_h)) OR
	((frog_x >= puddle4_x - puddle4_w) AND (frog_x <= puddle4_x + puddle4_w) AND
	(frog_y >= puddle4_y - puddle4_h) AND (frog_y <= puddle4_y + puddle4_h)) OR
	((frog_x >= puddle5_x - puddle5_w) AND (frog_x <= puddle5_x + puddle5_w) AND
	(frog_y >= puddle5_y - puddle5_h) AND (frog_y <= puddle5_y + puddle5_h)) THEN

 --if collide with puddle, character dies
	frog_dead <= '1';
END IF;

---------------------------------------------------------------------------------------------------------------
--new addition: Puddle drawing logic
	-- Puddle 1 drawing logic 
	PROCESS (puddle1_x, puddle1_y, pixel_row, pixel_col)
	    VARIABLE dx, dy : INTEGER; --distances from center of shape
	    VARIABLE ellipse_lefteq : INTEGER; --will store result of left side of ellipse eqn
	BEGIN
		--drawing logic (puddles are ellipses)
	    dx := CONV_INTEGER(pixel_col) - CONV_INTEGER(puddle1_x);
	    dy := CONV_INTEGER(pixel_row) - CONV_INTEGER(puddle1_y);

	    -- Ellipse equation: (dx/w)^2 + (dy/h)^2 <= 1
	    -- rewritten version that avoids using division: dx^2 * h^2 + dy^2 *w ^2 <= w^2 * h^2
	    ellipse_lefteq := (dx * dx * puddle1_h * puddle1_h) + (dy * dy * puddle1_w * puddle1_w);

		-- if current pixel inside the ellipse (lhs eq <= rhs eq)... draw the puddle
	    IF ellipse_lefteq <= (puddle1_w * puddle1_w * puddle1_h * puddle1_h) THEN
	        puddle1_on <= '1';

		--otherwise dont draw the puddle
	    ELSE
	        puddle1_on <= '0';
	    END IF;
	END PROCESS;

	-- similar processes were written for puddles 2-5 
```

**10. Shapes Of Game Characters, Cars, and Obstacles (Rocks & Trees) Created**
- To make the game better resemble crossy road we wanted to modify our code to include characters and obstacles that were more involved than the standard shapes used in the starter code. We came up with the idea of using sprite ROMs to create more intricate shapes from the [2025 Spring Grid Escape Project](https://github.com/ashaligram04/Grid_Escape/blob/main/README.md). Note that this project also provided us with the general idea of how to format and implement these types of shapes into a VHDL project.
- We made 5 different game characters using 32 x 32 binary maps. 1s in the map signified to draw the shape while 0s in the map signified not to draw anything. Our first 3 characters made were a duck, a frog, and a pig. We chose these characters since they were all animals included in the actual crossy road game. Our last 2 characters made were a christmas tree and a pumpkin. We chose these characters since the crossy road game creates seasonal characters in the app around holiday times. Since we are in a holiday season, we thought the pumpkin and christmas tree could resemble holiday characters for halloween, thanksgiving, and christmas. For our car obstacles we also used a 32 x 32 binary map to create the shape of a 2D car. We used the same idea for our rock and tree obstacles but we made these maps 40 x 40. We made these a little bigger so our tree obstacles could be taller. However, we didn't want the rocks to be too big so we left a lot of blank space (0s) in that map. Constants to store the width and height of each binary map were also created to be used in the actual drawing process.
- Note that the drawing process for the trees and rocks is described in modification 9 and the drawing process for the game characters is described in modification 10.
- The drawing process for the car objects is shown in the second block of code below. For this process we kept the same logic from the starter code but just changed it to apply to our sprite ROM instead of the general square shape. To do this we checked if the current pixel was within the shape of the car's binary map. If it was, we then checked to see which digit of the binary sprite map the current pixel corresponded to. If it corresponded to a 1 we set the car_on signal to 1 to signify the car shape should be drawn and if it was set to a 0 we set the car_on signal to 0 to signify nothing needed to be drawn. Note that the color process for the cars is mentioned in modification 12.

#### Frog.vhd
```
--GAME CHARACTERS
	-- character sprite size 32 x 32
	CONSTANT CHARACTER_WIDTH : INTEGER := 32;
	CONSTANT CHARACTER_HEIGHT : INTEGER := 32;

	-- Duck sprite ROM (32x32)
	-- 1 = body, 0 = transparent/background
	TYPE duck_sprite_rom IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	CONSTANT duck_sprite : duck_sprite_rom := (
    "00000000000000000000000000000000", --  0
    "00000000000000000000000000000000", --  1
    "00000000000000111100000000000000", --  2 top of head
    "00000000000011111111000000000000", --  3 
    "00000000000111111111100000000000", --  4 
    "00000000001111111111110000000000", --  5 
    "00000000011111111111111000000000", --  6 
    "00000000111111111111111100000000", --  7 
    "00000001111111111111111110000000", --  8 
    "00000001111100011000111110000000", --  9 eye start
    "00000001111100011000111110000000", -- 10 eye row 2
    "00000001111100011000111110000000", -- 11 eyes end
    "00000011111111111111111111000000", -- 12  
    "00000011111110000001111111000000", -- 13 beak start
    "00000111111111000011111111100000", -- 14 beak row 2
    "00000111111111100111111111100000", -- 15 beak end
    "00001111111111111111111111110000", -- 16 body start
    "00001111111111111111111111110000", -- 17
    "00000111111111111111111111100000", -- 18 
    "00000111111111111111111111100000", -- 19
    "00000011111111111111111111000000", -- 20 
    "00000001111111111111111110000000", -- 21  
    "00000000111111111111111100000000", -- 22 body end
    "00000000111000000000001110000000", -- 23 feet start
    "00000000111000000000001110000000", -- 24 feet row 2
    "00000001110000000000000111000000", -- 25 feet end
    "00000000000000000000000000000000", -- 26 
    "00000000000000000000000000000000", -- 27 
    "00000000000000000000000000000000", -- 28 
    "00000000000000000000000000000000", -- 29 
    "00000000000000000000000000000000", -- 30 
    "00000000000000000000000000000000"  -- 31 
);

-- frog sprite ROM (32x32)
    TYPE frog_sprite_rom IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	CONSTANT frog_sprite : frog_sprite_rom := (
    "00000000000000000000000000000000", -- 0
    "00000011111110001111111000000000", -- 1 eyes top
    "00000110000011001100000110000000", -- 2 eyes circles
    "00000110000011001100000110000000", -- 3 eyes circles
    "00000110000011001100000110000000", -- 4 eyes circles
    "00000001111111000111111100000000", -- 5 eyes bottom
    "00000011111111111111111110000000", -- 6 head top
    "00000111111111111111111111000000", -- 7
    "00001111111111111111111111100000", -- 8
    "00011111110000000011111111100000", -- 9 mouth
    "00011111100000000001111111100000", --10 mouth
    "00011111100000000001111111100000", --11 mouth
    "00011111110000000011111111100000", --12 mouth
    "00001111111111111111111111111000", --13 head bottom
    "00011111111111111111111111111100", --14 start of body
    "00111111111111111111111111111110", --15
    "00111111111111111111111111111110", --16
    "01111111111111111111111111111111", --17 body widest
    "01111111111111111111111111111111", --18
    "01111111111111111111111111111111", --19
    "00111111111111111111111111111110", --20 
    "00111111111111111111111111111110", --21 
    "00011111111111111111111111111100", --22 
    "00001111111111111111111111111000", --23 body end
    "00000111000111100001111001110000", --24 legs and arms
    "00000111000111100001111001110000", --25 legs and arms
    "00000111000111100001111001110000", --26 legs and arms
    "00000000000000000000000000000000", --27
    "00000000000000000000000000000000", --28
    "00000000000000000000000000000000", --29
    "00000000000000000000000000000000", --30
    "00000000000000000000000000000000"  --31
);

-- pig sprite ROM (32x32)
TYPE pig_sprite_rom IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	CONSTANT pig_sprite : pig_sprite_rom := (
    "00000000001000000000100000000000", --  0
    "00000000011100000001110000000000", --  1 ears start
    "00000000011100000001110000000000", --  2
    "00000000111110000011111000000000", --  3 
    "00000000111111111111111100000000", --  4 ears end
    "00000001111111111111111110000000", --  5 top of head /body
    "00000011111111111111111111000000", --  6
    "00000011111111111111111111000000", --  7 
    "00000111111000011100001111100000", --  8 eyes row 1
    "00001111111000011100001111110000", --  9 eyes row 2
    "00001111111000011100001111110000", -- 10 eyes row 3
    "00011111111111111111111111111000", -- 11
    "00011111111111111111111111111000", -- 12
    "00111111111111111111111111111100", -- 13
    "00111111111110000000111111111100", -- 14 nose 
    "00111111111100110011011111111100", -- 15 nostrils 
    "00111111111110000000111111111100", -- 16 nose 
    "00111111111111111111111111111100", -- 17 
    "00111111111111111111111111111100", -- 18
    "00111111111111111111111111111100", -- 19
    "00111111111111111111111111111100", -- 20
    "00011111111111111111111111111000", -- 21
    "00001111111111111111111111110000", -- 22
    "00001111111111111111111111110000", -- 23
    "00000111111111111111111111100000", -- 24
    "00000011111111111111111111000000", -- 25
    "00000001111000000000011110000000", -- 26 legs
    "00000001111000000000011110000000", -- 27 legs
    "00000001111000000000011110000000", -- 28 legs
    "00000000000000000000000000000000", -- 29
    "00000000000000000000000000000000", -- 30
    "00000000000000000000000000000000" -- 31
);

-- christmas tree sprite ROM (32x32)
TYPE christmas_sprite_rom IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	CONSTANT christmas_sprite : christmas_sprite_rom := (
    "00000000000000010000000000000000", -- 0 top of tree layer 1
    "00000000000000111000000000000000", -- 1
    "00000000000001111100000000000000", -- 2
    "00000000000011111110000000000000", -- 3
    "00000000000111111111000000000000", -- 4
    "00000000001111111111100000000000", -- 5
    "00000000011111111111110000000000", -- 6
    "00000000111111111111111000000000", -- 7
    "00000001111111111111111100000000", -- 8
    "00000011111111111111111110000000", -- 9
    "00000111111111111111111111000000", -- 10
    "00001111111111111111111111100000", -- 11 
    "00011111111111111111111111110000", -- 12
    "00111111111111111111111111111000", -- 13 bottom of tree layer 1
    "00000000000001111100000000000000", -- 14 top of tree layer 2
    "00000000000011111110000000000000", -- 15
    "00000000000111111111000000000000", -- 16
    "00000000001111111111100000000000", -- 17
    "00000000011111111111110000000000", -- 18
    "00000000111111111111111000000000", -- 19
    "00000001111111111111111100000000", -- 20
    "00000011111111111111111110000000", -- 21
    "00000111111111111111111111000000", -- 22
    "00001111111111111111111111100000", -- 23
    "00011111111111111111111111110000", -- 24
    "00111111111111111111111111111000", -- 25 bottom of tree layer 2
    "00000000000000111110000000000000", -- 26 stump
    "00000000000000111110000000000000", -- 27 stump
    "00000000000000111110000000000000", -- 28 stump
    "00000000000000111110000000000000", -- 29 stump
    "00000000000000000000000000000000", -- 30
    "00000000000000000000000000000000" -- 31
);

-- Pumpkin sprite (32x32) 
TYPE pumpkin_sprite_rom IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(31 DOWNTO 0);

CONSTANT pumpkin_sprite : pumpkin_sprite_rom := (
	"00000000000000000000000000000000", -- 0
	"00000000000000000000000000000000", -- 1
	"00000000000000000000000000000000", -- 2
	"00000000000000000000000000000000", -- 3
	"00000000000111100000000000000000", -- 4 stem
	"00000000001111110000000000000000", -- 5 stem
	"00000000001111110000000000000000", -- 6 stem
	"00000000011111111000000000000000", -- 7 stem
	"00000000111111111100000000000000", -- 8 top of pumpkin
	"00000001111111111110000000000000", -- 9
	"00000011111111111111000000000000", -- 10
	"00000111111111111111100000000000", -- 11
	"00001111111111111111110000000000", -- 12
	"00011111111111111111111000000000", -- 13
	"00111111111111111111111100000000", -- 14
	"01111110011111111100111110000000", -- 15 eyes
	"01111100001111111000011110000000", -- 16 eyes
	"11111100001111111000011111000000", -- 17 eyes
	"11111000000111110000001111000000", -- 18 eyes
	"11111111111111111111111111000000", -- 19
	"11111111011111111101111111000000", -- 20 mouth
	"11111111101111111011111111000000", -- 21 mouth
	"11111111110000000111111111000000", -- 22 mouth
	"01111111111111111111111110000000", -- 23
	"01111111111111111111111110000000", -- 24
	"00111111111111111111111100000000", -- 25
	"00011111111111111111111000000000", -- 26
	"00001111111111111111110000000000", -- 27
	"00000111111111111111100000000000", -- 28
	"00000011111111111111000000000000", -- 29
	"00000001111111111110000000000000", -- 30 bottom of pumpkin
	"00000000000000000000000000000000" -- 31
);
---------------------------------------------------------------------------------------------
-- OBSTACLES
	-- Car sprite ROM  (32x32)
	CONSTANT CAR_WIDTH : INTEGER := 32;
	CONSTANT CAR_HEIGHT : INTEGER := 32;
	
	TYPE car_sprite_rom IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	CONSTANT car_sprite : car_sprite_rom := (
	"00000000000000000000000000000000", -- 0
	"00000000000000000000000000000000", -- 1
	"00000000000000000000000000000000", -- 2
	"00000000000000000000000000000000", -- 3
	"00000000000000000000000000000000", -- 4
	"00000000000000000000000000000000", -- 5
	"00000000111111111111000000000000", -- 6  roof
	"00000011111111111111110000000000", -- 7
	"00000111111111111111111000000000", -- 8
	"00001111111111111111111100000000", -- 9
	"00011110000000000000111110000000", -- 10 windshield
	"00111100000000000000011111000000", -- 11
	"00111000000000000000001111000000", -- 12 
	"01111000000000000000000111100000", -- 13
	"01110000000000000000000111100000", -- 14
	"11110000000000000000000011110000", -- 15 end windshield
	"11111111111111111111111111111100", -- 16 car body
	"11111111111111111111111111111100", -- 17
	"11111111111111111111111111111100", -- 18
	"11111111111111111111111111111100", -- 19
	"11111111111111111111111111111100", -- 20
	"11111111111111111111111111111100", -- 21
	"11111111111111111111111111111100", -- 22
	"11111111111111111111111111111100", -- 23
	"11111111111111111111111111111100", -- 24 end car body
	"11110011111111111111111100111100", -- 25 wheels start
	"11100011111111111111111100011100", -- 26
	"11000011111111111111111100001100", -- 27
	"00000111111100001111111100000000", -- 28 
	"00000111111100001111111100000000", -- 29
	"00000111111100001111111100000000", -- 30 wheels end
	"00000000000000000000000000000000" -- 31
);

	-- stationary obstacle sprites (40 x 40)
    TYPE sprite_rom IS ARRAY (0 TO 39) OF STD_LOGIC_VECTOR(39 DOWNTO 0);

    -- tree (40 x 40)
	CONSTANT tree_sprite : sprite_rom := (
    "0000000000000000000000000000000000000000", --  0
    "0000000000000000111110000000000000000000", --  1  top of leaves
    "0000000000000001111111000000000000000000", --  2
    "0000000000000011111111100000000000000000", --  3
    "0000000000000111111111110000000000000000", --  4
    "0000000000001111111111111000000000000000", --  5 
    "0000000000011111111111111100000000000000", --  6
    "0000000000111111111111111110000000000000", --  7
    "0000000001111111111111111111000000000000", --  8
    "0000000011111111111111111111100000000000", --  9 
    "0000000011111111111111111111100000000000", -- 10
    "0000000111111111111111111111110000000000", -- 11
    "0000000111111111111111111111110000000000", -- 12
    "0000000111111111111111111111110000000000", -- 13
    "0000000011111111111111111111100000000000", -- 14
    "0000000011111111111111111111100000000000", -- 15
    "0000000001111111111111111111000000000000", -- 16
    "0000000000111111111111111110000000000000", -- 17
    "0000000000011111111111111100000000000000", -- 18
    "0000000000001111111111111000000000000000", -- 19
    "0000000000000111111111110000000000000000", -- 20
    "0000000000000011111111100000000000000000", -- 21
    "0000000000000001111111000000000000000000", -- 22 bottom of leaves
    "0000000000000000011100000000000000000000", -- 23 trunk start
    "0000000000000000011100000000000000000000", -- 24 
    "0000000000000000011100000000000000000000", -- 25 
    "0000000000000000011100000000000000000000", -- 26
    "0000000000000000011100000000000000000000", -- 27
    "0000000000000000011100000000000000000000", -- 28
    "0000000000000000011100000000000000000000", -- 29
    "0000000000000000011100000000000000000000", -- 30
    "0000000000000000011100000000000000000000", -- 31
    "0000000000000000011100000000000000000000", -- 32
    "0000000000000000011100000000000000000000", -- 33
    "0000000000000000011100000000000000000000", -- 34
    "0000000000000000011100000000000000000000", -- 35
    "0000000000000000011100000000000000000000", -- 36 trunk end
    "0000000000000000000000000000000000000000", -- 37
    "0000000000000000000000000000000000000000", -- 38
    "0000000000000000000000000000000000000000" -- 39
);

	
	-- Rock (40x40) 
	CONSTANT rock_sprite : sprite_rom := (
    "0000000000000000000000000000000000000000", --  0
    "0000000000000000000000000000000000000000", --  1
    "0000000000000000000000000000000000000000", --  2
    "0000000000000000000000000000000000000000", --  3
    "0000000000000000000000000000000000000000", --  4
    "0000000000000011111110000000000000000000", --  5  top
    "0000000000001111111111110000000000000000", --  6
    "0000000000011111111111111000000000000000", --  7
    "0000000000111111111111111100000000000000", --  8
    "0000000001111111111111111110000000000000", --  9
    "0000000011111111111111111111000000000000", -- 10 
    "0000000011111111111111111111000000000000", -- 11
    "0000000111111111111111111111100000000000", -- 12
    "0000000111111111111111111111100000000000", -- 13
    "0000000111111111111111111111100000000000", -- 14
    "0000000011111111111111111111000000000000", -- 15
    "0000000011111111111111111111000000000000", -- 16
    "0000000001111111111111111110000000000000", -- 17
    "0000000000111111111111111100000000000000", -- 18
    "0000000000011111111111111000000000000000", -- 19
    "0000000000001111111111110000000000000000", -- 20
    "0000000000000011111110000000000000000000", -- 21 bottom
    "0000000000000000000000000000000000000000", -- 22
    "0000000000000000000000000000000000000000", -- 23
    "0000000000000000000000000000000000000000", -- 24
    "0000000000000000000000000000000000000000", -- 25
    "0000000000000000000000000000000000000000", -- 26
    "0000000000000000000000000000000000000000", -- 27
    "0000000000000000000000000000000000000000", -- 28
    "0000000000000000000000000000000000000000", -- 29
    "0000000000000000000000000000000000000000", -- 30
    "0000000000000000000000000000000000000000", -- 31
    "0000000000000000000000000000000000000000", -- 32
    "0000000000000000000000000000000000000000", -- 33
    "0000000000000000000000000000000000000000", -- 34
    "0000000000000000000000000000000000000000", -- 35
    "0000000000000000000000000000000000000000", -- 36
    "0000000000000000000000000000000000000000", -- 37
    "0000000000000000000000000000000000000000", -- 38
    "0000000000000000000000000000000000000000"  -- 39
);

--obstacle signals
	CONSTANT OBSTACLE_WIDTH : INTEGER := 40;
	CONSTANT OBSTACLE_HEIGHT : INTEGER := 40;
------------------------------------------------------------------------------
```

```
--Note this process was repreated for all 5 car objects with their respective signals being used
--CAR DRAWING (changed logic a bit to fit our project but took ideas from starter code)
	-- Car 1 drawing 
	c1draw : PROCESS (car1_x, car1_y, pixel_row, pixel_col) IS
		VARIABLE sprite_x, sprite_y : INTEGER;
	BEGIN
		-- Calculate position within sprite
		sprite_x := CONV_INTEGER(pixel_col) - CONV_INTEGER(car1_x) + (CAR_WIDTH/2);
		sprite_y := CONV_INTEGER(pixel_row) - CONV_INTEGER(car1_y) + (CAR_HEIGHT/2);

		-- if current pixel is within the shape of the car...
		IF (sprite_x >= 0 AND sprite_x < CAR_WIDTH) AND
		   (sprite_y >= 0 AND sprite_y < CAR_HEIGHT) THEN
			
			-- check to see what part of the binary sprite map corresponds to the current pixel 
			IF car_sprite(sprite_y)(CAR_WIDTH - 1 - sprite_x) = '1' THEN
				car1_on <= '1'; --draw shape if the binary map has a 1
			ELSE
				car1_on <= '0'; --dont draw anything if binary map is a 0 (empty space)
			END IF;
		-- otherwise dont draw car
		ELSE
			car1_on <= '0';
		END IF;
	END PROCESS;
```

**11. Trees and Rock Obstacles Drawn Into Game + Logic Created So Character Bounces Off These Objects**
- We added stationary tree and rock obstacles into our game to make the game more closely resemble crossy road. For each obstacle we created signals to represent its center (x, y position) and to represent when the obstacle should be drawn. The tree and rock drawing processes were almost identical with the only difference being which sprite ROM was assigned to be drawn. Essentially, the current pixel's horizontal and vertical distance from the center of the obstacle were calculated. If these distances were within the shape of the binary sprite map, the obstacle_on signal was assigned to be the value of the digit of the binary map that corresponded to the current pixel location. For all other cases, the obtacle_on signal was set to 0 to indicate that the shape shouldn't be drawn. Note the color process for these obstacles is mentioned in modification 12.
- To detect when the character collided with these objects, we implemented the same collision detection logic that we used for car collision. Note the logic for both of these collision detection algorithms was taken from the starter code, we just updated it to fit with our project. While our obstacles were 40x40 maps, not all of the shape was filled in with 1s. Therefore, to ensure the character would only collide when it actually touched the object we based our collision radius off of the constant, size, that the starter code had already created. Initally, we were going to keep testing values of size to figure out which worked best for our objects collision raidus, but the originally value of 8 ended up working well for our project so we just stuck with that number, which ended up making our collision radius a 16x16 box. Essentially, the collision logic just checks whether the game character is within the collision radius of the obstacle from any side (left, right, top, bottom). 

#### Frog.vhd
```
--obstacle signals (new additions --> 5 total) 

	-- tree
	SIGNAL obstacle1_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00110010000"; --400
	SIGNAL obstacle1_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000110010"; -- 50
	SIGNAL obstacle1_on : STD_LOGIC;

	--rock
	SIGNAL obstacle2_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00010100000"; --160
	SIGNAL obstacle2_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00011110110"; -- 246
	SIGNAL obstacle2_on : STD_LOGIC;

	-- tree
	SIGNAL obstacle3_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := "01001100100"; -- 612
	SIGNAL obstacle3_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00100010010"; -- 274
	SIGNAL obstacle3_on : STD_LOGIC;

	-- rock
	SIGNAL obstacle4_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := "01010110000"; -- 688
	SIGNAL obstacle4_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := "01000101000"; -- 552
	SIGNAL obstacle4_on : STD_LOGIC;

	-- tree
	SIGNAL obstacle5_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00001100100"; -- 100
	SIGNAL obstacle5_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := "01000100110"; -- 550
	SIGNAL obstacle5_on : STD_LOGIC;

-- added in for obstacles so when player hits it will revert to previous position
    SIGNAL prev_frog_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00110010000";
    SIGNAL prev_frog_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := "01001000100";
------------------------------------------------------------------------------------------------------------------------------
-- Obstacle 1 drawing (tree)
	PROCESS (obstacle1_x, obstacle1_y, pixel_row, pixel_col)
		VARIABLE sprite_x, sprite_y : INTEGER;
	BEGIN
		sprite_x := CONV_INTEGER(pixel_col) - CONV_INTEGER(obstacle1_x) + (OBSTACLE_WIDTH/2);
		sprite_y := CONV_INTEGER(pixel_row) - CONV_INTEGER(obstacle1_y) + (OBSTACLE_HEIGHT/2);

		--if current pixel is within range of object....draw the corresponding value (1 or 0) from the binary sprite map to draw the shape
		IF (sprite_x >= 0 AND sprite_x < OBSTACLE_WIDTH) AND (sprite_y >= 0 AND sprite_y < OBSTACLE_HEIGHT) THEN
			obstacle1_on <= tree_sprite(sprite_y)(OBSTACLE_WIDTH - 1 - sprite_x);
		--otherwise dont draw the shape
		ELSE
			obstacle1_on <= '0';
		END IF;
	END PROCESS;
	
	-- Obstacle 2 drawing (rock)
	PROCESS (obstacle2_x, obstacle2_y, pixel_row, pixel_col)
		VARIABLE sprite_x, sprite_y : INTEGER;
	BEGIN
		sprite_x := CONV_INTEGER(pixel_col) - CONV_INTEGER(obstacle2_x) + (OBSTACLE_WIDTH/2);
		sprite_y := CONV_INTEGER(pixel_row) - CONV_INTEGER(obstacle2_y) + (OBSTACLE_HEIGHT/2);

		IF (sprite_x >= 0 AND sprite_x < OBSTACLE_WIDTH) AND (sprite_y >= 0 AND sprite_y < OBSTACLE_HEIGHT) THEN
			obstacle2_on <= rock_sprite(sprite_y)(OBSTACLE_WIDTH - 1 - sprite_x);
		ELSE
			obstacle2_on <= '0';
		END IF;
	END PROCESS;
	
-- obstacles 3 & 5 were also trees that have a similar drawing process to obstacle 1
-- obstacle 4 was also a rock that has a similar drawing process to obstacle 2
-------------------------------------------------------------------------------------------------------------------------
-- inside mfrog process
--added these lines to update prev_frog positions everytime the character moves
	       prev_frog_x <= frog_x;
	       prev_frog_y <= frog_y;

-- added obstacle collision (blocks movement in the direction of the obstacle)
				--we used the size constant = 8 (from the starter code) as the collision radius for the cars and it worked well so we stuck with the 8 for the obstalce collision radius too
	       IF ((frog_x + 8 >= obstacle1_x - 8) AND (frog_x - 8 <= obstacle1_x + 8) AND
	           (frog_y + 8 >= obstacle1_y - 8) AND (frog_y - 8 <= obstacle1_y + 8)) OR
	          ((frog_x + 8 >= obstacle2_x - 8) AND (frog_x - 8 <= obstacle2_x + 8) AND
	           (frog_y + 8 >= obstacle2_y - 8) AND (frog_y - 8 <= obstacle2_y + 8)) OR
	          ((frog_x + 8 >= obstacle3_x - 8) AND (frog_x - 8 <= obstacle3_x + 8) AND
	           (frog_y + 8 >= obstacle3_y - 8) AND (frog_y - 8 <= obstacle3_y + 8)) OR
	          ((frog_x + 8 >= obstacle4_x - 8) AND (frog_x - 8 <= obstacle4_x + 8) AND
	           (frog_y + 8 >= obstacle4_y - 8) AND (frog_y - 8 <= obstacle4_y + 8)) OR
	          ((frog_x + 8 >= obstacle5_x - 8) AND (frog_x - 8 <= obstacle5_x + 8) AND
	           (frog_y + 8 >= obstacle5_y - 8) AND (frog_y - 8 <= obstacle5_y + 8)) THEN
			   
			   -- if collides set character back to their prevous position
	           frog_x <= prev_frog_x;
	           frog_y <= prev_frog_y;
	       END IF;
```

**12. Change Character using Switch 0, 1, 2, 3, 4 + Draw Selected Game Character**
- To draw the game character we kept the same logic as the starter code and just modified it to be applicable to our sprite ROMs rather than the general shape used by the starter code. Note that the color process for the characters is mentioned in modification 12.
- To incorporate changing characters based on switches 0-4, we first added the 5 lines that corresponded to switches 0-4 into our constraints file so that the switches could be used in our project. Note that we got this code from the master constraints file posted on the course GitHub. We mapped the switch inputs hierarchically through the project from frogger.xdc to frog.vhd to vga_top.vhd to ensure it was integrated properly into our project. Then in our fdraw process we assigned which sprite ROM to draw based on which switch was flipped upward. The characters and their corresponding switches are as follows
	- Duck -> switch 0
	- Frog -> switch 1
	- Pig -> switch 2
	- Christmas Tree -> switch 3
	- Pumpkin -> switch 4
- To keep the code more simple, we made it so if multiple switches were flipped up at the same time, the character selected would correspond to whichever switch flipped up had the highest value. For example, if all switches were flipped upward, the character would be the pumpkin since 4 is the highest number flipped up. Similarly, we made it so if all switches were flipped down, the game character would default to the duck. By doing this, we ensured a character was always on the screen even if the "one switch up at a time" rule wasn't followed.

#### Frog.vhd
```
-- IN FROG ENTITY
sw : IN std_logic_vector(4 downto 0) --added as our new input from board to code (switches for changing character)
----------------------------------------------------------------------------------------------------------------------
-- Process to draw game character sprite (changed most logic but built off foundation of starter code)
	fdraw : PROCESS (frog_x, frog_y, pixel_row, pixel_col, frog_dead, win, sw) IS --added sw into sensitivity list
		VARIABLE sprite_x, sprite_y : INTEGER; -- added integer variables to store x and y position 
	BEGIN
	    IF (frog_dead = '0' AND win = '0') THEN -- only draw character when alive and game not won 
			
	        -- Calculate current pixel position within the sprite
				--frog_x and frog_y represent the center of the game character
				--character_width /2 and character_height /2 are added to track pixel mapping so that the top left corner of the sprite will be 0 and so on
	        sprite_x := CONV_INTEGER(pixel_col) - CONV_INTEGER(frog_x) + (CHARACTER_WIDTH/2); 
	        sprite_y := CONV_INTEGER(pixel_row) - CONV_INTEGER(frog_y) + (CHARACTER_HEIGHT/2);

	        -- Check if current pixel position is within sprite boundary
	        IF (sprite_x >= 0 AND sprite_x < CHARACTER_WIDTH) AND
	           (sprite_y >= 0 AND sprite_y < CHARACTER_HEIGHT) THEN
				
	            -- assign character based on which switches are up 
				--character type (row, column) draws the sprite based on the 1s and 0s from the binary mapping (1 = draw, 0 = dont draw)
	            IF sw(4) = '1' THEN
                    frog_on <= pumpkin_sprite(sprite_y)(CHARACTER_WIDTH - 1 - sprite_x);
                ELSIF sw(3) = '1' THEN
                    frog_on <= christmas_sprite(sprite_y)(CHARACTER_WIDTH - 1 - sprite_x);
                ELSIF sw(2) = '1' THEN
                    frog_on <= pig_sprite(sprite_y)(CHARACTER_WIDTH - 1 - sprite_x);
                ELSIF sw(1) = '1' THEN
                    frog_on <= frog_sprite(sprite_y)(CHARACTER_WIDTH - 1 - sprite_x);
                ELSE
                frog_on <= duck_sprite(sprite_y)(CHARACTER_WIDTH - 1 - sprite_x);
            END IF;
			-- dont draw frog
	        ELSE
	            frog_on <= '0';
	        END IF;
		ELSE
			frog_on <= '0';
		END IF;
	END PROCESS;
```
#### frogger.xdc
```
#switches 0-4 --> inputs 
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { sw[0] }]; #IO_L24N_T3_RS0_15 Sch=sw[0]
set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports { sw[1] }]; #IO_L3N_T0_DQS_EMCCLK_14 Sch=sw[1]
set_property -dict { PACKAGE_PIN M13   IOSTANDARD LVCMOS33 } [get_ports { sw[2] }]; #IO_L6N_T0_D08_VREF_14 Sch=sw[2]
set_property -dict { PACKAGE_PIN R15   IOSTANDARD LVCMOS33 } [get_ports { sw[3] }]; #IO_L13N_T2_MRCC_14 Sch=sw[3]
set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { sw[4] }]; #IO_L12N_T1_MRCC_14 Sch=sw[4]
```
### vga_top.vhd
```
-- IN VGA_TOP ENTITY
sw : IN STD_LOGIC_VECTOR(4 DOWNTO 0) -- added for new input: switches 0-4 allow user to switch characters

-- IN FROG COMPONENT
sw: IN STD_LOGIC_VECTOR(4 DOWNTO 0) -- added for switches (to change character)

-- IN PORT MAP OF FROG INSTANCE
sw => sw --added for switches for character changes
```

**13. Code Written To Ensure Graphic Display Layers Show Up Correctly**
- To ensure all our graphics showed up in the right layout with the right colors we added in a process that assigns colors to our different elements based on priority. The first colors assigned were the background since we wanted our other elements to be drawn on top of the background. The last colors assigned were for the game character since we wanted that to override anything else on the screen. We used 4-bit RGB codes to assign colors to different objects. We started by assigning the default background color to green to resemble the grass. Then we assigned all the objects to the following colors in the following order:
	- roads: dark gray
	- puddles: blue
	- trees: dark green
	- rocks: gray
	- coins: gold
	- cars: red, blue, purple, orange, white (each car was a different color)
	- game character: (yellow for duck, green for frog, pink for pig, green for christmas tree, orange for pumpkin)
- Note that we used the object_on signals to indicate when a specific color should be drawn. In other words the color was only selected if our program indicated that the given object was intended to be drawn at the current pixel.
#### Frog.vhd
```
-- Color assignments with priority (i.e: game character will always show up over the background) 
	-- Order (most to least important): game character -> cars -> coins -> obstacles -> puddles -> background
	PROCESS (frog_on, car1_on, car2_on, car3_on, car4_on, car5_on, 
	         coin1_on, coin2_on, coin3_on, puddle1_on, puddle2_on, puddle3_on, puddle4_on, puddle5_on,
	         obstacle1_on, obstacle2_on, obstacle3_on, obstacle4_on, obstacle5_on,
	         grass_top_on, grass_bottom_on, grass_middle_on, road1_on, road2_on)
	BEGIN
		-- Default background -> grass (green)
		red <= "0000";
		green <= "1000";
		blue <= "0000";

		--general logic: if the object_on signal is 1 it indicates the object should be drawn so assign the correct color of the object to be used whenever object_on is 1
		
		-- Roads (dark gray)
		IF road1_on = '1' OR road2_on = '1' THEN
			red <= "0011";
			green <= "0011";
			blue <= "0011";
		END IF;
		
		-- Puddles (blue)
		IF puddle1_on = '1' OR puddle2_on = '1' OR puddle3_on = '1' OR puddle4_on = '1' OR puddle5_on = '1' THEN
			red <= "0001";
			green <= "0110";
			blue <= "1111";
		END IF;
		
		-- Obstacles -> trees (dark green) rocks (light gray)
		--trees
		IF obstacle1_on = '1' OR obstacle3_on = '1' OR obstacle5_on = '1' THEN
			red <= "0010";
			green <= "0110";
			blue <= "0010";
		--rocks
		ELSIF obstacle2_on = '1' OR obstacle4_on = '1' THEN
			red <= "1010";
			green <= "1010";
			blue <= "1010";
		END IF;
		
		-- Coins (gold)
		IF coin1_on = '1' OR coin2_on = '1' OR coin3_on = '1' THEN
			red <= "1111";
			green <= "1100";
			blue <= "0000";
		END IF;
		
		-- Cars (different colors for each)
		IF car1_on = '1' THEN
			-- red
			red <= "1111";
			green <= "0000";
			blue <= "0000";
		ELSIF car2_on = '1' THEN
			-- blue
			red <= "0000";
			green <= "0000";
			blue <= "1111";
		ELSIF car3_on = '1' THEN
			-- purple
			red <= "1100";
			green <= "0000";
			blue <= "1100";
		ELSIF car4_on = '1' THEN
			-- orange
			red <= "1111";
			green <= "0110";
			blue <= "0000";
		ELSIF car5_on = '1' THEN
			-- white
			red <= "1111";
			green <= "1111";
			blue <= "1111";
		END IF;
		
		-- game character (different depending on character)
		IF frog_on = '1' THEN
			
			--pumpkin --> orange
	       IF sw(4) = '1' THEN
		      red <= "1111";
		      green <= "1000";
		      blue <= "0000";

			--christmas tree --> green
	       ELSIF sw(3) = '1' THEN
		      red <= "0010";
		      green <= "1100";
		      blue <= "0010";

			-- pig --> pink
	       ELSIF sw(2) = '1' THEN
		      red <= "1111";
		      green <= "1000";
		      blue <= "1000";

			-- frog --> light green
	       ELSIF sw(1) = '1' THEN
		      red <= "0100";
		      green <= "1111";
		      blue <= "0100";

			-- duck --> yellow
	       ELSE
		      red <= "1111";
		      green <= "1111";
		      blue <= "0110";
	       END IF;
        END IF;
	END PROCESS;
```


## Development Process

#### Development Timeline
**Week of 11/13**
- Finished brainstorming concepts and goals for project
- Investigated starter code (Played around with previous project)
	- Found what we liked and wanted to fix <br>

**Week of 11/17**
- Added in new game functionality (wrap around screen, changing jumping instead of gliding)
- Finished up most of graphics (grass & roads for background, puddles, cars, duck character)
- Added in new scoring, made it possible to win the game + made a good job sign to track win when get to top of screen
 <br>

**Week of 11/24**
- Added in obstacles (trees and rocks to game)
- Added better comments to code for readability <br>

**Week of 12/1**
- Added frog, pig, christmas tree, & pumpkin characters + implemented changing characters using switches
- Added bottom right LED lighting up green when win is accomplished
- Completed code portion of project
- Began outlining Github

**Week of 12/8**
- Cleaned up code + comments
- Finished Github repository

#### Responsibilities
**Kyra**
1.  Replaced Gliding Character Movement With Hopping
2. Scoring Changed To +1 For Each New Hop Forward & +10 For Each Coin Collected
3. Created Wrap Around Feature When Character Reaches A Screen Edge
4. Car Speed Varies (not every object moves at same speed)
5. Added Functionality to Track if Player Won the Game
6. GOOD JOB Lights Up On Nexys 7-Segment Display When Player Wins
7. Bottom Right Nexys Board LED Lights Up Green When Player Wins

**Arden** <br>
8. Background Set Up To Resemble Roads And Grass <br>
9. Puddles Objects Created In Place of the River (Game Ends if Character Jumps in a Puddle) <br>
10. Shapes Of Game Characters, Cars, and Obstacles (Rocks & Trees) Created <br>
11. Trees and Rock Obstacles Drawn Into Game + Logic Created So Character Bounces Off These Objects <br>
12. Change Character using Switch 0, 1, 2, 3, 4 + Draw Selected Game Character <br>
13. Code Written To Ensure Graphic Display Layers Show Up Correctly <br>

#### Difficulties Encountered
1. Making our board display a win message
	- We initially wanted our board to say "win" when the player won the game. However, when we actually looked at the 7 segment display we realized we couldn't make a W. To solve this issue, we thought of other words/phrases that could signify a win that had letters that could be created on the 7 segment display. We ended up using "GOOD JOB" since all these letters were able to be created. <br>
2. Figuring out how to incorporate a water element into our game
	- The classic crossy road game has a river where the character can jump across moving logs to safely cross it. We were having difficulties implementing the moving logs for the character to cross safely while still making it so if they touched the water they would die. Because of this we tried to implement just a stationary river with a bridge to get across it, but we weren't please with how it looked. Therefore, to still add some kind of water element we removed the river and switched it to puddles, which were more visually pleasing. <br>
3. Designing our game characters
	- Since we used binary maps to create the shape of our characters, it was hard to add a ton of detail to them to make them resemble what they were supposed to be. To deal with this, we designed all the characters from a front-facing viewpoint and just did a simple recognizable shape outline and face. <br>
4. Adding new hardware inputs
	- One of the requirements for this project was if using starting code, add at least one new input & one new output from the Nexys board to the project code to demonstrate an understanding of modifying ports. Since all the buttons were used in our starter code, we had difficulty figuring out what new input we could add to our game that made sense. We ended up choosing to add the switches as inputs and implement a character switching feature to resolve this. <br>
5. Making score add 1 for every new hop forward
	- Initially when we added logic for adding 1 to score every time the character hops forward we didn't account for the fact that if you hopped backward then forward again the score would still increase by 1. This left a bug where players could get an infinite score by just hopping backward and forward over and over again. To fix this, we created a signal to track the furthest forward position that the character had crossed. Then we ensured the score would only increase by 1 if the character had hopped to a forward position that was further than any forward progess they had previously made. 

