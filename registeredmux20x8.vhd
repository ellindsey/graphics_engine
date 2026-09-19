LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY registeredmux20x8 IS
   PORT(
      CLK             : IN  STD_LOGIC;
      
      S0              : IN  STD_LOGIC;
      Q0              : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      
      S1              : IN  STD_LOGIC;
      Q1              : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      
      S2              : IN  STD_LOGIC;
      Q2              : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      
      S3              : IN  STD_LOGIC;
      Q3              : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      
      S4              : IN  STD_LOGIC;
      Q4              : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      
      S5              : IN  STD_LOGIC;
      Q5              : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      
      S6              : IN  STD_LOGIC;
      Q6              : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      
      S7              : IN  STD_LOGIC;
      Q7              : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      
      S8              : IN  STD_LOGIC;
      Q8              : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      
      S9              : IN  STD_LOGIC;
      Q9              : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      
      S10             : IN  STD_LOGIC;
      Q10             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      
      S11             : IN  STD_LOGIC;
      Q11             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      
      S12             : IN  STD_LOGIC;
      Q12             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      
      S13             : IN  STD_LOGIC;
      Q13             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      
      S14             : IN  STD_LOGIC;
      Q14             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      
      S15             : IN  STD_LOGIC;
      Q15             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      
      S16             : IN  STD_LOGIC;
      Q16             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      
      S17             : IN  STD_LOGIC;
      Q17             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      
      S18             : IN  STD_LOGIC;
      Q18             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      
      S19             : IN  STD_LOGIC;
      Q19             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      
      D               : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      
      );
END registeredmux20x8;

ARCHITECTURE behavioral OF registeredmux20x8 IS

BEGIN
    PROCESS (CLK,S0,Q0,S1,Q1,S2,Q2,S3,Q3,S4,Q4,S5,Q5,S6,Q6,S7,Q7,S8,Q8,S9,Q9,
             S10,Q10,S11,Q11,S12,Q12,S13,Q13,S14,Q14,S15,Q15,S16,Q16,S17,Q17,S18,Q18,S19,Q19)

        VARIABLE D0INT          : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D1INT          : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D2INT          : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D3INT          : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D4INT          : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D5INT          : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D6INT          : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D7INT          : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D8INT          : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D9INT          : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D10INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D11INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D12INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D13INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D14INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D15INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D16INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D17INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D18INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D19INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D20INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D21INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D22INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D23INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D24INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D25INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D26INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D27INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D28INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D29INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D30INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D31INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D32INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D33INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D34INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D35INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D36INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE D37INT         : STD_LOGIC_VECTOR(7 DOWNTO 0);
        
    BEGIN
        --IF RISING_EDGE(CLK) THEN
            IF S0 = '1' THEN
                D0INT := Q0;
            ELSE
                D0INT := "00000000";
            END IF;
            
            IF S1 = '1' THEN
                D1INT := Q1;
            ELSE
                D1INT := "00000000";
            END IF;
            
            IF S2 = '1' THEN
                D2INT := Q2;
            ELSE
                D2INT := "00000000";
            END IF;
            
            IF S3 = '1' THEN
                D3INT := Q3;
            ELSE
                D3INT := "00000000";
            END IF;
            
            IF S4 = '1' THEN
                D4INT := Q4;
            ELSE
                D4INT := "00000000";
            END IF;
            
            IF S5 = '1' THEN
                D5INT := Q5;
            ELSE
                D5INT := "00000000";
            END IF;
            
            IF S6 = '1' THEN
                D6INT := Q6;
            ELSE
                D6INT := "00000000";
            END IF;
            
            IF S7 = '1' THEN
                D7INT := Q7;
            ELSE
                D7INT := "00000000";
            END IF;
            
            IF S8 = '1' THEN
                D8INT := Q8;
            ELSE
                D8INT := "00000000";
            END IF;
            
            IF S9 = '1' THEN
                D9INT := Q9;
            ELSE
                D9INT := "00000000";
            END IF;
            
            IF S10 = '1' THEN
                D10INT := Q10;
            ELSE
                D10INT := "00000000";
            END IF;
            
            IF S11 = '1' THEN
                D11INT := Q11;
            ELSE
                D11INT := "00000000";
            END IF;
            
            IF S12 = '1' THEN
                D12INT := Q12;
            ELSE
                D12INT := "00000000";
            END IF;
            
            IF S13 = '1' THEN
                D13INT := Q13;
            ELSE
                D13INT := "00000000";
            END IF;
            
            IF S14 = '1' THEN
                D14INT := Q14;
            ELSE
                D14INT := "00000000";
            END IF;
            
            IF S15 = '1' THEN
                D15INT := Q15;
            ELSE
                D15INT := "00000000";
            END IF;
            
            IF S16 = '1' THEN
                D16INT := Q16;
            ELSE
                D16INT := "00000000";
            END IF;
            
            IF S17 = '1' THEN
                D17INT := Q17;
            ELSE
                D17INT := "00000000";
            END IF;
            
            IF S18 = '1' THEN
                D18INT := Q18;
            ELSE
                D18INT := "00000000";
            END IF;
            
            IF S19 = '1' THEN
                D19INT := Q19;
            ELSE
                D19INT := "00000000";
            END IF;
        --END IF;
        
        D20INT := D0INT OR D1INT;
        D21INT := D2INT OR D3INT;
        D22INT := D4INT OR D5INT;
        D23INT := D6INT OR D7INT;
        D24INT := D8INT OR D9INT;
        D25INT := D10INT OR D11INT;
        D26INT := D12INT OR D13INT;
        D27INT := D14INT OR D15INT;
        D28INT := D16INT OR D17INT;
        D29INT := D18INT OR D19INT;
        
        D30INT := D20INT OR D21INT;
        D31INT := D22INT OR D23INT;
        D32INT := D24INT OR D25INT;
        D33INT := D26INT OR D27INT;
        D34INT := D28INT OR D29INT;
        
        D35INT := D30INT OR D31INT;
        D36INT := D32INT OR D33INT;
        
        D37INT := D34INT OR D35INT;
        
        IF RISING_EDGE(CLK) THEN
            D <= D36INT OR D37INT;
        END IF;
    END PROCESS;
END behavioral;