LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY audioSum IS
   PORT(
        clk     : IN  STD_LOGIC;
        clear   : IN  STD_LOGIC;
        add     : IN  STD_LOGIC;
        
        audio   : IN  SIGNED(15 DOWNTO 0);
        total   : OUT SIGNED(15 DOWNTO 0)
        );
END audioSum;

ARCHITECTURE behavior OF audioSum IS

SIGNAL totalVal           : SIGNED (15 downto 0) := (others => '0');
SIGNAL next_totalVal      : SIGNED (15 downto 0) := (others => '0');

BEGIN
    PROCESS(clk,clear,add,totalVal,audio)
        VARIABLE immSum          : SIGNED(16 DOWNTO 0);
    BEGIN
        immSum := resize(totalVal,17) + resize(audio,17);
    
        IF clear = '1' THEN
            next_totalVal <= "0000000000000000";
        ELSIF add = '1' THEN
        
            IF immSum(16 downto 15) = "01" THEN
                next_totalVal <= "0111111111111111";
            ELSIF immSum(16 downto 15) = "10" THEN
                next_totalVal <= "1000000000000000";
            ELSE
                next_totalVal <= immSum(15 downto 0);
            END IF;
        ELSE
            next_totalVal <= totalVal;
        END IF;
    
        IF RISING_EDGE(CLK) THEN
            totalVal             <= next_totalVal;
        END IF;
    END PROCESS;
    
    total <= totalVal;
END behavior;