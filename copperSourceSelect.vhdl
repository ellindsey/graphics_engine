LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY sourceSelect IS
    PORT(
        source_select   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        reg_A           : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        reg_B           : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        reg_C           : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        reg_D           : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        active_line     : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        invsqrt         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        sinCos          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        sel_16_bit      : IN  STD_LOGIC;
        out_8           : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        out_16          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        out_combined    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END sourceSelect;

ARCHITECTURE behavior OF sourceSelect IS

    COMPONENT mux16x8 IS
        PORT(
            selectIn : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            in0      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            in1      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            in2      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            in3      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            in4      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            in5      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            in6      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            in7      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            out0     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT mux16x8;
    
    COMPONENT mux8x8 IS
        PORT(
            selectIn : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            in0      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            in1      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            in2      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            in3      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            in4      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            in5      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            in6      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            in7      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            out0     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT mux8x8;
    
    COMPONENT mux16x2 IS
        PORT(
            selectIn : IN  STD_LOGIC;
            in0      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            in1      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            out0     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT mux16x2;
    
BEGIN
    
    --steering for 8 bit value
    source8Steer : mux8x8
        PORT MAP(
            selectIn => source_select,
            in0      => reg_A,
            in1      => reg_B,
            in2      => reg_C,
            in3      => reg_D,
            in4      => active_line,
            in5      => "00000000",
            in6      => "00000001",
            in7      => "11111111",
            out0     => out_8
        );

    --steering for 16 bit value
    source16Steer : mux16x8
        PORT MAP(
            selectIn => source_select,
            in0      => reg_A & reg_B,
            in1      => reg_C & reg_D,
            in2      => invsqrt,
            in3      => sinCos,
            in4      => active_line & "00000000",
            in5      => "0000000000000000",
            in6      => "0000000000000001",
            in7      => "1111111111111111",
            out0     => out_16
        );
        
    --steering for 16 bit value
    combinedOutSteer : mux16x2
        PORT MAP(
            selectIn => sel_16_bit,
            in0      => out_8 & "00000000",
            in1      => out_16,
            out0     => out_combined
        );
        
END behavior;