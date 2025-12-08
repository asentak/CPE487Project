-- from starter code: expanded on a large porition of this file to allow for more complicated digit displays
    -- starter code used two bit scoring and assigned the mapping for 0-3 to seg
    -- we expanded to be able to display numbers 0-9 and letters in good job + changed the way scoring was tracked to convert binary score to decimal display
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL; --added this library so could do math with the score

ENTITY leddec IS
    PORT (
        dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0); --changed from 1 downto 0 to 2 downto 0 to make it 8 bits so could expand display to say good job when win 
        f_data : IN STD_LOGIC_VECTOR (7 DOWNTO 0); --changed from 1 downto 0 to 7 downto 0 (to match the size of score)
        win : IN STD_LOGIC; --added to track win 
        anode : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
    );
END leddec;

ARCHITECTURE Behavioral OF leddec IS
    SIGNAL data4 : STD_LOGIC_VECTOR(3 DOWNTO 0); --4 bit signal to represent which character to display

    --signals created to help calculate the score as an integer 
    SIGNAL temp_score : INTEGER RANGE 0 TO 255;
    SIGNAL hundreds : INTEGER RANGE 0 TO 9;
    SIGNAL tens : INTEGER RANGE 0 TO 9;
    SIGNAL ones : INTEGER RANGE 0 TO 9;
BEGIN

    -- converts the binary score to decimal numbers and store the digit of each tens place so it can be displayed 
    temp_score <= CONV_INTEGER(f_data);
    hundreds <= temp_score / 100;
    tens <= (temp_score / 10) MOD 10;
    ones <= temp_score MOD 10;
    
    -- Select what character/number will be displayed 

    -- win message: "GOOD JOB"
    data4 <= "1010" WHEN (win = '1' AND dig = "000") ELSE -- b (rightmost)
             "0000" WHEN (win = '1' AND dig = "001") ELSE -- O
             "1101" WHEN (win = '1' AND dig = "010") ELSE -- J 
             "1011" WHEN (win = '1' AND dig = "011") ELSE -- d
             "0000" WHEN (win = '1' AND dig = "100") ELSE -- O
             "0000" WHEN (win = '1' AND dig = "101") ELSE -- O
             "1100" WHEN (win = '1' AND dig = "110") ELSE -- G (leftmost)

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

    -- Digit enable (active low) (letting 7 of the digits light up) --> tells which digits to light up
    anode <= "11111110" WHEN dig = "000" ELSE --rightmost position
             "11111101" WHEN dig = "001" ELSE
             "11111011" WHEN dig = "010" ELSE
             "11110111" WHEN dig = "011" ELSE
             "11101111" WHEN dig = "100" ELSE
             "11011111" WHEN dig = "101" ELSE
             "10111111" WHEN dig = "110" ELSE --leftmost position (where the G is for good job)
             "11111111";

END Behavioral;
