LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY ALU IS
    PORT(
        alu_op_select           : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        alu_A                   : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        alu_B                   : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        alu_carry_in            : IN STD_LOGIC;
        alu_result              : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        alu_carry_out           : OUT STD_LOGIC;
        alu_zero_out            : OUT STD_LOGIC;
        alu_sign_out            : OUT STD_LOGIC
    );
END ALU;

ARCHITECTURE behavior OF ALU IS
    SIGNAL result               : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
    
    PROCESS(alu_op_select,alu_A,alu_B,alu_carry_in)
        VARIABLE resultTemp  : integer range 0 to 131071;
        VARIABLE sourceAtemp : integer range 0 to 65535;
        VARIABLE sourceBtemp : integer range 0 to 65535;
        VARIABLE resultVec   : STD_LOGIC_VECTOR(16 DOWNTO 0);

    BEGIN        
        sourceAtemp := to_integer(unsigned(alu_A));
        sourceBtemp := to_integer(unsigned(alu_B));
        
        CASE alu_op_select IS

            WHEN "000" => --add without carry
                resultTemp := sourceAtemp + sourceBtemp;
                resultVec := STD_LOGIC_VECTOR(to_unsigned(resultTemp,17));
                result <= resultVec(15 downto 0);
                alu_carry_out <= alu_carry_in;
                
            WHEN "001" => --subtract without carry
                resultTemp := (sourceAtemp + 65536) - sourceBtemp;
                resultVec := STD_LOGIC_VECTOR(to_unsigned(resultTemp,17));
                result <= resultVec(15 downto 0);
                alu_carry_out <= alu_carry_in;
                
            WHEN "010" => --add with carry
                IF alu_carry_in THEN
                    resultTemp := sourceAtemp + sourceBtemp + 1;
                ELSE
                    resultTemp := sourceAtemp + sourceBtemp;
                END IF;
                resultVec := STD_LOGIC_VECTOR(to_unsigned(resultTemp,17));
                result <= resultVec(15 downto 0);
                alu_carry_out <= resultVec(16);
            
            WHEN "011" => --subtract with carry
                IF alu_carry_in THEN
                    resultTemp := (sourceAtemp + 65536) - (sourceBtemp + 1);
                ELSE
                    resultTemp := (sourceAtemp + 65536) - sourceBtemp;
                END IF;
                resultVec := STD_LOGIC_VECTOR(to_unsigned(resultTemp,17));
                result <= resultVec(15 downto 0);
                alu_carry_out <= resultVec(16);
            
            WHEN "100" => --and
                result <= alu_A AND alu_B;
                alu_carry_out <= alu_carry_in;
                
            WHEN "101" => --or
                result <= alu_A OR alu_B;
                alu_carry_out <= alu_carry_in;
                
            WHEN "110" => --xor
                result <= alu_A XOR alu_B;
                alu_carry_out <= alu_carry_in;
                
            WHEN "111" => --rotate A left/right by B
                IF alu_B(15) = '0' THEN
                    CASE alu_B(3 downto 0) IS
                        WHEN "0000" =>
                            result <= alu_A;
                            alu_carry_out <= alu_carry_in;
                        WHEN "0001" =>
                            result <= alu_A(14 downto 0) & "0";
                            alu_carry_out <= alu_A(15);
                        WHEN "0010" =>
                            result <= alu_A(13 downto 0) & "00";
                            alu_carry_out <= alu_A(14);
                        WHEN "0011" =>
                            result <= alu_A(12 downto 0) & "000";
                            alu_carry_out <= alu_A(13);
                        WHEN "0100" =>
                            result <= alu_A(11 downto 0) & "0000";
                            alu_carry_out <= alu_A(12);
                        WHEN "0101" =>
                            result <= alu_A(10 downto 0) & "00000";
                            alu_carry_out <= alu_A(11);
                        WHEN "0110" =>
                            result <= alu_A(9 downto 0) & "000000";
                            alu_carry_out <= alu_A(10);
                        WHEN "0111" =>
                            result <= alu_A(8 downto 0) & "0000000";
                            alu_carry_out <= alu_A(9);
                        WHEN "1000" =>
                            result <= alu_A(7 downto 0) & "00000000";
                            alu_carry_out <= alu_A(8);
                        WHEN "1001" =>
                            result <= alu_A(6 downto 0) & "000000000";
                            alu_carry_out <= alu_A(7);
                        WHEN "1010" =>
                            result <= alu_A(5 downto 0) & "0000000000";
                            alu_carry_out <= alu_A(6);
                        WHEN "1011" =>
                            result <= alu_A(4 downto 0) & "00000000000";
                            alu_carry_out <= alu_A(5);
                        WHEN "1100" =>
                            result <= alu_A(3 downto 0) & "000000000000";
                            alu_carry_out <= alu_A(4);
                        WHEN "1101" =>
                            result <= alu_A(2 downto 0) & "0000000000000";
                            alu_carry_out <= alu_A(3);
                        WHEN "1110" =>
                            result <= alu_A(1 downto 0) & "00000000000000";
                            alu_carry_out <= alu_A(2);
                        WHEN "1111" =>
                            result <= alu_A(0) & "000000000000000";
                            alu_carry_out <= alu_A(1);
                        WHEN OTHERS =>
                            result <= "0000000000000000";
                            alu_carry_out <= '0';
                    END CASE;
                ELSE
                    CASE alu_B(3 downto 0) IS
                        WHEN "0000" =>
                            result <= "0000000000000000";
                            alu_carry_out <= alu_A(15);
                        WHEN "0001" =>
                            result <= "000000000000000" & alu_A(15);
                            alu_carry_out <= alu_A(14);
                        WHEN "0010" =>
                            result <= "00000000000000" & alu_A(15 downto 14);
                            alu_carry_out <= alu_A(13);
                        WHEN "0011" =>
                            result <= "0000000000000" & alu_A(15 downto 13);
                            alu_carry_out <= alu_A(12);
                        WHEN "0100" =>
                            result <= "000000000000" & alu_A(15 downto 12);
                            alu_carry_out <= alu_A(11);
                        WHEN "0101" =>
                            result <= "00000000000" & alu_A(15 downto 11);
                            alu_carry_out <= alu_A(10);
                        WHEN "0110" =>
                            result <= "0000000000" & alu_A(15 downto 10);
                            alu_carry_out <= alu_A(9);
                        WHEN "0111" =>
                            result <= "000000000" & alu_A(15 downto 9);
                            alu_carry_out <= alu_A(8);
                        WHEN "1000" =>
                            result <= "00000000" & alu_A(15 downto 8);
                            alu_carry_out <= alu_A(7);
                        WHEN "1001" =>
                            result <= "0000000" & alu_A(15 downto 7);
                            alu_carry_out <= alu_A(6);
                        WHEN "1010" =>
                            result <= "000000" & alu_A(15 downto 6);
                            alu_carry_out <= alu_A(5);
                        WHEN "1011" =>
                            result <= "00000" & alu_A(15 downto 5);
                            alu_carry_out <= alu_A(4);
                        WHEN "1100" =>
                            result <= "0000" & alu_A(15 downto 4);
                            alu_carry_out <= alu_A(3);
                        WHEN "1101" =>
                            result <= "000" & alu_A(15 downto 3);
                            alu_carry_out <= alu_A(2);
                        WHEN "1110" =>
                            result <= "00" & alu_A(15 downto 2);
                            alu_carry_out <= alu_A(1);
                        WHEN "1111" =>
                            result <= "0" & alu_A(15 downto 1);
                            alu_carry_out <= alu_A(0);
                        WHEN OTHERS =>
                            result <= "0000000000000000";
                            alu_carry_out <= '0';
                    END CASE;
                END IF;
            WHEN OTHERS => 
                result <= "0000000000000000";
                alu_carry_out <= '0';
                
        END CASE;
    END PROCESS;
    
    PROCESS(result)
    BEGIN
        IF result = "0000000000000000" THEN
            alu_zero_out <= '1';
        ELSE
            alu_zero_out <= '0';
        END IF;
    END PROCESS;
    
    alu_sign_out <= result(15);
    
    alu_result <= result;
    
END behavior;