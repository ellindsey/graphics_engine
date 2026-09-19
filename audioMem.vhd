
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY audioMem IS
    PORT(
        clk         : IN STD_LOGIC;
        
        addrA       : IN integer range 0 to 511;
        wdataA      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rdataA      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        weA         : IN STD_LOGIC;
        
        addrB       : IN integer range 0 to 511;
        wdataB      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rdataB      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        weB         : IN STD_LOGIC
        );
END audioMem;

ARCHITECTURE behavioral OF audioMem IS

COMPONENT mem512K is
    PORT (
        we_a : in std_logic;
        we_b : in std_logic;
        addr_a : in std_logic_vector(8 downto 0);
        wdata_a : in std_logic_vector(7 downto 0);
        rdata_a : out std_logic_vector(7 downto 0);
        addr_b : in std_logic_vector(8 downto 0);
        rdata_b : out std_logic_vector(7 downto 0);
        wdata_b : in std_logic_vector(7 downto 0);
        clk_a : in std_logic;
        clk_b : in std_logic
        --clke_b : in std_logic;
        --clke_a : in std_logic
        );
END COMPONENT;

    --TYPE audio_mem IS ARRAY (0 TO 511) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    --SIGNAL mem : audio_mem;
    
    SIGNAL latchedAddress  : integer range 0 to 511;
    SIGNAL latchedDataIn   : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN
    PROCESS(CLK)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            latchedAddress <= addrA;
            latchedDataIn <= wdataA;
        END IF;
    END PROCESS;
    
    /*PROCESS (CLK)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            IF weA = '1' THEN
                mem(latchedAddress) <= latchedDataIn;
            END IF;
        END IF;
    END PROCESS;
    
    PROCESS (latchedAddress)
    BEGIN
        rdataA <= mem(latchedAddress);
    END PROCESS;
    
    PROCESS (CLK)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            IF weB = '1' THEN
                mem(addrB) <= wdataB;
            END IF;
        END IF;
    END PROCESS;
    
    PROCESS (addrB)
    BEGIN
        rdataB <= mem(addrB);
    END PROCESS;*/
    
    offsetmem : mem512K
        PORT MAP (
            we_a => weA,
            we_b => weB,
            addr_a => STD_LOGIC_VECTOR(to_unsigned(latchedAddress,9)),
            wdata_a => latchedDataIn,
            rdata_a => rdataA,
            rdata_b => rdataB,
            addr_b => STD_LOGIC_VECTOR(to_unsigned(addrB,9)),
            wdata_b => wdataB,
            clk_a => clk,
            clk_b => clk
            --clke_b => '1',
            --clke_a => '1'
            );
            
END behavioral;