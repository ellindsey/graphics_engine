LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY copper IS
    PORT(
        --CLK25M                  : IN  STD_LOGIC;
        CLK100M                 : IN  STD_LOGIC;
        COPPER_RESET            : IN  STD_LOGIC;
        COPPER_RUN              : IN  STD_LOGIC;
        
        CONDITIONS              : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
        ACTIVE_LINE             : IN  integer range 0 to 239;
        
        ADDRESS_OUT             : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        DATA_OUT                : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        DATA_IN                 : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        WRITE_STROBE            : OUT STD_LOGIC;
        BYTE_FLAGS              : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        
        COPPER_ADDRESS_OUT      : OUT integer range 0 to 1023;
        COPPER_INST_IN          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        
        LOOKUP_ADDRESS_OUT      : OUT integer range 0 to 511;
        INVSQRT_DATA_IN         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        SINCOS_DATA_IN          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        
        COPPER_INTERRUPT_OUT    : OUT STD_LOGIC
    );
END copper;

ARCHITECTURE behavior OF copper IS
          
    COMPONENT instDecode IS
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
    END COMPONENT instDecode;
    
    COMPONENT copperStateEngine IS
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
    END COMPONENT copperStateEngine;
    
    COMPONENT copperDataPath IS
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
    END COMPONENT copperDataPath;
    
    COMPONENT copperInstructionPointer IS
        PORT(    
            CLK                     : IN  STD_LOGIC;
            RUN                     : IN  STD_LOGIC;
            RESET                   : IN  STD_LOGIC;
            flow_control            : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            jump_address            : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
            instructionPointerOut   : OUT integer range 0 to 1023
        );
    END COMPONENT copperInstructionPointer;

    COMPONENT copperConditionals IS
        PORT(    
            op_decode_cond_control  : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
            value_immediate         : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            data8int                : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            active_line             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            aluFlags                : IN  STD_LOGIC_VECTOR(2 downto 0);
            conditions              : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
            conditionCheckFlags     : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    END COMPONENT copperConditionals;

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

    COMPONENT mux16x4 IS
        PORT(
            selectIn : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            in0      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            in1      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            in2      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            in3      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            out0     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT mux16x4;

    COMPONENT mux16x2 IS
        PORT(
            selectIn : IN  STD_LOGIC;
            in0      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            in1      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            out0     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT mux16x2;
    
    COMPONENT mux8x2 IS
        PORT(
            selectIn : IN  STD_LOGIC;
            in0      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            in1      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            out0     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT mux8x2;

    SIGNAL op_decode_state_control  : STD_LOGIC_VECTOR(25 DOWNTO 0);
    SIGNAL op_decode_data_control   : STD_LOGIC_VECTOR(30 DOWNTO 0);
    SIGNAL op_decode_cond_control   : STD_LOGIC_VECTOR(17 DOWNTO 0);
    
    SIGNAL state_data_control       : STD_LOGIC_VECTOR(8 DOWNTO 0);
    
    SIGNAL int_active_line          : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL int_instruction_reg      : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL int_conditions           : STD_LOGIC_VECTOR(10 DOWNTO 0);
    
    SIGNAL index_register           : STD_LOGIC_VECTOR(15 DOWNTO 0); --TODO
    
    SIGNAL aluFlags                 : STD_LOGIC_VECTOR(2 downto 0);
    
    SIGNAL instructionPointer       : integer range 0 to 1023;
    
    SIGNAL scanline_imm_select      : STD_LOGIC;
    SIGNAL value_immediate          : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL jump_address             : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL screen_flags_select      : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL alu_flags_select         : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL lookup_select            : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL rw_16_bits               : STD_LOGIC;
    
    SIGNAL data8int                 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL mem_in_value             : STD_LOGIC_VECTOR(15 DOWNTO 0);
    
    SIGNAL conditionCheckFlags      : STD_LOGIC_VECTOR(3 DOWNTO 0);
    
    SIGNAL load_inst_reg            : STD_LOGIC;
    SIGNAL memory_write             : STD_LOGIC;
    SIGNAL raise_interrupt          : STD_LOGIC;
    SIGNAL ext_mem_read             : STD_LOGIC; --TODO
    SIGNAL ext_mem_write            : STD_LOGIC; --TODO
    
    SIGNAL flow_control             : STD_LOGIC_VECTOR(1 DOWNTO 0);
    
    SIGNAL next_address_out         : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL lookup_address           : integer range 0 to 511;
    
    --TODO: finish code for general memory access instructions
    --      read process to read general memory at index to 8 bit register A/B
    --      write process to write general memory at index from 8 or 16 bit
    --      read and write output strobes, driven by state engine and decoded instruction lines
    --      also need to add the hooks in main to allow this memory access to override the CPU access port
    
BEGIN
    --instruction decoder
    copperInstDecode: instDecode 
        PORT MAP(
            instruction_reg         => int_instruction_reg,
            op_decode_state_control => op_decode_state_control,
            op_decode_data_control  => op_decode_data_control,
            op_decode_cond_control  => op_decode_cond_control,
            value_immediate         => value_immediate,
            jump_address            => jump_address,
            lookup_select           => lookup_select,
            rw_16_bits              => rw_16_bits
        );
    
    --state engine
    stateEngine: copperStateEngine 
        PORT MAP(
            CLK                     => CLK100M,
            RUN                     => COPPER_RUN,
            RESET                   => COPPER_RESET,
            op_decode_state_control => op_decode_state_control,
            state_data_control      => state_data_control,
            lookup_select           => lookup_select,
            rw_16_bits              => rw_16_bits,
            conditionCheckFlags     => conditionCheckFlags,
            load_inst_reg           => load_inst_reg,
            memory_write            => memory_write,
            raise_interrupt         => raise_interrupt,
            ext_mem_read            => ext_mem_read,
            ext_mem_write           => ext_mem_write,
            flow_control            => flow_control
        );
        
    -- Main data path logic
    dataPath : copperDataPath
        PORT MAP(
            CLK                     => CLK100M,
            RESET                   => COPPER_RESET,
            RUN                     => COPPER_RUN,
            op_decode_data_control  => op_decode_data_control,
            state_data_control      => state_data_control,
            active_line             => int_active_line,
            value_immediate         => value_immediate,
            lookup_select           => lookup_select,
            mem_in_value            => mem_in_value,
            conditions              => int_conditions,
            invSqrtDataIn           => INVSQRT_DATA_IN,
            sinCosDataIn            => SINCOS_DATA_IN,
            aluFlags                => aluFlags,
            MemoryDataOut           => DATA_OUT,
            MemoryAddressOut        => next_address_out,
            IndexRegisterOut        => index_register,
            LookupAddressOut        => lookup_address
        );
    
    --Condition check and control flow logic
    conditionCheck : copperConditionals
        PORT MAP(    
            op_decode_cond_control  => op_decode_cond_control,
            value_immediate         => value_immediate,
            data8int                => data8int,
            active_line             => int_active_line,
            aluFlags                => aluFlags,
            conditions              => int_conditions,
            conditionCheckFlags     => conditionCheckFlags
        );
    
    --next instruction pointer math and steering
    copperIP : copperInstructionPointer
        PORT MAP(
            CLK                     => CLK100M,
            RUN                     => COPPER_RUN,
            RESET                   => COPPER_RESET,
            flow_control            => flow_control,
            jump_address            => jump_address,
            instructionPointerOut   => instructionPointer
        );
    
    --steering for memory read data register
    mem_in_value_mux: mux16x4 
        PORT MAP(
            selectIn => rw_16_bits & next_address_out(0),
            in0      => DATA_IN(15 downto 8) & "00000000",  --00 = opcode 10101dd0, address low bit 0 = read high 8 bits
            in1      => DATA_IN(7 downto 0) & "00000000",   --01 = opcode 10101dd0, address low bit 1 = read low 8 bits
            in2      => DATA_IN,                            --10 = opcode 10101d01 = read all 16 bits
            in3      => DATA_IN,                            --11 = opcode 10101d01 = read all 16 bits
            out0     => mem_in_value
        );
    
    --clocked register update
    PROCESS(CLK100M,COPPER_RUN,next_address_out,memory_write)
    BEGIN
        IF RISING_EDGE(CLK100M) AND (COPPER_RUN = '1') THEN
            
            ADDRESS_OUT <= next_address_out(6 downto 1);
            BYTE_FLAGS(0) <= rw_16_bits OR NOT next_address_out(0);
            BYTE_FLAGS(1) <= rw_16_bits OR next_address_out(0);
            
            WRITE_STROBE <= memory_write;  --might need this here
            
            --load active line register and system flags on 100M clock
            int_active_line <= STD_LOGIC_VECTOR(to_unsigned(ACTIVE_LINE,8));
            int_conditions <= CONDITIONS;
            
            --load instruction register on 100M clock when flag is set
            IF load_inst_reg = '1' THEN
                int_instruction_reg <= COPPER_INST_IN;
            END IF;
        END IF;
    END PROCESS;
    
    COPPER_ADDRESS_OUT <= instructionPointer;
    COPPER_INTERRUPT_OUT <= raise_interrupt;
    LOOKUP_ADDRESS_OUT <= lookup_address;
    
END behavior;