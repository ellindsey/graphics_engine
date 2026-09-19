LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY engineBufferAttach IS
      PORT(
        bufferSelect           : IN  integer range 0 to 1;
        
        sel_0_write_address     : IN  integer range 0 to 511;
        sel_0_write_strobe      : IN  STD_LOGIC;
        sel_0_write_data        : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        
        sel_1_write_address     : IN  integer range 0 to 511;
        sel_1_write_strobe      : IN  STD_LOGIC;
        sel_1_write_data        : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        
        buffer_write_address    : OUT integer range 0 to 511;
        buffer_write_strobe     : OUT STD_LOGIC;
        buffer_write_data       : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
   );
END engineBufferAttach;


ARCHITECTURE behavior OF engineBufferAttach IS

BEGIN
    PROCESS(bufferSelect,sel_0_write_address,sel_0_write_strobe,sel_0_write_data,sel_1_write_address,sel_1_write_strobe,sel_1_write_data)
    BEGIN    
        CASE bufferSelect IS
            WHEN 0 => 
                buffer_write_address <= sel_0_write_address;
                buffer_write_strobe <= sel_0_write_strobe;
                buffer_write_data <= sel_0_write_data;
            WHEN 1 => 
                buffer_write_address <= sel_1_write_address;
                buffer_write_strobe <= sel_1_write_strobe;
                buffer_write_data <= sel_1_write_data;
            --WHEN OTHERS =>
            --    buffer_write_address <= sel_0_write_address;
            --    buffer_write_strobe <= sel_0_write_strobe;
            --    buffer_write_data <= sel_0_write_data;
        END CASE;
    END PROCESS;
END behavior;