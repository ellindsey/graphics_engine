LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

--0mmmmmmm iiiiiiii	Save immediate 8 bit value at memory location m
--10000dd0 xxxxxaaa	Save 8 bit source indicated by a to destination d
--10000xx1 xaaaaaaa	Goto relative address a
--10001dx0 xxxxxaaa	Save 16 bit source indicated by a to 16 bit register d          
--10001001 xxxxxaaa	transfer 16 bit register a to both bytes of index register      
--10010ddo oobbbaaa	d = a (op) b		(8 bit operation)
--100110aa aaaaaaaa	Goto absolute address a
--10011100 xxxxxaaa	Square root table lookup with source a as index
--10011101 xxxxxaaa	Inverse table lookup with source a as index
--10011110 xxxxxaaa	Sine table lookup with source a as index
--10011111 xxxxxaaa	Cosine table lookup with source a as index
--10100dd0 iiiiiiii	Set 8 bit register d to immediate value
--10100d01 iiiiiiii	Set 16 bit register d to immediate value + "00000000"           
--10100011 iiiiiiii	write immediate to high byte of index register                  
--10100111 iiiiiiii	write immediate to low byte of index register                   
--10101dd0 0mmmmmmm	Load 8 bit register d from memory location m
--10101dd0 1xxxxaaa	Load 8 bit register d from memory at address of register a
--10101d01 0mmmmmmm	Load 16 bit register d from memory location m                   
--10101d01 1xxxxaaa	Load 16 bit register d from memory at address of register a     
--10101d11 xxxxxxxx	read memory at index into 8 bit register A or B
--10110x00 xxxxxxxx	Nop
--10110d01 xxxxxxxx	Save alu and screen flags to 16 bit register d
--10110010 iiiiiiii	Wait for immediate scanline
--10110011 xxxxxaaa	Wait for scanline matching register a
--10110110 iiiiiiii	Skip if reached immediate scanline
--10110111 xxxxxaaa	Skip if reached scanline matching register a
--10111d11 xxxxxxxx	Transfer both bytes of index register to 16 bit register d
--10111000 xxxxxxxx	Nop
--10111010 xxxxxxxx	Clear ALU flags
--10111100 xxxxxxxx	Raise interrupt to CPU
--10111110 xxxxxxxx	Clear ALU flags and Raise interrupt to CPU
--11000rr0 0mmmmmmm	Save 8 bit register r to memory location m
--11000rr0 1xxxxaaa	Save 8 bit register r to memory at address of register a
--11000r01 0mmmmmmm	Save 16 bit register r to memory location m
--11000r01 1xxxxaaa	Save 16 bit register r to memory at address of register a
--11000011 iiiiiiii	write immediate to memory at index
--11000111 xxxxxaaa	write 8 bit source a contents to memory at index              
--11001fff ffffffff	Wait until screen flags indicated by f are all 1
--11010dxo oobbbaaa	d = a (op) b		(16 bit operation)
--11011dss ssbbbaaa	d = (a X b) >> s	(16 bit operation)
--111fffff faaaaaaa	Branch relative (-64 to +63) if alu flags matched

--8 bit register sources aaa and bbb:
--  000:    8 bit register A
--  001:    8 bit register B
--  010:    8 bit register C
--  011:    8 bit register D
--  100:    active line register
--  101:    constant 0
--  110:    constant 1
--  111:    constant 255

--16 bit register sources aaa and bbb:
--  000:    16 bit register AB
--  001:    16 bit register CD
--  010:    Inverse/Square root table lookup result
--  011:    Sin/Cos table lookup result
--  100:    Active line in high byte, 0 in low byte
--  101:    constant 0
--  110:    constant 1
--  111:    constant 65535

--8 bit destination register dd:
--  00:    8 bit register A
--  01:    8 bit register B
--  10:    8 bit register C
--  11:    8 bit register D

--16 bit destination register d:
--  0:    16 bit register AB
--  1:    16 bit register CD

--ALU operations:
--  000:    Add without carry (ADD)
--  001:    Subtract without borrow (SUB)
--  010:    Add with carry (ADC)
--  011:    Subtract with borrow (SBB)
--  100:    Logical AND
--  101:    Logical OR
--  110:    Logical XOR
--  111:    Shift A left or right by B

--8 bit memory write data source rr:
--  00:    8 bit register A
--  01:    8 bit register B
--  10:    8 bit register C
--  11:    8 bit register D

--18 bit memory write data source r:
--  0:    16 bit register AB
--  1:    16 bit register CD

--ALU flags:
--  xxxxx1: Branch if positive or zero
--  xxxx1x: Branch if not zero
--  xxx1xx: Branch if not carry
--  xx1xxx: Branch if negative
--  x1xxxx: Branch if zero
--  1xxxxx: Branch if carry

--Screen flags:
--  10000000000:	screen reset flag
--  01000000000:	line reset flag
--  00100000000:	horizontal blank flag
--  00010000000:	vertical blank flag
--  00001000000:	sprite engine completion flag
--  00000100000:	tile 2 engine completion flag
--  00000010000:	tile 1 engine completion flag
--  00000001000:	text engine completion flag
--  00000000100:	bitmap engine completion flag
--  00000000010:	affine engine completion flag
--  00000000001:	unused flag

ENTITY instDecode IS
    PORT(
        instruction_reg         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        
        op_decode_state_control : OUT STD_LOGIC_VECTOR(25 DOWNTO 0);
        op_decode_data_control  : OUT STD_LOGIC_VECTOR(30 DOWNTO 0);
        op_decode_cond_control  : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
          
        value_immediate         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        jump_address            : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        
        lookup_select           : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        rw_16_bits              : OUT STD_LOGIC  
    );
END instDecode;

ARCHITECTURE behavior OF instDecode IS

    SIGNAL memory_index_flag        : STD_LOGIC;

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
        
    SIGNAL mem_immediate_address   : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL dest_8_select           : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL dest_16_select          : STD_LOGIC;
    SIGNAL alu_16_bit              : STD_LOGIC;
    SIGNAL source_select_1         : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL source_select_2         : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL mem_save_reg_select     : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL alu_op_select           : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL multiply_shift          : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL result_select           : STD_LOGIC_VECTOR(2 DOWNTO 0);     
    SIGNAL memory_address_immediate: STD_LOGIC; 
    SIGNAL scanline_imm_select     : STD_LOGIC;
    SIGNAL screen_flags_select     : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL alu_flags_select        : STD_LOGIC_VECTOR(5 DOWNTO 0);
    
BEGIN
    
    PROCESS(instruction_reg)
    BEGIN
    
        op_save_R16_to_index    <= '0';
        op_save_imm_to_index    <= '0';
        op_read_ext_mem         <= '0';
        op_save_index_to_r16    <= '0';
        op_write_ext_mem        <= '0';
        op_save_immediate       <= '0';
        op_save_to_reg_8        <= '0';
        op_goto_relative        <= '0';
        op_save_to_reg_16       <= '0';
        op_goto_absolute        <= '0';
        op_alu_8                <= '0';
        op_lookup               <= '0';
        op_load_reg_immediate   <= '0';
        op_load_reg_memory      <= '0';
        op_nop                  <= '0';
        op_save_flags           <= '0';
        op_wait_scanline        <= '0';
        op_raise_interrupt      <= '0';
        op_save_reg_memory      <= '0';
        op_wait_screen_flags    <= '0';
        op_alu_16               <= '0';
        op_multiply             <= '0';
        op_branch_rel_if_flag   <= '0';
        op_clear_flags          <= '0';
        
        IF instruction_reg(15) = '0' THEN
            op_save_immediate <= '1';               --0mmmmmmm      Save to memory immediate
        ELSE
            case instruction_reg(14 downto 11) is
                WHEN "0000" =>                  
                    op_save_to_reg_8 <= NOT instruction_reg(8);     
                    --10000dd0      Save (source) to 8 bit register
                    
                    op_goto_relative <= instruction_reg(8);         
                    --10000xx1      Goto relative
                    
                WHEN "0001" =>
                    op_save_to_reg_16 <= NOT instruction_reg(8);    
                    --10001dx0      Save (source) to 16 bit register
                    
                    op_save_R16_to_index <= instruction_reg(8);     
                    --10001001      Transfer 16 bit register a to both bytes of index register
                    
                WHEN "0010" =>
                    op_alu_8 <= '1';                                
                    --10010ddo      8 bit ALU operation
                    
                WHEN "0011" =>
                    op_goto_absolute <= NOT instruction_reg(10);    
                    --100110aa      Goto absolute
                    
                    op_lookup <= instruction_reg(10);               
                    --100111xx      Table lookup
                    
                WHEN "0100" =>
                    op_load_reg_immediate <= NOT (instruction_reg(8) AND instruction_reg(9));
                    --10100dd0      Load 8 bit register from immediate
                    --10100d01      Load 16 bit register d from immediate value + "00000000"
                    
                    op_save_imm_to_index <= instruction_reg(8) AND instruction_reg(9);                    
                    --10100011      Write immediate to high byte of index register
                    --10100111      write immediate to low byte of index register
                    
                WHEN "0101" =>
                    op_load_reg_memory <= NOT instruction_reg(8);   
                    --10101dd0      Load register d from memory
                    
                    op_read_ext_mem <= instruction_reg(8);          
                    --10101d11 	    read memory at index into an 8 bit register
                    
                WHEN "0110" =>
                    case instruction_reg(9 downto 8) is
                        WHEN "00" =>                                
                            op_nop <= '1';                          
                            --10110x00      Nop
                            
                        WHEN "01" =>                                
                            op_save_flags <= '1';                   
                            --10110d01      Save screen flags to 16 bit register
                            
                        WHEN "10" =>
                            op_wait_scanline <= '1';                
                            --10110x10      Wait for immediate scanline
                            
                        WHEN "11" =>
                            op_wait_scanline <= '1';                
                            --10110x11      Wait for scanline matching register
                            
                        WHEN OTHERS =>
                        
                    END CASE;
                WHEN "0111" =>
                    op_save_index_to_r16 <= instruction_reg(8);
                    --10111dx1 xxxxxxxx	Transfer both bytes of index register to 16 bit register d   
                    
                    op_clear_flags <= instruction_reg(9) AND NOT instruction_reg(8);
                    op_raise_interrupt <= instruction_reg(10) AND NOT instruction_reg(8);   
                    --10111000 xxxxxxxx	unofficial Nop                                                             
                    --10111010 xxxxxxxx	Clear ALU flags                                                 
                    --10111100 xxxxxxxx	Raise interrupt to CPU                                          
                    --10111110 xxxxxxxx	Clear ALU flags and Raise interrupt to CPU 
                    
                WHEN "1000" =>
                    op_save_reg_memory <= NOT (instruction_reg(9) AND instruction_reg(8));
                    --11000rr0 0mmmmmmm	Save 8 bit register r to memory location m
                    --11000rr0 1xxxxaaa	Save 8 bit register r to memory at address of register a
                    --11000r01 0mmmmmmm	Save 16 bit register r to memory location m                     
                    --11000r01 1xxxxaaa	Save 16 bit register r to memory at address of register a  
                    
                    op_write_ext_mem <= instruction_reg(9) AND instruction_reg(8);     
                    --11000011 iiiiiiii	write immediate to memory at index                              
                    --11000111 xxxxxaaa	write 8 bit register a contents to memory at index    
                    
                WHEN "1001" =>
                    op_wait_screen_flags <= '1';                    
                    --11001fff      Wait for screen flags
                    
                WHEN "1010" =>
                    op_alu_16 <= '1';                               
                    --11010dxo      16 bit ALU operation
                    
                WHEN "1011" =>
                    op_multiply <= '1';                             
                    --11011dss      Multiply
                    
                WHEN "1100" =>
                    op_branch_rel_if_flag <= '1';                   
                    --111fffff      Branch relative if
                    
                WHEN "1101" =>
                    op_branch_rel_if_flag <= '1';                   
                    --111fffff      Branch relative if
                    
                WHEN "1110" =>
                    op_branch_rel_if_flag <= '1';                   
                    --111fffff      Branch relative if
                    
                WHEN "1111" =>
                    op_branch_rel_if_flag <= '1';                   
                    --111fffff      Branch relative if
                    
                WHEN OTHERS =>
                
            END CASE;
        END IF;
    
    END PROCESS;

    PROCESS(instruction_reg,op_save_immediate,op_write_ext_mem)
    BEGIN
    
        --7 bits, immediate memory address for memory read/write operations
        IF instruction_reg(15) = '1' THEN
            mem_immediate_address  <= instruction_reg(6 downto 0);      --1xxxxxxx xmmmmmmm
        ELSE
            mem_immediate_address  <= instruction_reg(14 downto 8);     --0mmmmmmm xxxxxxxx
        END IF;
        
        --8 bits, immediate value for scanline wait, write to memory, or set register operation
        value_immediate         <= instruction_reg(7 downto 0);         --xxxxxxxx iiiiiiii
        
        --2 bits, 8 bit register destination select (A,B,C,D)
        dest_8_select           <= instruction_reg(10 downto 9);        --xxxxxddx xxxxxxxx
        
        --1 bit, 16 bit register destination select (AB, CD)
        dest_16_select          <= instruction_reg(10);                 --xxxxxdxx xxxxxxxx
        
        --3 bits, source A select
        source_select_1         <= instruction_reg(2 downto 0);         --xxxxxxxx xxxxxaaa
        
        --3 bits, source B select
        source_select_2         <= instruction_reg(5 downto 3);         --xxxxxxxx xxbbbxxx
        
        --7 bits, relative jump address (signed -64 to +63)
        --10 bits, absolute_jump_address (unsigned 0 to 1023)
        jump_address            <= instruction_reg(9 downto 0);         --xxxxxxaa aaaaaaaa
           
        --3 bits, ALU operation select
        alu_op_select           <= instruction_reg(8 downto 6);         --xxxxxxxo ooxxxxxx
        
        --1 bit, memory immediate versus indexed flag
        memory_index_flag       <= instruction_reg(7);                  --xxxxxxxx ixxxxxxx
        
        --1 bit, scanline immediate versus register flag
        scanline_imm_select     <= instruction_reg(8);                  --xxxxxxxs xxxxxxxx
        
        --4 bits, multiply post-shift value
        multiply_shift          <= instruction_reg(9 downto 6);         --xxxxxxss ssxxxxxx
        
        --11 bits, screen flag compare bitmask
        screen_flags_select     <= instruction_reg(10 downto 0);        --xxxxxfff ffffffff
        
        --6 bits, ALU flags compare bitmask
        alu_flags_select        <= instruction_reg(12 downto 7);        --xxxfffff fxxxxxxx
        
        --3 bits, result value steering
        result_select           <= instruction_reg(13 downto 11);       --xxrrrxxx xxxxxxxx
        
        --1 bit, ALU 8/16 bit mode select
        alu_16_bit              <= instruction_reg(14);                 --xsxxxxxx xxxxxxxx
        
        --2 bits, table lookup select
        lookup_select           <= instruction_reg(9 downto 8);         --xxxxxxss xxxxxxxx
        
        --1 bit, scanline wait/skip select
        passed_select           <= instruction_reg(10);                 --xxxxxsxx xxxxxxxx
        
        --1 bit, 16 bit memory access flag
        rw_16_bits              <= instruction_reg(8);                  --xxxxxxxs xxxxxxxx
        
        index_reg_select        <= instruction_reg(10);                 --xxxxxsxx xxxxxxxx
        
        memory_address_immediate <= op_save_immediate OR NOT memory_index_flag;
        
        mem_save_reg_select(2)     <= (rw_16_bits or op_save_immediate or op_write_ext_mem);
        
        --2 bits, memory write data source select
        IF op_save_immediate THEN
            mem_save_reg_select(1 downto 0)     <= "01";
        ELSE
            mem_save_reg_select(1 downto 0)     <= instruction_reg(10 downto 9);        --xxxxxrrx xxxxxxxx
        END IF;
        
    END PROCESS;
    
    op_decode_state_control <=  passed_select &
                                index_reg_select &
                                op_save_R16_to_index & 
                                op_save_imm_to_index &
                                op_read_ext_mem &                   
                                op_save_index_to_r16 &                  
                                op_write_ext_mem &
                                op_save_immediate &                 
                                op_save_to_reg_8 &                 
                                op_goto_relative &                   
                                op_save_to_reg_16 &                
                                op_goto_absolute &
                                op_alu_8 &                    
                                op_lookup &                   
                                op_load_reg_immediate &                    
                                op_load_reg_memory &                    
                                op_nop &
                                op_save_flags &                   
                                op_wait_scanline &                    
                                op_raise_interrupt &                   
                                op_clear_flags &                      
                                op_save_reg_memory &
                                op_wait_screen_flags &                  
                                op_alu_16 &                   
                                op_multiply &                    
                                op_branch_rel_if_flag;
                                
    op_decode_data_control <= mem_immediate_address &   -- 7 bits, 30 downto 24
                              dest_8_select &           -- 2 bits, 23 downto 22
                              dest_16_select &          -- 1 bit,  21
                              alu_16_bit &              -- 1 bit,  20
                              source_select_1 &         -- 3 bits, 19 downto 17
                              source_select_2 &         -- 3 bits, 16 downto 14
                              mem_save_reg_select &     -- 3 bits, 13 downto 11
                              alu_op_select &           -- 3 bits, 10 downto 8
                              multiply_shift &          -- 4 bits, 7 downto 4
                              result_select &           -- 3 bits, 3 downto 1
                              memory_address_immediate; -- 1 bit,  0
    
    op_decode_cond_control <=   scanline_imm_select &   -- 1 bit,   17
                                screen_flags_select &   -- 11 bits, 16 downto 6
                                alu_flags_select;       -- 6 bits,  5 downto 0

    
END behavior;