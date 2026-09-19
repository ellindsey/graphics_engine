
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY mem2Kfonts IS
    PORT(
        clk         : IN STD_LOGIC;
        
        addrA       : IN integer range 0 to 2047;
        wdataA      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rdataA      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        weA         : IN STD_LOGIC;
        
        addrB       : IN integer range 0 to 2047;
        rdataB      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
END mem2Kfonts;

ARCHITECTURE behavioral OF mem2Kfonts IS

COMPONENT mem2Kfont is
    PORT (
        we_a : in std_logic;
        we_b : in std_logic;
        addr_a : in std_logic_vector(10 downto 0);
        wdata_a : in std_logic_vector(7 downto 0);
        rdata_a : out std_logic_vector(7 downto 0);
        rdata_b : out std_logic_vector(7 downto 0);
        addr_b : in std_logic_vector(10 downto 0);
        wdata_b : in std_logic_vector(7 downto 0);
        clk_a : in std_logic;
        clk_b : in std_logic
        --clke_b : in std_logic;
        --clke_a : in std_logic
        );
END COMPONENT;

    SIGNAL latchedAddress  : integer range 0 to 2047;
    SIGNAL latchedDataIn   : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN
    PROCESS(CLK)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            latchedAddress <= addrA;
            latchedDataIn <= wdataA;
        END IF;
    END PROCESS;
    
    fontmem : mem2Kfont
        PORT MAP (
            we_a => weA,
            we_b => '0',
            addr_a => STD_LOGIC_VECTOR(to_unsigned(latchedAddress,11)),
            wdata_a => latchedDataIn,
            rdata_a => rdataA,
            rdata_b => rdataB,
            addr_b => STD_LOGIC_VECTOR(to_unsigned(addrB,11)),
            wdata_b => "00000000",
            clk_a => clk,
            clk_b => clk
            --clke_b => '1',
            --clke_a => '1'
            );
            
END behavioral;