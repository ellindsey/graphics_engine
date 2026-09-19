library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity windowed_effects is
    PORT(    
        CLK                 : IN  STD_LOGIC;
        CONTROL_BITS        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        R_BLANK_VALUE       : IN  integer range 0 to 255;
        G_BLANK_VALUE       : IN  integer range 0 to 255;
        B_BLANK_VALUE       : IN  integer range 0 to 255;
        R_VALUE             : IN  integer range 0 to 255;
        G_VALUE             : IN  integer range 0 to 255;
        B_VALUE             : IN  integer range 0 to 255;
        WINDOW_START_0      : IN  integer range 0 to 511;
        WINDOW_STOP_0       : IN  integer range 0 to 511;
        WINDOW_START_1      : IN  integer range 0 to 511;
        WINDOW_STOP_1       : IN  integer range 0 to 511;
        X_ADDRESS           : IN  integer range 0 to 511;
        COLOR_IN_RED_BITS   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        COLOR_IN_GREEN_BITS : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        COLOR_IN_BLUE_BITS  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        COLOR_OUT_RED_BITS  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        COLOR_OUT_GREEN_BITS: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        COLOR_OUT_BLUE_BITS : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END windowed_effects;

architecture Behavioral of windowed_effects is

    COMPONENT window_compare is
        PORT(    
            WINDOW_ENABLE       : IN  STD_LOGIC;
            WINDOW_INVERT       : IN  STD_LOGIC;
            WINDOW_START        : IN  integer range 0 to 511;
            WINDOW_STOP         : IN  integer range 0 to 511;
            POSITION            : IN  integer range 0 to 511;
            IN_WINDOW           : OUT STD_LOGIC
        );
    END COMPONENT window_compare;

    COMPONENT effect_math is
        PORT(    
            EFFECT_ENABLE       : IN  STD_LOGIC;
            EFFECT_SELECT       : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            EFFECT_VALUE        : IN  integer range 0 to 255;
            BLANK_OUTSIDE       : IN  STD_LOGIC;
            COLOR_BLANK         : IN  integer range 0 to 255;
            COLOR_IN            : IN  integer range 0 to 255;
            COLOR_OUT           : OUT integer range 0 to 255
        );
    END COMPONENT effect_math;
    
    SIGNAL  window_enable_0         : STD_LOGIC;
    SIGNAL  window_enable_1         : STD_LOGIC;
    SIGNAL  window_invert_0         : STD_LOGIC;
    SIGNAL  window_invert_1         : STD_LOGIC;
    SIGNAL  window_mask_logic       : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL  red_effect_select       : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL  green_effect_select     : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL  blue_effect_select      : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL  blank_outside_window    : STD_LOGIC;
   
    SIGNAL  color_in_red            : integer range 0 to 255;
    SIGNAL  color_in_green          : integer range 0 to 255;
    SIGNAL  color_in_blue           : integer range 0 to 255;
    
    SIGNAL  color_out_red           : integer range 0 to 255;
    SIGNAL  color_out_green         : integer range 0 to 255;
    SIGNAL  color_out_blue          : integer range 0 to 255;
    
    SIGNAL  in_window_0             : STD_LOGIC;
    SIGNAL  in_window_1             : STD_LOGIC;
    SIGNAL  in_window               : STD_LOGIC;
    
    SIGNAL  CONTROL_BITS_int        : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL  R_BLANK_VALUE_int       : integer range 0 to 255;
    SIGNAL  G_BLANK_VALUE_int       : integer range 0 to 255;
    SIGNAL  B_BLANK_VALUE_int       : integer range 0 to 255;
    SIGNAL  R_VALUE_int             : integer range 0 to 255;
    SIGNAL  G_VALUE_int             : integer range 0 to 255;
    SIGNAL  B_VALUE_int             : integer range 0 to 255;
    SIGNAL  WINDOW_START_0_int      : integer range 0 to 511;
    SIGNAL  WINDOW_STOP_0_int       : integer range 0 to 511;
    SIGNAL  WINDOW_START_1_int      : integer range 0 to 511;
    SIGNAL  WINDOW_STOP_1_int       : integer range 0 to 511;
    
BEGIN

    PROCESS(CLK,CONTROL_BITS,R_BLANK_VALUE,G_BLANK_VALUE,B_BLANK_VALUE,R_VALUE,G_VALUE,B_VALUE,WINDOW_START_0,WINDOW_STOP_0,WINDOW_START_1,WINDOW_STOP_1)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            CONTROL_BITS_int <= CONTROL_BITS;
            R_BLANK_VALUE_int <= R_BLANK_VALUE;
            G_BLANK_VALUE_int <= G_BLANK_VALUE;
            B_BLANK_VALUE_int <= B_BLANK_VALUE;
            R_VALUE_int <= R_VALUE;
            G_VALUE_int <= G_VALUE;
            B_VALUE_int <= B_VALUE;
            WINDOW_START_0_int <= WINDOW_START_0;
            WINDOW_STOP_0_int <= WINDOW_STOP_0;
            WINDOW_START_1_int <= WINDOW_START_1;
            WINDOW_STOP_1_int <= WINDOW_STOP_1;
        END IF;
    END PROCESS;

    window_enable_0 <= CONTROL_BITS_int(0);
    window_enable_1 <= CONTROL_BITS_int(1);
    window_invert_0 <= CONTROL_BITS_int(2);
    window_invert_1 <= CONTROL_BITS_int(3);
    window_mask_logic <= CONTROL_BITS_int(5 downto 4);
    red_effect_select <= CONTROL_BITS_int(8 downto 6);
    green_effect_select <= CONTROL_BITS_int(11 downto 9);
    blue_effect_select <= CONTROL_BITS_int(14 downto 12);
    blank_outside_window <= CONTROL_BITS_int(15);
    
    color_in_red <= to_integer(unsigned(COLOR_IN_RED_BITS));
    color_in_green <= to_integer(unsigned(COLOR_IN_GREEN_BITS));
    color_in_blue <= to_integer(unsigned(COLOR_IN_BLUE_BITS));
    
    window_compare_0 : window_compare
        PORT MAP (
            WINDOW_ENABLE       => window_enable_0,
            WINDOW_INVERT       => window_invert_0,
            WINDOW_START        => WINDOW_START_0_int,
            WINDOW_STOP         => WINDOW_STOP_0_int,
            POSITION            => X_ADDRESS,
            IN_WINDOW           => in_window_0
        );
    
    window_compare_1 : window_compare
        PORT MAP (
            WINDOW_ENABLE       => window_enable_1,
            WINDOW_INVERT       => window_invert_1,
            WINDOW_START        => WINDOW_START_1_int,
            WINDOW_STOP         => WINDOW_STOP_1_int,
            POSITION            => X_ADDRESS,
            IN_WINDOW           => in_window_1
        );
        
    PROCESS(in_window_0,in_window_1,window_mask_logic)
    BEGIN
        CASE window_mask_logic IS
            WHEN "00" =>
                in_window <= in_window_0 AND in_window_1;
                
            WHEN "01" =>
                in_window <= in_window_0 OR in_window_1;
            
            WHEN "10" =>
                in_window <= in_window_0 XOR in_window_1;
            
            WHEN "11" =>
                in_window <= NOT (in_window_0 XOR in_window_1);
            
            WHEN OTHERS =>
                in_window <= '0';
        END CASE;
    END PROCESS;
    
    effect_math_red : effect_math
        PORT MAP (
            EFFECT_ENABLE       => in_window,
            EFFECT_SELECT       => red_effect_select,
            EFFECT_VALUE        => R_VALUE_int,
            BLANK_OUTSIDE       => blank_outside_window,
            COLOR_BLANK         => R_BLANK_VALUE_int,
            COLOR_IN            => color_in_red,
            COLOR_OUT           => color_out_red
        );
    
    effect_math_green: effect_math
        PORT MAP (
            EFFECT_ENABLE       => in_window,
            EFFECT_SELECT       => green_effect_select,
            EFFECT_VALUE        => G_VALUE_int,
            BLANK_OUTSIDE       => blank_outside_window,
            COLOR_BLANK         => G_BLANK_VALUE_int,
            COLOR_IN            => color_in_green,
            COLOR_OUT           => color_out_green
        );
    
    effect_math_blue: effect_math
        PORT MAP (
            EFFECT_ENABLE       => in_window,
            EFFECT_SELECT       => blue_effect_select,
            EFFECT_VALUE        => B_VALUE_int,
            BLANK_OUTSIDE       => blank_outside_window,
            COLOR_BLANK         => B_BLANK_VALUE_int,
            COLOR_IN            => color_in_blue,
            COLOR_OUT           => color_out_blue
        );
    
    COLOR_OUT_RED_BITS <= STD_LOGIC_VECTOR(to_unsigned(color_out_red,8));
    COLOR_OUT_GREEN_BITS <= STD_LOGIC_VECTOR(to_unsigned(color_out_green,8));
    COLOR_OUT_BLUE_BITS <= STD_LOGIC_VECTOR(to_unsigned(color_out_blue,8));
    
    
END Behavioral;