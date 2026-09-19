
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY audioRawMem IS
    PORT(
        clk         : IN STD_LOGIC;
        
        addrA       : IN integer range 0 to 31;
        rdataA      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        addrB       : IN integer range 0 to 31;
        wdataB      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rdataB      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        weB         : IN STD_LOGIC
        );
END audioRawMem;

ARCHITECTURE behavioral OF audioRawMem IS

COMPONENT mem32b is
    PORT (
        we_a : in std_logic;
        we_b : in std_logic;
        addr_a : in std_logic_vector(4 downto 0);
        wdata_a : in std_logic_vector(7 downto 0);
        rdata_a : out std_logic_vector(7 downto 0);
        addr_b : in std_logic_vector(4 downto 0);
        rdata_b : out std_logic_vector(7 downto 0);
        wdata_b : in std_logic_vector(7 downto 0);
        clk_a : in std_logic;
        clk_b : in std_logic
        --clke_b : in std_logic;
        --clke_a : in std_logic
        );
END COMPONENT;

    SIGNAL latchedAddress  : integer range 0 to 31;

BEGIN
    PROCESS(CLK)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            latchedAddress <= addrA;
        END IF;
    END PROCESS;
    
    audioraw : mem32b
        PORT MAP (
            we_a => '0',
            we_b => weB,
            addr_a => STD_LOGIC_VECTOR(to_unsigned(latchedAddress,5)),
            wdata_a => "00000000",
            rdata_a => rdataA,
            rdata_b => rdataB,
            addr_b => STD_LOGIC_VECTOR(to_unsigned(addrB,5)),
            wdata_b => wdataB,
            clk_a => clk,
            clk_b => clk
            --clke_b => '1',
            --clke_a => '1'
            );
            
END behavioral;