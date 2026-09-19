library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_math is
    PORT(    
        EFFECT_ENABLE       : IN  STD_LOGIC;
        EFFECT_SELECT       : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        EFFECT_VALUE        : IN  integer range 0 to 255;
        BLANK_OUTSIDE       : IN  STD_LOGIC;
        COLOR_BLANK         : IN  integer range 0 to 255;
        COLOR_IN            : IN  integer range 0 to 255;
        COLOR_OUT           : OUT integer range 0 to 255
    );
END effect_math;

architecture Behavioral of effect_math is

    

BEGIN

    PROCESS(EFFECT_ENABLE,EFFECT_SELECT,EFFECT_VALUE,COLOR_BLANK,BLANK_OUTSIDE,COLOR_IN)
        VARIABLE colorTempAdd         : integer range 0 to 511;
        VARIABLE colorTempAddBits     : STD_LOGIC_VECTOR(8 DOWNTO 0);
        VARIABLE colorTempAddOut      : integer range 0 to 255;
        
        VARIABLE colorTempSub1        : integer range -255 to 255;
        VARIABLE colorTempSub1Bits    : STD_LOGIC_VECTOR(8 DOWNTO 0);
        VARIABLE colorTempSub1Out     : integer range 0 to 255;
        
        VARIABLE colorTempSub2        : integer range -255 to 255;
        VARIABLE colorTempSub2Bits    : STD_LOGIC_VECTOR(8 DOWNTO 0);
        VARIABLE colorTempSub2Out     : integer range 0 to 255;
    
        VARIABLE colorTempBlendOut    : integer range 0 to 255;
    
        VARIABLE colorTempMul         : integer range 0 to 65535;
        VARIABLE colorTempMulBits     : STD_LOGIC_VECTOR(15 DOWNTO 0);
        VARIABLE colorTempMulOut      : integer range 0 to 255;
    
        VARIABLE colorThreshHighOut   : integer range 0 to 255;
    
        VARIABLE colorThreshLowOut    : integer range 0 to 255;
    
    BEGIN
        colorTempAdd := COLOR_IN + EFFECT_VALUE;
        colorTempAddBits := STD_LOGIC_VECTOR(to_unsigned(colorTempAdd,9));
        
        IF colorTempAddBits(8) = '0' THEN
            colorTempAddOut := to_integer(unsigned(colorTempAddBits(7 downto 0)));
        ELSE
            colorTempAddOut := 255;
        END IF;
        
        colorTempSub1 := COLOR_IN - EFFECT_VALUE;
        colorTempSub1Bits := STD_LOGIC_VECTOR(to_signed(colorTempSub1,9));
        
        IF colorTempSub1Bits(8) = '0' THEN
            colorTempSub1Out := to_integer(unsigned(colorTempSub1Bits(7 downto 0)));
        ELSE
            colorTempSub1Out := 0;
        END IF;
        
        colorTempSub2 := EFFECT_VALUE - COLOR_IN;
        colorTempSub2Bits := STD_LOGIC_VECTOR(to_signed(colorTempSub2,9));
        
        IF colorTempSub2Bits(8) = '0' THEN
            colorTempSub2Out := to_integer(unsigned(colorTempSub2Bits(7 downto 0)));
        ELSE
            colorTempSub2Out := 0;
        END IF;
        
        colorTempBlendOut := to_integer(unsigned(colorTempAddBits(8 downto 1)));
        
        colorTempMul := COLOR_IN * EFFECT_VALUE;
        colorTempMulBits := STD_LOGIC_VECTOR(to_signed(colorTempMul,16));
        
        IF colorTempMulBits(15 downto 14) = "00" THEN
            colorTempMulOut := to_integer(unsigned(colorTempMulBits(13 downto 6)));
        ELSE
            colorTempMulOut := 255;
        END IF;
        
        IF COLOR_IN > EFFECT_VALUE THEN
            colorThreshHighOut := EFFECT_VALUE;
        ELSE
            colorThreshHighOut := COLOR_IN;
        END IF;
        
        IF COLOR_IN < EFFECT_VALUE THEN
            colorThreshLowOut := EFFECT_VALUE;
        ELSE
            colorThreshLowOut := COLOR_IN;
        END IF;
        
        IF EFFECT_ENABLE = '1' THEN
            CASE EFFECT_SELECT IS
                WHEN "000" => --Replace (output = value)
                    COLOR_OUT <= EFFECT_VALUE;
                    
                WHEN "001" => --Add (output = input + value, max 255)
                    COLOR_OUT <= colorTempAddOut;
                
                WHEN "010" => --Subtract (output = input - value, min 0)
                    COLOR_OUT <= colorTempSub1Out;
                
                WHEN "011" => --Subtract from (output = value - input, min 0)
                    COLOR_OUT <= colorTempSub2Out;
                
                WHEN "100" => --Blend (output = (input + value) / 2)  
                    COLOR_OUT <= colorTempBlendOut;
                
                WHEN "101" => --Multiply (output = (input * value) / 64, max 255)
                    COLOR_OUT <= colorTempMulOut;
                
                WHEN "110" => --Threshhold high (output = value if input > value, otherwise input)
                    COLOR_OUT <= colorThreshHighOut;
                
                WHEN "111" => --Threshhold low (output = value if input < value, otherwise input)
                    COLOR_OUT <= colorThreshLowOut;
                
                WHEN OTHERS =>
                    COLOR_OUT <= COLOR_IN;
            END CASE;
        ELSIF BLANK_OUTSIDE = '1' THEN
            COLOR_OUT <= COLOR_BLANK;
        ELSE
            COLOR_OUT <= COLOR_IN;
        END IF;
    END PROCESS;
    
END Behavioral;