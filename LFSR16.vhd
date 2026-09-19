LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY LFSR16 IS
   PORT(
        clk                     : IN  STD_LOGIC;
        output                  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
END LFSR16;


ARCHITECTURE behavior OF LFSR16 IS

SIGNAL r        : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000001";

BEGIN

    PROCESS(clk,r)
        VARIABLE feedback : STD_LOGIC;
    BEGIN
        feedback := r(10) xor r(12) xor r(13) xor r(15);
        
        IF RISING_EDGE(clk) THEN
            r <= r(14 downto 0) & feedback;
        END IF;
    END PROCESS;

    output <= r;
END behavior;