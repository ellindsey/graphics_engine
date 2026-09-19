LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Mult16 IS
    PORT(
        shift       : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        SOURCE_A    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        SOURCE_B    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        RESULT      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END Mult16;

ARCHITECTURE behavior OF Mult16 IS
BEGIN
    
    PROCESS(shift,SOURCE_A,SOURCE_B) --16 bit signed multiplier
        VARIABLE sourceA            : signed(15 downto 0); 
        VARIABLE sourceB            : signed(15 downto 0); 
        VARIABLE resulttemp         : signed(31 downto 0); 
    BEGIN
        sourceA := signed(SOURCE_A);
        sourceB := signed(SOURCE_B);
        
        resulttemp := sourceA * sourceB;
        
        CASE shift IS
            WHEN "0000" =>
                RESULT <= STD_LOGIC_VECTOR(resulttemp(15 downto 0));
            WHEN "0001" =>
                RESULT <= STD_LOGIC_VECTOR(resulttemp(16 downto 1));
            WHEN "0010" =>
                RESULT <= STD_LOGIC_VECTOR(resulttemp(17 downto 2));
            WHEN "0011" =>
                RESULT <= STD_LOGIC_VECTOR(resulttemp(18 downto 3));
            WHEN "0100" =>
                RESULT <= STD_LOGIC_VECTOR(resulttemp(19 downto 4));
            WHEN "0101" =>
                RESULT <= STD_LOGIC_VECTOR(resulttemp(20 downto 5));
            WHEN "0110" =>
                RESULT <= STD_LOGIC_VECTOR(resulttemp(21 downto 6));
            WHEN "0111" =>
                RESULT <= STD_LOGIC_VECTOR(resulttemp(22 downto 7));
            WHEN "1000" =>
                RESULT <= STD_LOGIC_VECTOR(resulttemp(23 downto 8));
            WHEN "1001" =>
                RESULT <= STD_LOGIC_VECTOR(resulttemp(24 downto 9));
            WHEN "1010" =>
                RESULT <= STD_LOGIC_VECTOR(resulttemp(25 downto 10));
            WHEN "1011" =>
                RESULT <= STD_LOGIC_VECTOR(resulttemp(26 downto 11));
            WHEN "1100" =>
                RESULT <= STD_LOGIC_VECTOR(resulttemp(27 downto 12));
            WHEN "1101" =>
                RESULT <= STD_LOGIC_VECTOR(resulttemp(28 downto 13));
            WHEN "1110" =>
                RESULT <= STD_LOGIC_VECTOR(resulttemp(29 downto 14));
            WHEN "1111" =>
                RESULT <= STD_LOGIC_VECTOR(resulttemp(30 downto 15));
            WHEN OTHERS =>
                RESULT <= "0000000000000000";
        END CASE;
    END PROCESS;
END behavior;