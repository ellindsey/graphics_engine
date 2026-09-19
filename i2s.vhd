LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY i2s IS
   PORT(
        clk         : IN  STD_LOGIC;
        
        rdata       : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        ldata       : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        
        sclk        : OUT STD_LOGIC;
        lrclk       : OUT STD_LOGIC;
        sdata       : OUT STD_LOGIC;
        
        latched     : OUT STD_LOGIC
        );
END i2s;

ARCHITECTURE behavior OF i2s IS

    SIGNAL count    : INTEGER RANGE 0 TO 31 := 0;
    
    SIGNAL latchedData : STD_LOGIC_VECTOR(31 downto 0) := "00000000000000000000000000000000";
    
    SIGNAL lastLRCLK : STD_LOGIC := '0';
    
BEGIN
    PROCESS(clk,count,latchedData)   
        VARIABLE countb   : STD_LOGIC_VECTOR(4 DOWNTO 0);
    BEGIN
        IF FALLING_EDGE(CLK) THEN
            count <= count + 1;
            IF lastLRCLK = '1' AND countb(4) = '0' THEN
                latchedData <= ldata & rdata;
                latched <= '1';
            ELSE
                latchedData(31 downto 1) <= latchedData(30 downto 0);
                latched <= '0';
            END IF;
            lastLRCLK <= countb(4);
        END IF;
        
        countb := std_logic_vector(to_unsigned(count, 5));
        sdata <= latchedData(31);
        lrclk <= countb(4);
        sclk <= clk;
    END PROCESS;

END behavior;