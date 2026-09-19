LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY copperStateEngine IS
    PORT(    
        CLK                     : IN STD_LOGIC;
        RUN                     : IN STD_LOGIC;
        RESET                   : IN STD_LOGIC;
            
        op_decode_state_control : IN STD_LOGIC_VECTOR(25 DOWNTO 0);
        
        lookup_select           : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        rw_16_bits              : IN STD_LOGIC;
            
        conditionCheckFlags     : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        
        memory_write            : OUT STD_LOGIC;
        raise_interrupt         : OUT STD_LOGIC;
        load_inst_reg           : OUT STD_LOGIC;
        
        state_data_control      : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
        
        ext_mem_read            : OUT STD_LOGIC;
        ext_mem_write           : OUT STD_LOGIC;
        
        flow_control            : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
END copperStateEngine;

ARCHITECTURE behavior OF copperStateEngine IS  

    type cpu_state is (cpu_phase_0,
                       cpu_phase_1,
                       cpu_phase_2,
                       cpu_phase_3);
    
    SIGNAL state                    : cpu_state := cpu_phase_0;
    SIGNAL next_state               : cpu_state;
    
    SIGNAL action_pulse             : STD_LOGIC;
    
    SIGNAL passed_select           : STD_LOGIC;
    SIGNAL index_reg_select        : STD_LOGIC;   
    SIGNAL op_save_R16_to_index    : STD_LOGIC;                    
    SIGNAL op_save_imm_to_index    : STD_LOGIC;                    
    SIGNAL op_read_ext_mem         : STD_LOGIC;                    
    SIGNAL op_save_index_to_r16    : STD_LOGIC;                    
    SIGNAL op_write_ext_mem        : STD_LOGIC;  
    SIGNAL op_save_immediate       : STD_LOGIC;                    
    SIGNAL op_save_to_reg_8        : STD_LOGIC;                    
    SIGNAL op_goto_relative        : STD_LOGIC;                    
    SIGNAL op_save_to_reg_16       : STD_LOGIC;                    
    SIGNAL op_goto_absolute        : STD_LOGIC;  
    SIGNAL op_alu_8                : STD_LOGIC;                    
    SIGNAL op_lookup               : STD_LOGIC;                    
    SIGNAL op_load_reg_immediate   : STD_LOGIC;                    
    SIGNAL op_load_reg_memory      : STD_LOGIC;                    
    SIGNAL op_nop                  : STD_LOGIC;  
    SIGNAL op_save_flags           : STD_LOGIC;                    
    SIGNAL op_wait_scanline        : STD_LOGIC;                    
    SIGNAL op_raise_interrupt      : STD_LOGIC;                    
    SIGNAL op_clear_flags          : STD_LOGIC;                      
    SIGNAL op_save_reg_memory      : STD_LOGIC;  
    SIGNAL op_wait_screen_flags    : STD_LOGIC;                   
    SIGNAL op_alu_16               : STD_LOGIC;                    
    SIGNAL op_multiply             : STD_LOGIC;                    
    SIGNAL op_branch_rel_if_flag   : STD_LOGIC;  
    
    SIGNAL load_sincos             : STD_LOGIC; -- 8
    SIGNAL load_invsqrt            : STD_LOGIC; -- 7
    SIGNAL clear_flags             : STD_LOGIC; -- 6
    SIGNAL load_reg_8              : STD_LOGIC; -- 5
    SIGNAL load_reg_16             : STD_LOGIC; -- 4
    SIGNAL load_ALU_flags          : STD_LOGIC; -- 3
    SIGNAL load_index_16           : STD_LOGIC; -- 2
    SIGNAL load_index_8_high       : STD_LOGIC; -- 1
    SIGNAL load_index_8_low        : STD_LOGIC; -- 0
    
    --SIGNAL increment_inst          : STD_LOGIC; -- 2
    --SIGNAL relative_jump           : STD_LOGIC; -- 1
    --SIGNAL absolute_jump           : STD_LOGIC; -- 0
    SIGNAL flow_control_int              : STD_LOGIC_VECTOR(1 DOWNTO 0);
    
    SIGNAL lineMatched             : STD_LOGIC; -- 3
    SIGNAL linePassed              : STD_LOGIC; -- 2
    SIGNAL aluFlagsMatched         : STD_LOGIC; -- 1
    SIGNAL screenFlagsMatched      : STD_LOGIC; -- 0
    
BEGIN

    lineMatched             <= conditionCheckFlags(3);
    linePassed              <= conditionCheckFlags(2);
    aluFlagsMatched         <= conditionCheckFlags(1);
    screenFlagsMatched      <= conditionCheckFlags(0);
    
    passed_select           <= op_decode_state_control(25); 
    index_reg_select        <= op_decode_state_control(24);  
    op_save_R16_to_index    <= op_decode_state_control(23);                 
    op_save_imm_to_index    <= op_decode_state_control(22);                    
    op_read_ext_mem         <= op_decode_state_control(21);                    
    op_save_index_to_r16    <= op_decode_state_control(20);                  
    op_write_ext_mem        <= op_decode_state_control(19); 
    op_save_immediate       <= op_decode_state_control(18);             
    op_save_to_reg_8        <= op_decode_state_control(17);                
    op_goto_relative        <= op_decode_state_control(16);               
    op_save_to_reg_16       <= op_decode_state_control(15);               
    op_goto_absolute        <= op_decode_state_control(14); 
    op_alu_8                <= op_decode_state_control(13);                
    op_lookup               <= op_decode_state_control(12);                
    op_load_reg_immediate   <= op_decode_state_control(11);                  
    op_load_reg_memory      <= op_decode_state_control(10);              
    op_nop                  <= op_decode_state_control(9); 
    op_save_flags           <= op_decode_state_control(8);                 
    op_wait_scanline        <= op_decode_state_control(7);            
    op_raise_interrupt      <= op_decode_state_control(6);                
    op_clear_flags          <= op_decode_state_control(5);               
    op_save_reg_memory      <= op_decode_state_control(4); 
    op_wait_screen_flags    <= op_decode_state_control(3);             
    op_alu_16               <= op_decode_state_control(2);                 
    op_multiply             <= op_decode_state_control(1);                 
    op_branch_rel_if_flag   <= op_decode_state_control(0); 
    
    --state engine unclocked process
    PROCESS (RUN,state,op_wait_scanline,op_wait_screen_flags,op_branch_rel_if_flag,op_goto_relative,op_goto_absolute,
             passed_select,lineMatched,screenFlagsMatched,linePassed,aluFlagsMatched)
        
    BEGIN
        action_pulse    <= '0';
        load_inst_reg   <= '0';
        --increment_inst  <= '0';
        --relative_jump   <= '0';
        --absolute_jump   <= '0';
        flow_control_int <= "00";
        
        next_state  <= cpu_phase_0;
        
        --all instructions take 4 clock cycles
        --100mhz master clock = 25mhz instruction cycles
        --line time is 64us (1,600 instruction cycles)
        --vertical blanking time is 1.44ms (36,000 instruction cycles)
        
        CASE state IS
            WHEN cpu_phase_0 =>
            
                --Phase zero
                --instruction pointer may be changing
                --load_inst_reg is 1
                --instruction register loads at the end of the phase
                
                load_inst_reg <= '1';
                
                IF RUN THEN
                    next_state <= cpu_phase_1;
                ELSE
                    next_state <= cpu_phase_0;
                END IF;
                
            WHEN cpu_phase_1 =>
            
                --Phase one
                --instruction register is loaded
                --instruction decode is acting
                --steering signals are being set to the data paths
                
                --logic here to block incrementing if we're waiting for a scanline or screen flag
                
                flow_control_int(0) <= NOT (((op_wait_scanline AND NOT passed_select) AND NOT lineMatched) OR  
                                            (op_wait_screen_flags AND NOT screenFlagsMatched));
                
                --IF op_wait_scanline THEN
                --    IF (passed_select = '0') AND (lineMatched = '1') THEN
                --        flow_control_int      <= "01"; --increment
                --    END IF;
                --ELSIF op_wait_screen_flags THEN
                --    IF screenFlagsMatched THEN
                --        flow_control_int      <= "01"; --increment
                --    END IF;
                --ELSE
                --    flow_control_int      <= "01"; --increment
                --END IF;
                
                --increment is set at the end of the phase unless we are in a wait state
                --wait instruction do not halt the 4 step cpu phase clock, but do prevent the instruction pointer from incrementing
                
                --ALU inputs latch at the end of the phase
                
                next_state <= cpu_phase_2;
                
            WHEN cpu_phase_2 =>
            
                --instruction pointer may be changing
                --inputs and outputs are being steered throught the data path selects
                --memory reads, ALU and multiplier actions happen here
                --we may optionally set the increment or jump flags here
                
                flow_control_int(0) <= (op_wait_scanline AND passed_select AND linePassed) OR op_goto_absolute;
                flow_control_int(1) <= (op_branch_rel_if_flag AND aluFlagsMatched) OR op_goto_relative OR op_goto_absolute;
                
                --IF (op_wait_scanline AND passed_select AND linePassed) THEN
                --    flow_control_int      <= "01"; --increment (skip instruction since we already incremented once)
                --END IF;
                
                --IF (op_branch_rel_if_flag AND aluFlagsMatched) OR op_goto_relative THEN
                --    flow_control_int      <= "10"; --relative jump
                --END IF;
                
                --IF op_goto_absolute THEN
                --    flow_control_int      <= "11"; --absolute jump
                --END IF;
                
                --result registers latch at the end of the phase
            
                next_state <= cpu_phase_3;
                
            WHEN cpu_phase_3 =>
                
                --data results and memory reads should be completed by now.
                --action pulse is always set
                --action pulse driven flags take effect
            
                action_pulse <= '1';
                next_state <= cpu_phase_0;
        
            WHEN OTHERS =>
                next_state <= cpu_phase_0;
                
        END CASE;
    END PROCESS;
    
    --state engine clocked process
    PROCESS (CLK,RESET,next_state)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            IF RESET THEN
                state <= cpu_phase_0;
            ELSE
                state <= next_state;
            END IF;
        END IF;
    END PROCESS;
    
    --action flag outputs
    
    ext_mem_read        <= action_pulse AND op_read_ext_mem;
    ext_mem_write       <= action_pulse AND op_write_ext_mem;
    load_index_16       <= action_pulse AND op_save_R16_to_index;
    load_index_8_high   <= action_pulse AND op_save_imm_to_index AND index_reg_select;
    load_index_8_low    <= action_pulse AND op_save_imm_to_index AND NOT index_reg_select;
    memory_write        <= action_pulse AND (op_save_immediate OR op_save_reg_memory);
    load_reg_8          <= action_pulse AND (op_read_ext_mem OR op_save_to_reg_8 OR op_alu_8 OR ((op_load_reg_immediate OR op_load_reg_memory) AND NOT rw_16_bits));
    load_reg_16         <= action_pulse AND (op_save_index_to_r16 OR op_save_to_reg_16 OR op_alu_16 OR op_save_flags OR op_multiply OR ((op_load_reg_immediate OR op_load_reg_memory) AND rw_16_bits));
    load_ALU_flags      <= action_pulse AND (op_alu_8 OR op_alu_16);-- OR op_modify_memory);
    raise_interrupt     <= action_pulse AND op_raise_interrupt;
    clear_flags         <= action_pulse AND op_clear_flags;
    load_invsqrt        <= action_pulse AND op_lookup AND NOT lookup_select(1);
    load_sincos         <= action_pulse AND op_lookup AND lookup_select(1);
    
    state_data_control <= load_sincos &       -- 8
                          load_invsqrt &      -- 7
                          clear_flags &       -- 6
                          load_reg_8 &        -- 5
                          load_reg_16 &       -- 4
                          load_ALU_flags &    -- 3
                          load_index_16 &     -- 2
                          load_index_8_high & -- 1
                          load_index_8_low;   -- 0
                          
    --flow_control <= increment_inst & relative_jump & absolute_jump;
    
    flow_control <= flow_control_int;

END behavior;