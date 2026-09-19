library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cpu_interface is
    Port (
      CLK               : IN  STD_LOGIC;
      CS                : IN  STD_LOGIC;
      RE                : IN  STD_LOGIC;
      WE                : IN  STD_LOGIC;
      
      WRITE_STROBE      : OUT STD_LOGIC;
      TRISTATE_OUT      : OUT STD_LOGIC;
      READY             : OUT STD_LOGIC;
      LATCH_ADDRESS     : OUT STD_LOGIC;
      LATCH_DATA_IN     : OUT STD_LOGIC
      
        );
end cpu_interface;

architecture Behavioral of cpu_interface is

    type state_type is (idle,
                        write_pulse,
                        write_pulse_delay,
                        wait_write_end,
                        read_delay,
                        read_set_output,
                        wait_read_end,
                        wait_read_turnaround_delay);

    SIGNAL state                : state_type := idle;
    SIGNAL next_state           : state_type := idle;
    
    SIGNAL next_write_strobe    : STD_LOGIC := '0';
    SIGNAL next_tristate_out    : STD_LOGIC := '0';
    SIGNAL next_latch_address   : STD_LOGIC := '0';
    SIGNAL next_latch_data_in   : STD_LOGIC := '0';
    SIGNAL next_ready           : STD_LOGIC := '0';
                        
begin
    PROCESS(state,CS,WE,RE)
    BEGIN
        CASE state IS
            WHEN idle =>
                next_write_strobe <= '0';
                next_tristate_out <= '0';
                next_ready <= '0';
                IF CS = '0' THEN
                    IF WE = '0' THEN
                        next_state <= write_pulse_delay;
                        next_latch_address <= '1';
                        next_latch_data_in <= '1';
                    ELSIF RE = '0' THEN
                        next_state <= read_delay;
                        next_latch_address <= '1';
                        next_latch_data_in <= '0';
                    ELSE
                        next_state <= idle;
                        next_latch_address <= '0';
                        next_latch_data_in <= '0';
                    END IF;
                ELSE
                    next_state <= idle;
                    next_latch_address <= '0';
                    next_latch_data_in <= '0';
                END IF;
                
            WHEN write_pulse_delay =>
                next_state <= write_pulse;
                next_write_strobe <= '0';
                next_tristate_out <= '0';
                next_ready <= '1';
                next_latch_address <= '0';
                next_latch_data_in <= '1';
                
            WHEN write_pulse =>
                next_state <= wait_write_end;
                next_write_strobe <= '1';
                next_tristate_out <= '0';
                next_ready <= '1';
                next_latch_address <= '0';
                next_latch_data_in <= '0';
                
            WHEN wait_write_end =>
                IF WE = '1' OR CS = '1' THEN
                    next_state <= idle;
                    next_ready <= '0';
                ELSE
                    next_state <= wait_write_end;
                    next_ready <= '1';
                END IF;
                next_write_strobe <= '0';
                next_tristate_out <= '0';
                next_latch_address <= '0';
                next_latch_data_in <= '0';
                
            WHEN read_delay =>
                next_state <= read_set_output;
                next_write_strobe <= '0';
                next_tristate_out <= '0';
                next_ready <= '0';
                next_latch_address <= '0';
                next_latch_data_in <= '0';
            
            WHEN read_set_output =>
                next_state <= wait_read_end;
                next_write_strobe <= '0';
                next_tristate_out <= '1';
                next_ready <= '1';
                next_latch_address <= '0';
                next_latch_data_in <= '0';
            
            WHEN wait_read_end =>
                IF RE = '1' OR CS = '1' THEN
                    next_state <= wait_read_turnaround_delay;
                ELSE
                    next_state <= wait_read_end;
                END IF;
                next_ready <= '1';
                next_write_strobe <= '0';
                next_tristate_out <= '1';
                next_latch_address <= '0';
                next_latch_data_in <= '0';
                
            WHEN wait_read_turnaround_delay =>
                next_state <= idle;
                next_write_strobe <= '0';
                next_tristate_out <= '0';
                next_ready <= '0';
                next_latch_address <= '0';
                next_latch_data_in <= '0';
            
            --WHEN OTHERS =>
            --    next_state <= idle;
            --    next_write_strobe <= '0';
            --    next_tristate_out <= '0';
            --    next_ready <= '0';
            --    next_latch_address <= '0';
            --    next_latch_data_in <= '0';
        END CASE;
    END PROCESS;
    
    PROCESS(CLK)
    BEGIN
        IF RISING_EDGE(clk) THEN
            state <= next_state;
            WRITE_STROBE <= next_write_strobe;
            TRISTATE_OUT <= next_tristate_out;
            READY <= next_ready;
            LATCH_ADDRESS <= next_latch_address;
            LATCH_DATA_IN <= next_latch_data_in;
        END IF;
    END PROCESS;
end Behavioral;