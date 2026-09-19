LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY sprite_scan IS
    PORT(
        CLK25M          : IN  STD_LOGIC;
        CLK100M         : IN  STD_LOGIC;
        RESET_SCREEN    : IN  STD_LOGIC;
        RESET_LINE      : IN  STD_LOGIC;
        RUN             : IN  STD_LOGIC;
        DONE            : OUT STD_LOGIC;
        DRAW_SPRITE     : IN  STD_LOGIC;
        FIFO_FULL       : IN  STD_LOGIC;
        WRITE_FIFO      : OUT STD_LOGIC;
        SPRITE_INDEX    : OUT integer range 0 to 127;
        DEBUG_OUT       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END sprite_scan;

ARCHITECTURE behavioral OF sprite_scan IS

    type state_type is (state_reset,
                        state_loop_1,
                        --state_loop_1a,
                        --state_loop_1b,
                        state_loop_2,
                        state_loop_3,
                        --state_write_pause,
                        state_write_fifo,
                        state_wait_fifo,
                        state_line_done);
                              
    SIGNAL spriteIndex              : integer range 0 to 127;
    SIGNAL next_spriteIndex         : integer range 0 to 127;
    
    SIGNAl step                     : state_type := state_reset;
    SIGNAl next_step                : state_type := state_reset;
    
    SIGNAL fifo_write               : STD_LOGIC;
    SIGNAL next_fifo_write          : STD_LOGIC; 
    
    SIGNAL lastSprite               : STD_LOGIC; 
    SIGNAL next_done                : STD_LOGIC; 
    
    SIGNAL reset                    : STD_LOGIC;
    
BEGIN

    --Check if we've processed all of the sprites
    
    PROCESS(SPRITE_INDEX)
    BEGIN
        IF SPRITE_INDEX = 127 THEN
            lastSprite <= '1';
        ELSE
            lastSprite <= '0';
        END IF;
    END PROCESS;
    
    PROCESS(CLK25M)
    BEGIN
        IF RISING_EDGE(CLK25M) THEN
            reset <= RESET_SCREEN OR RESET_LINE OR NOT RUN;
        END IF;
    END PROCESS;
    
    PROCESS(RESET_SCREEN,RESET_LINE,reset,RUN,DRAW_SPRITE,FIFO_FULL,lastSprite,spriteIndex,step)
        --VARIABLE reset              : STD_LOGIC;
        VARIABLE zeroSpriteIndex    : STD_LOGIC;
        VARIABLE incSpriteIndex     : STD_LOGIC;
        
    BEGIN
        --reset := RESET_SCREEN OR RESET_LINE OR NOT RUN;
        
        DEBUG_OUT(3) <= reset;
    
        CASE step IS
            WHEN state_reset =>
                next_fifo_write <= '0';
                next_done <= '0';
                zeroSpriteIndex := '1';
                incSpriteIndex := '0';
                
                IF reset THEN
                    next_step <= state_reset;
                ELSE
                    next_step <= state_loop_1;
                END IF;
                
                DEBUG_OUT(2 downto 0) <= "000";
                
            WHEN state_loop_1 =>
                next_fifo_write <= '0';
                next_done <= '0';
                zeroSpriteIndex := '0';
                incSpriteIndex := '0';
                
                --next_step <= state_loop_1a;
                next_step <= state_loop_2;
                
                DEBUG_OUT(2 downto 0) <= "001";
                
            /*WHEN state_loop_1a =>
                next_fifo_write <= '0';
                next_done <= '0';
                zeroSpriteIndex := '0';
                incSpriteIndex := '0';
                
                next_step <= state_loop_1b;
                
                DEBUG_OUT(2 downto 0) <= "010";
                
            WHEN state_loop_1b =>
                next_fifo_write <= '0';
                next_done <= '0';
                zeroSpriteIndex := '0';
                incSpriteIndex := '0';
                
                next_step <= state_loop_2;
                
                DEBUG_OUT(2 downto 0) <= "010";*/
                
            WHEN state_loop_2 =>
                next_fifo_write <= '0';
                next_done <= '0';
                zeroSpriteIndex := '0';
                incSpriteIndex := '0';
                
                IF DRAW_SPRITE THEN
                    IF FIFO_FULL THEN
                        next_step <= state_wait_fifo;
                    ELSE
                        next_step <= state_write_fifo;
                        --next_step <= state_write_pause;
                    END IF;
                ELSE
                    next_step <= state_loop_3;
                END IF;
                
                DEBUG_OUT(2 downto 0) <= "011";
           
            /*WHEN state_write_pause =>
                next_fifo_write <= '0';
                next_done <= '0';
                zeroSpriteIndex := '0';
                incSpriteIndex := '0';
            
                next_step <= state_write_fifo;
                
                DEBUG_OUT(2 downto 0) <= "100";*/
                
            WHEN state_write_fifo =>
                next_fifo_write <= '1';
                next_done <= '0';
                zeroSpriteIndex := '0';
                incSpriteIndex := '0';
            
                next_step <= state_loop_3;
                
                DEBUG_OUT(2 downto 0) <= "100";
                
            WHEN state_loop_3 =>
                next_fifo_write <= '0';
                next_done <= '0';
                zeroSpriteIndex := '0';
                incSpriteIndex := '1';
                
                IF lastSprite THEN
                    next_step <= state_line_done;
                ELSE
                    next_step <= state_loop_1;
                END IF;
                
                DEBUG_OUT(2 downto 0) <= "101";
                
            WHEN state_wait_fifo =>
                next_fifo_write <= '0';
                next_done <= '0';
                zeroSpriteIndex := '0';
                incSpriteIndex := '0';
                
                IF FIFO_FULL THEN
                    next_step <= state_wait_fifo;
                ELSE
                    next_step <= state_write_fifo;
                END IF;
                
                DEBUG_OUT(2 downto 0) <= "110";
                
            WHEN state_line_done =>
                next_fifo_write <= '0';
                next_done <= '1';
                zeroSpriteIndex := '1';
                incSpriteIndex := '0';
                
                IF reset THEN
                    next_step <= state_reset;
                ELSE
                    next_step <= state_line_done;
                END IF;
                
                DEBUG_OUT(2 downto 0) <= "111";
                
            --WHEN OTHERS =>
            --    next_fifo_write <= '0';
            --    next_done <= '0';
            --    zeroSpriteIndex := '1';
            --    incSpriteIndex := '0';
                
            --    next_step <= state_reset;
                
            --    DEBUG_OUT(2 downto 0) <= "000";
        END CASE;
        
        IF zeroSpriteIndex THEN
            next_spriteIndex <= 0;
        ELSIF incSpriteIndex THEN
            next_spriteIndex <= spriteIndex + 1;
        ELSE
            next_spriteIndex <= spriteIndex;
        END IF;
        
    END PROCESS;

    --PROCESS(CLK25M,next_step,next_spriteIndex,next_fifo_write,next_done)
    PROCESS(CLK100M,next_step,next_spriteIndex,next_fifo_write,next_done)
    BEGIN
        --IF RISING_EDGE(CLK25M) THEN
        IF RISING_EDGE(CLK100M) THEN
            step <= next_step;
            spriteIndex <= next_spriteIndex;
            fifo_write <= next_fifo_write;
            DONE <= next_done;
        END IF;
    END PROCESS;
    
    WRITE_FIFO <= fifo_write;
    SPRITE_INDEX <= spriteIndex;
    
END behavioral;