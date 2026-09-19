LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY copperOpSelect IS
    PORT(
        source_select   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        REG_A           : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        REG_B           : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        REG_C           : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        REG_D           : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        REG_INV         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        REG_SINCOS      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        active_line     : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        SOURCE_8        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        SOURCE_16       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END copperOpSelect;

ARCHITECTURE behavior OF copperOpSelect IS
BEGIN
    PROCESS(source_select,REG_A,REG_B,REG_C,REG_D,REG_INV,REG_SINCOS,active_line)
    BEGIN
        CASE source_select IS
            WHEN "000" =>
                SOURCE_8 <= REG_A;
                SOURCE_16 <= REG_A & REG_B;
            WHEN "001" =>
                SOURCE_8 <= REG_B;
                SOURCE_16 <= REG_C & REG_D;
            WHEN "010" =>
                SOURCE_8 <= REG_C;
                SOURCE_16 <= REG_INV;
            WHEN "011" =>
                SOURCE_8 <= REG_D;
                SOURCE_16 <= REG_SINCOS;
            WHEN "100" =>
                SOURCE_8 <= active_line;
                SOURCE_16 <= "00000000" & active_line;
            WHEN "101" =>
                SOURCE_8 <= "00000000";
                SOURCE_16 <= "0000000000000000";
            WHEN "110" =>
                SOURCE_8 <= "00000001";
                SOURCE_16 <= "0000000000000001";
            WHEN "111" =>
                SOURCE_8 <= "11111111";
                SOURCE_16 <= "1111111111111111";
            WHEN OTHERS =>
                SOURCE_8 <= "00000000";
                SOURCE_16 <= "0000000000000000";
        END CASE;
    END PROCESS;
    
END behavior;