LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY copperInstructionPointer IS
    PORT(    
        CLK                     : IN  STD_LOGIC;
        RUN                     : IN  STD_LOGIC;
        RESET                   : IN  STD_LOGIC;
        flow_control            : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        jump_address            : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        instructionPointerOut   : OUT integer range 0 to 1023
    );
END copperInstructionPointer;

ARCHITECTURE behavior OF copperInstructionPointer IS  

    SIGNAL instructionPointer       : integer range 0 to 1023 := 0;
    SIGNAL next_instructionPointer  : integer range 0 to 1023;
    
BEGIN

    --next instruction pointer math and steering
    PROCESS(RESET,instructionPointer,flow_control,jump_address)
        VARIABLE relative_jump_address_int : integer range -64 to 63;
        VARIABLE absolute_jump_address_int : integer range 0 to 1023;
        VARIABLE next_instPointer_sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
    BEGIN
        relative_jump_address_int := to_integer(signed(jump_address(6 downto 0)));
        absolute_jump_address_int := to_integer(unsigned(jump_address));
        
        next_instPointer_sel := (RESET AND RUN) & (flow_control(1) AND RUN) & (flow_control(0) AND RUN);
        
        case next_instPointer_sel is
            WHEN "000" =>
                next_instructionPointer <= instructionPointer;      --keep the same
            WHEN "001" =>
                next_instructionPointer <= instructionPointer + 1;  --increment
            WHEN "010" =>
                next_instructionPointer <= instructionPointer + relative_jump_address_int;  --relative jump
            WHEN "011" =>
                next_instructionPointer <= absolute_jump_address_int;                       --absolute jump
            WHEN "100" =>
                next_instructionPointer <= 0; --reset
            WHEN "101" =>
                next_instructionPointer <= 0; --reset
            WHEN "110" =>
                next_instructionPointer <= 0; --reset
            WHEN "111" =>
                next_instructionPointer <= 0; --reset
            WHEN OTHERS =>
                next_instructionPointer <= 0; --reset
        END CASE;
    END PROCESS;
    
    --clocked register update
    PROCESS(CLK,RUN,next_instructionPointer)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            instructionPointer <= next_instructionPointer;
        END IF;
    END PROCESS;
    
    instructionPointerOut <= instructionPointer;
END behavior;