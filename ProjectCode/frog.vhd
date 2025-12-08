
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- entity declaration
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

ARCHITECTURE Behavioral OF frog IS
 -- signals and variables for the game character
	CONSTANT size  : INTEGER := 8; -- sets size of sprite
	SIGNAL frog_on : STD_LOGIC; -- indicates whether frog is over current pixel position
	SIGNAL frog_dead : STD_LOGIC := '0'; -- 1 means frog died due to obstacle crash
	SIGNAL win : STD_LOGIC := '0'; -- (1 = win 0 = no win)

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
	
	--sprite additions for graphics: 

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

	
-- signals and variables for cars (was in starter code --> 5 total)
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


    --obstacle signals (new additions --> 5 total) 
	CONSTANT OBSTACLE_WIDTH : INTEGER := 40;
	CONSTANT OBSTACLE_HEIGHT : INTEGER := 40;

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

	-- Score signals
	SIGNAL s_score : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000"; --changed from 1 downto 0 to 7 downto 0 to ensure high enough scoring could be stored
	Signal max_forward_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := "01001000100"; -- added to track max forward position for scoring (starts at 580) --> so you cant get more points by jumping backward then forward again
	
	-- Coin signals --> from starter code
	CONSTANT coin_size : INTEGER := 10; -- size of coin set
	SIGNAL coin1_on : STD_LOGIC := '0'; -- indicates whether coin1 is over current pixel position
	SIGNAL coin1_collected : STD_LOGIC := '0'; -- coin flag to track whether player touched coin
    SIGNAL coin1_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00110010000"; -- (400) x position
	SIGNAL coin1_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00101011110"; -- (350) y position
	
	SIGNAL coin2_on : STD_LOGIC := '0';
	SIGNAL coin2_collected : STD_LOGIC := '0';
	SIGNAL coin2_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00011100110"; -- 230
	SIGNAL coin2_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00011001000"; -- 200
	
	SIGNAL coin3_on : STD_LOGIC := '0';
	SIGNAL coin3_collected : STD_LOGIC := '0';
	SIGNAL coin3_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "01000111111"; -- 575
	SIGNAL coin3_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00010100000"; -- 160
	
	-- added background signals to add different colors to different parts of background
	SIGNAL grass_top_on : STD_LOGIC; --grass on top of screen
	SIGNAL grass_bottom_on : STD_LOGIC; -- grass on bottom of screen
	SIGNAL grass_middle_on : STD_LOGIC; -- grass in the middle of the roads
	SIGNAL road1_on : STD_LOGIC;
	SIGNAL road2_on : STD_LOGIC;

	-- added in for obstacles so when player hits it will revert to previous position
    SIGNAL prev_frog_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00110010000";
    SIGNAL prev_frog_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := "01001000100";

BEGIN
	-- added to assign signals to entity outputs
	score <= s_score; 
	win_out <= win;
	LED <= win; --added for green led when win
	
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
		
	-- Process to move frog once every frame (game logic) (changed most of this logic + added stuff but built off starter code foundation)
	mfrog : PROCESS
	BEGIN
	   WAIT UNTIL rising_edge(v_sync);
	   
	   IF reset = '1' THEN
	       -- Reset the game
	       frog_x <= "00110010000"; -- 400 starting x position
           frog_y <= "01001000100"; -- 580 starting y position
           frog_dead <= '0';
           win <= '0';
           s_score <= "00000000";
           max_forward_y <= "01001000100";
           coin1_collected <= '0';
           coin2_collected <= '0';
           coin3_collected <= '0';
           up_last <= '0';
           down_last <= '0';
           left_last <= '0';
           right_last <= '0';
	   ELSIF frog_dead = '0' AND win = '0' THEN
		   -- game is currently being played
		   
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
	       
	       
	       -- added screen wrapping for left/right boundaries so character cant disappear off sides of screen
	       IF frog_x > "01110000100" THEN -- > 900 --edge of right side of screen
	           frog_x <= "00000001010"; -- wrap to 10 (wrap to edge of left side of screen)
	       END IF;
	       IF frog_x < "00000001010" THEN -- < 10 (edge of left side of screen)
	           frog_x <= "01110000100"; -- wrap to 900 (wrap to edge of right side of screen)
	       END IF;
	       
	       -- added to check for win condition
	       IF frog_y <= "00000011110" THEN -- <= 30 (top of screen reached)
	           win <= '1'; -- set win flag to 1
	       END IF;
	       
	       -- Collision detection for cars and puddles (checks character collisions from right, left, bottom, and top edges)
			   	-- from starter code size was initialized to 8 --> 
			   		-- just kinda picked & tested this value and it worked for collision radius since our sprites dont always take up all 32 bits of space so this prevents early collision
	       IF ((frog_x + size >= car1_x - size) AND (frog_x <= car1_x + size + size) AND
	           (frog_y + size >= car1_y - size) AND (frog_y <= car1_y + size + size)) OR
	          ((frog_x + size >= car2_x - size) AND (frog_x <= car2_x + size + size) AND
	           (frog_y + size >= car2_y - size) AND (frog_y <= car2_y + size + size)) OR
	          ((frog_x + size >= car3_x - size) AND (frog_x <= car3_x + size + size) AND
	           (frog_y + size >= car3_y - size) AND (frog_y <= car3_y + size + size)) OR
	          ((frog_x + size >= car4_x - size) AND (frog_x <= car4_x + size + size) AND
	           (frog_y + size >= car4_y - size) AND (frog_y <= car4_y + size + size)) OR
	          ((frog_x + size >= car5_x - size) AND (frog_x <= car5_x + size + size) AND
	           (frog_y + size >= car5_y - size) AND (frog_y <= car5_y + size + size)) OR
	          ((frog_x >= puddle1_x - puddle1_w) AND (frog_x <= puddle1_x + puddle1_w) AND
	           (frog_y >= puddle1_y - puddle1_h) AND (frog_y <= puddle1_y + puddle1_h)) OR
	          ((frog_x >= puddle2_x - puddle2_w) AND (frog_x <= puddle2_x + puddle2_w) AND
	           (frog_y >= puddle2_y - puddle2_h) AND (frog_y <= puddle2_y + puddle2_h)) OR
	          ((frog_x >= puddle3_x - puddle3_w) AND (frog_x <= puddle3_x + puddle3_w) AND
	           (frog_y >= puddle3_y - puddle3_h) AND (frog_y <= puddle3_y + puddle3_h)) OR
	          ((frog_x >= puddle4_x - puddle4_w) AND (frog_x <= puddle4_x + puddle4_w) AND
	           (frog_y >= puddle4_y - puddle4_h) AND (frog_y <= puddle4_y + puddle4_h)) OR
	          ((frog_x >= puddle5_x - puddle5_w) AND (frog_x <= puddle5_x + puddle5_w) AND
	           (frog_y >= puddle5_y - puddle5_h) AND (frog_y <= puddle5_y + puddle5_h)) THEN

			   --if collide with car or puddle, character dies
	           frog_dead <= '1';
	       END IF;
			   
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

	       IF coin2_collected = '0' THEN
	           IF (frog_x + size >= coin2_x - coin_size) AND (frog_x <= coin2_x + coin_size + size) AND
	              (frog_y + size >= coin2_y - coin_size) AND (frog_y <= coin2_y + coin_size + size) THEN
	               coin2_collected <= '1';
	               IF s_score <= "11110101" THEN -- <= 245
	                   s_score <= s_score + 10;
	               END IF;
	           END IF;
	       END IF;
	       
	       IF coin3_collected = '0' THEN
	           IF (frog_x + size >= coin3_x - coin_size) AND (frog_x <= coin3_x + coin_size + size) AND
	              (frog_y + size >= coin3_y - coin_size) AND (frog_y <= coin3_y + coin_size + size) THEN
	               coin3_collected <= '1';
	               IF s_score <= "11110101" THEN -- <= 245
	                   s_score <= s_score + 10;
	               END IF;
	           END IF;
	       END IF;
	   END IF;
	END PROCESS;


	--Coing drawing logic (took ideas from starter code just changed a bit to fit our project) 
		   -- we split coin drawing + collection up where starter code did it all together in the drawing process
	-- Coin 1 drawing logic
	PROCESS (coin1_x, coin1_y, pixel_row, pixel_col, coin1_collected)
	    VARIABLE dx, dy : INTEGER;
	    VARIABLE distance_squared : INTEGER;
	BEGIN
		--this drawing logic is from frogger starter code
	    IF coin1_collected = '0' THEN
	        dx := CONV_INTEGER(pixel_col) - CONV_INTEGER(coin1_x);
	        dy := CONV_INTEGER(pixel_row) - CONV_INTEGER(coin1_y);
	        distance_squared := (dx * dx) + (dy * dy);

			-- if current pixel is within the shape of the coin... draw it
	        IF distance_squared <= (coin_size * coin_size) THEN
	            coin1_on <= '1';
			-- otherwise dont draw the coin
	        ELSE
	            coin1_on <= '0';
	        END IF;
		-- if the coin was already collected turn it off so it disappears
	    ELSE
	        coin1_on <= '0';
	    END IF;
	END PROCESS;
	
	-- Coin 2 drawing logic
	PROCESS (coin2_x, coin2_y, pixel_row, pixel_col, coin2_collected)
	    VARIABLE dx, dy : INTEGER;
	    VARIABLE distance_squared : INTEGER;
	BEGIN
	    IF coin2_collected = '0' THEN
	        dx := CONV_INTEGER(pixel_col) - CONV_INTEGER(coin2_x);
	        dy := CONV_INTEGER(pixel_row) - CONV_INTEGER(coin2_y);
	        distance_squared := (dx * dx) + (dy * dy);
	        
	        IF distance_squared <= (coin_size * coin_size) THEN
	            coin2_on <= '1';
	        ELSE
	            coin2_on <= '0';
	        END IF;
	    ELSE
	        coin2_on <= '0';
	    END IF;
	END PROCESS;
	
	-- Coin 3 drawing logic
	PROCESS (coin3_x, coin3_y, pixel_row, pixel_col, coin3_collected)
	    VARIABLE dx, dy : INTEGER;
	    VARIABLE distance_squared : INTEGER;
	BEGIN
	    IF coin3_collected = '0' THEN
	        dx := CONV_INTEGER(pixel_col) - CONV_INTEGER(coin3_x);
	        dy := CONV_INTEGER(pixel_row) - CONV_INTEGER(coin3_y);
	        distance_squared := (dx * dx) + (dy * dy);
	        
	        IF distance_squared <= (coin_size * coin_size) THEN
	            coin3_on <= '1';
	        ELSE
	            coin3_on <= '0';
	        END IF;
	    ELSE
	        coin3_on <= '0';
	    END IF;
	END PROCESS;

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

	PROCESS (puddle2_x, puddle2_y, pixel_row, pixel_col)
	    VARIABLE dx, dy : INTEGER;
	    VARIABLE ellipse_lefteq : INTEGER;
	BEGIN
	    dx := CONV_INTEGER(pixel_col) - CONV_INTEGER(puddle2_x);
	    dy := CONV_INTEGER(pixel_row) - CONV_INTEGER(puddle2_y);
	    ellipse_lefteq := (dx*dx*puddle2_h*puddle2_h) + (dy*dy*puddle2_w*puddle2_w);
	    
	    IF ellipse_lefteq <= (puddle2_w*puddle2_w*puddle2_h*puddle2_h) THEN
	        puddle2_on <= '1';
	    ELSE
	        puddle2_on <= '0';
	    END IF;
	END PROCESS;
	
	-- Puddle 3 drawing logic
	PROCESS (puddle3_x, puddle3_y, pixel_row, pixel_col)
	    VARIABLE dx, dy : INTEGER;
	    VARIABLE ellipse_lefteq : INTEGER;
	BEGIN
	    dx := CONV_INTEGER(pixel_col) - CONV_INTEGER(puddle3_x);
	    dy := CONV_INTEGER(pixel_row) - CONV_INTEGER(puddle3_y);
	    ellipse_lefteq := (dx*dx*puddle3_h*puddle3_h) + (dy*dy*puddle3_w*puddle3_w);
	    
	    IF ellipse_lefteq <= (puddle3_w*puddle3_w*puddle3_h*puddle3_h) THEN
	        puddle3_on <= '1';
	    ELSE
	        puddle3_on <= '0';
	    END IF;
	END PROCESS;
	
	-- Puddle 4 drawing logic
	PROCESS (puddle4_x, puddle4_y, pixel_row, pixel_col)
	    VARIABLE dx, dy : INTEGER;
	    VARIABLE ellipse_lefteq : INTEGER;
	BEGIN
	    dx := CONV_INTEGER(pixel_col) - CONV_INTEGER(puddle4_x);
	    dy := CONV_INTEGER(pixel_row) - CONV_INTEGER(puddle4_y);
	    ellipse_lefteq := (dx*dx*puddle4_h*puddle4_h) + (dy*dy*puddle4_w*puddle4_w);
	    
	    IF ellipse_lefteq <= (puddle4_w*puddle4_w*puddle4_h*puddle4_h) THEN
	        puddle4_on <= '1';
	    ELSE
	        puddle4_on <= '0';
	    END IF;
	END PROCESS;
	
	-- Puddle 5 drawing logic
	PROCESS (puddle5_x, puddle5_y, pixel_row, pixel_col)
	    VARIABLE dx, dy : INTEGER;
	    VARIABLE ellipse_lefteq : INTEGER;
	BEGIN
	    dx := CONV_INTEGER(pixel_col) - CONV_INTEGER(puddle5_x);
	    dy := CONV_INTEGER(pixel_row) - CONV_INTEGER(puddle5_y);
	    ellipse_lefteq := (dx*dx*puddle5_h*puddle5_h) + (dy*dy*puddle5_w*puddle5_w);
	    
	    IF ellipse_lefteq <= (puddle5_w*puddle5_w*puddle5_h*puddle5_h) THEN
	        puddle5_on <= '1';
	    ELSE
	        puddle5_on <= '0';
	    END IF;
	END PROCESS;

	-- new addition: obstcale drawing logic		
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
	
	-- Obstacle 3 drawing (tree)
	PROCESS (obstacle3_x, obstacle3_y, pixel_row, pixel_col)
		VARIABLE sprite_x, sprite_y : INTEGER;
	BEGIN
		sprite_x := CONV_INTEGER(pixel_col) - CONV_INTEGER(obstacle3_x) + (OBSTACLE_WIDTH/2);
		sprite_y := CONV_INTEGER(pixel_row) - CONV_INTEGER(obstacle3_y) + (OBSTACLE_HEIGHT/2);
		IF (sprite_x >= 0 AND sprite_x < OBSTACLE_WIDTH) AND (sprite_y >= 0 AND sprite_y < OBSTACLE_HEIGHT) THEN
			obstacle3_on <= tree_sprite(sprite_y)(OBSTACLE_WIDTH - 1 - sprite_x);
		ELSE
			obstacle3_on <= '0';
		END IF;
	END PROCESS;
	
	-- Obstacle 4 drawing (rock)
	PROCESS (obstacle4_x, obstacle4_y, pixel_row, pixel_col)
		VARIABLE sprite_x, sprite_y : INTEGER;
	BEGIN
		sprite_x := CONV_INTEGER(pixel_col) - CONV_INTEGER(obstacle4_x) + (OBSTACLE_WIDTH/2);
		sprite_y := CONV_INTEGER(pixel_row) - CONV_INTEGER(obstacle4_y) + (OBSTACLE_HEIGHT/2);
		IF (sprite_x >= 0 AND sprite_x < OBSTACLE_WIDTH) AND (sprite_y >= 0 AND sprite_y < OBSTACLE_HEIGHT) THEN
			obstacle4_on <= rock_sprite(sprite_y)(OBSTACLE_WIDTH - 1 - sprite_x);
		ELSE
			obstacle4_on <= '0';
		END IF;
	END PROCESS;
	
	-- Obstacle 5 drawing (tree)
	PROCESS (obstacle5_x, obstacle5_y, pixel_row, pixel_col)
		VARIABLE sprite_x, sprite_y : INTEGER;
	BEGIN
		sprite_x := CONV_INTEGER(pixel_col) - CONV_INTEGER(obstacle5_x) + (OBSTACLE_WIDTH/2);
		sprite_y := CONV_INTEGER(pixel_row) - CONV_INTEGER(obstacle5_y) + (OBSTACLE_HEIGHT/2);
		IF (sprite_x >= 0 AND sprite_x < OBSTACLE_WIDTH) AND (sprite_y >= 0 AND sprite_y < OBSTACLE_HEIGHT) THEN
			obstacle5_on <= tree_sprite(sprite_y)(OBSTACLE_WIDTH - 1 - sprite_x);
		ELSE
			obstacle5_on <= '0';
		END IF;
	END PROCESS;

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

	-- CAR MOVEMENT (kept logic same as starter code just changed speeds so different cars would move at different speeds)
	-- Car 1 movement 
	mcar1 : PROCESS
	BEGIN
		WAIT UNTIL rising_edge(v_sync);
		IF car1_x + size >= 900 THEN
			car1_x_motion <= "11111111101"; -- -3 (speed)
		ELSIF car1_x <= size THEN
			car1_x_motion <= "00000000011"; -- 3 (speed)
		END IF;
		car1_x <= car1_x + car1_x_motion; -- calculates next car position
	END PROCESS;

				
	-- Car 2 drawing with sprite
	c2draw : PROCESS (car2_x, car2_y, pixel_row, pixel_col) IS
		VARIABLE sprite_x, sprite_y : INTEGER;
	BEGIN
		sprite_x := CONV_INTEGER(pixel_col) - CONV_INTEGER(car2_x) + (CAR_WIDTH/2);
		sprite_y := CONV_INTEGER(pixel_row) - CONV_INTEGER(car2_y) + (CAR_HEIGHT/2);
		
		IF (sprite_x >= 0 AND sprite_x < CAR_WIDTH) AND
		   (sprite_y >= 0 AND sprite_y < CAR_HEIGHT) THEN
			IF car_sprite(sprite_y)(CAR_WIDTH - 1 - sprite_x) = '1' THEN
				car2_on <= '1';
			ELSE
				car2_on <= '0';
			END IF;
		ELSE
			car2_on <= '0';
		END IF;
	END PROCESS;
	
	-- Car 2 movement
	mcar2 : PROCESS
	BEGIN
		WAIT UNTIL rising_edge(v_sync);
		IF car2_x + size >= 900 THEN
			car2_x_motion <= "11111111100"; -- -4 (speed)
		ELSIF car2_x <= size THEN
			car2_x_motion <= "00000000100"; -- 4 (speed)
		END IF;
		car2_x <= car2_x + car2_x_motion;
	END PROCESS;
	
	-- Car 3 drawing with sprite
	c3draw : PROCESS (car3_x, car3_y, pixel_row, pixel_col) IS
		VARIABLE sprite_x, sprite_y : INTEGER;
	BEGIN
		sprite_x := CONV_INTEGER(pixel_col) - CONV_INTEGER(car3_x) + (CAR_WIDTH/2);
		sprite_y := CONV_INTEGER(pixel_row) - CONV_INTEGER(car3_y) + (CAR_HEIGHT/2);
		
		IF (sprite_x >= 0 AND sprite_x < CAR_WIDTH) AND
		   (sprite_y >= 0 AND sprite_y < CAR_HEIGHT) THEN
			IF car_sprite(sprite_y)(CAR_WIDTH - 1 - sprite_x) = '1' THEN
				car3_on <= '1';
			ELSE
				car3_on <= '0';
			END IF;
		ELSE
			car3_on <= '0';
		END IF;
	END PROCESS;
	
	-- Car 3 movement
	mcar3 : PROCESS
	BEGIN
		WAIT UNTIL rising_edge(v_sync);
		IF car3_x + size >= 900 THEN
			car3_x_motion <= "11111111011"; -- -5 (speed)
		ELSIF car3_x <= size THEN
			car3_x_motion <= "00000000101"; -- 5 (speed)
		END IF;
		car3_x <= car3_x + car3_x_motion;
	END PROCESS;
	
	-- Car 4 drawing with sprite
	c4draw : PROCESS (car4_x, car4_y, pixel_row, pixel_col) IS
		VARIABLE sprite_x, sprite_y : INTEGER;
	BEGIN
		sprite_x := CONV_INTEGER(pixel_col) - CONV_INTEGER(car4_x) + (CAR_WIDTH/2);
		sprite_y := CONV_INTEGER(pixel_row) - CONV_INTEGER(car4_y) + (CAR_HEIGHT/2);
		
		IF (sprite_x >= 0 AND sprite_x < CAR_WIDTH) AND
		   (sprite_y >= 0 AND sprite_y < CAR_HEIGHT) THEN
			IF car_sprite(sprite_y)(CAR_WIDTH - 1 - sprite_x) = '1' THEN
				car4_on <= '1';
			ELSE
				car4_on <= '0';
			END IF;
		ELSE
			car4_on <= '0';
		END IF;
	END PROCESS;
	
	-- Car 4 movement
	mcar4 : PROCESS
	BEGIN
		WAIT UNTIL rising_edge(v_sync);
		IF car4_x + size >= 900 THEN
			car4_x_motion <= "11111111010"; -- -6 (speed)
		ELSIF car4_x <= size THEN
			car4_x_motion <= "00000000110"; -- 6 (speed)
		END IF;
		car4_x <= car4_x + car4_x_motion;
	END PROCESS;
	
	-- Car 5 drawing with sprite
	c5draw : PROCESS (car5_x, car5_y, pixel_row, pixel_col) IS
		VARIABLE sprite_x, sprite_y : INTEGER;
	BEGIN
		sprite_x := CONV_INTEGER(pixel_col) - CONV_INTEGER(car5_x) + (CAR_WIDTH/2);
		sprite_y := CONV_INTEGER(pixel_row) - CONV_INTEGER(car5_y) + (CAR_HEIGHT/2);
		
		IF (sprite_x >= 0 AND sprite_x < CAR_WIDTH) AND
		   (sprite_y >= 0 AND sprite_y < CAR_HEIGHT) THEN
			IF car_sprite(sprite_y)(CAR_WIDTH - 1 - sprite_x) = '1' THEN
				car5_on <= '1';
			ELSE
				car5_on <= '0';
			END IF;
		ELSE
			car5_on <= '0';
		END IF;
	END PROCESS;
	
	-- Car 5 movement
	mcar5 : PROCESS
	BEGIN
		WAIT UNTIL rising_edge(v_sync);
		IF car5_x + size >= 900 THEN
			car5_x_motion <= "11111111001"; -- -7 (speed)
		ELSIF car5_x <= size THEN
			car5_x_motion <= "00000000111"; -- 7 (speed)
		END IF;
		car5_x <= car5_x + car5_x_motion;
	END PROCESS;
				
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
	
END Behavioral;
