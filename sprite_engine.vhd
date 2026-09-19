LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY sprite_engine IS
    PORT(
        CLK25M                  : IN  STD_LOGIC;
        CLK100M                 : IN  STD_LOGIC;
        RESET_LINE              : IN  STD_LOGIC;
        RESET_SCREEN            : IN  STD_LOGIC;
        RUN                     : IN  STD_LOGIC;
        LINE_TO_DRAW            : IN  integer range 0 to 239;
        DONE                    : OUT STD_LOGIC;
        
        SPRITE_SCROLL_X         : IN  integer range 0 to 511;
        SPRITE_SCROLL_Y         : IN  integer range 0 to 255;
        
        ANIM_CYCLE              : IN  integer range 0 to 65535;
        
        SPRITE_READ_ADDRESS     : OUT integer range 0 to 127;
        SPRITE_DATA_IN          : IN  STD_LOGIC_VECTOR(63 DOWNTO 0);
        
        SPRITE_GFX_READ_ADDRESS : OUT integer range 0 to 65535;
        SPRITE_GFX_DATA_IN      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        COLLISION_WRITE_ADDRESS : OUT integer range 0 to 127;
        COLLISION_WRITE_STROBE  : OUT STD_LOGIC;
        COLLISION_WRITE_DATA    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        COLLISION_READ_DATA     : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        COLLISION_INTERRUPTS    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        BUFFER_WRITE_ADDRESS    : OUT integer range 0 to 319;
        BUFFER_WRITE_DATA       : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        BUFFER_WRITE_STROBE     : OUT STD_LOGIC;
        
        DEBUG_OUT               : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        COL_BUFF_ADDRESS        : OUT integer range 0 to 511;
        COL_BUFF_WRITE_DATA     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        COL_BUFF_READ_DATA      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        COL_BUFF_WRITE_STROBE   : OUT STD_LOGIC;
        
        COL_BUFF_READY          : IN  STD_LOGIC
    );
END sprite_engine;

ARCHITECTURE behavioral OF sprite_engine IS

    COMPONENT sprite_math is
        PORT(
            CLK25M                  : IN  STD_LOGIC;
            CLK100M                 : IN  STD_LOGIC;
            LINE_TO_DRAW            : IN  integer range 0 to 239;
            ANIM_CYCLE              : IN  integer range 0 to 65535;
            SPRITE_DATA_IN          : IN  STD_LOGIC_VECTOR(63 DOWNTO 0);
            SPRITE_INDEX            : IN  integer range 0 to 127;
            SPRITE_SCROLL_X         : IN  integer range 0 to 511;
            SPRITE_SCROLL_Y         : IN  integer range 0 to 255;
            DRAW_SPRITE             : OUT STD_LOGIC;
            FIFO_DATA_OUT           : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
        );
        END COMPONENT;

    COMPONENT sprite_scan is
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
        END COMPONENT;
        
    COMPONENT blitterFIFO is
        PORT (
            full_o          : out std_logic;
            empty_o         : out std_logic;
            clk_i           : in  std_logic;
            wr_en_i         : in  std_logic;
            rd_en_i         : in  std_logic;
            wdata           : in  std_logic_vector(63 downto 0);
            datacount_o     : out std_logic_vector(4 downto 0);
            rst_busy        : out std_logic;
            rdata           : out std_logic_vector(63 downto 0);
            a_rst_i         : in  std_logic
        );
        END COMPONENT;

    COMPONENT sprite_blitter IS
        PORT(
            CLK25M                  : IN  STD_LOGIC;
            CLK100M                 : IN  STD_LOGIC;
            RESET_SCREEN            : IN  STD_LOGIC;
            RESET_LINE              : IN  STD_LOGIC;
            RUN                     : IN  STD_LOGIC;
            FIFO_EMPTY              : IN  STD_LOGIC;
            FIFO_READ_DATA          : IN  STD_LOGIC_VECTOR(63 DOWNTO 0);
            SPRITE_GFX_DATA_IN      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            FIFO_READ               : OUT STD_LOGIC;
            SPRITE_GFX_READ_ADDRESS : OUT integer range 0 to 65535;
            COLLISION_WRITE_ADDRESS : OUT integer range 0 to 127;
            COLLISION_WRITE_STROBE  : OUT STD_LOGIC;
            COLLISION_WRITE_DATA    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            COLLISION_READ_DATA     : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            COLLISION_INTERRUPTS    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            BUFFER_WRITE_ADDRESS    : OUT integer range 0 to 319;
            BUFFER_WRITE_DATA       : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
            BUFFER_WRITE_STROBE     : OUT STD_LOGIC;
            DEBUG_OUT               : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            COLLISION_BUFF_READY    : IN  STD_LOGIC;
            COL_BUFF_ADDRESS        : OUT integer range 0 to 511;
            COL_BUFF_WRITE_DATA     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            COL_BUFF_READ_DATA      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            COL_BUFF_WRITE_STROBE   : OUT STD_LOGIC
        );
        END COMPONENT;
        
    SIGNAL spriteIndex              : integer range 0 to 127;
    SIGNAL drawSprite               : STD_LOGIC; 
    SIGNAL fifoFull                 : STD_LOGIC; 
    SIGNAL fifoEmpty                : STD_LOGIC; 
    SIGNAL fifoWrite                : STD_LOGIC;
    SIGNAL fifoRead                 : STD_LOGIC;
    SIGNAL fifoWriteData            : STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL fifoReadData             : STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL fifoDatacount            : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL fifoRstBusy              : STD_LOGIC; 
    SIGNAL scanDone                 : STD_LOGIC;
    
    SIGNAL lineToDrawInt            : integer range 0 to 239;
    SIGNAL animCycleInt             : integer range 0 to 65535;
    SIGNAL spriteScrollXInt         : integer range 0 to 511;
    SIGNAL spriteScrollYInt         : integer range 0 to 255;
    
BEGIN
    PROCESS(CLK100M)
    BEGIN
        IF RISING_EDGE(CLK100M) THEN
            lineToDrawInt <= LINE_TO_DRAW;
            animCycleInt <= ANIM_CYCLE;
            spriteScrollXInt <= SPRITE_SCROLL_X;
            spriteScrollYInt <= SPRITE_SCROLL_Y;
        END IF;
    END PROCESS;

    --sprite math block

    spritemath : sprite_math
        PORT MAP (
            CLK25M                  => CLK25M,
            CLK100M                 => CLK100M,
            LINE_TO_DRAW            => lineToDrawInt,
            ANIM_CYCLE              => animCycleInt,
            SPRITE_DATA_IN          => SPRITE_DATA_IN,
            SPRITE_INDEX            => spriteIndex,
            SPRITE_SCROLL_X         => spriteScrollXInt,
            SPRITE_SCROLL_Y         => spriteScrollYInt,
            DRAW_SPRITE             => drawSprite,
            FIFO_DATA_OUT           => fifoWriteData
            );
    
    --Sprite check and FIFO load state engine
    
    spritescan : sprite_scan
        PORT MAP (
            CLK25M          => CLK25M,
            CLK100M         => CLK100M,
            RESET_SCREEN    => RESET_SCREEN,
            RESET_LINE      => RESET_LINE,
            RUN             => RUN,
            DONE            => scanDone,
            DRAW_SPRITE     => drawSprite,
            FIFO_FULL       => fifoFull,
            WRITE_FIFO      => fifoWrite,
            SPRITE_INDEX    => spriteIndex,
            DEBUG_OUT       => DEBUG_OUT(5 downto 2)
        );
    
    --Blitter FIFO
    
    u_blitterFIFO : blitterFIFO
        PORT MAP (
            full_o          => fifoFull,
            empty_o         => fifoEmpty,
            clk_i           => CLK100M,
            wr_en_i         => fifoWrite,
            rd_en_i         => fifoRead,
            wdata           => fifoWriteData,
            datacount_o     => fifoDatacount,
            rst_busy        => fifoRstBusy,
            rdata           => fifoReadData,
            a_rst_i         => RESET_LINE
            );
    
    --Blitter engine
    
    spriteblitter : sprite_blitter
        PORT MAP (
            CLK25M                  => CLK25M,
            CLK100M                 => CLK100M,
            RESET_SCREEN            => RESET_SCREEN,
            RESET_LINE              => RESET_LINE,
            RUN                     => RUN,
            FIFO_EMPTY              => fifoEmpty,
            FIFO_READ_DATA          => fifoReadData,
            SPRITE_GFX_DATA_IN      => SPRITE_GFX_DATA_IN,
            FIFO_READ               => fifoRead,
            SPRITE_GFX_READ_ADDRESS => SPRITE_GFX_READ_ADDRESS,
            COLLISION_WRITE_ADDRESS => COLLISION_WRITE_ADDRESS,
            COLLISION_WRITE_STROBE  => COLLISION_WRITE_STROBE,
            COLLISION_WRITE_DATA    => COLLISION_WRITE_DATA,
            COLLISION_READ_DATA     => COLLISION_READ_DATA,
            COLLISION_INTERRUPTS    => COLLISION_INTERRUPTS,
            BUFFER_WRITE_ADDRESS    => BUFFER_WRITE_ADDRESS,
            BUFFER_WRITE_DATA       => BUFFER_WRITE_DATA,
            BUFFER_WRITE_STROBE     => BUFFER_WRITE_STROBE,
            DEBUG_OUT               => DEBUG_OUT(7 downto 6),
            COLLISION_BUFF_READY    => COL_BUFF_READY,
            COL_BUFF_ADDRESS        => COL_BUFF_ADDRESS,
            COL_BUFF_WRITE_DATA     => COL_BUFF_WRITE_DATA,
            COL_BUFF_READ_DATA      => COL_BUFF_READ_DATA,
            COL_BUFF_WRITE_STROBE   => COL_BUFF_WRITE_STROBE
        );
    
    SPRITE_READ_ADDRESS <= spriteIndex;
    
    DEBUG_OUT(0) <= drawSprite;
    DEBUG_OUT(1) <= fifoWrite;
    
    DONE <= scanDone AND fifoEmpty;
    
    
END behavioral;