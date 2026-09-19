LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY copperALU8 IS
    PORT(
        opSelect    : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        SOURCE_A    : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        SOURCE_B    : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        CarryIn     : IN  STD_LOGIC;
        RESULT      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        CarryOut    : OUT STD_LOGIC;
        ZeroOut     : OUT STD_LOGIC
    );
END copperALU8;

ARCHITECTURE behavior OF copperALU8 IS
BEGIN
    
    PROCESS(opSelect,SOURCE_A,SOURCE_B,CarryIn) --8 bit ALU
        VARIABLE resultTemp  : integer range 0 to 511;
        VARIABLE sourceAtemp : integer range 0 to 255;
        VARIABLE sourceBtemp : integer range 0 to 255;
        VARIABLE resultVec   : STD_LOGIC_VECTOR(8 DOWNTO 0);
 
    BEGIN
        sourceAtemp := to_integer(unsigned(SOURCE_A));
        sourceBtemp := to_integer(unsigned(SOURCE_B));
        
        CASE opSelect IS
            WHEN "000" => --add without carry
                resultTemp := sourceAtemp + sourceBtemp;
                resultVec := STD_LOGIC_VECTOR(to_unsigned(resultTemp,9));
                RESULT <= resultVec(7 downto 0);
                CarryOut <= CarryIn;
                
            WHEN "001" => --subtract without carry
                resultTemp := (sourceAtemp + 256) - sourceBtemp;
                resultVec := STD_LOGIC_VECTOR(to_unsigned(resultTemp,9));
                RESULT <= resultVec(7 downto 0);
                CarryOut <= CarryIn;
                
            WHEN "010" => --add with carry
                IF CarryIn THEN
                    resultTemp := sourceAtemp + sourceBtemp + 1;
                ELSE
                    resultTemp := sourceAtemp + sourceBtemp;
                END IF;
                resultVec := STD_LOGIC_VECTOR(to_unsigned(resultTemp,9));
                RESULT <= resultVec(7 downto 0);
                CarryOut <= resultVec(8);
            
            WHEN "011" => --subtract with carry
                IF CarryIn THEN
                    resultTemp := (sourceAtemp + 256) - (sourceBtemp + 1);
                ELSE
                    resultTemp := (sourceAtemp + 256) - sourceBtemp;
                END IF;
                resultVec := STD_LOGIC_VECTOR(to_unsigned(resultTemp,9));
                RESULT <= resultVec(7 downto 0);
                CarryOut <= resultVec(8);
            
            WHEN "100" => --and
                RESULT <= SOURCE_A AND SOURCE_B;
                CarryOut <= CarryIn;
                
            WHEN "101" => --or
                RESULT <= SOURCE_A OR SOURCE_B;
                CarryOut <= CarryIn;
                
            WHEN "110" => --xor
                RESULT <= SOURCE_A XOR SOURCE_B;
                CarryOut <= CarryIn;
                
            WHEN "111" => --rotate A left/right by B
                IF SOURCE_B(7) = '0' THEN
                    CASE SOURCE_B(2 downto 0) IS
                        WHEN "000" =>
                            RESULT <= SOURCE_A;
                            CarryOut <= CarryIn;
                        WHEN "001" =>
                            RESULT <= SOURCE_A(6 downto 0) & "0";
                            CarryOut <= SOURCE_A(7);
                        WHEN "010" =>
                            RESULT <= SOURCE_A(5 downto 0) & "00";
                            CarryOut <= SOURCE_A(6);
                        WHEN "011" =>
                            RESULT <= SOURCE_A(4 downto 0) & "000";
                            CarryOut <= SOURCE_A(5);
                        WHEN "100" =>
                            RESULT <= SOURCE_A(3 downto 0) & "0000";
                            CarryOut <= SOURCE_A(4);
                        WHEN "101" =>
                            RESULT <= SOURCE_A(2 downto 0) & "00000";
                            CarryOut <= SOURCE_A(3);
                        WHEN "110" =>
                            RESULT <= SOURCE_A(1 downto 0) & "000000";
                            CarryOut <= SOURCE_A(2);
                        WHEN "111" =>
                            RESULT <= SOURCE_A(0) & "0000000";
                            CarryOut <= SOURCE_A(1);
                        WHEN OTHERS =>
                            RESULT <= "00000000";
                            CarryOut <= '0';
                    END CASE;
                ELSE
                    CASE SOURCE_B(2 downto 0) IS
                        WHEN "000" =>
                            RESULT <= "00000000";
                            CarryOut <= SOURCE_A(7);
                        WHEN "001" =>
                            RESULT <= "0000000" & SOURCE_A(7);
                            CarryOut <= SOURCE_A(6);
                        WHEN "010" =>
                            RESULT <= "000000" & SOURCE_A(7 downto 6);
                            CarryOut <= SOURCE_A(5);
                        WHEN "011" =>
                            RESULT <= "00000" & SOURCE_A(7 downto 5);
                            CarryOut <= SOURCE_A(4);
                        WHEN "100" =>
                            RESULT <= "0000" & SOURCE_A(7 downto 4);
                            CarryOut <= SOURCE_A(3);
                        WHEN "101" =>
                            RESULT <= "000" & SOURCE_A(7 downto 3);
                            CarryOut <= SOURCE_A(2);
                        WHEN "110" =>
                            RESULT <= "00" & SOURCE_A(7 downto 2);
                            CarryOut <= SOURCE_A(1);
                        WHEN "111" =>
                            RESULT <= "0" & SOURCE_A(7 downto 1);
                            CarryOut <= SOURCE_A(0);
                        WHEN OTHERS =>
                            RESULT <= "00000000";
                            CarryOut <= '0';
                    END CASE;
                END IF;
                
            WHEN OTHERS =>
                RESULT     <= "00000000";
                CarryOut   <= '0';
        END CASE;
        
        IF (RESULT = "00000000") THEN
            ZeroOut <= '1';
        ELSE
            ZeroOut <= '0';
        END IF;
        
    END PROCESS;
END behavior;