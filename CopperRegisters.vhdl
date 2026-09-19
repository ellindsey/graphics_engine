LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY copperRegisters IS
    PORT(    
        CLK                     : IN  STD_LOGIC;
        RESET                   : IN  STD_LOGIC;
        RUN                     : IN  STD_LOGIC;
        load_reg_8              : IN  STD_LOGIC;
        load_reg_16             : IN  STD_LOGIC;
        dest_8_select           : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        dest_16_select          : IN  STD_LOGIC;
        new_value               : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        reg_A                   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        reg_B                   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        reg_C                   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        reg_D                   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END copperRegisters;

ARCHITECTURE behavior OF copperRegisters IS  

    SIGNAL int_reg_A                : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL int_reg_B                : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL int_reg_C                : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL int_reg_D                : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    
    SIGNAL next_reg_A               : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL next_reg_B               : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL next_reg_C               : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL next_reg_D               : STD_LOGIC_VECTOR(7 DOWNTO 0);
    
BEGIN
    PROCESS(RESET,load_reg_8,load_reg_16,dest_16_select,dest_8_select,new_value,int_reg_A,int_reg_B,int_reg_C,int_reg_D)
    BEGIN
        IF RESET THEN
            next_reg_A <= "00000000";
            next_reg_B <= "00000000";
            next_reg_C <= "00000000";
            next_reg_D <= "00000000";
        ELSIF load_reg_16 = '1' THEN
            CASE dest_16_select IS
                WHEN '0' =>
                    next_reg_A <= new_value(15 downto 8);
                    next_reg_B <= new_value(7 downto 0);
                    next_reg_C <= int_reg_C;
                    next_reg_D <= int_reg_D;
                WHEN '1' =>
                    next_reg_A <= int_reg_A;
                    next_reg_B <= int_reg_B;
                    next_reg_C <= new_value(15 downto 8);
                    next_reg_D <= new_value(7 downto 0);
                WHEN OTHERS =>
                    next_reg_A <= int_reg_A;
                    next_reg_B <= int_reg_B;
                    next_reg_C <= int_reg_C;
                    next_reg_D <= int_reg_D;
            END CASE;
        ELSIF load_reg_8 = '1' THEN
            CASE dest_8_select IS
                WHEN "00" =>
                    next_reg_A <= new_value(15 downto 8);
                    next_reg_B <= int_reg_B;
                    next_reg_C <= int_reg_C;
                    next_reg_D <= int_reg_D;
                WHEN "01" =>
                    next_reg_A <= int_reg_A;
                    next_reg_B <= new_value(15 downto 8);
                    next_reg_C <= int_reg_C;
                    next_reg_D <= int_reg_D;
                WHEN "10" =>
                    next_reg_A <= int_reg_A;
                    next_reg_B <= int_reg_B;
                    next_reg_C <= new_value(15 downto 8);
                    next_reg_D <= int_reg_D;
                WHEN "11" =>
                    next_reg_A <= int_reg_A;
                    next_reg_B <= int_reg_B;
                    next_reg_C <= int_reg_C;
                    next_reg_D <= new_value(15 downto 8);
                WHEN OTHERS =>
                    next_reg_A <= int_reg_A;
                    next_reg_B <= int_reg_B;
                    next_reg_C <= int_reg_C;
                    next_reg_D <= int_reg_D;
            END CASE;
        ELSE
            next_reg_A <= int_reg_A;
            next_reg_B <= int_reg_B;
            next_reg_C <= int_reg_C;
            next_reg_D <= int_reg_D;
        END IF;
    END PROCESS;

    PROCESS(CLK,RUN,next_reg_A,next_reg_B,next_reg_C,next_reg_D)
    BEGIN
        IF RISING_EDGE(CLK) AND (RUN = '1') THEN
            int_reg_A <= next_reg_A;
            int_reg_B <= next_reg_B;
            int_reg_C <= next_reg_C;
            int_reg_D <= next_reg_D;
        END IF;
    END PROCESS;
    
    reg_A <= int_reg_A;
    reg_B <= int_reg_B;
    reg_C <= int_reg_C;
    reg_D <= int_reg_D;
    
END behavior;
        