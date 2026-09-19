LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY instDecode IS
    PORT(
        instruction_reg         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        
        INST_DIRECT_WRITE       : OUT STD_LOGIC;    --cccccccc nnnnnnn0	Save (8 bit const) to (memory address)
        INST_WAIT_LINE          : OUT STD_LOGIC;    --cccccccc xx000001	Wait for (scanline)
        INST_GOTO               : OUT STD_LOGIC;    --aaaaaaaa aa001001	Goto (copper address)
        INST_WAIT_FLAGS         : OUT STD_LOGIC;    --cccccccc ccc10001	Wait for (screen flags)
        INST_SKIP_IF            : OUT STD_LOGIC;    --xxxxxxxx fp011001	Skip next instruction if (ALU flag) = (polarity)
        INST_INTERRUPT          : OUT STD_LOGIC;    --xxxxxxxx xx100001	Raise interrupt
        INST_LOAD_FLAGS         : OUT STD_LOGIC;    --00xxxxxx dx100101	(16 bit register) = (screen flags)
        INST_MOV                : OUT STD_LOGIC;    --00xxxaaa dd000101	(8 bit register) = (8 bit register)
        INST_INV                : OUT STD_LOGIC;    --00xxxaaa xx001101	Look up inverse using (8 bit register) as an index
        INST_SIN                : OUT STD_LOGIC;    --00xxxaaa xx010101	Look up sine using (8 bit register) as an index
        INST_COS                : OUT STD_LOGIC;    --00xxxaaa xx011101	Look up cosine using (8 bit register) as an index
        INST_ALU_8              : OUT STD_LOGIC;    --01bbbaaa ddooo101	(8 bit register) = (8 bit register) (ALU operation) (8 bit register)
        INST_ALU_16             : OUT STD_LOGIC;    --10bbbaaa dxooo101	(16 bit register) = (16 bit register) (ALU operation) (16 bit register)
        INST_MULT               : OUT STD_LOGIC;    --11bbbaaa dssss101	(16 bit register) = ((16 bit register) * (16 bit register)) >> (shift)
        INST_WRITE_MEM          : OUT STD_LOGIC;    --xnnnnnnn xxaaa011	Save (8 bit register) to (memory address)
        INST_READ_MEM           : OUT STD_LOGIC;    --xnnnnnnn ddxx0111	Load (8 bit register) from (memory address)
        INST_SET                : OUT STD_LOGIC;    --cccccccc ddxx1111	(8 bit register) = (8 bit constant)
        INST_LATCH              : OUT STD_LOGIC;
        const8                  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        target_mem_address      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        conditionsFilter        : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
        ALUflagSelect           : OUT STD_LOGIC;
        ALUflagPolarity         : OUT STD_LOGIC;
        source_select_a         : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        source_select_b         : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        ALUopSelect             : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        shiftval                : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        gotoAddress             : OUT integer range 0 to 1023;
        dest8                   : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        dest16                  : OUT STD_LOGIC
    );
END instDecode;

ARCHITECTURE behavior OF instDecode IS
BEGIN

    PROCESS(instruction_reg)
    BEGIN
        INST_DIRECT_WRITE <= NOT instruction_reg(0);
        
        INST_WAIT_LINE <= '1' when (instruction_reg(5 downto 0) = "000001") else '0';
        
        INST_GOTO <= '1' when (instruction_reg(5 downto 0) = "001001") else '0';
        
        INST_WAIT_FLAGS <= '1' when (instruction_reg(4 downto 0) = "10001") else '0';
        
        INST_SKIP_IF <= '1' when (instruction_reg(5 downto 0) = "011001") else '0';
        
        INST_INTERRUPT <= '1' when (instruction_reg(5 downto 0) = "100001") else '0';
        
        INST_LOAD_FLAGS <= '1' when (instruction_reg(5 downto 0) = "100101" AND instruction_reg(15 downto 14) = "00") else '0';
        
        INST_MOV <= '1' when (instruction_reg(5 downto 0) = "000101" AND instruction_reg(15 downto 14) = "00") else '0';
        
        INST_INV <= '1' when (instruction_reg(5 downto 0) = "001101" AND instruction_reg(15 downto 14) = "00") else '0';
        
        INST_SIN <= '1' when (instruction_reg(5 downto 0) = "010101" AND instruction_reg(15 downto 14) = "00") else '0';
        
        INST_COS <= '1' when (instruction_reg(5 downto 0) = "011101" AND instruction_reg(15 downto 14) = "00") else '0';
        
        INST_ALU_8 <= '1' when (instruction_reg(2 downto 0) = "101" AND instruction_reg(15 downto 14) = "01") else '0';
        
        INST_ALU_16 <= '1' when (instruction_reg(2 downto 0) = "101" AND instruction_reg(15 downto 14) = "10") else '0';
        
        INST_MULT <= '1' when (instruction_reg(2 downto 0) = "101" AND instruction_reg(15 downto 14) = "11") else '0';
        
        INST_WRITE_MEM <= '1' when (instruction_reg(2 downto 0) = "011") else '0';
        
        INST_READ_MEM <= '1' when (instruction_reg(3 downto 0) = "0111") else '0';
        
        INST_SET <= '1' when (instruction_reg(3 downto 0) = "1111") else '0';
        
        INST_LATCH <= instruction_reg(0) AND instruction_reg(2);
        
        const8 <= instruction_reg(15 downto 8);
    
        IF INST_DIRECT_WRITE THEN
            target_mem_address <= instruction_reg(7 downto 1);
        ELSE
            target_mem_address <= instruction_reg(14 downto 8);
        END IF;
        
        conditionsFilter <= instruction_reg(15 downto 5);
        
        IF INST_WRITE_MEM THEN
            source_select_a <= instruction_reg(5 downto 3);
        ELSE
            source_select_a <= instruction_reg(10 downto 8);
        END IF;
        
        source_select_b <= instruction_reg(13 downto 11);
        
        ALUopSelect <= instruction_reg(5 downto 3);
        
        shiftval <= instruction_reg(6 downto 3);
        
        gotoAddress <= to_integer(unsigned(instruction_reg(15 downto 6)));
    
        dest8 <= instruction_reg(7 downto 6);
        
        dest16 <= instruction_reg(7);
        
    END PROCESS;
    
END behavior;