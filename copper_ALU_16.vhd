LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY copperALU16 IS
    PORT(
        opSelect    : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        SOURCE_A    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        SOURCE_B    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        CarryIn     : IN  STD_LOGIC;
        RESULT      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        CarryOut    : OUT STD_LOGIC;
        ZeroOut     : OUT STD_LOGIC
    );
END copperALU16;

ARCHITECTURE behavior OF copperALU16 IS
BEGIN
    
    PROCESS(opSelect,SOURCE_A,SOURCE_B,CarryIn) --16 bit ALU
        VARIABLE resultTemp  : integer range 0 to 131071;
        VARIABLE sourceAtemp : integer range 0 to 65535;
        VARIABLE sourceBtemp : integer range 0 to 65535;
        VARIABLE resultVec   : STD_LOGIC_VECTOR(16 DOWNTO 0);
 
    BEGIN
        sourceAtemp := to_integer(unsigned(SOURCE_A));
        sourceBtemp := to_integer(unsigned(SOURCE_B));
        
        CASE opSelect IS
            WHEN "000" => --add without carry
                resultTemp := sourceAtemp + sourceBtemp;
                resultVec := STD_LOGIC_VECTOR(to_unsigned(resultTemp,17));
                RESULT <= resultVec(15 downto 0);
                CarryOut <= CarryIn;
                
            WHEN "001" => --subtract without carry
                resultTemp := (sourceAtemp + 65536) - sourceBtemp;
                resultVec := STD_LOGIC_VECTOR(to_unsigned(resultTemp,17));
                RESULT <= resultVec(15 downto 0);
                CarryOut <= CarryIn;
                
            WHEN "010" => --add with carry
                IF CarryIn THEN
                    resultTemp := sourceAtemp + sourceBtemp + 1;
                ELSE
                    resultTemp := sourceAtemp + sourceBtemp;
                END IF;
                resultVec := STD_LOGIC_VECTOR(to_unsigned(resultTemp,17));
                RESULT <= resultVec(15 downto 0);
                CarryOut <= resultVec(16);
            
            WHEN "011" => --subtract with carry
                IF CarryIn THEN
                    resultTemp := (sourceAtemp + 65536) - (sourceBtemp + 1);
                ELSE
                    resultTemp := (sourceAtemp + 65536) - sourceBtemp;
                END IF;
                resultVec := STD_LOGIC_VECTOR(to_unsigned(resultTemp,17));
                RESULT <= resultVec(15 downto 0);
                CarryOut <= resultVec(16);
            
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
                IF SOURCE_B(15) = '0' THEN
                    CASE SOURCE_B(3 downto 0) IS
                        WHEN "0000" =>
                            RESULT <= SOURCE_A;
                            CarryOut <= CarryIn;
                        WHEN "0001" =>
                            RESULT <= SOURCE_A(14 downto 0) & "0";
                            CarryOut <= SOURCE_A(15);
                        WHEN "0010" =>
                            RESULT <= SOURCE_A(13 downto 0) & "00";
                            CarryOut <= SOURCE_A(14);
                        WHEN "0011" =>
                            RESULT <= SOURCE_A(12 downto 0) & "000";
                            CarryOut <= SOURCE_A(13);
                        WHEN "0100" =>
                            RESULT <= SOURCE_A(11 downto 0) & "0000";
                            CarryOut <= SOURCE_A(12);
                        WHEN "0101" =>
                            RESULT <= SOURCE_A(10 downto 0) & "00000";
                            CarryOut <= SOURCE_A(11);
                        WHEN "0110" =>
                            RESULT <= SOURCE_A(9 downto 0) & "000000";
                            CarryOut <= SOURCE_A(10);
                        WHEN "0111" =>
                            RESULT <= SOURCE_A(8 downto 0) & "0000000";
                            CarryOut <= SOURCE_A(9);
                        WHEN "1000" =>
                            RESULT <= SOURCE_A(7 downto 0) & "00000000";
                            CarryOut <= SOURCE_A(8);
                        WHEN "1001" =>
                            RESULT <= SOURCE_A(6 downto 0) & "000000000";
                            CarryOut <= SOURCE_A(7);
                        WHEN "1010" =>
                            RESULT <= SOURCE_A(5 downto 0) & "0000000000";
                            CarryOut <= SOURCE_A(6);
                        WHEN "1011" =>
                            RESULT <= SOURCE_A(4 downto 0) & "00000000000";
                            CarryOut <= SOURCE_A(5);
                        WHEN "1100" =>
                            RESULT <= SOURCE_A(3 downto 0) & "000000000000";
                            CarryOut <= SOURCE_A(4);
                        WHEN "1101" =>
                            RESULT <= SOURCE_A(2 downto 0) & "0000000000000";
                            CarryOut <= SOURCE_A(3);
                        WHEN "1110" =>
                            RESULT <= SOURCE_A(1 downto 0) & "00000000000000";
                            CarryOut <= SOURCE_A(2);
                        WHEN "1111" =>
                            RESULT <= SOURCE_A(0) & "000000000000000";
                            CarryOut <= SOURCE_A(1);
                        WHEN OTHERS =>
                            RESULT <= "0000000000000000";
                            CarryOut <= '0';
                    END CASE;
                ELSE
                    CASE SOURCE_B(3 downto 0) IS
                        WHEN "0000" =>
                            RESULT <= "0000000000000000";
                            CarryOut <= SOURCE_A(15);
                        WHEN "0001" =>
                            RESULT <= "000000000000000" & SOURCE_A(15);
                            CarryOut <= SOURCE_A(14);
                        WHEN "0010" =>
                            RESULT <= "00000000000000" & SOURCE_A(15 downto 14);
                            CarryOut <= SOURCE_A(13);
                        WHEN "0011" =>
                            RESULT <= "0000000000000" & SOURCE_A(15 downto 13);
                            CarryOut <= SOURCE_A(12);
                        WHEN "0100" =>
                            RESULT <= "000000000000" & SOURCE_A(15 downto 12);
                            CarryOut <= SOURCE_A(11);
                        WHEN "0101" =>
                            RESULT <= "00000000000" & SOURCE_A(15 downto 11);
                            CarryOut <= SOURCE_A(10);
                        WHEN "0110" =>
                            RESULT <= "0000000000" & SOURCE_A(15 downto 10);
                            CarryOut <= SOURCE_A(9);
                        WHEN "0111" =>
                            RESULT <= "000000000" & SOURCE_A(15 downto 9);
                            CarryOut <= SOURCE_A(8);
                        WHEN "1000" =>
                            RESULT <= "00000000" & SOURCE_A(15 downto 8);
                            CarryOut <= SOURCE_A(7);
                        WHEN "1001" =>
                            RESULT <= "0000000" & SOURCE_A(15 downto 7);
                            CarryOut <= SOURCE_A(6);
                        WHEN "1010" =>
                            RESULT <= "000000" & SOURCE_A(15 downto 6);
                            CarryOut <= SOURCE_A(5);
                        WHEN "1011" =>
                            RESULT <= "00000" & SOURCE_A(15 downto 5);
                            CarryOut <= SOURCE_A(4);
                        WHEN "1100" =>
                            RESULT <= "0000" & SOURCE_A(15 downto 4);
                            CarryOut <= SOURCE_A(3);
                        WHEN "1101" =>
                            RESULT <= "000" & SOURCE_A(15 downto 3);
                            CarryOut <= SOURCE_A(2);
                        WHEN "1110" =>
                            RESULT <= "00" & SOURCE_A(15 downto 2);
                            CarryOut <= SOURCE_A(1);
                        WHEN "1111" =>
                            RESULT <= "0" & SOURCE_A(15 downto 1);
                            CarryOut <= SOURCE_A(0);
                        WHEN OTHERS =>
                            RESULT <= "0000000000000000";
                            CarryOut <= '0';
                    END CASE;
                END IF;
                
            WHEN OTHERS =>
                RESULT     <= "0000000000000000";
                CarryOut   <= '0';
        END CASE;
        
        IF (RESULT = "0000000000000000") THEN
            ZeroOut <= '1';
        ELSE
            ZeroOut <= '0';
        END IF;
    END PROCESS;
END behavior;