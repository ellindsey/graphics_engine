
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY line_buffers IS
    PORT(
        CLKW                : IN  STD_LOGIC;
        CLKR                : IN  STD_LOGIC;
        SWAP_BUFFERS        : IN  STD_LOGIC;
        
        LAYER_ENABLE        : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        
        WRITE_ADDRESS_0     : IN  integer range 0 to 511;
        WE_0                : IN  STD_LOGIC;
        DATA_IN_0           : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        
        WRITE_ADDRESS_1     : IN  integer range 0 to 511;
        WE_1                : IN  STD_LOGIC;
        DATA_IN_1           : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        
        WRITE_ADDRESS_2     : IN  integer range 0 to 511;
        WE_2                : IN  STD_LOGIC;
        DATA_IN_2           : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        
        WRITE_ADDRESS_3     : IN  integer range 0 to 511;
        WE_3                : IN  STD_LOGIC;
        DATA_IN_3           : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        
        READ_ADDRESS        : IN  integer range 0 to 511;
        READ_DATA           : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END line_buffers;

ARCHITECTURE behavioral OF line_buffers IS

COMPONENT line_buffer IS
   PORT(
        CLKW            : IN  STD_LOGIC;
        WE              : IN  STD_LOGIC;
        RE              : IN  STD_LOGIC;
        
        ADDRESS_WRITE   : IN  integer range 0 to 511;
        DATA_WRITE      : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        
        ADDRESS_READ    : IN  integer range 0 to 511;
        DATA_READ       : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
      );
END COMPONENT line_buffer;

SIGNAL WE_0A            : STD_LOGIC;
SIGNAL WE_0B            : STD_LOGIC;
SIGNAL WE_1A            : STD_LOGIC;
SIGNAL WE_1B            : STD_LOGIC;
SIGNAL WE_2A            : STD_LOGIC;
SIGNAL WE_2B            : STD_LOGIC;
SIGNAL WE_3A            : STD_LOGIC;
SIGNAL WE_3B            : STD_LOGIC;

SIGNAL READ_DATA_0A     : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL READ_DATA_0B     : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL READ_DATA_1A     : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL READ_DATA_1B     : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL READ_DATA_2A     : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL READ_DATA_2B     : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL READ_DATA_3A     : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL READ_DATA_3B     : STD_LOGIC_VECTOR(9 DOWNTO 0);

SIGNAL READ_DATA_0      : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL READ_DATA_1      : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL READ_DATA_2      : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL READ_DATA_3      : STD_LOGIC_VECTOR(9 DOWNTO 0);

BEGIN
    --instantiate the individual buffers
    buffer0A : line_buffer
        PORT MAP (
            CLKW            => CLKW,
            WE              => WE_0A,
            RE              => LAYER_ENABLE(0),
            ADDRESS_WRITE   => WRITE_ADDRESS_0,
            DATA_WRITE      => DATA_IN_0,
            ADDRESS_READ    => READ_ADDRESS,
            DATA_READ       => READ_DATA_0A
        );
        
    buffer0B : line_buffer
        PORT MAP (
            CLKW            => CLKW,
            WE              => WE_0B,
            RE              => LAYER_ENABLE(0),
            ADDRESS_WRITE   => WRITE_ADDRESS_0,
            DATA_WRITE      => DATA_IN_0,
            ADDRESS_READ    => READ_ADDRESS,
            DATA_READ       => READ_DATA_0B
        );
        
    buffer1A : line_buffer
        PORT MAP (
            CLKW            => CLKW,
            WE              => WE_1A,
            RE              => LAYER_ENABLE(1),
            ADDRESS_WRITE   => WRITE_ADDRESS_1,
            DATA_WRITE      => DATA_IN_1,
            ADDRESS_READ    => READ_ADDRESS,
            DATA_READ       => READ_DATA_1A
        );
        
    buffer1B : line_buffer
        PORT MAP (
            CLKW            => CLKW,
            WE              => WE_1B,
            RE              => LAYER_ENABLE(1),
            ADDRESS_WRITE   => WRITE_ADDRESS_1,
            DATA_WRITE      => DATA_IN_1,
            ADDRESS_READ    => READ_ADDRESS,
            DATA_READ       => READ_DATA_1B
        );
        
    buffer2A : line_buffer
        PORT MAP (
            CLKW            => CLKW,
            WE              => WE_2A,
            RE              => LAYER_ENABLE(2),
            ADDRESS_WRITE   => WRITE_ADDRESS_2,
            DATA_WRITE      => DATA_IN_2,
            ADDRESS_READ    => READ_ADDRESS,
            DATA_READ       => READ_DATA_2A
        );
        
    buffer2B : line_buffer
        PORT MAP (
            CLKW            => CLKW,
            WE              => WE_2B,
            RE              => LAYER_ENABLE(2),
            ADDRESS_WRITE   => WRITE_ADDRESS_2,
            DATA_WRITE      => DATA_IN_2,
            ADDRESS_READ    => READ_ADDRESS,
            DATA_READ       => READ_DATA_2B
        );
        
    buffer3A : line_buffer
        PORT MAP (
            CLKW            => CLKW,
            WE              => WE_3A,
            RE              => LAYER_ENABLE(3),
            ADDRESS_WRITE   => WRITE_ADDRESS_3,
            DATA_WRITE      => DATA_IN_3,
            ADDRESS_READ    => READ_ADDRESS,
            DATA_READ       => READ_DATA_3A
        );
        
    buffer3B : line_buffer
        PORT MAP (
            CLKW            => CLKW,
            WE              => WE_3B,
            RE              => LAYER_ENABLE(3),
            ADDRESS_WRITE   => WRITE_ADDRESS_3,
            DATA_WRITE      => DATA_IN_3,
            ADDRESS_READ    => READ_ADDRESS,
            DATA_READ       => READ_DATA_3B
        );
    
    --buffers swap
    PROCESS(SWAP_BUFFERS,CLKW,WE_0,WE_1,WE_2,WE_3)
    BEGIN
        CASE SWAP_BUFFERS IS
            WHEN '0' =>
                WE_0A <= WE_0;
                WE_1A <= WE_1;
                WE_2A <= WE_2;
                WE_3A <= WE_3;
                WE_0B <= '0';
                WE_1B <= '0';
                WE_2B <= '0';
                WE_3B <= '0';
            WHEN '1' =>
                WE_0A <= '0';
                WE_1A <= '0';
                WE_2A <= '0';
                WE_3A <= '0';
                WE_0B <= WE_0;
                WE_1B <= WE_1;
                WE_2B <= WE_2;
                WE_3B <= WE_3;
            WHEN OTHERS =>
                WE_0A <= '0';
                WE_1A <= '0';
                WE_2A <= '0';
                WE_3A <= '0';
                WE_0B <= '0';
                WE_1B <= '0';
                WE_2B <= '0';
                WE_3B <= '0';
        END CASE;
    END PROCESS;
    
    --buffers swap
    PROCESS(SWAP_BUFFERS,CLKR,READ_DATA_0B,READ_DATA_1B,READ_DATA_2B,READ_DATA_3B,READ_DATA_0A,READ_DATA_1A,READ_DATA_2A,READ_DATA_3A)
    BEGIN
        --IF RISING_EDGE(CLKR) THEN
            CASE SWAP_BUFFERS IS
                WHEN '0' =>
                    READ_DATA_0 <= READ_DATA_0B;
                    READ_DATA_1 <= READ_DATA_1B;
                    READ_DATA_2 <= READ_DATA_2B;
                    READ_DATA_3 <= READ_DATA_3B;
                WHEN '1' =>
                    READ_DATA_0 <= READ_DATA_0A;
                    READ_DATA_1 <= READ_DATA_1A;
                    READ_DATA_2 <= READ_DATA_2A;
                    READ_DATA_3 <= READ_DATA_3A;
                WHEN OTHERS =>
                    READ_DATA_0 <= "0000000000";
                    READ_DATA_1 <= "0000000000";
                    READ_DATA_2 <= "0000000000";
                    READ_DATA_3 <= "0000000000";
            END CASE;
        --END IF;
    END PROCESS;
    
    --layer priority encoding
    
    PROCESS(READ_DATA_0,READ_DATA_1,READ_DATA_2,READ_DATA_3,CLKR)
    BEGIN
        IF READ_DATA_0(9 downto 8) = "11" THEN
            READ_DATA <= READ_DATA_0(7 downto 0);
        ELSIF READ_DATA_1(9 downto 8) = "11" THEN
            READ_DATA <= READ_DATA_1(7 downto 0); 
        ELSIF READ_DATA_2(9 downto 8) = "11" THEN
            READ_DATA <= READ_DATA_2(7 downto 0);
        ELSIF READ_DATA_3(9 downto 8) = "11" THEN
            READ_DATA <= READ_DATA_3(7 downto 0);
            
        ELSIF READ_DATA_0(9 downto 8) = "10" THEN
            READ_DATA <= READ_DATA_0(7 downto 0);
        ELSIF READ_DATA_1(9 downto 8) = "10" THEN
            READ_DATA <= READ_DATA_1(7 downto 0);
        ELSIF READ_DATA_2(9 downto 8) = "10" THEN
            READ_DATA <= READ_DATA_2(7 downto 0);
        ELSIF READ_DATA_3(9 downto 8) = "10" THEN
            READ_DATA <= READ_DATA_3(7 downto 0);
            
        ELSIF READ_DATA_0(9 downto 8) = "01" THEN
            READ_DATA <= READ_DATA_0(7 downto 0);
        ELSIF READ_DATA_1(9 downto 8) = "01" THEN
            READ_DATA <= READ_DATA_1(7 downto 0);
        ELSIF READ_DATA_2(9 downto 8) = "01" THEN
            READ_DATA <= READ_DATA_2(7 downto 0);
        ELSIF READ_DATA_3(9 downto 8) = "01" THEN
            READ_DATA <= READ_DATA_3(7 downto 0);
            
        ELSE
            READ_DATA <= READ_DATA_0(7 downto 0);
        END IF;
    END PROCESS;

END behavioral;