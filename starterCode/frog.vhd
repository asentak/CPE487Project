LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY frog IS
	PORT (
		v_sync    : IN STD_LOGIC;
		pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		red       : OUT STD_LOGIC;
		green     : OUT STD_LOGIC;
		blue      : OUT STD_LOGIC;
		up        : IN STD_LOGIC;
		down      : IN STD_LOGIC;
	   	left      : IN STD_LOGIC;
	 	right     : IN STD_LOGIC;
                reset     : IN STD_LOGIC;
		score 	  : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
	);
END frog;

ARCHITECTURE Behavioral OF frog IS
 -- signals and variables for frog
	CONSTANT size  : INTEGER := 8;
	SIGNAL frog_on : STD_LOGIC; -- indicates whether frog is over current pixel position
	SIGNAL frog_dead : STD_LOGIC := '0';
	SIGNAL win : STD_LOGIC := '0';
	SIGNAL frog_dead_on : STD_LOGIC;
	SIGNAL win_on : STD_LOGIC;
	SIGNAL frog_deadx  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
	SIGNAL frog_deady  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(580, 11);
	-- current frog position - intitialized to center of screen
	SIGNAL frog_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
	SIGNAL frog_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(580, 11);
	-- goal coordinates
	SIGNAL goal_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(50,11);
	-- current frog motion - initialized to +2 pixels/frame
	SIGNAL frog_hop : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000010";
	SIGNAL direction  : INTEGER := 8;
-- signals and variables for cars
    CONSTANT car_size  : INTEGER := 12;
	SIGNAL car1_on : STD_LOGIC; -- indicates whether car1 is over current pixel position
	-- current car position 
	SIGNAL car1_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(10, 11);
	SIGNAL car1_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
	-- current car motion - initialized to +3 pixels/frame
	SIGNAL car1_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "10100100011";
	-- car 2 -
	SIGNAL car2_on : STD_LOGIC; -- indicates whether car1 is over current pixel position
	-- current car position 
	SIGNAL car2_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(10, 11);
	SIGNAL car2_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(350, 11);
	-- current car motion - initialized to +4 pixels/frame
	SIGNAL car2_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "01011100100";
	-- car 3 -
	SIGNAL car3_on : STD_LOGIC; -- indicates whether car1 is over current pixel position
	-- current car position 
	SIGNAL car3_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(10, 11);
	SIGNAL car3_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
	-- current car motion - initialized to +5 pixels/frame
	SIGNAL car3_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "01110010111";	
	-- car 4 -
	SIGNAL car4_on : STD_LOGIC; -- indicates whether car1 is over current pixel position
	-- current car position 
	SIGNAL car4_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(20, 11);
	SIGNAL car4_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(150, 11);
	-- current car motion - initialized to +5 pixels/frame
	SIGNAL car4_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "11110001001";
	-- car 5 -
	SIGNAL car5_on : STD_LOGIC; -- indicates whether car5 is over current pixel position
	-- current car position 
	SIGNAL car5_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(30, 11);
	SIGNAL car5_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(200, 11);
	-- current car motion - initialized to +5 pixels/frame
	SIGNAL car5_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000001101";	
	
	SIGNAL river_w : INTEGER := 390; -- bat width in pixels
        CONSTANT river_h : INTEGER := 8; -- bat height in pixels
	SIGNAL Rriver_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(410, 11);
	SIGNAL Rriver_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(250, 11);
	SIGNAL Rriver_on : STD_LOGIC;
        SIGNAL Lriver_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(20, 11);
	SIGNAL Lriver_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(250, 11);
        SIGNAL Lriver_on : STD_LOGIC;
	
--	SIGNAL s_score : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
--	SIGNAL score_incr : STD_LOGIC_VECTOR(1 DOWNTO 0) := "01";
	SIGNAL s_score1 : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
	SIGNAL s_score2 : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
	SIGNAL s_score3 : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
	-- coins!!!!
	CONSTANT coin_size : INTEGER := 10;
	SIGNAL coin1_on : STD_LOGIC := '0';
	SIGNAL coin1_off : STD_LOGIC := '1';
        SIGNAL coin1_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
    	SIGNAL coin1_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(350, 11);
    	SIGNAL coin2_on : STD_LOGIC := '0';
	SIGNAL coin2_off : STD_LOGIC := '1';
    	SIGNAL coin2_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(230, 11);
    	SIGNAL coin2_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(200, 11);
    	SIGNAL coin3_on : STD_LOGIC := '0';
	SIGNAL coin3_off : STD_LOGIC := '1';
    	SIGNAL coin3_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(575, 11);
    	SIGNAL coin3_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(160, 11);
    


BEGIN
	-- THIS IS WHERE THE COLORS WERE DONE FOR DRAWING 
    red   <=  win_on OR car1_on OR car2_on OR car3_on OR car4_on OR car5_on OR coin1_on OR coin2_on OR coin3_on;
    green <=  win_on OR frog_on OR coin1_on OR coin2_on OR coin3_on;
    blue  <=  win_on OR Rriver_on OR Lriver_on;

    
	score <= s_score1 + s_score2 + s_score3;
	-- process to draw frog current pixel address is covered by frog position
	fdraw : PROCESS (frog_x, frog_y, pixel_row, pixel_col, frog_dead, win) IS
	BEGIN
	    IF NOT (frog_dead = '1' OR win = '1') THEN
		IF (pixel_col >= frog_x - size) AND
		   (pixel_col <= frog_x + size) AND
		   (pixel_row >= frog_y - size) AND
	  	   (pixel_row <= frog_y + size) THEN
			frog_on <= '1';
		ELSE
			frog_on <= '0';
		END IF;
		ELSIF frog_dead = '1' THEN
		IF (pixel_col >= frog_deadx - size) AND
		   (pixel_col <= frog_deadx + size) AND
		   (pixel_row >= frog_deady - size) AND
	  	   (pixel_row <= frog_deady + size) THEN
			frog_dead_on <= '1';
			frog_on <= '0';
	    ELSIF win = '1' THEN
	       IF (pixel_col >= frog_deadx - size) AND
		   (pixel_col <= frog_deadx + size) AND
		   (pixel_row >= frog_deady - size) AND
	  	   (pixel_row <= frog_deady + size) THEN
			win_on <= '1'; 
			frog_on <= '0';
		END IF;
		END IF;
	END IF;
	END PROCESS;
		
	-- process to move frog once every frame (i.e. once every vsync pulse)
	mfrog : PROCESS
	BEGIN
	   WAIT UNTIL rising_edge(v_sync);
	   IF up = '1' THEN
	       direction <= 1;
	   ELSIF down = '1' THEN
	       direction <= 2;
	   ELSIF left = '1' THEN
	       direction <= 3;
	   ELSIF right = '1' THEN
	       direction <= 4;
	   ELSIF reset = '1' THEN
	       direction <= 8;
	   ELSE
	       direction <= 0;
	   END IF;
	   
	   IF direction = 1 THEN
	       frog_y <= frog_y - frog_hop;
	   ELSIF direction = 2 THEN
	       frog_y <= frog_y + frog_hop;
	   ELSIF direction = 3 THEN
	       frog_x <= frog_x - frog_hop;
	   ELSIF direction = 4 THEN
	       frog_x <= frog_x + frog_hop;
	   ELSIF direction = 8 THEN
	       frog_x <= CONV_STD_LOGIC_VECTOR(400, 11);
           frog_y <= CONV_STD_LOGIC_VECTOR(580, 11);
           frog_dead <= '0';
           win <= '0';
	   ELSIF direction = 0 THEN
	       frog_x <= frog_x;  
	   END IF;  
	   --- collision detection for car1, 2 and 3
	   IF ((frog_x >= car1_x - 15 AND frog_x <= car1_x + 15) 
       AND (frog_y >= car1_y - 15 AND frog_y <= car1_y + 15)) OR 
       ((frog_x >= car2_x - 15 AND frog_x <= car2_x + 15) 
       AND (frog_y >= car2_y - 15 AND frog_y <= car2_y + 15)) OR
       ((frog_x >= car3_x - 15 AND frog_x <= car3_x + 15) 
       AND (frog_y >= car3_y - 15 AND frog_y <= car3_y + 15)) OR
       ((frog_x >= car4_x - 15 AND frog_x <= car4_x + 15) 
       AND (frog_y >= car4_y - 15 AND frog_y <= car4_y + 15)) OR
       ((frog_x >= car5_x - 15 AND frog_x <= car5_x + 15) 
       AND (frog_y >= car5_y - 15 AND frog_y <= car5_y + 15)) OR
       ((frog_x >= Lriver_x - 15 AND frog_x <= (Lriver_x + river_w) + 15) 
       AND (frog_y >= Lriver_y - 15 AND frog_y <= (Lriver_y + river_h) + 15)) OR
       ((frog_x >= Rriver_x - 15 AND frog_x <= (Rriver_x + river_w) + 15) 
       AND (frog_y >= Rriver_y - 15 AND frog_y <= (Rriver_y + river_h) + 15))
       THEN
           frog_dead <= '1';
           frog_deadx <= frog_x;
           frog_deady <= frog_y;
           win <= '1';
           frog_deadx <= frog_x;
           frog_deady <= frog_y; 	   
       END IF;

	   END PROCESS;
	
	-- Coin 1 drawing logic
PROCESS (direction, frog_x, frog_y, coin1_x, coin1_y, pixel_row, pixel_col, coin1_on, coin1_off)
    VARIABLE dx, dy : INTEGER;
    VARIABLE distance_squared : INTEGER;
BEGIN
    dx := CONV_INTEGER(pixel_col) - CONV_INTEGER(coin1_x);
    dy := CONV_INTEGER(pixel_row) - CONV_INTEGER(coin1_y);
    distance_squared := (dx * dx) + (dy * dy);

    IF distance_squared <= (coin_size * coin_size) AND coin1_off = '1'  THEN
        coin1_on <= '1';
    ELSE
        coin1_on <= '0';
    END IF;
    IF (((frog_x >= coin1_x - 15 AND frog_x <= coin1_x + 15) AND (frog_y >= coin1_y - 15 AND frog_y <= coin1_y + 15)) AND coin1_on = '1') THEN --coin 1
        coin1_off <= '0'; -- Hide coin
        s_score1 <= "01";   -- Increase score
    ELSIF (direction = 8) THEN
        s_score1 <= "00";
        coin1_off <= '1'; -- Hide coin
    END IF;
END PROCESS;
		

-- Coin 2 drawing logic
PROCESS (direction, frog_x, frog_y, coin2_x, coin2_y, pixel_row, pixel_col, coin2_on, coin2_off)
    VARIABLE dx, dy : INTEGER;
    VARIABLE distance_squared : INTEGER;
BEGIN
    dx := CONV_INTEGER(pixel_col) - CONV_INTEGER(coin2_x);
    dy := CONV_INTEGER(pixel_row) - CONV_INTEGER(coin2_y);
    distance_squared := (dx * dx) + (dy * dy);

    IF distance_squared <= (coin_size * coin_size) AND coin2_off = '1' THEN
        coin2_on <= '1';
    ELSE
        coin2_on <= '0';
    END IF;
    IF (((frog_x >= coin2_x - 15 AND frog_x <= coin2_x + 15) AND (frog_y >= coin2_y - 15 AND frog_y <= coin2_y + 15)) AND coin2_on = '1') THEN --coin 2
        coin2_off <= '0'; -- Hide coin
        s_score2 <= "01";   -- Increase score
    ELSIF (direction = 8) THEN
        s_score2 <= "00";
        coin2_off <= '1'; -- Hide coin
    END IF;    
END PROCESS;

-- Coin 3 drawing logic
PROCESS (direction, frog_x, frog_y, coin3_x, coin3_y, pixel_row, pixel_col, coin3_on, coin3_off)
    VARIABLE dx, dy : INTEGER;
    VARIABLE distance_squared : INTEGER;
BEGIN
    dx := CONV_INTEGER(pixel_col) - CONV_INTEGER(coin3_x);
    dy := CONV_INTEGER(pixel_row) - CONV_INTEGER(coin3_y);
    distance_squared := (dx * dx) + (dy * dy);

    IF distance_squared <= (coin_size * coin_size) AND coin3_off = '1'  THEN
        coin3_on <= '1';
    ELSE
        coin3_on <= '0';
    END IF;
    IF (((frog_x >= coin3_x - 15 AND frog_x <= coin3_x + 15) AND (frog_y >= coin3_y - 15 AND frog_y <= coin3_y + 15)) AND coin3_on = '1') THEN --coin 3
        coin3_off <= '0'; -- Hide coin
        s_score3 <= "01";   -- Increase score
    ELSIF (direction = 8) THEN
        s_score3 <= "00";
        coin3_off <= '1'; -- Hide coin
    END IF;
END PROCESS;

-- right river drawing logic
PROCESS (Rriver_x, Rriver_y, pixel_row, pixel_col)
BEGIN
    IF ((pixel_col >= Rriver_x - river_w) OR (Rriver_x <= river_w)) AND
    pixel_col <= Rriver_x + river_w AND
    pixel_row >= Rriver_y - river_h AND
    pixel_row <= Rriver_y + river_h THEN
        Rriver_on <= '1';
    ELSE
        Rriver_on <= '0';
    END IF;
END PROCESS;
 
-- left river drawing logic
PROCESS (Lriver_x, Lriver_y, pixel_row, pixel_col)
BEGIN
    IF ((pixel_col >= Lriver_x - river_w) OR (Lriver_x <= river_w)) AND
    pixel_col <= Lriver_x + river_w AND
    pixel_row >= Lriver_y - river_h AND
    pixel_row <= Lriver_y + river_h THEN
        Lriver_on <= '1';
    ELSE
        Lriver_on <= '0';
    END IF;
END PROCESS;


	
	--process to draw cars
	c1draw : PROCESS (car1_x, car1_y, pixel_row, pixel_col) IS
	BEGIN
		IF (pixel_col >= car1_x - size) AND
		 (pixel_col <= car1_x + size) AND
			 (pixel_row >= car1_y - size) AND
			 (pixel_row <= car1_y + size) THEN
				car1_on <= '1';
		ELSE
			car1_on <= '0';
		END IF;
		END PROCESS;
		-- process to move car1 once every frame (i.e. once every vsync pulse)
		mcar1 : PROCESS
		BEGIN
			WAIT UNTIL rising_edge(v_sync);
			-- allow for bounce off top or bottom of screen
			IF car1_x + size >= 900 THEN
				car1_x_motion <= "11111111100"; -- -4 pixels
			ELSIF car1_x <= size THEN
				car1_x_motion <= "00000000100"; -- +4 pixels
			END IF;
			car1_x <= car1_x + car1_x_motion; -- compute next car1 position
		END PROCESS;
		
		c2draw : PROCESS (car2_x, car2_y, pixel_row, pixel_col) IS
	   BEGIN
		IF (pixel_col >= car2_x - size) AND
		 (pixel_col <= car2_x + size) AND
			 (pixel_row >= car2_y - size) AND
			 (pixel_row <= car2_y + size) THEN
				car2_on <= '1';
		ELSE
			car2_on <= '0';
		END IF;
		END PROCESS;
		-- process to move car2 once every frame (i.e. once every vsync pulse)
		mcar2 : PROCESS
		BEGIN
			WAIT UNTIL rising_edge(v_sync);
			-- allow for bounce off top or bottom of screen
			IF car2_x + size >= 900 THEN
				car2_x_motion <= "11111111100"; -- -4 pixels
			ELSIF car2_x <= size THEN
				car2_x_motion <= "00000000100"; -- +4 pixels
			END IF;
			car2_x <= car2_x + car2_x_motion; -- compute next car2 position
		END PROCESS;
		c3draw : PROCESS (car3_x, car3_y, pixel_row, pixel_col) IS
	   BEGIN
		IF (pixel_col >= car3_x - size) AND
		 (pixel_col <= car3_x + size) AND
			 (pixel_row >= car3_y - size) AND
			 (pixel_row <= car3_y + size) THEN
				car3_on <= '1';
		ELSE
			car3_on <= '0';
		END IF;
		END PROCESS;
		-- process to move car3 once every frame (i.e. once every vsync pulse)
		mcar3 : PROCESS
		BEGIN
			WAIT UNTIL rising_edge(v_sync);
			-- allow for bounce off top or bottom of screen
			IF car3_x + size >= 900 THEN
				car3_x_motion <= "11111111100"; -- -4 pixels
			ELSIF car3_x <= size THEN
				car3_x_motion <= "00000000100"; -- +4 pixels
			END IF;
			car3_x <= car3_x + car3_x_motion; -- compute next car3 position
		END PROCESS;
		c4draw : PROCESS (car4_x, car4_y, pixel_row, pixel_col) IS
	   BEGIN
		IF (pixel_col >= car4_x - size) AND
		 (pixel_col <= car4_x + size) AND
			 (pixel_row >= car4_y - size) AND
			 (pixel_row <= car4_y + size) THEN
				car4_on <= '1';
		ELSE
			car4_on <= '0';
		END IF;
		END PROCESS;
		-- process to move car3 once every frame (i.e. once every vsync pulse)
		mcar4 : PROCESS
		BEGIN
			WAIT UNTIL rising_edge(v_sync);
			-- allow for bounce off top or bottom of screen
			IF car4_x + size >= 900 THEN
				car4_x_motion <= "11111111100"; -- -4 pixels
			ELSIF car4_x <= size THEN
				car4_x_motion <= "00000000100"; -- +4 pixels
			END IF;
			car4_x <= car4_x + car4_x_motion; -- compute next car3 position
		END PROCESS;
		c5draw : PROCESS (car5_x, car5_y, pixel_row, pixel_col) IS
	   BEGIN
		IF (pixel_col >= car5_x - size) AND
		 (pixel_col <= car5_x + size) AND
			 (pixel_row >= car5_y - size) AND
			 (pixel_row <= car5_y + size) THEN
				car5_on <= '1';
		ELSE
			car5_on <= '0';
		END IF;
		END PROCESS;
		-- process to move car3 once every frame (i.e. once every vsync pulse)
		mcar5 : PROCESS
		BEGIN
			WAIT UNTIL rising_edge(v_sync);
			-- allow for bounce off top or bottom of screen
			IF car5_x + size >= 900 THEN
				car5_x_motion <= "11111111100"; -- -4 pixels
			ELSIF car5_x <= size THEN
				car5_x_motion <= "00000000100"; -- +4 pixels
			END IF;
			car5_x <= car5_x + car5_x_motion; -- compute next car3 position
		END PROCESS;
END Behavioral;
