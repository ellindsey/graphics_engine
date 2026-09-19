library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity window_compare is
    PORT(    
        WINDOW_ENABLE       : IN  STD_LOGIC;
        WINDOW_INVERT       : IN  STD_LOGIC;
        WINDOW_START        : IN  integer range 0 to 511;
        WINDOW_STOP         : IN  integer range 0 to 511;
        POSITION            : IN  integer range 0 to 511;
        IN_WINDOW           : OUT STD_LOGIC
    );
END window_compare;

architecture Behavioral of window_compare is

BEGIN
    
    PROCESS(WINDOW_ENABLE,WINDOW_INVERT,WINDOW_START,WINDOW_STOP,POSITION)
    BEGIN
        if WINDOW_ENABLE = '1' THEN
            if (POSITION >= WINDOW_START) AND (POSITION <= WINDOW_STOP) THEN
                IN_WINDOW <= NOT WINDOW_INVERT;
            ELSE
                IN_WINDOW <= WINDOW_INVERT;
            END IF;
        ELSE
            IN_WINDOW <= '0';
        END IF;
    END PROCESS;
    
END Behavioral;