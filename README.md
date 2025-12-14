# CPE487 Project
## Crossy Road
![CrossyRoadImage](images/CrossyRoadBaseImage.jpg)

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

