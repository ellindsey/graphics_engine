LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY mux16x8 IS
    PORT(
        selectIn : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        in0      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        in1      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        in2      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        in3      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        in4      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        in5      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        in6      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        in7      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        out0     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END mux16x8;

ARCHITECTURE behavior OF mux16x8 IS
BEGIN
    PROCESS (selectIn,in0,in1,in2,in3,in4,in5,in6,in7)
    BEGIN
        CASE selectIn IS
            WHEN "000" =>
                out0 <= in0;
            WHEN "001" =>
                out0 <= in1;
            WHEN "010" =>
                out0 <= in2;
            WHEN "011" =>
                out0 <= in3;
            WHEN "100" =>
                out0 <= in4;
            WHEN "101" =>
                out0 <= in5;
            WHEN "110" =>
                out0 <= in6;
            WHEN "111" =>
                out0 <= in7;
            WHEN OTHERS =>
                out0 <= in0;
        END CASE;
    END PROCESS;
END behavior;