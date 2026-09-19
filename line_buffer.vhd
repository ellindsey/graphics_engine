
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY line_buffer IS
   PORT(
        CLKW            : IN  STD_LOGIC;
        WE              : IN  STD_LOGIC;
        RE              : IN  STD_LOGIC;
        
        ADDRESS_WRITE   : IN  integer range 0 to 511;
        DATA_WRITE      : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        
        ADDRESS_READ    : IN  integer range 0 to 511;
        DATA_READ       : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
      );
END line_buffer;

ARCHITECTURE behavioral OF line_buffer IS

    TYPE line_buffer_mem IS ARRAY (0 TO 511) OF STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL mem : line_buffer_mem;
    
BEGIN

    PROCESS (CLKW,WE,mem)

    BEGIN
        IF RISING_EDGE(CLKW) THEN
            IF WE = '1' THEN
                mem(ADDRESS_WRITE) <= DATA_WRITE;
            END IF;
        END IF;
    END PROCESS;

    PROCESS (ADDRESS_READ,RE,mem)

    BEGIN
            IF RE = '1' THEN
                DATA_READ <= mem(ADDRESS_READ);
            ELSE
                DATA_READ <= "0000000000";
            END IF;
    END PROCESS;
    
END behavioral;