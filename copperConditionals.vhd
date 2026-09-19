LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY copperConditionals IS
    PORT(    
        op_decode_cond_control  : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
        value_immediate     : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        data8int            : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        active_line         : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        aluFlags            : IN  STD_LOGIC_VECTOR(2 downto 0);
        conditions          : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
        conditionCheckFlags : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END copperConditionals;

ARCHITECTURE behavior OF copperConditionals IS  

    COMPONENT mux8x2 IS
        PORT(
            selectIn : IN  STD_LOGIC;
            in0      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            in1      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            out0     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT mux8x2;
    
    SIGNAL aluFlagZero              : STD_LOGIC;
    SIGNAL aluFlagCarry             : STD_LOGIC;
    SIGNAL aluFlagSign              : STD_LOGIC;
    
    SIGNAL targetLine               : STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    SIGNAL lineMatched              : STD_LOGIC;
    SIGNAL linePassed               : STD_LOGIC;
    SIGNAL aluFlagsMatched          : STD_LOGIC;
    SIGNAL screenFlagsMatched       : STD_LOGIC;
    SIGNAL scanline_imm_select     : STD_LOGIC;
    SIGNAL screen_flags_select     : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL alu_flags_select        : STD_LOGIC_VECTOR(5 DOWNTO 0);
    
BEGIN
    aluFlagZero <= aluFlags(2);
    aluFlagCarry <= aluFlags(1);
    aluFlagSign <= aluFlags(0);
    
    scanline_imm_select <= op_decode_cond_control(17);
    screen_flags_select <= op_decode_cond_control(16 downto 6);
    alu_flags_select    <= op_decode_cond_control(5 downto 0);
    
    --select active line to match from immediate or register
    targetLineSteer : mux8x2
        PORT MAP(
            selectIn => scanline_imm_select,
            in0      => value_immediate,            --opcode 10110x10 = wait for scanline matching immediate value
            in1      => data8int,                   --opcode 10110x11 = wait for scanline matching value in selected 8 bit register
            out0     => targetLine
        );
    
    --check for active line match
    PROCESS(active_line,targetLine)
    BEGIN
        IF active_line = targetLine THEN
            lineMatched <= '1';
        ELSE
            lineMatched <= '0';
        END IF;
        
        IF active_line >= targetLine THEN
            linePassed <= '1';
        ELSE
            linePassed <= '0';
        END IF;
    END PROCESS;
    
    --check for ALU flag condition match
    PROCESS(alu_flags_select,aluFlagCarry,aluFlagSign,aluFlagZero)
        VARIABLE carryMatched  : STD_LOGIC;
        VARIABLE zeroMatched   : STD_LOGIC;
        VARIABLE signMatched   : STD_LOGIC;
    BEGIN
        carryMatched :=  ((NOT alu_flags_select(5)) OR aluFlagCarry) AND NOT (alu_flags_select(2) OR aluFlagCarry);
        zeroMatched :=  ((NOT alu_flags_select(4)) OR aluFlagZero) AND NOT (alu_flags_select(1) OR aluFlagZero);
        signMatched :=  ((NOT alu_flags_select(3)) OR aluFlagSign) AND NOT (alu_flags_select(0) OR aluFlagSign);
        
        aluFlagsMatched <= carryMatched AND zeroMatched AND signMatched;
    END PROCESS;
    
    --check for screen flag condition match
    PROCESS(screen_flags_select,conditions)
        VARIABLE screen_flags_compare : STD_LOGIC_VECTOR(10 DOWNTO 0);
    BEGIN
        screen_flags_compare := (NOT screen_flags_select) OR conditions;
        
        IF screen_flags_compare = "11111111111" THEN
            screenFlagsMatched <= '1';
        ELSE
            screenFlagsMatched <= '0';
        END IF;
    END PROCESS;
    
    conditionCheckFlags <= lineMatched & linePassed & aluFlagsMatched & screenFlagsMatched;

END behavior;
