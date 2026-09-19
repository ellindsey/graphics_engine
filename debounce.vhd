
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY debouncer IS
   PORT(
        CLK             : IN  STD_LOGIC;
        INP             : IN  STD_LOGIC;
        OUTP            : OUT STD_LOGIC
      );
END debouncer;

ARCHITECTURE behavioral OF debouncer IS

SIGNAL OUTLATCH         : STD_LOGIC := '1';
    
BEGIN

    PROCESS (CLK,OUTLATCH)
        
        VARIABLE INP1             : STD_LOGIC := '1';
        VARIABLE INP2             : STD_LOGIC := '1';
        VARIABLE INP3             : STD_LOGIC := '1';
        VARIABLE INP4             : STD_LOGIC := '1';
        VARIABLE INP5             : STD_LOGIC := '1';
        VARIABLE OUTLATCH_NEXT    : STD_LOGIC := '1';

    BEGIN
        IF (INP5 = '1') AND (INP4 = '1') AND (INP3 = '1') THEN
            OUTLATCH_NEXT := '1';
        ELSIF (INP5 = '0') AND (INP4 = '0') AND (INP3 = '0') THEN
            OUTLATCH_NEXT := '0';
        ELSE
            OUTLATCH_NEXT := OUTLATCH;
        END IF;
                
        IF RISING_EDGE(CLK) THEN
            INP5 := INP4;
            INP4 := INP3;
            INP3 := INP2;
            INP2 := INP1;
            INP1 := INP;
            OUTLATCH <= OUTLATCH_NEXT;
        END IF;
    END PROCESS;
    
    OUTP <= OUTLATCH;
    
END behavioral;