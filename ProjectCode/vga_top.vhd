LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

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

ARCHITECTURE Behavioral OF vga_top IS
    SIGNAL pxl_clk : STD_LOGIC := '0';
	SIGNAL ck_25 : STD_LOGIC := '0';	
	SIGNAL cnt : STD_LOGIC_VECTOR(20 DOWNTO 0) := (OTHERS => '0');
	SIGNAL S_red, S_green, S_blue : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL S_vsync : STD_LOGIC;
	SIGNAL S_pixel_row, S_pixel_col : STD_LOGIC_VECTOR (10 DOWNTO 0);	
	SIGNAL S_data : STD_LOGIC_VECTOR (7 DOWNTO 0);	
	SIGNAL led_mpx : STD_LOGIC_VECTOR (2 DOWNTO 0);
	SIGNAL S_win : STD_LOGIC; --added to track win
	
	COMPONENT frog IS
		PORT (
			v_sync : IN STD_LOGIC;
			pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
			pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);

			-- changed colors from single bit to 4 bit to expand our color options for graphics
			red : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			green : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			blue : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			
			left: IN STD_LOGIC;
            right: IN STD_LOGIC;            
            up: IN STD_LOGIC;            
            down: IN STD_LOGIC;                        
            reset: IN STD_LOGIC;
			score: OUT STD_LOGIC_VECTOR (7 DOWNTO 0); --changed from 1 downto 0 to 7 downto 0 to ensure high enough scoring could be stored
			win_out: OUT STD_LOGIC; --added to track win
			LED: out std_logic; --added for led output (bottom right led lights up when win)
			sw: IN STD_LOGIC_VECTOR(4 DOWNTO 0) -- added for switches (to change character)
		);
	END COMPONENT;

	COMPONENT vga_sync IS
		PORT (
			pixel_clk : IN STD_LOGIC;
			red_in       : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			green_in     : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			blue_in      : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			red_out      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			green_out    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			blue_out     : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			hsync : OUT STD_LOGIC;
			vsync : OUT STD_LOGIC;
			pixel_row : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
			pixel_col : OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT leddec IS
        PORT (
            dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0); --changed from 1 downto 0 to 2 downto 0 to make it 8 bits so could expand display to say good job when win 
            f_data : IN STD_LOGIC_VECTOR (7 DOWNTO 0); --changed from 1 downto 0 to 7 downto 0 (to match the size of score)
            win : IN STD_LOGIC; --added to detect win (1 = win, 0 = no win)
            anode : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
        );
    END COMPONENT;

BEGIN
	-- Process to generate 25 MHz clock from 100 MHz system clock
	ckp : PROCESS (clk_in)
	BEGIN	
		IF rising_edge(clk_in) THEN		
			cnt <= cnt + 1;
			ck_25 <= NOT ck_25;
		END IF;
	END PROCESS;
	
	led_mpx <= cnt(19 DOWNTO 17); --changed to 3 bits to have 8 options --> allows good job to be displayed 

	add_frog : frog
	PORT MAP(
		v_sync => S_vsync, 
		pixel_row => S_pixel_row, 
		pixel_col => S_pixel_col, 
		red => S_red, 
		green => S_green, 
		blue => S_blue,
		up => b_up,		
		down => b_down,		
		left => b_left,		
		right => b_right,		
		reset => b_reset,		
		score => S_data,
		win_out => S_win, --added for win tracking
		LED => LED, --added for win game led
		sw => sw --added for switches for character changes
	);

	vga_driver : vga_sync
	PORT MAP(
		pixel_clk => ck_25, 
		red_in => S_red, 
        green_in => S_green, 
        blue_in => S_blue, 
        red_out => VGA_red, 
        green_out => VGA_green, 
        blue_out => VGA_blue, 
		pixel_row => S_pixel_row, 
		pixel_col => S_pixel_col,
		hsync => vga_hsync, 
		vsync => S_vsync
	);

	vga_vsync <= S_vsync;
	
	led_driver : leddec	
	PORT MAP(		
		dig => led_mpx,	
		f_data => S_data,
		win => S_win,	--added for win tracking
		anode => AN,	
		seg => seg	
	);

END Behavioral;
