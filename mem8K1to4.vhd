
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY mem8K1to4 IS
    PORT(
        clk         : IN STD_LOGIC;
        
        addrA       : IN integer range 0 to 8191;
        wdataA      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rdataA      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        weA         : IN STD_LOGIC;
        
        addrB       : IN integer range 0 to 2047;
        rdataB      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
END mem8K1to4;

ARCHITECTURE behavioral OF mem8K1to4 IS

COMPONENT mem4Kmap is
    PORT (
        we_a : in std_logic;
        we_b : in std_logic;
        addr_a : in std_logic_vector(11 downto 0);
        wdata_a : in std_logic_vector(7 downto 0);
        rdata_a : out std_logic_vector(7 downto 0);
        rdata_b : out std_logic_vector(31 downto 0);
        addr_b : in std_logic_vector(9 downto 0);
        wdata_b : in std_logic_vector(31 downto 0);
        clk_a : in std_logic;
        clk_b : in std_logic
        --clke_b : in std_logic;
        --clke_a : in std_logic
        );
END COMPONENT;

    SIGNAL latchedAddress  : integer range 0 to 8191;
    SIGNAL latchedDataIn   : STD_LOGIC_VECTOR(7 DOWNTO 0);

    SIGNAL addrAvec : std_logic_vector(12 downto 0);
    SIGNAL addrBvec : std_logic_vector(10 downto 0);

    SIGNAL rdataA0 : std_logic_vector(7 downto 0);
    SIGNAL rdataA1 : std_logic_vector(7 downto 0);
    --SIGNAL en_A0 : std_logic;
    --SIGNAL en_A1 : std_logic;
    
    SIGNAL rdataB0 : std_logic_vector(31 downto 0);
    SIGNAL rdataB1 : std_logic_vector(31 downto 0);
    --SIGNAL en_B0 : std_logic;
    --SIGNAL en_B1 : std_logic;
    
    SIGNAL we_A0 : std_logic;
    SIGNAL we_A1 : std_logic;
    
    
BEGIN
    PROCESS(CLK)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            latchedAddress <= addrA;
            latchedDataIn <= wdataA;
        END IF;
    END PROCESS;
    
    addrAvec <= STD_LOGIC_VECTOR(to_unsigned(latchedAddress,13));
    addrBvec <= STD_LOGIC_VECTOR(to_unsigned(addrB,11));

    mem0 : mem4Kmap
        PORT MAP (
            we_a => we_A0,
            we_b => '0',
            addr_a => addrAvec(11 downto 0),
            wdata_a => latchedDataIn,
            rdata_a => rdataA0,
            rdata_b => rdataB0,
            addr_b => addrBvec(9 downto 0),
            wdata_b => "00000000000000000000000000000000",
            clk_a => clk,
            clk_b => clk
            --clke_b => en_B0,
            --clke_a => en_A0
            );
            
    mem1 : mem4Kmap
        PORT MAP (
            we_a => we_A1,
            we_b => '0',
            addr_a => addrAvec(11 downto 0),
            wdata_a => latchedDataIn,
            rdata_a => rdataA1,
            rdata_b => rdataB1,
            addr_b => addrBvec(9 downto 0),
            wdata_b => "00000000000000000000000000000000",
            clk_a => clk,
            clk_b => clk
            --clke_b => en_B1,
            --clke_a => en_A1
            );
            
    PROCESS(addrAvec,rdataA0,rdataA1,weA)
    BEGIN
        CASE addrAvec(12) IS
            WHEN '0' =>
                --en_A0 <= '1';
                --en_A1 <= '0';
                we_A0 <= weA;
                we_A1 <= '0';
                rdataA <= rdataA0;
            WHEN '1' =>
                --en_A0 <= '0';
                --en_A1 <= '1';
                we_A0 <= '0';
                we_A1 <= weA;
                rdataA <= rdataA1;
            WHEN OTHERS =>
                --en_A0 <= '1';
                --en_A1 <= '0';
                we_A0 <= '0';
                we_A1 <= '0';
                rdataA <= rdataA0;
        END CASE;
    END PROCESS;
    
    PROCESS(addrBvec,rdataB0,rdataB1)
    BEGIN
        CASE addrBvec(10) IS
            WHEN '0' =>
                --en_B0 <= '1';
                --en_B1 <= '0';
                rdataB <= rdataB0;
            WHEN '1' =>
                --en_B0 <= '0';
                --en_B1 <= '1';
                rdataB <= rdataB1;
            WHEN OTHERS =>
                --en_B0 <= '1';
                --en_B1 <= '0';
                rdataB <= rdataB0;
        END CASE;
    END PROCESS;
    
    
END behavioral;