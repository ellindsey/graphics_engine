LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY wavegen IS
   PORT(
        clk                     : IN  STD_LOGIC;
        hold                    : IN  STD_LOGIC;
        done                    : OUT STD_LOGIC;
        
        phase                   : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        wavesel                 : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        shaper                  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        priorHighBit            : IN  STD_LOGIC;
        random                  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        valueIn                 : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        valueOut                : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        
        SINE_TABLE_ADDRESS_OUT  : OUT integer range 0 to 255;
        SINE_TABLE_DATA_IN      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        INV_TABLE_ADDRESS_OUT   : OUT integer range 0 to 255;
        INV_TABLE_DATA_IN       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
END wavegen;

ARCHITECTURE behavior OF wavegen IS

    type state_type is (state_hold,
                        state_square,
                        state_triangle_1,
                        state_triangle_2,
                        state_sine_1,
                        state_sine_2,
                        state_noise,
                        state_done);
                        
    SIGNAl step             : state_type := state_hold;
    SIGNAl next_step        : state_type := state_hold;
    
    SIGNAL rawValue         : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL nextRawValue     : STD_LOGIC_VECTOR(15 DOWNTO 0);
    
    SIGNAL nextDone         : STD_LOGIC;
    
    SIGNAL multTri          : unsigned(15 downto 0);
    
    SIGNAL multSin          : unsigned(15 downto 0);
    
    SIGNAL sineStep         : STD_LOGIC;
    SIGNAl nextSineStep     : STD_LOGIC;
    
    SIGNAL phasePart        : STD_LOGIC;
    
BEGIN

    PROCESS(step,clk,phase,sineStep,phasePart,shaper,multTri,multSin,valueIn,wavesel,rawValue,random,hold,
            INV_TABLE_DATA_IN,SINE_TABLE_DATA_IN,priorHighBit)
        VARIABLE inv_mult_result    : unsigned(31 downto 0);
        VARIABLE sin_mult_result    : signed(31 downto 0);
        
    BEGIN
    
        IF phase(15 downto 8) < shaper THEN
            phasePart <= '0';
        ELSE
            phasePart <= '1';
        END IF;
        
        if sineStep = '0' THEN
            SINE_TABLE_ADDRESS_OUT <= to_integer(unsigned(phase(15 downto 8)));
            multSin <= "0000000100000000" - unsigned(phase(7 downto 0));
        ELSE
            SINE_TABLE_ADDRESS_OUT <= to_integer(unsigned(phase(15 downto 8))) + 1;
            multSin <= "00000000" & unsigned(phase(7 downto 0));
        END IF;
    
        IF phasePart = '0' THEN
            INV_TABLE_ADDRESS_OUT <= to_integer(unsigned(shaper)) - 1;
            multTri <= unsigned(phase);
        ELSE
            INV_TABLE_ADDRESS_OUT <= 255 - to_integer(unsigned(shaper));
            multTri <= 65535 - unsigned(phase);
        END IF;
                
        inv_mult_result := multTri * unsigned(INV_TABLE_DATA_IN(7 downto 0) & INV_TABLE_DATA_IN(15 downto 8));
        sin_mult_result := signed(multSin) * signed(SINE_TABLE_DATA_IN(7 downto 0) & SINE_TABLE_DATA_IN(15 downto 8));
    
        CASE step IS
            WHEN state_hold =>
                nextRawValue <= valueIn;
                nextDone <= '0';
                IF hold = '0' THEN
                    CASE wavesel IS
                        WHEN "00" =>
                            next_step <= state_square;
                        WHEN "01" =>
                            next_step <= state_triangle_1;
                        WHEN "10" =>
                            next_step <= state_sine_1;
                        WHEN "11" =>
                            next_step <= state_noise;
                        WHEN others =>
                            next_step <= state_done;
                    END CASE;
                ELSE
                    next_step <= state_hold;
                END IF;
                nextSineStep <= '0';
                
            WHEN state_square =>
                IF phasePart = '0' THEN
                    nextRawValue <= "1000000000000000"; -- largest possible negative value
                ELSE
                    nextRawValue <= "0111111111111111"; -- largest possible positive value
                END IF;
                nextDone <= '0';
                next_step <= state_done;
                nextSineStep <= '0';
                
            WHEN state_triangle_1 =>
                nextRawValue <= "0000000000000000";
                nextDone <= '0';
                next_step <= state_triangle_2;
                nextSineStep <= '0';
                
            WHEN state_triangle_2 =>
                nextRawValue <= std_logic_vector(not inv_mult_result(22) & inv_mult_result(21 downto 7));
                nextDone <= '0';
                next_step <= state_done;
                nextSineStep <= '0';
           
            WHEN state_sine_1 =>
                nextRawValue <= std_logic_vector(sin_mult_result(23 downto 8));
                nextDone <= '0';
                next_step <= state_sine_2;
                nextSineStep <= '1';
                
            WHEN state_sine_2 =>
                nextRawValue <= std_logic_vector(signed(rawValue) + sin_mult_result(23 downto 8));
                nextDone <= '0';
                next_step <= state_done;
                nextSineStep <= '0';
                
            WHEN state_noise =>
                IF phase(15) = priorHighBit THEN
                    nextRawValue <= valueIn;
                ELSE
                    nextRawValue <= random;
                END IF;
                nextDone <= '0';
                next_step <= state_done;
                nextSineStep <= '0';
                
            WHEN state_done =>
                nextRawValue <= rawValue;
                nextDone <= '1';
                IF hold = '1' THEN
                    next_step <= state_hold;
                ELSE
                    next_step <= state_done;
                END IF;
                nextSineStep <= '0';
                
            WHEN others =>
                nextRawValue <= "0000000000000000";
                nextDone <= '0';
                next_step <= state_done;
                nextSineStep <= '0';
        END CASE;
    END PROCESS;
    
    PROCESS(CLK)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            step <= next_step;
            rawValue <= nextRawValue;
            done <= nextDone;
            sineStep <= nextSineStep;
        END IF;
    END PROCESS;
    
    valueOut <= rawValue;

END behavior;