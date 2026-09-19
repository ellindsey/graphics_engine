LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY mux16x4 IS
    PORT(
        selectIn : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        in0      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        in1      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        in2      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        in3      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        out0     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END mux16x4;

ARCHITECTURE behavior OF mux16x4 IS
BEGIN
    PROCESS (selectIn,in0,in1,in2,in3)
    BEGIN
        CASE selectIn IS
            WHEN "00" =>
                out0 <= in0;
            WHEN "01" =>
                out0 <= in1;
            WHEN "10" =>
                out0 <= in2;
            WHEN "11" =>
                out0 <= in3;
            WHEN OTHERS =>
                out0 <= in0;
        END CASE;
    END PROCESS;
END behavior;