
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY mem1K1to8 IS
    PORT(
        clk         : IN STD_LOGIC;
        
        addrA       : IN integer range 0 to 1023;
        wdataA      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rdataA      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        weA         : IN STD_LOGIC;
        
        addrB       : IN integer range 0 to 127;
        rdataB      : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
        );
END mem1K1to8;

ARCHITECTURE behavioral OF mem1K1to8 IS

COMPONENT mem1Ksprites is
    PORT (
        we_a : in std_logic;
        we_b : in std_logic;
        addr_a : in std_logic_vector(9 downto 0);
        wdata_a : in std_logic_vector(7 downto 0);
        rdata_a : out std_logic_vector(7 downto 0);
        rdata_b : out std_logic_vector(63 downto 0);
        addr_b : in std_logic_vector(6 downto 0);
        wdata_b : in std_logic_vector(63 downto 0);
        clk_a : in std_logic;
        clk_b : in std_logic
        --clke_b : in std_logic;
        --clke_a : in std_logic
        );
END COMPONENT;

BEGIN
    spritemem : mem1Ksprites
        PORT MAP (
            we_a => weA,
            we_b => '0',
            addr_a => STD_LOGIC_VECTOR(to_unsigned(addrA,10)),
            wdata_a => wdataA,
            rdata_a => rdataA,
            rdata_b => rdataB,
            addr_b => STD_LOGIC_VECTOR(to_unsigned(addrB,7)),
            wdata_b => "0000000000000000000000000000000000000000000000000000000000000000",
            clk_a => clk,
            clk_b => clk
            --clke_b => '1',
            --clke_a => '1'
            );
            
END behavioral;