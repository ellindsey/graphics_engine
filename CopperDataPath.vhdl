LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY copperDataPath IS
    PORT(    
        CLK                     : IN  STD_LOGIC;
        RESET                   : IN  STD_LOGIC;
        RUN                     : IN  STD_LOGIC;
        
        active_line             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        mem_in_value            : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        conditions              : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
        invSqrtDataIn           : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        sinCosDataIn            : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        
        op_decode_data_control  : IN  STD_LOGIC_VECTOR(30 DOWNTO 0);
        state_data_control      : IN  STD_LOGIC_VECTOR(8 DOWNTO 0);
        
        value_immediate         : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        lookup_select           : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        
        aluFlags                : OUT STD_LOGIC_VECTOR(2 downto 0);
        
        MemoryDataOut           : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        MemoryAddressOut        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        IndexRegisterOut        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        LookupAddressOut        : OUT integer range 0 to 511
    );
END copperDataPath;

ARCHITECTURE behavior OF copperDataPath IS

    COMPONENT sourceSelect IS
        PORT(
            source_select   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            reg_A           : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            reg_B           : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            reg_C           : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            reg_D           : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            active_line     : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            invsqrt         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            sinCos          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            sel_16_bit      : IN  STD_LOGIC;
            
            out_8           : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            out_16          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            out_combined    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT sourceSelect;
    
    COMPONENT ALU IS
        PORT(
            alu_op_select           : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            alu_A                   : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            alu_B                   : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            alu_carry_in            : IN STD_LOGIC;
            alu_result              : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            alu_carry_out           : OUT STD_LOGIC;
            alu_zero_out            : OUT STD_LOGIC;
            alu_sign_out            : OUT STD_LOGIC
        );
    END COMPONENT ALU;
    
    COMPONENT Mult16 IS
        PORT(
            shift       : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            SOURCE_A    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            SOURCE_B    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            RESULT      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT Mult16;
    
    COMPONENT mux16x8 IS
        PORT(
            selectIn : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            in0      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            in1      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            in2      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            in3      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            in4      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            in5      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            in6      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            in7      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            out0     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT mux16x8;
    
    COMPONENT mux16x2 IS
        PORT(
            selectIn : IN  STD_LOGIC;
            in0      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            in1      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            out0     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT mux16x2;
    
    COMPONENT copperRegisters IS
        PORT(    
            CLK                     : IN  STD_LOGIC;
            RESET                   : IN  STD_LOGIC;
            RUN                     : IN  STD_LOGIC;
            load_reg_8              : IN  STD_LOGIC;
            load_reg_16             : IN  STD_LOGIC;
            dest_8_select           : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            dest_16_select          : IN  STD_LOGIC;
            new_value               : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            reg_A                   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            reg_B                   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            reg_C                   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            reg_D                   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT copperRegisters;
    
    SIGNAL reg_A                    : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL reg_B                    : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL reg_C                    : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL reg_D                    : STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    SIGNAL alu_A                    : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";    --ALU or multiplier input A value register
    SIGNAL alu_b                    : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";    --ALU or multiplier input B value register

    SIGNAL next_alu_A               : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL next_alu_B               : STD_LOGIC_VECTOR(15 DOWNTO 0);
    
    SIGNAL alu_result               : STD_LOGIC_VECTOR(15 DOWNTO 0);    --alu result value
    SIGNAL mult_result              : STD_LOGIC_VECTOR(15 DOWNTO 0);    --multiplier result value
    
    SIGNAL result                   : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";    --result register
    SIGNAL next_result              : STD_LOGIC_VECTOR(15 DOWNTO 0);
     
    SIGNAL aluFlagZero              : STD_LOGIC := '0';
    SIGNAL aluFlagCarry             : STD_LOGIC := '0';
    SIGNAL aluFlagSign              : STD_LOGIC := '0';
    
    SIGNAL aluFlagZero_new          : STD_LOGIC;
    SIGNAL aluFlagCarry_new         : STD_LOGIC;
    SIGNAL aluFlagSign_new          : STD_LOGIC;
    
    SIGNAL next_aluFlagZero         : STD_LOGIC;
    SIGNAL next_aluFlagCarry        : STD_LOGIC;
    SIGNAL next_aluFlagSign         : STD_LOGIC;
    
    SIGNAL source_8_1               : STD_LOGIC_VECTOR(7 DOWNTO 0);     --ALU 8 bit input 1 value
    SIGNAL source_8_2               : STD_LOGIC_VECTOR(7 DOWNTO 0);     --ALU 8 bit input 2 value
    SIGNAL source_16_1              : STD_LOGIC_VECTOR(15 DOWNTO 0);    --ALU 16 bit input 1 value
    SIGNAL source_16_2              : STD_LOGIC_VECTOR(15 DOWNTO 0);    --ALU 16 bit input 2 value
    
    SIGNAL index_register           : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    SIGNAL next_index_register      : STD_LOGIC_VECTOR(15 DOWNTO 0);
    
    SIGNAL lookup_address           : integer range 0 to 511 := 0;
    SIGNAL next_lookup_address      : integer range 0 to 511;
    
    SIGNAL invsqrt                  : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL next_invsqrt             : STD_LOGIC_VECTOR(15 DOWNTO 0);
    
    SIGNAL sinCos                   : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL next_sinCos              : STD_LOGIC_VECTOR(15 DOWNTO 0);
    
    SIGNAL memory_write_data        : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    SIGNAL next_memory_write_data   : STD_LOGIC_VECTOR(15 DOWNTO 0);
   
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
    
    SIGNAL load_sincos             : STD_LOGIC; -- 8
    SIGNAL load_invsqrt            : STD_LOGIC; -- 7
    SIGNAL clear_flags             : STD_LOGIC; -- 6
    SIGNAL load_reg_8              : STD_LOGIC; -- 5
    SIGNAL load_reg_16             : STD_LOGIC; -- 4
    SIGNAL load_ALU_flags          : STD_LOGIC; -- 3
    SIGNAL load_index_16           : STD_LOGIC; -- 2
    SIGNAL load_index_8_high       : STD_LOGIC; -- 1
    SIGNAL load_index_8_low        : STD_LOGIC; -- 0
    
BEGIN
    
    mem_immediate_address <= op_decode_data_control(30 downto 24);-- 7 bits, 30 downto 24
    dest_8_select <= op_decode_data_control(23 downto 22);        -- 2 bits, 23 downto 22
    dest_16_select <= op_decode_data_control(21);                 -- 1 bit,  21
    alu_16_bit <= op_decode_data_control(20);                     -- 1 bit,  20
    source_select_1 <= op_decode_data_control(19 downto 17);      -- 3 bits, 19 downto 17
    source_select_2 <= op_decode_data_control(16 downto 14);      -- 3 bits, 16 downto 14
    mem_save_reg_select <= op_decode_data_control(13 downto 11);  -- 3 bits, 13 downto 11
    alu_op_select <= op_decode_data_control(10 downto 8);         -- 3 bits, 10 downto 8
    multiply_shift <= op_decode_data_control(7 downto 4);         -- 4 bits, 7 downto 4
    result_select <= op_decode_data_control(3 downto 1);          -- 3 bits, 3 downto 1
    memory_address_immediate <= op_decode_data_control(0);        -- 1 bit,  0
    
    load_sincos <= state_data_control(8);      -- 8    
    load_invsqrt <= state_data_control(7);     -- 7
    clear_flags <= state_data_control(6);      -- 6
    load_reg_8 <= state_data_control(5);       -- 5
    load_reg_16 <= state_data_control(4);      -- 4
    load_ALU_flags <= state_data_control(3);   -- 3
    load_index_16 <= state_data_control(2);    -- 2
    load_index_8_high <= state_data_control(1);-- 1
    load_index_8_low <= state_data_control(0); -- 0
                          
    --steering for source register 1
    sourceSelect1: sourceSelect 
        PORT MAP(
            source_select   => source_select_1,         --from bits 0-2 of the operation code
            reg_A           => reg_A,               
            reg_B           => reg_B,               
            reg_C           => reg_C,               
            reg_D           => reg_D,               
            active_line     => active_line,     
            invsqrt         => invsqrt,                 --from table lookup
            sinCos          => sinCos,                  --from table lookup
            sel_16_bit      => alu_16_bit,              --8 or 16 bit ALU operation
            out_8           => source_8_1,              --selected 8 bit data value 1
            out_16          => source_16_1,             --selected 16 bit data value 2
            out_combined    => next_alu_A               --to ALU
        );
    
    --steering for source register 2
    sourceSelect2: sourceSelect 
        PORT MAP(
            source_select   => source_select_2,         --from bits 3-5 of the operation code
            reg_A           => reg_A,
            reg_B           => reg_B,
            reg_C           => reg_C,
            reg_D           => reg_D,
            active_line     => active_line,
            invsqrt         => invsqrt,                 --from table lookup
            sinCos          => sinCos,                  --from table lookup
            sel_16_bit      => alu_16_bit,              --8 or 16 bit ALU operation
            out_8           => source_8_2,              --selected 8 bit data value 1
            out_16          => source_16_2,             --selected 16 bit data value 2
            out_combined    => next_alu_B               --to ALU
        );
    
    --16 bit ALU
    copperALU: ALU 
        PORT MAP(
                alu_op_select           => alu_op_select,
                alu_A                   => alu_A,
                alu_B                   => alu_b,
                alu_carry_in            => aluFlagCarry,
                alu_result              => alu_result,
                alu_carry_out           => aluFlagCarry_new,
                alu_zero_out            => aluFlagZero_new,
                alu_sign_out            => aluFlagSign_new
            );
    
    --16 bit multiplier with shift
    copperMult: Mult16
        PORT MAP(
                shift       => multiply_shift,
                SOURCE_A    => alu_A,
                SOURCE_B    => alu_b,
                RESULT      => mult_result
            );
            
    --steering for result value
    resultSteer : mux16x8
        PORT MAP(
            selectIn => result_select,
            in0      => source_8_1 & "00000000",                                            --opcode xx000xxx = 8 bit source to destination
            in1      => source_16_1,                                                        --opcode xx001xxx = 16 bit source to destination
            in2      => alu_result,                                                         --opcode xx010xxx = ALU operation, 8 or 16 bit
            in3      => mult_result,                                                        --opcode xx011xxx = multiplication operation
            in4      => value_immediate & "00000000",                                       --opcode xx100xxx = immediate value operation
            in5      => mem_in_value,                                                       --opcode xx101xxx = read from memory operation
            in6      => ALUflagZero & ALUflagCarry & ALUflagSign & "00" & conditions,       --opcode xx110xxx = save flags and condition
            in7      => index_register,                                                     --opcode xx111xxx = index register to destination
            out0     => next_result
        );
        
    --register save strobe and destination steering
    registers : copperRegisters
        PORT MAP(
            CLK                     => CLK,
            RESET                   => RESET,
            RUN                     => RUN,
            load_reg_8              => load_reg_8,
            load_reg_16             => load_reg_16,
            dest_8_select           => dest_8_select,
            dest_16_select          => dest_16_select,
            new_value               => result,
            reg_A                   => reg_A,
            reg_B                   => reg_B,
            reg_C                   => reg_C,
            reg_D                   => reg_D
        );
        
    --ALU flag update strobe handling
    PROCESS(RESET,clear_flags,load_ALU_flags,aluFlagZero,aluFlagCarry,aluFlagSign,aluFlagZero_new,aluFlagCarry_new,aluFlagSign_new)
    BEGIN
        IF RESET OR clear_flags THEN
            next_aluFlagZero <= '0';
            next_aluFlagCarry <= '0';
            next_aluFlagSign <= '0';
        ELSIF load_ALU_flags THEN
            next_aluFlagZero <= aluFlagZero_new;
            next_aluFlagCarry <= aluFlagCarry_new;
            next_aluFlagSign <= aluFlagSign_new;
        ELSE
            next_aluFlagZero <= aluFlagZero;
            next_aluFlagCarry <= aluFlagCarry;
            next_aluFlagSign <= aluFlagSign;
        END IF;
    END PROCESS;
        
    --steering for memory write data register
    data_out_mux: mux16x8 
        PORT MAP(
            selectIn => mem_save_reg_select,
            in0      => reg_A & reg_A,                      --000 = opcode 11000000 = write 8 bit register A to memory (7 bit address mode)
            in1      => reg_B & reg_B,                      --001 = opcode 11000010 = write 8 bit register B to memory (7 bit address mode)
            in2      => reg_C & reg_C,                      --010 = opcode 11000100 = write 8 bit register C to memory (7 bit address mode)
            in3      => reg_D & reg_D,                      --011 = opcode 11000110 = write 8 bit register D to memory (7 bit address mode)
            in4      => reg_A & reg_B,                      --100 = opcode 11000001 = write 16 bit register AB to memory (7 bit address mode)
            in5      => value_immediate & value_immediate,  --101 = opcode 11000011 = write immediate value to memory
            in6      => reg_C & reg_D,                      --110 = opcode 11000101 = write 16 bit register CD to memory (7 bit address mode)
            in7      => source_8_1 & source_8_1,            --111 = opcode 11000111 = write selected 8 bit register to memory (indexed address mode)
            out0     => next_memory_write_data
        );
        
    --memory address steering
    PROCESS(memory_address_immediate,mem_immediate_address,source_8_1)
    BEGIN
        IF memory_address_immediate THEN
            MemoryAddressOut <= mem_immediate_address;
        ELSE
            MemoryAddressOut <= source_8_1(6 downto 0);
        END IF;
    END PROCESS;
    
    --next index register steering
    PROCESS(RESET,index_register,load_index_8_high,load_index_8_low,load_index_16,value_immediate,source_16_1)
    BEGIN
        IF RESET THEN
            next_index_register <= "0000000000000000";
        ELSIF load_index_8_high THEN
            next_index_register <= index_register(15 downto 8) & value_immediate;
        ELSIF load_index_8_low THEN
            next_index_register <= value_immediate & index_register(7 downto 0);
        ELSIF load_index_16 THEN
            next_index_register <= source_16_1;
        ELSE
            next_index_register <= index_register;
        END IF;
    END PROCESS;
    
    --Lookup table address output calculation
    PROCESS(lookup_select,source_8_1)
        variable addrSqrt : integer range 0 to 511;
        variable addrInv : integer range 0 to 511;
        variable addrSin : integer range 0 to 255;
        variable addrCos : integer range 0 to 255;
    BEGIN
        addrInv := to_integer(unsigned(source_8_1));
        addrSqrt := addrInv + 256;
        addrSin := to_integer(unsigned(source_8_1));
        addrCos := addrSin + 192;
        
        CASE lookup_select IS
            WHEN "00" => --square root lookup
                next_lookup_address <= addrSqrt;
            WHEN "01" => --inverse lookup
                next_lookup_address <= addrInv;
            WHEN "10" => --sine lookup
                next_lookup_address <= addrSin;
            WHEN "11" => --cosine lookup
                next_lookup_address <= addrCos;
            WHEN OTHERS =>
                next_lookup_address <= 0;
        END CASE;
    END PROCESS;
        
    --load inverse/square root lookup data
    next_invsqrt_reg_mux: mux16x2 
        PORT MAP(
            selectIn => load_invsqrt,
            in0      => invsqrt,
            in1      => invSqrtDataIn,
            out0     => next_invsqrt
        );
    
    --load sin/cos lookup data
    next_sincos_reg_mux: mux16x2 
        PORT MAP(
            selectIn => load_sincos,
            in0      => sinCos,
            in1      => sinCosDataIn,
            out0     => next_sinCos
        );
        
    --clocked register update
    PROCESS(CLK,RUN,next_result,next_alu_A,next_alu_B)
    BEGIN
        IF RISING_EDGE(CLK) AND (RUN = '1') THEN
            aluFlagCarry <= next_aluFlagCarry;
            aluFlagSign <= next_aluFlagSign;
            aluFlagZero <= next_aluFlagZero;
            
            result <= next_result;
            alu_A <= next_alu_A;
            alu_B <= next_alu_B;
            
            index_register <= next_index_register;
            lookup_address <= next_lookup_address;
            
            invsqrt <= next_invsqrt;
            sinCos <= next_sinCos;
            
            memory_write_data <= next_memory_write_data;
        END IF;
    END PROCESS;
    
    aluFlags <= aluFlagZero & aluFlagCarry & aluFlagSign;
    
    IndexRegisterOut <= index_register;
    
    LookupAddressOut <= lookup_address;
    
    MemoryDataOut <= memory_write_data;
END behavior;