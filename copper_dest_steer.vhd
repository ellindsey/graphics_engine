LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY copperDestSelect IS
    PORT(
        reg8_latch_0        : IN  STD_LOGIC;
        reg8_latch_1        : IN  STD_LOGIC;
        reg8_latch_2        : IN  STD_LOGIC;
        reg8_latch_3        : IN  STD_LOGIC;
        reg16_latch_0       : IN  STD_LOGIC;
        reg16_latch_1       : IN  STD_LOGIC;
        reg16_latch_2       : IN  STD_LOGIC;
        reg8_source_0       : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        reg8_source_1       : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        reg8_source_2       : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        reg8_source_3       : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        reg16_source_0      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        reg16_source_1      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        reg16_source_2      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        REG_A               : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        REG_B               : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        REG_C               : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        REG_D               : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        dest8               : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        dest16              : IN  STD_LOGIC;
        next_REG_A          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        next_REG_B          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        next_REG_C          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        next_REG_D          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END copperDestSelect;

ARCHITECTURE behavior OF copperDestSelect IS
BEGIN

    PROCESS (ALL)
        VARIABLE int8       : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE int16      : STD_LOGIC_VECTOR(15 DOWNTO 0);
        VARIABLE latch8     : STD_LOGIC;
        VARIABLE latch16    : STD_LOGIC;
    BEGIN
        latch8 := reg8_latch_0 OR reg8_latch_1 OR reg8_latch_2 OR reg8_latch_3;
        latch16 := reg16_latch_0 OR reg16_latch_1 OR reg16_latch_2;
        
        IF reg8_latch_0 THEN
            int8 := reg8_source_0;
        ELSIF reg8_latch_1 THEN
            int8 := reg8_source_1;
        ELSIF reg8_latch_2 THEN
            int8 := reg8_source_2;
        ELSIF reg8_latch_3 THEN
            int8 := reg8_source_3;
        ELSE
            int8 := "00000000";
        END IF;
        
        IF reg16_latch_0 THEN
            int16 := reg16_source_0;
        ELSIF reg16_latch_1 THEN
            int16 := reg16_source_1;
        ELSIF reg16_latch_2 THEN
            int16 := reg16_source_2;
        ELSE
            int16 := "0000000000000000";
        END IF;
        
        IF latch8 THEN
            CASE dest8 IS
                WHEN "00" =>
                    next_REG_A <= int8;
                    next_REG_B <= REG_B;
                    next_REG_C <= REG_C;
                    next_REG_D <= REG_D;
                WHEN "01" =>
                    next_REG_A <= REG_A;
                    next_REG_B <= int8;
                    next_REG_C <= REG_C;
                    next_REG_D <= REG_D;
                WHEN "10" =>
                    next_REG_A <= REG_A;
                    next_REG_B <= REG_B;
                    next_REG_C <= int8;
                    next_REG_D <= REG_D;
                WHEN "11" =>
                    next_REG_A <= REG_A;
                    next_REG_B <= REG_B;
                    next_REG_C <= REG_C;
                    next_REG_D <= int8;
                WHEN OTHERS =>
                    next_REG_A <= REG_A;
                    next_REG_B <= REG_B;
                    next_REG_C <= REG_C;
                    next_REG_D <= REG_D;
            END CASE;
        ELSIF latch16 THEN
            CASE dest16 IS
                WHEN '0' =>
                    next_REG_A <= int16(15 downto 8);
                    next_REG_B <= int16(7 downto 0);
                    next_REG_C <= REG_C;
                    next_REG_D <= REG_D;
                WHEN '1' =>
                    next_REG_A <= REG_A;
                    next_REG_B <= REG_B;
                    next_REG_C <= int16(15 downto 8);
                    next_REG_D <= int16(7 downto 0);
                WHEN OTHERS =>
                    next_REG_A <= REG_A;
                    next_REG_B <= REG_B;
                    next_REG_C <= REG_C;
                    next_REG_D <= REG_D;
            END CASE;
        ELSE
            next_REG_A <= REG_A;
            next_REG_B <= REG_B;
            next_REG_C <= REG_C;
            next_REG_D <= REG_D;
        END IF;
            
    END PROCESS;
END behavior;