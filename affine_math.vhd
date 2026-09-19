LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY affine_math IS
    PORT(
        clk                         : IN  STD_LOGIC;
        xin                         : IN  integer range 0 to 319;
        yin                         : IN  integer range 0 to 239;
        xoff                        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        yoff                        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        a                           : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        b                           : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        c                           : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        d                           : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        xc                          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        yc                          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        xout                        : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        yout                        : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        in_map                      : OUT STD_LOGIC
        );
END affine_math;

ARCHITECTURE behavioral OF affine_math IS

BEGIN
    PROCESS(clk,xin,yin,xoff,yoff,a,b,c,d,xc,yc) 
    
        VARIABLE XIN_VEC                : STD_LOGIC_VECTOR(8 DOWNTO 0);
        VARIABLE YIN_VEC                : STD_LOGIC_VECTOR(7 downto 0);
    
        VARIABLE XIN_CONV_VEC           : STD_LOGIC_VECTOR(17 downto 0);
        VARIABLE YIN_CONV_VEC           : STD_LOGIC_VECTOR(17 downto 0);
        
        VARIABLE XIN_CONV               : signed(17 downto 0); 
        VARIABLE YIN_CONV               : signed(17 downto 0); 

        VARIABLE XOFF_CONV_VEC          : STD_LOGIC_VECTOR(17 downto 0);
        VARIABLE YOFF_CONV_VEC          : STD_LOGIC_VECTOR(17 downto 0);
        
        VARIABLE XOFF_CONV              : signed(17 downto 0); 
        VARIABLE YOFF_CONV              : signed(17 downto 0); 

        VARIABLE XC_CONV_VEC            : STD_LOGIC_VECTOR(17 downto 0);
        VARIABLE YC_CONV_VEC            : STD_LOGIC_VECTOR(17 downto 0);
        
        VARIABLE XC_CONV                : signed(17 downto 0); 
        VARIABLE YC_CONV                : signed(17 downto 0); 
        
        VARIABLE A_CONV_VEC             : STD_LOGIC_VECTOR(17 downto 0);
        VARIABLE B_CONV_VEC             : STD_LOGIC_VECTOR(17 downto 0);
        VARIABLE C_CONV_VEC             : STD_LOGIC_VECTOR(17 downto 0);
        VARIABLE D_CONV_VEC             : STD_LOGIC_VECTOR(17 downto 0);
        
        VARIABLE A_CONV                 : signed(17 downto 0); 
        VARIABLE B_CONV                 : signed(17 downto 0); 
        VARIABLE C_CONV                 : signed(17 downto 0); 
        VARIABLE D_CONV                 : signed(17 downto 0); 
        
        VARIABLE X0                     : signed(17 downto 0);  
        VARIABLE X1                     : signed(35 DOWNTO 0); 
        VARIABLE X2                     : signed(35 DOWNTO 0); 
        VARIABLE X3P                    : signed(35 DOWNTO 0); 
        VARIABLE X3                     : signed(27 downto 0); 
        VARIABLE X4                     : signed(27 downto 0); 
        
        VARIABLE Y0                     : signed(17 downto 0);  
        VARIABLE Y1                     : signed(35 DOWNTO 0); 
        VARIABLE Y2                     : signed(35 DOWNTO 0); 
        VARIABLE Y3P                    : signed(35 DOWNTO 0); 
        VARIABLE Y3                     : signed(27 downto 0); 
        VARIABLE Y4                     : signed(27 downto 0); 
        
        VARIABLE XRESULT_VEC            : STD_LOGIC_VECTOR(27 downto 0);
        VARIABLE YRESULT_VEC            : STD_LOGIC_VECTOR(27 downto 0);
        
        VARIABLE IN_MAP_X               : STD_LOGIC;
        VARIABLE IN_MAP_Y               : STD_LOGIC;
        
    BEGIN
    
        --Affine math:
        
        --Input coordinates are 9 bits of integer, range of 0 to 511
        --Output coordinates are 10 bits of integer, range of 0 to 1023

        --only eight coefficients are actually needed
        --xoff and yoff applied to the input coordinates
        --a,b,c,d rotation/scaling matrix
        --xc and yc set the center point on the screen for rotation and scaling

        --x0 = xin + xoff - xc
        --y0 = yin + yoff - yc

        --x = x0*a + y0*b + xc
        --y = x0*c + y0*d + yc

        --The FPGA has high-performance multipliers that support 18 x 18 fixed-point multiplication.
        --Each multiplier takes two signed 18-bit input operands and generates a signed 36-bit output product. 
        --The multiplier has optional registers on the input and output ports.

        --signed fixed point must be used, 18 bits
        --1 bit for sign, 9 bits for integer, 8 bits for fractional part

        --xoff, yoff: 10.6 signed (1 in 64 fraction)
        --a,b,c,d: 8.8 signed (1 in 256 fraction)
        --xc, yc: 10.6 unsigned (1 in 64 fraction)
        
        --convert xin (unsigned 9 bit integer) to signed 12.6. Range is 0 to 319.
        --we have to treat it as a signed 18 bit integer and fix the decimal point later.
        
        XIN_VEC := std_logic_vector(to_unsigned(xin, 9));
        XIN_CONV_VEC := "000" & XIN_VEC & "000000";
        XIN_CONV := signed(XIN_CONV_VEC);
        
        --convert yin (unsigned 8 bit integer) to signed 12.6. Range is 0 to 239.
        --we have to treat it as a signed 18 bit integer and fix the decimal point later.
        
        YIN_VEC := std_logic_vector(to_unsigned(yin, 8));
        YIN_CONV_VEC := "0000" & YIN_VEC & "000000";
        YIN_CONV := signed(YIN_CONV_VEC);
        
        --convert xoff(signed 10.6) to signed 12.6. Range is -512 to 511.
        --we have to treat it as a signed 18 bit integer and fix the decimal point later.
        
        XOFF_CONV_VEC := xoff(15) & xoff(15) & xoff;
        XOFF_CONV := signed(XOFF_CONV_VEC);
        
        --convert yoff(signed 10.6) to signed 12.6. Range is -512 to 511.
        --we have to treat it as a signed 18 bit integer and fix the decimal point later.
        
        YOFF_CONV_VEC := yoff(15) & yoff(15) & yoff;
        YOFF_CONV := signed(YOFF_CONV_VEC);
        
        --convert xc(unsigned 10.6) to signed 12.6. Range is 0 to 1023.
        --we have to treat it as a signed 18 bit integer and fix the decimal point later.
        
        XC_CONV_VEC := xc(15) & xc(15) & xc;
        XC_CONV := signed(XC_CONV_VEC);
        
        --convert yc(unsigned 10.6) to signed 12.6. Range is 0 to 1023.
        --we have to treat it as a signed 18 bit integer and fix the decimal point later.
        
        YC_CONV_VEC := yc(15) & yc(15) & yc;
        YC_CONV := signed(YC_CONV_VEC);

        --Calculate x0 = xin + xoff - xc. Result is a signed 12.6 value.
        
        X0 := XIN_CONV + XOFF_CONV - XC_CONV;
        
        --Calculate y0 = yin + yoff - yc. Result is a signed 12.6 value.

        Y0 := YIN_CONV + YOFF_CONV - YC_CONV;
        
        --Convert a,b,c,d to 10.8 signed numbers.
        
        A_CONV_VEC := a(15) & a(15) & a;
        A_CONV := signed(A_CONV_VEC);
        
        B_CONV_VEC := b(15) & b(15) & b;
        B_CONV := signed(B_CONV_VEC);
        
        C_CONV_VEC := c(15) & c(15) & c;
        C_CONV := signed(C_CONV_VEC);
        
        D_CONV_VEC := d(15) & d(15) & d;
        D_CONV := signed(D_CONV_VEC);
        
        --Clocked registering to break calculation into two clocks to meet timing
        IF RISING_EDGE(clk)THEN
        
            --Multiply a*x0. Result is a signed 22.14 value.
            X1 := A_CONV * X0;
        
            --Multiply b*y0. Result is a signed 22.14 value.
            X2 := B_CONV * Y0;
            
            --Multiply c*x0. Result is a signed 22.14 value.
            Y1 := C_CONV * X0;
        
            --Multiply d*y0. Result is a signed 22.14 value.
            Y2 := D_CONV * Y0;
        END IF;
        
        --Add sums together, giving a signed 22.14 value
        
        X3P := X1 + X2;
        Y3P := Y1 + Y2;
        
        --Convert the sums to signed 22.6 values.
        
        X3 := X3P(35 downto 8);
        Y3 := Y3P(35 downto 8);
        
        --Add xc,yc. This yields 22.6 values.
        
        X4 := X3 + XC_CONV;
        Y4 := Y3 + YC_CONV;
        
        --The 6 bit fractional part is ignored.
        --The first 10 bits of the integer result is the results X,Y
        
        XRESULT_VEC := std_logic_vector(X4);
        xout <= XRESULT_VEC(15 downto 6);
        
        YRESULT_VEC := std_logic_vector(Y4);
        yout <= YRESULT_VEC(15 downto 6);
        
        --The remaining 12 bits of the integer result are checked against 0 to see if we are off map.
        
        IF XRESULT_VEC(27 downto 16) = "000000000000" THEN
            IN_MAP_X := '1';
        ELSE
            IN_MAP_X := '0';
        END IF;
        
        IF YRESULT_VEC(27 downto 16) = "000000000000" THEN
            IN_MAP_Y := '1';
        ELSE
            IN_MAP_Y := '0';
        END IF;
        
        IF RISING_EDGE(clk)THEN
            in_map <= IN_MAP_X AND IN_MAP_Y;
        END IF;
    END PROCESS;
END behavioral;