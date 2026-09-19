LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY mux8x2 IS
    PORT(
        selectIn : IN  STD_LOGIC;
        in0      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        in1      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        out0     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END mux8x2;

ARCHITECTURE behavior OF mux8x2 IS
BEGIN
    PROCESS (selectIn,in0,in1)
    BEGIN
        CASE selectIn IS
            WHEN '0' =>
                out0 <= in0;
            WHEN '1' =>
                out0 <= in1;
            WHEN OTHERS =>
                out0 <= in0;
        END CASE;
    END PROCESS;
END behavior;